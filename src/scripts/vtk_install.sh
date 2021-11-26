#! /bin/sh

CMAKE_BIN=$1
NCORES=$2
ARCH=$3
AR=$4

"${CMAKE_BIN}" --build vtk${ARCH}-build -j ${NCORES} --config Release
"${CMAKE_BIN}" --install vtk${ARCH}-build --prefix vtk${ARCH}

for f in vtk${ARCH}/lib/*.a; do
    "${AR}" -x $f
done
"${AR}" -qc vtk${ARCH}/lib/libvtk.a *.o

rm -fr vtk${ARCH}-build
rm -f *.o
