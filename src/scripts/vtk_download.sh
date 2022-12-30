#! /bin/sh

RSCRIPT_BIN=$1
VERSION=9.2
THIRD=2

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/${VERSION}/VTK-${VERSION}.${THIRD}.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-${VERSION}.${THIRD} vtk-src
rm -f vtk-src.tar.gz
