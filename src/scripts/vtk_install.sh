#! /bin/sh

CMAKE_BIN=$1

"${CMAKE_BIN}" --build vtk-build --config Release
"${CMAKE_BIN}" --install vtk-build --prefix vtk

LIB_FOLDER=`ls -d vtk/lib*`
if [ $LIB_FOLDER != "vtk/lib" ]; then
    mv $LIB_FOLDER vtk/lib
fi

rm -fr vtk-build

# Handle line endings
"${R_HOME}/bin/Rscript" "../tools/lineendings.R" "vtk/include/vtk/vtkutf8/utf8.h"
