#! /bin/sh

: ${R_HOME=$(R RHOME)}
RSCRIPT_BIN=${R_HOME}/bin/Rscript
NCORES=`${RSCRIPT_BIN} -e "cat(min(2, parallel::detectCores(logical = FALSE)))"`

cd src

#### CMAKE CONFIGURATION ####
. ./scripts/cmake_config.sh

# Compile VTK from source
sh ./scripts/vtk_download.sh ${RSCRIPT_BIN}
dot() { file=$1; shift; . "$file"; }
dot ./scripts/r_config.sh ""
# ${CMAKE_BIN} \
#   -D BUILD_SHARED_LIBS=OFF \
#   -D CMAKE_BUILD_TYPE=Release \
#   -D CMAKE_AR=${AR} \
#   -D CMAKE_RANLIB=${RANLIB} \
#   -D VTK_BUILD_TESTING=OFF \
#   -D VTK_ENABLE_WRAPPING=OFF \
#   -D VTK_GROUP_ENABLE_Imaging=DONT_WANT \
#   -D VTK_GROUP_ENABLE_MPI=DONT_WANT \
#   -D VTK_GROUP_ENABLE_Qt=DONT_WANT \
#   -D VTK_GROUP_ENABLE_Rendering=DONT_WANT \
#   -D VTK_GROUP_ENABLE_StandAlone=DONT_WANT \
#   -D VTK_GROUP_ENABLE_Views=DONT_WANT \
#   -D VTK_GROUP_ENABLE_Web=DONT_WANT \
#   -D VTK_MODULE_ENABLE_VTK_CommonCore=YES \
#   -D VTK_MODULE_ENABLE_VTK_CommonDataModel=YES \
#   -D VTK_MODULE_ENABLE_VTK_CommonExecutionModel=YES \
#   -D VTK_MODULE_ENABLE_VTK_CommonMath=YES \
#   -D VTK_MODULE_ENABLE_VTK_CommonMisc=YES \
#   -D VTK_MODULE_ENABLE_VTK_CommonSystem=YES \
#   -D VTK_MODULE_ENABLE_VTK_CommonTransforms=YES \
#   -D VTK_MODULE_ENABLE_VTK_IOCore=YES \
#   -D VTK_MODULE_ENABLE_VTK_IOLegacy=YES \
#   -D VTK_MODULE_ENABLE_VTK_IOXML=YES \
#   -D VTK_MODULE_ENABLE_VTK_IOXMLParser=YES \
#   -D VTK_VERSIONED_INSTALL=OFF \
#   -S vtk-src \
#   -B vtk-build
${CMAKE_BIN} \
  -D BUILD_SHARED_LIBS=OFF \
  -D BUILD_TESTING=OFF \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_AR=${AR} \
  -D CMAKE_RANLIB=${RANLIB} \
  -D VTK_ENABLE_WRAPPING=OFF \
  -D VTK_Group_Imaging=OFF \
  -D VTK_Group_MPI=OFF \
  -D VTK_Group_Qt=OFF \
  -D VTK_Group_Rendering=OFF \
  -D VTK_Group_StandAlone=OFF \
  -D VTK_Group_Tk=OFF \
  -D VTK_Group_Views=OFF \
  -D VTK_Group_Web=OFF \
  -D VTK_RENDERING_BACKEND=None \
  -D Module_vtkCommonCore=ON \
  -D Module_vtkCommonDataModel=ON \
  -D Module_vtkCommonExecutionModel=ON \
  -D Module_vtkCommonMath=ON \
  -D Module_vtkCommonMisc=ON \
  -D Module_vtkCommonSystem=ON \
  -D Module_vtkCommonTransforms=ON \
  -D Module_vtkIOCore=ON \
  -D Module_vtkIOLegacy=ON \
  -D Module_vtkIOXML=ON \
  -D Module_vtkIOXMLParser=ON \
  -S vtk-src \
  -B vtk-build
sh ./scripts/vtk_install.sh ${CMAKE_BIN} ${NCORES} ""

# Cleanup
sh ./scripts/vtk_cleanup.sh
