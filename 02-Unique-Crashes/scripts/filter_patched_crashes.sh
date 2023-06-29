#!/bin/bash

set -u
set -o pipefail

DIR="$(dirname $(readlink -f $0))"
ROOT_DIR="$(readlink -f "$DIR/../..")"

source $ROOT_DIR/config.sh
RESULT_DIR=$(readlink -f $DIR/../results)
LOG_DIR=$(readlink -f $DIR/../logs)
FILTERED_CRASHES_DIR="${RESULT_DIR}/filtered_crashes"

if [[ ! -d "$RESULT_DIR" ]]; then
    echo "$RESULT_DIR does not exists, please execute the fuzzers before running this script"
    exit 1
fi

rm -f $LOG_DIR/filtered_crashes_log.txt
rm -rf $FILTERED_CRASHES_DIR
mkdir -p "$FILTERED_CRASHES_DIR"

TARGET=cxxfilt
export ASAN_OPTIONS=detect_odr_violation=0:allocator_may_return_null=1:abort_on_error=1:symbolize=0:detect_leaks=0
for FUZZER in "MemLock" "AFL"; do
    crashes=( $(find $RESULT_DIR/${TARGET}/out_${FUZZER}-*${TARGET}-*/crashes -iname "id:*"))
    crashes_cnt=${#crashes[@]}
    crashes_cnt_filtered_with_patch=0
    crashes_cnt_filtered_without_patch=0
    for crash in ${crashes[@]}; do
        cat $crash | /workdir/MemLock/evaluation/BUILD/${TARGET}_b9913fd2/SRC_${FUZZER}/binutils/${TARGET} -t > /dev/null 2>&1
        exit_code=$?
        log_path="${FILTERED_CRASHES_DIR}/$TARGET/$FUZZER/$(basename $crash)"
        mkdir -p $(dirname $log_path)
        if [[ $exit_code -gt 127 ]]; then
            signal=$(kill -l $((exit_code - 128)))
            echo "Target terminated via signal $signal"
            crashes_cnt_filtered_with_patch=$((crashes_cnt_filtered_with_patch + 1))
            (
            export ASAN_OPTIONS=detect_odr_violation=0:allocator_may_return_null=1:abort_on_error=1:symbolize=1:detect_leaks=0
            cat $crash | /workdir/MemLock/evaluation/BUILD/${TARGET}_b9913fd2/SRC_${FUZZER}/binutils/${TARGET} -t 2> $log_path
            )
        fi
        cat $crash | /workdir/MemLock/evaluation/BUILD/${TARGET}/SRC_${FUZZER}/binutils/${TARGET} -t > /dev/null 2>&1
        exit_code=$?
        if [[ $exit_code -gt 127 ]]; then
            signal=$(kill -l $((exit_code - 128)))
            echo "Target terminated via signal $signal"
            crashes_cnt_filtered_without_patch=$((crashes_cnt_filtered_without_patch + 1))
        fi
    done
    echo "${FUZZER}@${TARGET}: $crashes_cnt_filtered_with_patch of $crashes_cnt crashed with applied patch ($crashes_cnt_filtered_without_patch without the patch)" >> $LOG_DIR/filtered_crashes_log.txt
done

TARGET=readelf
export ASAN_OPTIONS=detect_odr_violation=0:allocator_may_return_null=0:abort_on_error=1:symbolize=0:detect_leaks=0
for FUZZER in "MemLock" "AFL"; do
    crashes=( $(find $RESULT_DIR/${TARGET}/out_${FUZZER}-*${TARGET}-*/crashes -iname "id:*"))
    crashes_cnt=${#crashes[@]}
    crashes_cnt_filtered_with_patch=0
    crashes_cnt_filtered_without_patch=0
    for crash in ${crashes[@]}; do
        /workdir/MemLock/evaluation/BUILD/${TARGET}_b9913fd2/SRC_${FUZZER}/binutils/${TARGET} -a $crash > /dev/null 2>&1
        exit_code=$?
        log_path="${FILTERED_CRASHES_DIR}/$TARGET/$FUZZER/$(basename $crash)"
        mkdir -p $(dirname $log_path)
        if [[ $exit_code -gt 127 ]]; then
            signal=$(kill -l $((exit_code - 128)))
            echo "Target terminated via signal $signal"
            crashes_cnt_filtered_with_patch=$((crashes_cnt_filtered_with_patch + 1))
            (
            export ASAN_OPTIONS=detect_odr_violation=0:allocator_may_return_null=0:abort_on_error=1:symbolize=1:detect_leaks=0
            /workdir/MemLock/evaluation/BUILD/${TARGET}_b9913fd2/SRC_${FUZZER}/binutils/${TARGET} -a $crash 2> $log_path
            )
        fi
        /workdir/MemLock/evaluation/BUILD/${TARGET}/SRC_${FUZZER}/binutils/${TARGET} -a $crash > /dev/null 2>&1
        exit_code=$?
        if [[ $exit_code -gt 127 ]]; then
            signal=$(kill -l $((exit_code - 128)))
            echo "Target terminated via signal $signal"
            crashes_cnt_filtered_without_patch=$((crashes_cnt_filtered_without_patch + 1))
        fi
    done
    echo "${FUZZER}@${TARGET}: $crashes_cnt_filtered_with_patch of $crashes_cnt crashed with applied patch ($crashes_cnt_filtered_without_patch without the patch)" >> $LOG_DIR/filtered_crashes_log.txt
done


TARGET=nm
export ASAN_OPTIONS=detect_odr_violation=0:allocator_may_return_null=1:abort_on_error=1:symbolize=0:detect_leaks=0
for FUZZER in "MemLock" "AFL"; do
    crashes=( $(find $RESULT_DIR/${TARGET}/out_${FUZZER}-*${TARGET}-*/crashes -iname "id:*"))
    crashes_cnt=${#crashes[@]}
    crashes_cnt_filtered_with_patch=0
    crashes_cnt_filtered_without_patch=0
    for crash in ${crashes[@]}; do
        /workdir/MemLock/evaluation/BUILD/${TARGET}_b9913fd2/SRC_${FUZZER}/binutils/nm-new -C $crash > /dev/null 2>&1
        exit_code=$?
        log_path="${FILTERED_CRASHES_DIR}/$TARGET/$FUZZER/$(basename $crash)"
        mkdir -p $(dirname $log_path)
        if [[ $exit_code -gt 127 ]]; then
            signal=$(kill -l $((exit_code - 128)))
            echo "Target terminated via signal $signal"
            crashes_cnt_filtered_with_patch=$((crashes_cnt_filtered_with_patch + 1))
            (
            export ASAN_OPTIONS=detect_odr_violation=0:allocator_may_return_null=1:abort_on_error=1:symbolize=1:detect_leaks=0
            /workdir/MemLock/evaluation/BUILD/${TARGET}_b9913fd2/SRC_${FUZZER}/binutils/nm-new -C $crash 2> $log_path
            )
        fi
        /workdir/MemLock/evaluation/BUILD/${TARGET}/SRC_${FUZZER}/binutils/nm-new -C $crash > /dev/null 2>&1
        exit_code=$?
        if [[ $exit_code -gt 127 ]]; then
            signal=$(kill -l $((exit_code - 128)))
            echo "Target terminated via signal $signal"
            crashes_cnt_filtered_without_patch=$((crashes_cnt_filtered_without_patch + 1))
        fi
    done
    echo "${FUZZER}@${TARGET}: $crashes_cnt_filtered_with_patch of $crashes_cnt crashed with applied patch ($crashes_cnt_filtered_without_patch without the patch)" >> $LOG_DIR/filtered_crashes_log.txt
done
