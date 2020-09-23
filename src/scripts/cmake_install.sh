#! /bin/sh

RSCRIPT_BIN=$1
R_BIN=$2
NCORES=`${RSCRIPT_BIN} -e "cat(parallel::detectCores(logical = FALSE))"`

${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2.tar.gz',
    destfile = 'cmake.tar.gz')"

${RSCRIPT_BIN} -e "utils::untar('cmake.tar.gz')"
mv cmake-3.18.2 cmake

cd cmake
env CC=`${R_BIN} CMD config CC` CXX=`${R_BIN} CMD config CXX` ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=OFF
make -j${NCORES}
cd ..
