# Prepare this experiment

set -eu
set -o pipefail

DIR="$(dirname $(readlink -f $0))"
ROOT_DIR="$(readlink -f "$DIR/..")"
source $ROOT_DIR/config.sh

# Prepare the environment as recommended in the artifacts readme.
echo core | sudo tee /proc/sys/kernel/core_pattern
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Build the artifact itself, since the image below uses it as base.
pushd ..
./prepare.sh
popd

docker build -t memlock-01 --build-arg MEMLOCK_DOCKER_IMAGE_NAME=$MEMLOCK_DOCKER_IMAGE_NAME .
