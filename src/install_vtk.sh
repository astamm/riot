#! /bin/sh

RSCRIPT_BIN=$1
CMAKE_BIN=`which cmake`

NCORES=`${RSCRIPT_BIN} -e "cat(parallel::detectCores(logical = FALSE))"`

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/9.0/VTK-9.0.1.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-9.0.1 vtk-src

# Build VTK
rm -fr vtk-build
rm -fr ../inst/vtk
${CMAKE_BIN} \
	-D BUILD_SHARED_LIBS=OFF \
	-S vtk-src \
	-B vtk-build
${CMAKE_BIN} --build vtk-build -j ${NCORES} --clean-first --config Release
${CMAKE_BIN} --install vtk-build --prefix ../inst/vtk

rm -fr vtk-src vtk-build
rm -f vtk-src.tar.gz
