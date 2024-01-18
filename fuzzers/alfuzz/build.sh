#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

if [ ! -d "$FUZZER/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

export PATH="$PATH:/usr/lib/llvm-12/bin"
cd "$FUZZER/repo/fuzzer"
CC=clang make -j $(nproc)
CC=clang make -j $(nproc) -C module/llvm_mode

# compile afl_driver.cpp
"clang++" $CXXFLAGS -std=c++11 -c "afl_driver.cpp" -fPIC -o "$OUT/afl_driver.o"
# "./afl-clang-fast++" $CXXFLAGS -std=c++11 -c "afl_driver.cpp" -fPIC -o "$OUT/afl_driver.o"
