#! /bin/sh

RSCRIPT_BIN=$1

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/9.0/VTK-9.0.1.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-9.0.1 vtk-src
rm -f vtk-src.tar.gz

# Make ISO compilers happy
echo 'typedef int make_iso_compilers_happy;' | cat - vtk-src/ThirdParty/expat/vtkexpat/lib/xmltok_impl.c > temp && mv temp vtk-src/ThirdParty/expat/vtkexpat/lib/xmltok_impl.c
echo 'typedef int make_iso_compilers_happy;' | cat - vtk-src/ThirdParty/expat/vtkexpat/lib/xmltok_ns.c > temp && mv temp vtk-src/ThirdParty/expat/vtkexpat/lib/xmltok_ns.c

# Fix missing include <limits>
echo '#include <limits>' | cat - vtk-src/Common/Core/vtkGenericDataArrayLookupHelper.h > temp && mv temp vtk-src/Common/Core/vtkGenericDataArrayLookupHelper.h
echo '#include <limits>' | cat - vtk-src/Common/Core/vtkDataArrayPrivate.txx > temp && mv temp vtk-src/Common/Core/vtkDataArrayPrivate.txx
echo '#include <limits>' | cat - vtk-src/Common/DataModel/vtkPiecewiseFunction.cxx > temp && mv temp vtk-src/Common/DataModel/vtkPiecewiseFunction.cxx

# Do not check for array bounds for two files in CommonDataModel module if GNU gcc is used
echo '
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set_source_files_properties(vtkHyperTreeGrid.cxx vtkPolyhedron.cxx PROPERTIES COMPILE_FLAGS "-Wno-array-bounds -Wno-stringop-overread")
endif()
' | cat - vtk-src/Common/DataModel/CMakeLists.txt > temp && mv temp vtk-src/Common/DataModel/CMakeLists.txt

# Do not check for array bounds for one file in CommonCore module if GNU gcc is used
echo '
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set_source_files_properties(vtkScalarsToColors.cxx PROPERTIES COMPILE_FLAGS "-Wno-array-bounds -Wno-stringop-overflow")
endif()
' | cat - vtk-src/Common/Core/CMakeLists.txt > temp && mv temp vtk-src/Common/Core/CMakeLists.txt
