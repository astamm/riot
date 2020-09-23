#! /bin/sh

RSCRIPT_BIN=$1
CC=$2
CFLAGS=$3
CXX=$4
CXXFLAGS=$5
NCORES=$6

${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2.tar.gz',
    destfile = 'cmake.tar.gz')"

${RSCRIPT_BIN} -e "utils::untar('cmake.tar.gz')"
mv cmake-3.18.2 cmake

cd cmake
./bootstrap CC="${CC}" CFLAGS="${CFLAGS}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=OFF -DCMAKE_C_STANDARD=11 -DCMAKE_CXX_STANDARD=11
make -j${NCORES}
cd ..

CMAKE_BIN=./cmake/bin/cmake
