#! /bin/sh

CMAKE_BIN=$1
NCORES=$2
ARCH=$3

"${CMAKE_BIN}" --build vtk${ARCH}-build -j ${NCORES} --config Release
"${CMAKE_BIN}" --install vtk${ARCH}-build --prefix vtk${ARCH}
rm -fr vtk${ARCH}-build
