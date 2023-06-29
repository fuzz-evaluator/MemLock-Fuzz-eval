set -e
set -o pipefail

source config.sh

# Build the image
pushd Memlock-Fuzz-upstream >/dev/null
sudo docker build -t $MEMLOCK_DOCKER_IMAGE_NAME .
popd >/dev/null

# Prepare the environment as recommended in the artifacts readme.
echo core | sudo tee /proc/sys/kernel/core_pattern
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor