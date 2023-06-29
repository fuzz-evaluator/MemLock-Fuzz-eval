# 01-Artificial-Runtime-Environment
This experiment is designed to test the influence of the artificially reduced stack size (via `ulimit -s`) used for the `flex` target (see Chapter 4.2 in the paper). The results of this experiment and further details are presented in the repositorie's main [README.md](../README.md).

## Setup
To evaluate the impact of the `ulimit -s` parameter, the following experiments were run:
- MemLock / 24h / 10 repetitions / **with** ulimit set  
- MemLock / 24h / 10 repetitions / **without** ulimit set  
- AFL / 24h / 10 repetitions / **with** ulimit set  
- AFL / 24h / 10 repetitions / **without** ulimit set

## Layout
- `scripts/run.sh`: This script is used to run this experiment and must be executed in the Docker container built via the `prepare.sh` script.
- `Dockerfile`: The Dockerfile used to build the images this experiment is based on. Essentially, this is the artifact as provided by the authors with `flex` being already built as part of the image.
- `prepare.sh`: This will build the Docker image of both the artifact and the experiment, and it will set system the artificial limits as done by the authors
- `spawn.sh`: Spawn a Docker container to run this experiment. The scripts are mounted at `/data/
- `logs`: This folder includes the logs for all fuzzing runs conducted as part of this experiment.
- `results`: This folder contains all files produced during execution of this experiment.
  - `out_AFL-afl-noulimit-[1-10]`
    - Results of all AFL runs performed **without** explicitly setting `ulimit -s 2048`.
  - `out_AFL-afl-ulimit-[1-10]`
    -  Results of all AFL runs performed **with** `ulimit -s 2048` being set.
  - `out_MemLock-memlock-noulimit-[1-10]`
    - Results of all MemLock runs performed **without** explicitly setting `ulimit -s 2048`.
  - `out_MemLock-memlock-ulimit-[1-10]`
    - Results of all MemLock runs performed **with** `ulimit -s 2048` being set.