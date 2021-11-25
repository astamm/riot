#! /bin/sh

CMAKE_BIN=$1
NCORES=$2
ARCH=$3

"${CMAKE_BIN}" --build vtk${ARCH}-build -j ${NCORES} --config Release
"${CMAKE_BIN}" --install vtk${ARCH}-build --prefix vtk${ARCH}

LIB_FOLDER=`ls -d vtk${ARCH}/lib*`
if [[ $LIB_FOLDER != "vtk${ARCH}/lib" ]]; then
    mv $LIB_FOLDER vtk${ARCH}/lib
fi
rm -fr vtk${ARCH}/lib/*
cp -r `find vtk-build -name "*.o" -o -name "*.obj" | xargs` vtk${ARCH}/lib
rm -fr vtk${ARCH}-build
