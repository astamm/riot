#!/bin/sh

mkdir -p ../inst/include
mkdir -p ../inst/include/vtk
cp -r vtk${R_ARCH}/include/vtk/* ../inst/include/vtk/
rm -fr vtk-src
rm -f vtk-src.tar.gz
