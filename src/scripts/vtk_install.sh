#! /bin/sh

CMAKE_BIN=$1
NCORES=$2
ARCH=$3

"${CMAKE_BIN}" --build vtk-build${ARCH} -j ${NCORES} --config Release
"${CMAKE_BIN}" --install vtk-build${ARCH} --prefix vtk${ARCH}

LIB_FOLDER=`ls -d vtk${ARCH}/lib*`
if [[ $LIB_FOLDER != "vtk/lib" ]]; then
    mv $LIB_FOLDER vtk${ARCH}/lib
fi
rm -fr vtk${ARCH}/lib/*
cp -r vtk${ARCH}/include/vtk/* vtk${ARCH}/include
rm -fr vtk${ARCH}/include/vtk
cp -r `find vtk${ARCH}-build -name "*.o" -o -name "*.obj" | xargs` vtk${ARCH}/lib

rm -fr vtk${ARCH}-build
