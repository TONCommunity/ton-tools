#!/usr/bin/env bash
# ******************************************************
# Author        :   zagjade
# Last modified :   2020-09-09 18:03
# Filename      :   install.sh
# Description   :   Install ton programs from binary file
# ******************************************************

set -e

SCRIPT_DIR=$(cd `dirname $0`; pwd)

. ${SCRIPT_DIR}/setenv.sh

VERSION=1.0.1
TON_BINARY_FILE=toncommunity-binary-v${VERSION}.tar.gz

wget https://github.com/TONCommunity/ton/releases/download/v1.0.1/$TON_BINARY_FILE

mkdir -p ${TON_WORK_DIR}
tar xzf $TON_BINARY_FILE -C ${TON_WORK_DIR}

rm -f $TON_BINARY_FILE


exit 0
