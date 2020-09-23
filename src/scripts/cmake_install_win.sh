#! /bin/sh

RSCRIPT_BIN=$1
NCORES=`${RSCRIPT_BIN} -e "cat(parallel::detectCores(logical = FALSE))"`

if [[ ${R_ARCH} =~ "x64" ]]; then
    ${RSCRIPT_BIN} -e "utils::download.file(
        url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2-win64-x64.zip',
        destfile = 'cmake.zip')"
    ${RSCRIPT_BIN} -e "utils::unzip('cmake.zip')"
    mv cmake-3.18.2-win64-x64 cmake
else
    ${RSCRIPT_BIN} -e "utils::download.file(
        url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2-win32-x86.zip',
        destfile = 'cmake.zip')"
    ${RSCRIPT_BIN} -e "utils::unzip('cmake.zip')"
    mv cmake-3.18.2-win32-x86 cmake
fi
