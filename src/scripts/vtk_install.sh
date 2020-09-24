#! /bin/sh

CMAKE_BIN=$1
NCORES=$2
WIN=$3

${CMAKE_BIN} --build vtk-build -j ${NCORES} --config Release
${CMAKE_BIN} --install vtk-build --prefix vtk${WIN}

LIB_FOLDER=`ls -d vtk${WIN}/lib*`
if [[ $LIB_FOLDER != "vtk${WIN}/lib" ]]; then
    mv $LIB_FOLDER vtk${WIN}/lib
fi
rm -fr vtk${WIN}/lib/*
cp -r vtk${WIN}/include/vtk/* vtk${WIN}/include
rm -fr vtk${WIN}/include/vtk
cp -r `find vtk-build -name "*.o" -o -name "*.obj" | xargs` vtk${WIN}/lib

rm -fr vtk-src vtk-build
rm -f vtk-src.tar.gz
