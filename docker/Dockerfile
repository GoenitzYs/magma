FROM ubuntu:18.04

# TODO remove sudo for user "magma" to avoid unwanted priv escalation from
# other attack vectors.

RUN apt-get update && apt-get install -y sudo

RUN apt update && \
    apt install -y build-essential wget git && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    echo -e "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-12 main \
    \\ndeb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-12 main \
    \\n\\ndeb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-15 main \
    \ndeb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-15 main \
    \n\ndeb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-17 main \
    \ndeb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-17 main" |tee /etc/apt/sources.list.d/llvm.list && \
    apt update && \
    apt install -y clang-12 clang-15 clang-17

RUN apt install -y libc++-12-dev
# RUN apt install -y libc++-12-dev && \ 
#     apt install -y libc++-15-dev && \
#     apt install -y libc++-17-dev

RUN apt install -y python3-pip
RUN python3 -m pip install --upgrade pip
# RUN python3 -m pip install torch torchvision torchaudio
RUN python3 -m pip install torch==1.10.1+cu111 torchvision==0.11.2+cu111 torchaudio==0.10.1 \
	-f https://download.pytorch.org/whl/cu111/torch_stable.html
COPY requireements.txt /
RUN python3 -m pip install -r /requirements.txt

ENV PATH="${PATH}:/usr/lib/llvm-12/bin"
ENV LD_LIBRARY_PATH="/usr/lib/llvm-12/lib:${LD_LIBRARY_PATH}"

## Magma directory hierarchy
# magma_root is relative to the docker-build's working directory
# The Docker image must be built in the root of the magma directory
ARG magma_root=./

## Path variables inside the container
ENV MAGMA_R /magma
ENV OUT		/magma_out
ENV SHARED 	/magma_shared

ENV CC  /usr/bin/gcc
ENV CXX /usr/bin/g++
ENV LD /usr/bin/ld
ENV AR /usr/bin/ar
ENV AS /usr/bin/as
ENV NM /usr/bin/nm
ENV RANLIB /usr/bin/ranlib

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN mkdir -p /home && \
	groupadd -g ${GROUP_ID} magma && \
	useradd -l -u ${USER_ID} -K UMASK=0000 -d /home -g magma magma && \
	chown magma:magma /home
RUN	echo "magma:amgam" | chpasswd && usermod -a -G sudo magma

RUN mkdir -p ${SHARED} ${OUT} && \
	chown magma:magma ${SHARED} ${OUT} && \
	chmod 744 ${SHARED} ${OUT}

ARG magma_path=magma
ENV MAGMA 	${MAGMA_R}/${magma_path}
USER root:root
RUN mkdir -p ${MAGMA} && chown magma:magma ${MAGMA}
COPY --chown=magma:magma ${magma_root}/${magma_path} ${MAGMA}/
RUN ${MAGMA}/preinstall.sh
USER magma:magma
RUN ${MAGMA}/prebuild.sh

ARG fuzzer_name
ARG fuzzer_path=fuzzers/${fuzzer_name}
ENV FUZZER 	${MAGMA_R}/${fuzzer_path}
USER root:root
RUN mkdir -p ${FUZZER} && chown magma:magma ${FUZZER}
COPY --chown=magma:magma ${magma_root}/${fuzzer_path} ${FUZZER}/
RUN ${FUZZER}/preinstall.sh
USER magma:magma
RUN ${FUZZER}/fetch.sh
RUN ${FUZZER}/build.sh

ARG target_name
ARG target_path=targets/${target_name}
ENV TARGET 	${MAGMA_R}/${target_path}
USER root:root
RUN mkdir -p ${TARGET} && chown magma:magma ${TARGET}
COPY --chown=magma:magma ${magma_root}/${target_path} ${TARGET}/
RUN ${TARGET}/preinstall.sh
USER magma:magma
RUN ${TARGET}/fetch.sh
RUN ${MAGMA}/apply_patches.sh

## Configuration parameters
ARG isan
ARG harden
ARG canaries
ARG fixes

ARG ISAN_FLAG=${isan:+-DMAGMA_FATAL_CANARIES}
ARG HARDEN_FLAG=${harden:+-DMAGMA_HARDEN_CANARIES}
ARG CANARIES_FLAG=${canaries:+-DMAGMA_ENABLE_CANARIES}
ARG FIXES_FLAG=${fixes:+-DMAGMA_ENABLE_FIXES}
ARG BUILD_FLAGS="-include ${MAGMA}/src/canary.h ${CANARIES_FLAG} ${FIXES_FLAG} ${ISAN_FLAG} ${HARDEN_FLAG} -g -O0"

ENV CFLAGS ${BUILD_FLAGS}
ENV CXXFLAGS ${BUILD_FLAGS}
ENV LIBS -l:magma.o -lrt
ENV LDFLAGS -L"${OUT}" -g

RUN ${FUZZER}/instrument.sh

ENTRYPOINT "${MAGMA}/run.sh"
