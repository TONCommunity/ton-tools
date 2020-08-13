#!/usr/bin/env bash
# ******************************************************
# Author        :   zagjade
# Last modified :   2020-08-13 11:44
# Filename      :   fullnode.sh
# Description   :   start full-node process
# ******************************************************

set -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)

. ${SCRIPT_DIR}/setenv.sh

TEMPLATE_DIR=${SCRIPT_DIR}/template

export FIFTPATH=${FIFTPATH}
export PATH=${TON_ROOT_DIR}/bin:$PATH

rm -fr ${TON_WORK_DIR}
mkdir -p ${TON_WORK_DIR}/{etc,db,keys}
mkdir -p ${TON_WORK_DIR}/db/{static,import,keyring}

cp ${TEMPLATE_DIR}/$GLOBAL_CONFIG_FILE ${TON_WORK_DIR}/etc/

cd ${TON_WORK_DIR}/keys
validator-engine -C ${TON_WORK_DIR}/etc/$GLOBAL_CONFIG_FILE --db ${TON_WORK_DIR}/db --ip $PUBLIC_NODE

read SERVER_ID_HEX SERVER_ID_BASE64 <<< $(generate-random-id -m keys -n server)
mv server ${TON_WORK_DIR}/db/keyring/$SERVER_ID_HEX

read CLIENT_ID_HEX CLIENT_ID_BASE64 <<< $(generate-random-id -m keys -n client)
sed -e "s/PORT/\"$(printf "%q" $CONSOLE_PORT)\"/g" -e "s~SERVER~\"$(printf "%q" $SERVER_ID_BASE64)\"~g" -e "s~CLIENT~\"$(printf "%q" $CLIENT_ID_BASE64)\"~g" ${TEMPLATE_DIR}/control.template > control.new
sed -e "s~\"control\"\ \:\ \[~$(printf "%q" $(cat control.new))~g" ${TON_WORK_DIR}/db/config.json > config.json.new
mv -f config.json.new ${TON_WORK_DIR}/db/config.json
rm -f control.new

read -r LITESERVER_ID_HEX LITESERVER_ID_BASE64 <<< $(generate-random-id -m keys -n liteserver)
mv liteserver ${TON_WORK_DIR}/db/keyring/$LITESERVER_ID_HEX
LITESERVERS=$(printf "%q" "\"liteservers\":[{\"id\":\"$LITESERVER_ID_BASE64\",\"port\":\"$LITE_PORT\"}")
sed -e "s~\"liteservers\"\ \:\ \[~$LITESERVERS~g" ${TON_WORK_DIR}/db/config.json > config.json.liteservers
mv -f config.json.liteservers ${TON_WORK_DIR}/db/config.json

cd ${TON_WORK_DIR}
nohup validator-engine -v 0 -C ${TON_WORK_DIR}/etc/$GLOBAL_CONFIG_FILE --db ${TON_WORK_DIR}/db -l ${TON_WORK_DIR}/log > validator.log 2>&1 &

exit 0
