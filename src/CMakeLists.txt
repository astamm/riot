cmake_minimum_required(VERSION 3.12)

find_program(CMAKE_CXX_COMPILER ${R_CXX})

project(riot)

message(STATUS "CMake version: ${CMAKE_VERSION}")
message(STATUS "Project name: ${PROJECT_NAME}")
message(STATUS "Project source dir: ${CMAKE_SOURCE_DIR}")
message(STATUS "Project binary dir: ${CMAKE_BINARY_DIR}")

set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake
  ${CMAKE_MODULE_PATH}
)
message(STATUS "CMake module path: ${CMAKE_MODULE_PATH}")

message (STATUS "R_INCLUDE_DIRS: ${R_INCLUDES}")
include_directories(BEFORE ${R_INCLUDES})

execute_process(
  COMMAND ${R_BIN} "--slave" "-e" "stopifnot(require('Rcpp'));cat(Rcpp:::Rcpp.system.file('include'))"
   OUTPUT_VARIABLE RCPP_INCLUDE_DIRS
)
message(STATUS "RCPP_INCLUDE_DIRS: ${RCPP_INCLUDE_DIRS}")
include_directories(BEFORE ${RCPP_INCLUDE_DIRS})

find_package(VTK COMPONENTS
  CommonCore
  CommonDataModel
  IOLegacy
  IOXML
  vtksys
  QUIET
)

if (NOT VTK_FOUND)
  message("Skipping ${PROJECT_NAME}: VTK not found.")
  return ()
endif()
message (STATUS "VTK_VERSION: ${VTK_VERSION}")

add_library(vtk INTERFACE)
target_link_libraries(vtk INTERFACE ${VTK_LIBRARIES})

# List source files
set(RIOT_SOURCES 
  fascicleWriters.cpp fascicleReaders.cpp RcppExports.cpp tinyxml2.cpp
)
add_library(riot SHARED ${RIOT_SOURCES})

set_target_properties(riot PROPERTIES COMPILE_FLAGS "-std=c++11")

target_link_libraries(riot vtk ${R_LIBRARIES})

set_target_properties(riot PROPERTIES PREFIX "")
if(NOT WIN32) # Need to force .so on Mac, but Windows needs to be .dll
  set_target_properties(riot PROPERTIES SUFFIX ".so")
  install(TARGETS riot LIBRARY DESTINATION . )
else(NOT WIN32)
  install(TARGETS riot RUNTIME DESTINATION . )
endif(NOT WIN32)