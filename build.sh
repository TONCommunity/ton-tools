#!/usr/bin/env bash
# ******************************************************
# Author        :   zagjade
# Last modified :   2020-08-11 18:19
# Filename      :   build.sh
# Description   :   Compile and install ton resource
# ******************************************************

set -e

# with root user
if [ "root" != "`whoami`" ];then
	echo "WARN: current user is not root!"
fi

# install compiler and dependencies
function dependencies() {
cat << EOF
`echo -e "\033[35m  1) CentOS 8.1 or later\033[0m"`
`echo -e "\033[35m  2) Ubuntu 18.04 or later\033[0m"`
EOF
	read -p "Your OS release version [1 or 2]: " version
	case $version in
		1)
			echo "INFO: install dependencies ..."
			yum update -y
			yum install -y gcc gcc-c++ gdb cmake ccache make git texlive texlive-*.noarch ghostscript
			yum install -y zlib-devel openssl-devel readline-devel gsl-devel
			# install libmicrohttpd-devel
			wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.70.tar.gz
			tar xzf libmicrohttpd-0.9.70.tar.gz
			cd libmicrohttpd-0.9.70/
			./configure
			make && make install
			cd .. && rm -fr libmicrohttpd-0.9.70*
			# install texlive module
	        wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/t/texlive-xypic-svn26642.0-56.el7.noarch.rpm
			yum localinstall -y texlive-xypic-svn26642.0-56.el7.noarch.rpm
			rm -f texlive-xypic-svn26642.0-56.el7.noarch.rpm
			# sudo yum install -y epel-release
	        # sudo dnf config-manager --set-enabled PowerTools
	        # sudo yum install -y git make cmake clang gflags gflags-devel zlib zlib-devel openssl-devel openssl-libs readline-devel libmicrohttpd python3 python3-pip python36-devel
			;;
		2)
			echo "INFO: install dependencies ..."
			apt update -y
			apt install -y build-essential git cargo ccache cmake curl gawk gcc gperf g++
			apt install -y libgflags-dev libmicrohttpd-dev libreadline-dev libssl-dev libz-dev ninja-build pkg-config zlib1g-dev
			curl https://sh.rustup.rs -sSf | sh -s -- -y
			. "$HOME/.cargo/env"
			rustup update
			;;
		*)
			echo "ERROR: Invalid OS release version!"
			exit -1
			;;
	esac
	echo "INFO: install dependencies ... DONE"
	touch ~/.ton_dependencies
}

if [ ! -f ~/.ton_dependencies ];then
	dependencies
fi

SCRIPT_DIR=$(cd `dirname $0`; pwd)

. ${SCRIPT_DIR}/setenv.sh

cat << EOF
`echo -e "\033[35m  Your Build Params:\033[0m"`
`echo -e "\033[35m  TON_SRC_DIR          = ${TON_SRC_DIR}\033[0m"`
`echo -e "\033[35m  TON_BUILD_DIR        = ${TON_BUILD_DIR}\033[0m"`
`echo -e "\033[35m  TON_ROOT_DIR         = ${TON_ROOT_DIR}\033[0m"`
`echo -e "\033[35m  TON_GITHUB_REPO      = ${TON_GITHUB_REPO}\033[0m"`
`echo -e "\033[35m  TON_GITHUB_COMMIT_ID = ${TON_GITHUB_COMMIT_ID}\033[0m"`
EOF
read -p "Continue?[Y/N]" sure
case $sure in
	[Nn])
		echo "INFO: Break!!!"
		exit 0
		;;
	[Yy])
		echo "INFO: Install ..."
		;;
	*)
		echo "ERROR: Invalid param!"
		exit 1
		;;
esac

# checkout ton resource
echo "INFO: git clone ${TON_GITHUB_REPO} ${TON_GITHUB_COMMIT_ID} ..."
rm -fr ${TON_SRC_DIR}
git clone --recursive ${TON_GITHUB_REPO} ${TON_SRC_DIR}
cd ${TON_SRC_DIR} && git checkout ${TON_GITHUB_COMMIT_ID}
echo "INFO: git clone ${TON_GITHUB_REPO} ${TON_GITHUB_COMMIT_ID} ... DONE"

# compile
echo "INFO: build ton resource ..."
mkdir -p ${TON_BUILD_DIR}
cd ${TON_BUILD_DIR}
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${TON_ROOT_DIR} ${TON_SRC_DIR}
cmake --build .

# install
echo "INFO: install ton programs ..."
make install
cp -f ${TON_BUILD_DIR}/lite-client/lite-client ${TON_ROOT_DIR}/bin/
cp -f ${TON_BUILD_DIR}/utils/generate-random-id ${TON_ROOT_DIR}/bin/
cp -f ${TON_BUILD_DIR}/crypto/create-state ${TON_ROOT_DIR}/bin/
cp -f ${TON_BUILD_DIR}/dht-server/dht-server ${TON_ROOT_DIR}/bin/
cp -fr ${TON_SRC_DIR}/crypto/smartcont ${TON_ROOT_DIR}/

exit 0
