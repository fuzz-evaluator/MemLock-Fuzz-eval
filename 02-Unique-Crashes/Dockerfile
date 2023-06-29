ARG MEMLOCK_DOCKER_IMAGE_NAME
FROM ${MEMLOCK_DOCKER_IMAGE_NAME}

RUN apt install parallel -y

# Build tested targets
RUN cd /workdir/MemLock/evaluation/BUILD \
    && ./build_nm.sh \
    && ./build_cxxfilt.sh \
    && ./build_readelf.sh

# Build targets with the patch supplied in response to the bug report that got
# CVE-2018-18701 assigned.
# These are exactly the same as above, but implement a counter for the stack depth.
RUN cd /workdir/MemLock/evaluation/BUILD \
    && ./build_nm_b9913fd2.sh \
    && ./build_cxxfilt_b9913fd2.sh \
    && ./build_readelf_b9913fd2.sh

RUN ls -l /workdir/MemLock/evaluation/BUILD