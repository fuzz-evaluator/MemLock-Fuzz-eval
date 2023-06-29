#!/bin/bash

#
# Spawn a container for this experiment.
# To execute the experiment, switch to `/data/01-Artificial-Runtime-Environment`
# and execute the `run.sh` script.
#

set -eu
DIR="$(dirname $(readlink -f $0))"
ROOT_DIR="$(readlink -f "$DIR/..")"
source $ROOT_DIR/config.sh

# Build the images
./prepare.sh

docker run -it -v $ROOT_DIR:/data memlock-01 bash 