#! /bin/sh

NCORES=$1

# Download VTK source
${R_HOME}/bin/Rscript -e "utils::download.file(
    url = 'https://www.vtk.org/files/release/9.0/VTK-9.0.1.tar.gz',
    destfile = 'vtk-src.tar.gz')"

# Uncompress VTK source
${R_HOME}/bin/Rscript -e "utils::untar(tarfile = 'vtk-src.tar.gz')"
mv VTK-9.0.1 vtk-src

# Build VTK
rm -fr vtk-build
rm -fr ../inst/vtk-install
cmake \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_SHARED_LIBS=OFF \
	-D VTK_LEGACY_SILENT=ON \
	-D VTK_GROUP_ENABLE_Imaging=NO \
	-D VTK_GROUP_ENABLE_MPI=NO \
	-D VTK_GROUP_ENABLE_Qt=NO \
	-D VTK_GROUP_ENABLE_StandAlone=NO \
	-D VTK_GROUP_ENABLE_Views=NO \
	-D VTK_GROUP_ENABLE_Web=NO \
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
cmake --build vtk-build -j ${NCORES} --clean-first
cmake --install vtk-build --prefix ../inst/vtk-install

rm -fr vtk-src
rm -fr vtk-build
rm -f vtk-src.tar.gz
