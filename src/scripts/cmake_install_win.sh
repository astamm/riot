#! /bin/sh

NCORES=$1
CC=$2
CXX=$3
# R_BIN=$2
# NCORES=`${RSCRIPT_BIN} -e "cat(parallel::detectCores(logical = FALSE))"`


cd cmake
./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=OFF -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}
make -j${NCORES}
cd ..

# if [[ ${R_ARCH} =~ "x64" ]]; then
#     ${RSCRIPT_BIN} -e "utils::download.file(
#         url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2-win64-x64.zip',
#         destfile = 'cmake.zip')"
#     ${RSCRIPT_BIN} -e "utils::unzip('cmake.zip')"
#     mv cmake-3.18.2-win64-x64 cmake
# else
#     ${RSCRIPT_BIN} -e "utils::download.file(
#         url = 'https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2-win32-x86.zip',
#         destfile = 'cmake.zip')"
#     ${RSCRIPT_BIN} -e "utils::unzip('cmake.zip')"
#     mv cmake-3.18.2-win32-x86 cmake
# fi