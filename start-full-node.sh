#!/usr/bin/env bash
# ******************************************************
# Author        :   zagjade
# Last modified :   2020-09-09 10:06
# Filename      :   fullnode-start.sh
# Description   :   start fullnode service
# ******************************************************

set -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)

. ${SCRIPT_DIR}/setenv.sh

export PATH=${TON_ROOT_DIR}/bin:$PATH

validator-engine -d -C ${TON_WORK_DIR}/etc/$GLOBAL_CONFIG_FILE --db ${TON_WORK_DIR}/db -l ${TON_WORK_DIR}/logs/ton &

exit 0
