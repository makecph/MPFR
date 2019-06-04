#!/usr/bin/env sh

# This script builds a static version of MPFR for the Apple Platforms

set -x

# Setup readonly variables
readonly MPFR_VERSION="4.0.1"
readonly WORKING_DIR=$( cd "$( dirname "$0" )" && pwd )
readonly PRODUCT_ASSET="mpfr-${MPFR_VERSION}.tar.bz2"
readonly PRODUCT_DIR="${WORKING_DIR}/build/product"

function failed {
  local error=${1:-Undefined error}
  echo "Failed: $error" >&2
  exit 1
}

function download {
  curl -R "https://www.mpfr.org/mpfr-current/${PRODUCT_ASSET}" > "${WORKING_DIR}/${PRODUCT_ASSET}"
}

function unpackage {
  tar xjf "${WORKING_DIR}/${PRODUCT_ASSET}" -C "${WORKING_DIR}/"
}

function submodule {
  git submodule update
  pushd GMP
    ./$pwd/bootstrap.sh
  popd
}

function bootstrap {
    mkdir -p ${PRODUCT_DIR}
    declare -a platforms=("arm","$(xcrun --sdk iphoneos --find clang) -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64" "x86_64","$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path) -arch x86_64")

    for i in "${platforms[@]}"
    do
        IFS=","; 
        set $i; 
        declare config_directory=build/$1
        declare install_directory=${PRODUCT_DIR}/$1
        mkdir -p ${config_directory}
        mkdir -p ${install_directory}
        pushd ${config_directory}
            ../../mpfr-${MPFR_VERSION}/configure --disable-shared --host $1-apple-darwin --prefix=${install_directory} --exec-prefix=${install_directory} --with-gmp-include=/Users/jens/Workspace/MakeCPH/MPFR/GMP/build/product/$1/include/ --with-gmp-lib=/Users/jens/Workspace/MakeCPH/MPFR/GMP/build/product/$1/lib/ CC=$2
        popd
    done
}

download
unpackage
submodule
bootstrap
