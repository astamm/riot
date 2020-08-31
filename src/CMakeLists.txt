cmake_minimum_required(VERSION 3.15)

if (POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif ()

if (POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif ()

project(trio)

## GET R-specific ENV variables
set(R_HOME $ENV{R_HOME})
set(RLIB "${R_HOME}/lib")
set(RSCRIPT "${R_HOME}/bin/Rscript")
set(RCPP_DIR "$ENV{RCPP_DIR}/include")
set(R_INCLUDE_DIR "$ENV{R_INCLUDE_DIR}")
set(CXX "$ENV{CXX}")

set(CXXFLAGS "$ENV{CXXFLAGS}")
set(CPPFLAGS "$ENV{CPPFLAGS}")
set(BLAS_LIBS "$ENV{BLAS_LIBS}")
set(LAPACK_LIBS "$ENV{LAPACK_LIBS}")

## set variables accordingly
set(CMAKE_CXX_FLAGS "${CXXFLAGS}")
set(CMAKE_C_FLAGS "${CPPFLAGS} ${CFLAGS}")
set(CMAKE_CXX_COMPILER "${CXX}")
set(CMAKE_VERBOSE_MAKEFILE OFF)

# helpful for setting the language standard
set(CMAKE_C_STANDARD    11 CACHE STRING "C language standard")
set(CMAKE_CXX_STANDARD  11 CACHE STRING "C++ language standard")
set(CMAKE_CUDA_STANDARD 11 CACHE STRING "CUDA language standard")

set(CMAKE_C_STANDARD_REQUIRED    ON CACHE BOOL "Require the C language standard to set")
set(CMAKE_CXX_STANDARD_REQUIRED  ON CACHE BOOL "Require the C++ language standard to set")
set(CMAKE_CUDA_STANDARD_REQUIRED ON CACHE BOOL "Require the CUDA language standard to set")

set(CMAKE_C_EXTENSIONS    OFF CACHE BOOL "Enable/disable extensions, e.g. -std=gnu11 vs. -std=c11")
set(CMAKE_CXX_EXTENSIONS  OFF CACHE BOOL "Enable/disable extensions, e.g. -std=gnu++11 vs. -std=c++11")
set(CMAKE_CUDA_EXTENSIONS OFF CACHE BOOL "Enable/disable extensions")

### only link against necessary libs
set(required_vtk_modules
    CommonCore # vtkSmartPointer.h
    CommonDataModel # vtkPolyData.h, vtkPointData.h
    IOLegacy # vtkPolyDataReader.h
    IOXML # vtkXMLPolyDataReader.h
)
find_package( VTK REQUIRED COMPONENTS ${required_vtk_modules} )
include_directories(${VTK_INCLUDE_DIRS})

LINK_DIRECTORIES(${RLIB} ${VTK_LIBRARY_DIR})
include_directories(BEFORE ${R_INCLUDE_DIR} ${RCPP_DIR} ${VTK_INCLUDE_DIR} "../inst/include/")
add_library(trio SHARED trackReaders.cpp RcppExports.cpp)
set(CMAKE_SHARED_LINKER_FLAGS "${BLAS_LIBS} ${LAPACK_LIBS}")
option(LINK_STATIC_LIBSTDC "link statically against libstdc++" OFF)
if (LINK_STATIC_LIBSTDC)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static-libstdc++")
endif(LINK_STATIC_LIBSTDC)

target_link_libraries(trio ${VTK_LIBRARIES} R)
set_property(TARGET trio PROPERTY PREFIX "")
if(APPLE)
  SET_TARGET_PROPERTIES(trio PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
  set_property(TARGET trio PROPERTY OUTPUT_NAME "trio")
  set_property(TARGET trio PROPERTY SUFFIX ".so")
endif()
