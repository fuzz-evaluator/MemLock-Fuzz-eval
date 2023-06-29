#!/bin/bash

set -e
DIR="$(dirname $(readlink -f $0))"
ROOT_DIR="$(readlink -f "$DIR/..")"
source $ROOT_DIR/config.sh

pushd ..
./prepare.sh
popd

./prepare.sh

docker run -it -v $ROOT_DIR:/data memlock-02 bash 