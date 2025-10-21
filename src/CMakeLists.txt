cmake_minimum_required(VERSION 3.12)

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

find_package(LibR)
if(${LIBR_FOUND})
else()
  message(FATAL_ERROR "No R...")
endif()
message(STATUS "LIBR_VERSION: ${LIBR_VERSION}")
message(STATUS "LIBR_INCLUDE_DIRS: ${LIBR_INCLUDE_DIRS}")
message(STATUS "LIBR_LIBRARIES: ${LIBR_LIBRARIES}")
message(STATUS "LIBR_EXECUTABLE: ${LIBR_EXECUTABLE}")
include_directories(BEFORE ${LIBR_INCLUDE_DIRS})

execute_process(
  COMMAND ${LIBR_EXECUTABLE} "--slave" "-e" "stopifnot(require('Rcpp'));cat(Rcpp:::Rcpp.system.file('include'))"
   OUTPUT_VARIABLE LIBRCPP_INCLUDE_DIRS
)
message(STATUS "LIBRCPP_INCLUDE_DIRS: ${LIBRCPP_INCLUDE_DIRS}")
include_directories(BEFORE ${LIBRCPP_INCLUDE_DIRS})

find_package(VTK COMPONENTS
  CommonCore
  CommonDataModel
  IOLegacy
  IOXML
  vtksys
  QUIET
)

if (NOT VTK_FOUND)
  message("Skipping ${PROJECT_NAME}: ${VTK_NOT_FOUND_MESSAGE}")
  return ()
endif()
message (STATUS "VTK_VERSION: ${VTK_VERSION}")

add_library(vtk INTERFACE)
target_link_libraries(vtk INTERFACE ${VTK_LIBRARIES})

# List source files
set(RIOT_LIB_SOURCES 
  fascicleWriters.cpp fascicleReaders.cpp RcppExports.cpp tinyxml2.cpp
)
add_library(riot SHARED ${RIOT_LIB_SOURCES})

message (STATUS "R_LIBRARIES: ${R_LIBRARIES}")
target_link_libraries(riot vtk ${LIBR_LIBRARIES} ${R_LIBRARIES})

set_target_properties(riot PROPERTIES PREFIX "")
if(NOT WIN32) # Need to force .so on Mac, but Windows needs to be .dll
  set_target_properties(riot PROPERTIES SUFFIX ".so")
  install(TARGETS riot LIBRARY DESTINATION . )
else(NOT WIN32)
  install(TARGETS riot RUNTIME DESTINATION . )
endif(NOT WIN32)