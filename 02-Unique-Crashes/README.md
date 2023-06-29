# 02-Unique-Crashes
The goal of this experiment is to determine the suitability of unique crashes as metric to compare fuzzers.
The related experiment in the paper can be found in Chapter 4.2 and the results in Table 1 in the paper.

## Setup
To evaluate unique crashes as metric, the following fuzzing runs were conducted:
| Fuzzer  | Duration | Trials | Target   |
| ------- | :------: | :----: | -------- |
| Memlock |   24h    |   10   | `readelf`  |
| Memlock |   24h    |   10   | `cxxfilt`  |
| Memlock |   24h    |   10   | `nm`       |
| AFL     |   24h    |   10   | `readelf`  |
| AFL     |   24h    |   10   | `cxxfilt`  |
| AFL     |   24h    |   10   | `nm`       |

The three targets, `readelf`, `cxxfilt` and `nm` (all part of binutils) have been additionally compiled with the [patch](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=87636) that has been provided by the binutils authors in response to [CVE-2018-18484](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-18484) that has been reported by the MemLock authors.
We refer to these patched versions as `readelf*`, `cxxfilt*`, and `nm*` in the following.

The provided patch essentially limits the stack depth during demangling by keeping track of the current stack depth and triggers a clean exit if some arbitrary limit is exceeded. Using the patched version allows us to automatically determine the number of unique crashes belonging to the same root cause by simply running these crashes against the patched binary; all unique crashes belonging to the fixed root cause will no longer crash.

## Layout
- `scripts/*`: These are the scripts that must be executed inside the experiment's container spawned via the `spawn.sh` script.
  - `fuzz.sh`: Run the fuzzing campaigns. Can be adapted to the available resources.
  - `filter_patched_crashes.sh`: Filter  out crashes that where fixed by the applied patch.
- `Dockerfile`: The Dockerfile used to build the images this experiment is based on. This will build the targets mentioned above, including the patched version.
- `prepare.sh`: This will build the Docker images of the artifact and the experiment and set system limits as suggested by the authors
- `spawn.sh`: Spawn the experiment's container. The scripts are mounted at `/data/02-Unique-Crashes/scripts/`.
- `logs`: This folder includes the logs for all runs conducted as part of this experiment.
- `results/*`: This folder contains all files produced during execution of this experiment.
  - `readelf`: The output of the fuzzing runs for MemLock and AFL (`fuzz.sh`).
  - `cxxfilt`: The output of the fuzzing runs for MemLock and AFL (`fuzz.sh`).
  - `nm`: The output of the fuzzing runs for MemLock and AFL (`fuzz.sh`).
  - `filtered_crashes/*`: The crashes of the fuzzing runs that can still be triggered on the patched version (i.e., on `readelf*`, `cxxfilt*` or `nm*`). The filtering happens via the `filter_patched_crashes.sh` script.