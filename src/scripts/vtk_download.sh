#! /bin/sh

RSCRIPT_BIN=$1
VERSION=9.2
PATCH=4

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/${VERSION}/VTK-${VERSION}.${PATCH}.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-${VERSION}.${PATCH} vtk-src
rm -f vtk-src.tar.gz

# Disabling compilation warnings in vtkzlib if LLVM clang is used
echo '
if (CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set_source_files_properties(adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c inflate.c infback.c inftrees.c inffast.c trees.c uncompr.c zutil.c PROPERTIES COMPILE_FLAGS "-Wno-deprecated-non-prototype -Wno-strict-prototypes")
endif()
' | cat - vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt > temp && mv temp vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt

# Disabling compilation warnings in vtkzlib if Apple clang is used
echo '
if (CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
  set_source_files_properties(crc32.c PROPERTIES COMPILE_FLAGS "-Wno-strict-prototypes")
endif()
' | cat - vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt > temp && mv temp vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt

# Disabling compilation warnings in vtkzlib if GNU gcc is used
echo '
if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
  set_source_files_properties(crc32.c PROPERTIES COMPILE_FLAGS "-Wno-strict-prototypes")
endif()
' | cat - vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt > temp && mv temp vtk-src/ThirdParty/zlib/vtkzlib/CMakeLists.txt

# Disabling compilation warnings in CommonDataModel if Apple clang is used
echo '
if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  set_source_files_properties(vtkCellTreeLocator.cxx PROPERTIES COMPILE_FLAGS "-Wno-reorder")
endif()
' | cat - vtk-src/Common/DataModel/CMakeLists.txt > temp && mv temp vtk-src/Common/DataModel/CMakeLists.txt

# Disabling compilation warnings in CommonDataModel if GNU gcc is used
echo '
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set_source_files_properties(vtkPolyhedron.cxx PROPERTIES COMPILE_FLAGS "-Wno-array-bounds -Wno-stringop-overread")
  set_source_files_properties(vtkCellTreeLocator.cxx PROPERTIES COMPILE_FLAGS "-Wno-reorder")
endif()
' | cat - vtk-src/Common/DataModel/CMakeLists.txt > temp && mv temp vtk-src/Common/DataModel/CMakeLists.txt
