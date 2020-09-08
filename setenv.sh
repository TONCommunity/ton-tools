#!/usr/bin/env bash
# ******************************************************
# Author        :   zagjade
# Last modified :   2020-08-11 18:12
# Filename      :   setenv.sh
# Description   :   Define variables for build.sh and fullnode.sh
# ******************************************************

set -e

#
PUBLIC_IP=
ENGINE_PORT=53760
DHT_PORT=53761
LITE_PORT=53762
CONSOLE_PORT=53763

# 
TON_WORK_DIR=/data
TON_SRC_DIR=${TON_WORK_DIR}/ton/resource
TON_BUILD_DIR=${TON_WORK_DIR}/ton/build
TON_ROOT_DIR=${TON_WORK_DIR}/ton/bin
TON_DHT_DIR=${TON_WORK_DIR}/dht
FIFTPATH=${TON_ROOT_DIR}/lib/fift

#
TON_GITHUB_REPO="https://github.com/ton-blockchain/ton.git"
TON_GITHUB_COMMIT_ID="master"

#
GLOBAL_CONFIG_FILE=toncommunity-global.config.json
PUBLIC_NODE=${PUBLIC_IP}:${ENGINE_PORT}
