#! /bin/sh

RSCRIPT_BIN=$1
CC=$2
CXX=$3
NCORES=`${RSCRIPT_BIN} -e "cat(parallel::detectCores(logical = FALSE))"`

${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2.tar.gz',
    destfile = 'cmake.tar.gz')"

${RSCRIPT_BIN} -e "utils::untar('cmake.tar.gz')"
mv cmake-3.18.2 cmake

cd cmake
./bootstrap CC="${CC}" CXX="${CXX}" -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=OFF -DCMAKE_C_STANDARD=11 -DCMAKE_CXX_STANDARD=11
echo "Number of cores: ${NCORES}"
make -j${NCORES}
cd ..

CMAKE_BIN=./cmake/bin/cmake
