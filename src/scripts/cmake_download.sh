#! /bin/sh

RSCRIPT_BIN=$1

${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2.tar.gz',
    destfile = 'cmake.tar.gz')"

${RSCRIPT_BIN} -e "utils::untar('cmake.tar.gz')"
mv cmake-3.18.2 cmake
