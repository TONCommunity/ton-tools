#!/usr/bin/env bash
# ******************************************************
# Author        :   zagjade
# Last modified :   2020-09-09 18:03
# Filename      :   install.sh
# Description   :   Install ton programs from binary file
# ******************************************************

set -e

VERSION=1.0.1

wget https://github.com/TONCommunity/ton/releases/download/v${VERSION}/toncommunity-binary-v${VERSION}.tar.gz

tar xzf toncommunity-binary-v${VERSION}.tar.gz -C .

exit 0
