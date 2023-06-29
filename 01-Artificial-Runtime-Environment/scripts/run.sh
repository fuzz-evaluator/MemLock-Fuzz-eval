#!/bin/bash
set -eu
set -o pipefail

DIR="$(dirname $(readlink -f $0))"
readonly ROOT_DIR="$(readlink -f "$DIR/../..")"
echo "[+] Workdir is $DIR"

source $ROOT_DIR/config.sh
readonly RESULT_DIR=$(readlink -f $DIR/../results)
readonly LOG_DIR=$(readlink -f $DIR/../logs)

if [[ -d "$RESULT_DIR" ]]; then
    echo "$RESULT_DIR exists, please remove"
    exit 1
fi

# Generate the flex configs based on the artifact's one without setting ulimit -s
readonly afl_noulimit_config_path="/workdir/MemLock/evaluation/FUZZ/run_AFL_flex_without_ulimit.sh"
rm -f $afl_noulimit_config_path
cp /workdir/MemLock/evaluation/FUZZ/run_AFL_flex.sh $afl_noulimit_config_path
sed -i 's/ulimit -s.*//' $afl_noulimit_config_path
readonly afl_ulimit_config_path="/workdir/MemLock/evaluation/FUZZ/run_AFL_flex.sh"

readonly memlock_noulimit_config_path="/workdir/MemLock/evaluation/FUZZ/run_MemLock_flex_without_ulimit.sh"
rm -f $memlock_noulimit_config_path
cp /workdir/MemLock/evaluation/FUZZ/run_MemLock_flex.sh $memlock_noulimit_config_path
sed -i 's/ulimit -s.*//' $memlock_noulimit_config_path
readonly memlock_ulimit_config_path="/workdir/MemLock/evaluation/FUZZ/run_MemLock_flex.sh"

# Start the fuzzers
readonly CPUS=40
readonly TRIALS=10
readonly DURATION=24h

args=""
for trial in $(seq 1 $TRIALS); do
    args+="afl@ulimit@$trial "
    args+="afl@noulimit@$trial "
    args+="memlock@ulimit@$trial "
    args+="memlock@noulimit@$trial "
done

function run_fuzzer () {
    set -eu
    set -o pipefail

    # Trim trailing whitespace from last element.
    local arg="$(echo -ne $1 | tr -d ' ')"

    # Args are seperated by the '@' character.
    fuzzer="$(echo -ne $arg | cut -d '@' -f 1)"
    limit="$(echo -ne $arg | cut -d '@' -f 2)"
    trial="$(echo -nw $arg | cut -d '@' -f 3)"

    # Get config path based on the current config
    if [[ "$fuzzer" == "afl" ]]; then
        if [[ "$limit" == "ulimit" ]]; then
            cfg=$afl_ulimit_config_path
        else
            cfg=$afl_noulimit_config_path
        fi
    else
        if [[ "$limit" == "ulimit" ]]; then
            cfg=$memlock_ulimit_config_path
        else
            cfg=$memlock_noulimit_config_path
        fi
    fi

    pushd /workdir/MemLock/evaluation/FUZZ >/dev/null
    echo "fuzzer: $fuzzer"
    echo "limit: $limit"
    echo "trial: $trial"
    echo "cfg: $cfg"

    # Disable AFL's UI
    export AFL_NO_UI=1

    # First argument is used as suffix for the output directory.
    # We use the `args` tuple and replace the `@`` character with the `-` character.
    timeout $DURATION $cfg "-$(echo $arg | tr '@' '-')"
    popd >/dev/null
}

# Export the `run_fuzzer` function such that it can be passed to `parallel`.
export -f run_fuzzer
# Export variables used in the `run_fuzzer` function.
export DURATION
export afl_ulimit_config_path
export afl_noulimit_config_path
export memlock_ulimit_config_path
export memlock_noulimit_config_path
export MEMLOCK_DOCKER_IMAGE_NAME

rm -rf $LOG_DIR
mkdir -p $LOG_DIR

# Start processing the tasks.
echo -ne $args | parallel -j $CPUS --bar -kd' ' -- run_fuzzer {} '>' $LOG_DIR/{}.log '2>&1' ';' || true

# Copy into mount shared with host in order to persist the data.
mkdir -p $RESULT_DIR
cp -rv /workdir/MemLock/evaluation/FUZZ/flex $RESULT_DIR 
