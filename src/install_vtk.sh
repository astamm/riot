#! /bin/sh

RSCRIPT_BIN=$1
CMAKE_BIN=`which cmake`

NCORES=`${RSCRIPT_BIN} -e "cat(parallel::detectCores(logical = FALSE))"`

# Download VTK source
${RSCRIPT_BIN} -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/9.0/VTK-9.0.1.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${RSCRIPT_BIN} -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-9.0.1 vtk-src

# Build VTK
rm -fr vtk-build vtk-install
HACK=""
# if [[ `uname -s` =~ "MINGW" ]]; then
#   HACK='-G "MinGW Makefiles" -D VTK_USE_EXTERN_TEMPLATE=OFF'
# fi
${CMAKE_BIN} ${HACK} \
	-D BUILD_SHARED_LIBS=OFF \
	-D VTK_ENABLE_WRAPPING=OFF \
	-D VTK_GROUP_ENABLE_Imaging=NO \
	-D VTK_GROUP_ENABLE_MPI=NO \
	-D VTK_GROUP_ENABLE_Qt=NO \
	-D VTK_GROUP_ENABLE_Rendering=NO \
	-D VTK_GROUP_ENABLE_StandAlone=NO \
	-D VTK_GROUP_ENABLE_Views=NO \
	-D VTK_GROUP_ENABLE_Web=NO \
	-D VTK_LEGACY_SILENT=ON \
	-D VTK_MODULE_ENABLE_VTK_CommonCore=YES \
	-D VTK_MODULE_ENABLE_VTK_CommonDataModel=YES \
	-D VTK_MODULE_ENABLE_VTK_CommonExecutionModel=YES \
	-D VTK_MODULE_ENABLE_VTK_CommonMath=YES \
	-D VTK_MODULE_ENABLE_VTK_CommonMisc=YES \
	-D VTK_MODULE_ENABLE_VTK_CommonSystem=YES \
	-D VTK_MODULE_ENABLE_VTK_CommonTransforms=YES \
	-D VTK_MODULE_ENABLE_VTK_IOCore=YES \
	-D VTK_MODULE_ENABLE_VTK_IOLegacy=YES \
	-D VTK_MODULE_ENABLE_VTK_IOXML=YES \
	-D VTK_MODULE_ENABLE_VTK_IOXMLParser=YES \
	-S vtk-src \
	-B vtk-build
${CMAKE_BIN} --build vtk-build -j ${NCORES} --config Release
${CMAKE_BIN} --install vtk-build --prefix vtk-install

# Create proper vtk folder
mkdir vtk
mkdir vtk/include
mkdir vtk/lib
cp -r vtk-install/include/vtk-9.0/* vtk/include
rm -f *CMakeC*CompilerId.obj
cp `find vtk-build -type f -name "*.o" -o -name "*.obj" | xargs` vtk/lib

rm -fr vtk-src vtk-build vtk-install
rm -f vtk-src.tar.gz
