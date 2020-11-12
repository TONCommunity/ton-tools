#! /usr/bin/env bash

set -e

LITE_PORT=53762
CONSOLE_PORT=53763

MAX_FACTOR=2
STAKE_GRAMS=20000.
FEE_GRAMS=1.

WALLET_NAME_ID=
STAKE_WALLET_ADDR=
RECOVER_WALLET_ADDR=

TON_WORK_DIR=/data
TON_ROOT_DIR=${TON_WORK_DIR}/toncommunity

PRIVATE_KEY_CLIENT=${TON_WORK_DIR}/keys/client
PUBLIC_KEY_SERVER=${TON_WORK_DIR}/keys/server.pub
PUBLIC_KEY_LITE=${TON_WORK_DIR}/keys/liteserver.pub

if [ -z "$FIFTPATH" ]; then
    export FIFTPATH=${TON_ROOT_DIR}/lib/fift
fi

export PATH=${TON_ROOT_DIR}/bin:$PATH

function veconsole() {
    validator-engine-console -t 3 -v 0 -k $PRIVATE_KEY_CLIENT -p $PUBLIC_KEY_SERVER -a 127.0.0.1:$CONSOLE_PORT -rc "$1"
}

function liteclient() {
    lite-client -t 3 -v 0 -a 127.0.0.1:$LITE_PORT -p $PUBLIC_KEY_LITE -c "$1"
}

TMPFILE=".last_election_id"
function doElect() {
    if [ -s $TMPFILE ]; then
        if [ -n "$(cat $TMPFILE)" -a "$1" == "$(cat $TMPFILE)" ]; then
            return
        fi
    fi
    read -r ELECTED START END HELD <<< $(liteclient "getconfig 15" | awk '/^ConfigParam\(15\)/ {print $4,$5,$6,$7}')
    ELECTED=$(echo $ELECTED | awk -F ':' '{print $2}')
    START=$(echo $START | awk -F ':' '{print $2}')
    END=$(echo $END | awk -F ':' '{print $2}')
    HELD=$(echo ${HELD%?} | awk -F ':' '{print $2}')
    STOP_TIMESTAMP=$(expr $1 + $ELECTED + $START + $END + $HELD)

    read -r NEW_NODE_KEY <<< $(veconsole "newkey" | awk '/^created new key/ {print $4}')
    read -r NEW_VAL_ADNL <<< $(veconsole "newkey" | awk '/^created new key/ {print $4}')
    read -r NEW_PUB_KEY <<< $(veconsole "exportpub $NEW_NODE_KEY" | awk '/^got public key/ {print $4}')
    veconsole "addpermkey $NEW_NODE_KEY $1 $STOP_TIMESTAMP"
    veconsole "addtempkey $NEW_NODE_KEY $NEW_NODE_KEY $STOP_TIMESTAMP"
    veconsole "addadnl $NEW_VAL_ADNL 0"
    veconsole "addvalidatoraddr $NEW_NODE_KEY $NEW_VAL_ADNL $STOP_TIMESTAMP"

    read -r MESSAGE_REQ <<< $(fift -s ${TON_ROOT_DIR}/smartcont/validator-elect-req.fif $STAKE_WALLET_ADDR $1 $MAX_FACTOR $NEW_VAL_ADNL | sed -n '2p')

    read -r SIGNATURE <<< $(veconsole "sign $NEW_NODE_KEY $MESSAGE_REQ" | awk '/^got signature/ {print $3}')

    fift -s ${TON_ROOT_DIR}/smartcont/validator-elect-signed.fif $STAKE_WALLET_ADDR $1 $MAX_FACTOR $NEW_VAL_ADNL $NEW_PUB_KEY $SIGNATURE

    SEQNO=$(liteclient "runmethod $STAKE_WALLET_ADDR seqno" | awk '/^result:/ {print $3}')
    if [ -z "$SEQNO" ]; then
        SEQNO=0
    fi

    fift -s ${TON_ROOT_DIR}/smartcont/wallet.fif $WALLET_NAME_ID -1:$2 $SEQNO $STAKE_GRAMS -B validator-query.boc

    liteclient "sendfile  wallet-query.boc"

    echo $ACTIVE_ELECTION_ID > $TMPFILE
}

function doRecover() {
    REWARD=$(liteclient "runmethod -1:$1 compute_returned_stake 0x$RECOVER_WALLET_ADDR" | awk '/^result:/ {print $3}')
    if [ $REWARD -gt 0 ]; then
        fift -s ${TON_ROOT_DIR}/smartcont/recover-stake.fif
        SEQNO=$(liteclient "runmethod $STAKE_WALLET_ADDR seqno" | awk '/^result:/ {print $3}')
        if [ -z "$SEQNO" ]; then
            SEQNO=0
        fi
        fift -s ${TON_ROOT_DIR}/smartcont/wallet.fif $WALLET_NAME_ID -1:$1 $SEQNO $FEE_GRAMS -B recover-query.boc
        liteclient "sendfile  wallet-query.boc"
    fi
}

RECORDFILE="history.log"
while true; do
    ELECT_CONTRACT_ADDR=$(liteclient "getconfig 1" | awk -F ':' '/^ConfigParam\(1\)/ {print substr($2,2,64)}')
    if [ -z "$ELECT_CONTRACT_ADDR" ]; then
        sleep 180
        continue
    fi
    ACTIVE_ELECTION_ID=$(liteclient "runmethod -1:$ELECT_CONTRACT_ADDR active_election_id" | awk '/^result:/ {print $3}')
    if [ -z "$ACTIVE_ELECTION_ID" ]; then
        sleep 180
        continue
    fi
    if [ $ACTIVE_ELECTION_ID -gt 0 ]; then
        echo $(date '+%F %T') $ACTIVE_ELECTION_ID >> $RECORDFILE
        doElect $ACTIVE_ELECTION_ID $ELECT_CONTRACT_ADDR
    else
        echo $(date '+%F %T') 0 >> $RECORDFILE
        doRecover $ELECT_CONTRACT_ADDR
    fi
    sleep 180
done

exit 0
