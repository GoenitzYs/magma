#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

git clone \
    --depth 1 \
    --branch test \
    git@host.docker.internal:git-server/ALFUZZ.git "$FUZZER/repo"
# git clone --no-checkout https://github.com/google/AFL.git "$FUZZER/repo"
# git -C "$FUZZER/repo" checkout 61037103ae3722c8060ff7082994836a794f978e
#wget -O "$FUZZER/repo/afl_driver.cpp" \
#    "https://cs.chromium.org/codesearch/f/chromium/src/third_party/libFuzzer/src/afl/afl_driver.cpp"
cp "$FUZZER/src/afl_driver.cpp" "$FUZZER/repo/fuzzer/afl_driver.cpp"
