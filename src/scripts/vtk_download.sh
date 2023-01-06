#! /bin/sh

RSCRIPT_BIN=$1
VERSION=9.2
THIRD=4

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/${VERSION}/VTK-${VERSION}.${THIRD}.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-${VERSION}.${THIRD} vtk-src
rm -f vtk-src.tar.gz

# Do not check for deprecated-non-prototype and strict-prototypes in vtkzlib
echo '
  set_source_files_properties(adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c inflate.c infback.c inftrees.c inffast.c trees.c uncompr.c zutil.c PROPERTIES COMPILE_FLAGS "-Wno-deprecated-non-prototype -Wno-strict-prototypes")
' | cat - vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt > temp && mv temp vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt
