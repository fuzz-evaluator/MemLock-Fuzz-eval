#!/bin/bash
set -eu
set -o pipefail

DIR="$(dirname $(readlink -f $0))"
ROOT_DIR="$(readlink -f "$DIR/../..")"
echo "[+] Workdir is $DIR"

source $ROOT_DIR/config.sh
RESULT_DIR=$(readlink -f $DIR/../results)
LOG_DIR=$(readlink -f $DIR/../logs)

if [[ -d "$RESULT_DIR" ]]; then
    echo "$RESULT_DIR exists, please remove"
    exit 1
fi

TARGETS=("nm" "cxxfilt" "readelf")

# nm_afl="/workdir/MemLock/evaluation/FUZZ/run_AFL_nm.sh"
# cxxfilt_afl="/workdir/MemLock/evaluation/FUZZ/run_AFL_cxxfilt.sh"

# nm_memlock="/workdir/MemLock/evaluation/FUZZ/run_MemLock_nm.sh"
# cxxfilt_memlock="/workdir/MemLock/evaluation/FUZZ/run_MemLock_cxxfilt.sh"

# Start the fuzzers
CPUS=40
TRIALS=10
DURATION=24h

# Generate arguments: [AFL|MemLock]@<target name>@<trial number>
args=""
for target in ${TARGETS[@]}; do
    for trial in $(seq 1 $TRIALS); do
        args+="AFL@$target@$trial "
        args+="MemLock@$target@$trial "
    done
done

function run_fuzzer () {
    set -eu
    set -o pipefail

    # Trim trailing whitespace from last element.
    local arg="$(echo -ne $1 | tr -d ' ')"

    # Args are seperated by the '@' character.
    fuzzer="$(echo -ne $arg | cut -d '@' -f 1)"
    target="$(echo -ne $arg | cut -d '@' -f 2)"
    trial="$(echo -nw $arg | cut -d '@' -f 3)"

    pushd /workdir/MemLock/evaluation/FUZZ >/dev/null
    echo "fuzzer: $fuzzer"
    echo "target: $target"
    echo "trial: $trial"
    config_path="/workdir/MemLock/evaluation/FUZZ/run_${fuzzer}_${target}.sh"
    echo "cfg: $config_path"

    if [[ ! -f "$config_path" ]]; then
        echo "Unable to find config at $config_path"
        exit 1
    fi

    # Disable AFL's UI
    export AFL_NO_UI=1

    # Start the fuzzer and provide a suffix for the name of the output directory.
    timeout $DURATION $config_path "-$(echo $arg | tr '@' '-')"

    popd >/dev/null
}
export -f run_fuzzer
export DURATION
export afl_ulimit_config_path
export afl_noulimit_config_path
export memlock_ulimit_config_path
export memlock_noulimit_config_path
export MEMLOCK_DOCKER_IMAGE_NAME

rm -rf $LOG_DIR
mkdir -p $LOG_DIR

echo -ne $args | parallel -j $CPUS --bar -kd' ' -- run_fuzzer {} '>' $LOG_DIR/{}.log '2>&1' ';' || true

# Copy into mount shared with host in order to persist the data.
mkdir -p $RESULT_DIR
cp -rv /workdir/MemLock/evaluation/FUZZ/* $RESULT_DIR 
