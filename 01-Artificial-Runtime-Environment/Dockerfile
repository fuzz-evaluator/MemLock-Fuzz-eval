ARG MEMLOCK_DOCKER_IMAGE_NAME
FROM ${MEMLOCK_DOCKER_IMAGE_NAME}

RUN apt install parallel -y

# Build the flex target
RUN cd /workdir/MemLock/evaluation/BUILD && ./build_flex.sh