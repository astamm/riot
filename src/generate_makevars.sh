#! /bin/sh

# Generate the Makevars file

# mkdir -p vtk
# mkdir -p vtk/include
# mkdir -p vtk/include/vtkdoubleconversion
# mkdir -p vtk/include/expat
# mkdir -p vtk/include/expat/lib
# mkdir -p vtk/include/vtkkwiml
# mkdir -p vtk/include/vtklz4
# mkdir -p vtk/include/vtklz4/lib
# mkdir -p vtk/include/vtklzma
# mkdir -p vtk/include/vtklzma/src
# mkdir -p vtk/include/vtklzma/src/liblzma/
# mkdir -p vtk/include/vtklzmasrc/liblzma/api
# mkdir -p vtk/include/vtksys
# mkdir -p vtk/include/vtkutf8
# mkdir -p vtk/include/vtkzlib

echo "PKG_CPPFLAGS = -Ivtk/include -Ivtk/lib" > Makevars
echo "PKG_LIBS = \$(LAPACK_LIBS) \$(BLAS_LIBS) \$(FLIBS) -Lvtk/lib -lvtk_all" >> Makevars
echo "" >> Makevars
echo ".PHONY: all ./vtk/lib/libvtk_all.a" >> Makevars
echo "" >> Makevars
echo "SOURCES = trackReaders.cpp RcppExports.cpp" >> Makevars
echo "" >> Makevars
echo "OBJECTS = \$(SOURCES:.cpp=.o)" >> Makevars
echo "" >> Makevars

# SOURCES_COMMON_CORE=`find ./vtk-src/Common/Core -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_CORE=${SOURCES_COMMON_CORE}" >> Makevars
# HEADERS_COMMON_CORE=`find ./vtk-src/Common/Core -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_CORE} vtk/include
#
# SOURCES_COMMON_DATAMODEL=`find ./vtk-src/Common/DataModel -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_DATAMODEL=${SOURCES_COMMON_DATAMODEL}" >> Makevars
# HEADERS_COMMON_DATAMODEL=`find ./vtk-src/Common/DataModel -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_DATAMODEL} vtk/include
#
# SOURCES_COMMON_EXECUTIONMODEL=`find ./vtk-src/Common/ExecutionModel -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_EXECUTIONMODEL=${SOURCES_COMMON_EXECUTIONMODEL}" >> Makevars
# HEADERS_COMMON_EXECUTIONMODEL=`find ./vtk-src/Common/ExecutionModel -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_EXECUTIONMODEL} vtk/include
#
# SOURCES_COMMON_MATH=`find ./vtk-src/Common/Math -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_MATH=${SOURCES_COMMON_MATH}" >> Makevars
# HEADERS_COMMON_MATH=`find ./vtk-src/Common/Math -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_MATH} vtk/include
#
# SOURCES_COMMON_MISC=`find ./vtk-src/Common/Misc -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_MISC=${SOURCES_COMMON_MISC}" >> Makevars
# HEADERS_COMMON_MISC=`find ./vtk-src/Common/Misc -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_MISC} vtk/include
#
# SOURCES_COMMON_SYSTEM=`find ./vtk-src/Common/System -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_SYSTEM=${SOURCES_COMMON_SYSTEM}" >> Makevars
# HEADERS_COMMON_SYSTEM=`find ./vtk-src/Common/System -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_SYSTEM} vtk/include
#
# SOURCES_COMMON_TRANSFORMS=`find ./vtk-src/Common/Transforms -type f -name "*.cxx" | xargs`
# echo "SOURCES_COMMON_TRANSFORMS=${SOURCES_COMMON_TRANSFORMS}" >> Makevars
# HEADERS_COMMON_TRANSFORMS=`find ./vtk-src/Common/Transforms -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_COMMON_TRANSFORMS} vtk/include
#
# SOURCES_IO_CORE=`find ./vtk-src/IO/Core -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_CORE=${SOURCES_IO_CORE}" >> Makevars
# HEADERS_IO_CORE=`find ./vtk-src/IO/Core -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_CORE} vtk/include
#
# SOURCES_IO_LEGACY=`find ./vtk-src/IO/Legacy -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_LEGACY=${SOURCES_IO_LEGACY}" >> Makevars
# HEADERS_IO_LEGACY=`find ./vtk-src/IO/Legacy -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_LEGACY} vtk/include
#
# SOURCES_IO_XML=`find ./vtk-src/IO/XML -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XML=${SOURCES_IO_XML}" >> Makevars
# HEADERS_IO_XML=`find ./vtk-src/IO/XML -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XML} vtk/include
#
# SOURCES_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
# HEADERS_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include
#
# # doubleconversion
# SOURCES_DOUBLECONVERSION=`find ./vtk-src/ThirdParty/doubleconversion/vtkdoubleconversion/double-conversion -type f -name "*.cc" | xargs`
# echo "SOURCES_DOUBLECONVERSION=${SOURCES_DOUBLECONVERSION}" >> Makevars
# HEADERS_DOUBLECONVERSION=`find ./vtk-src/ThirdParty/doubleconversion/vtkdoubleconversion/double-conversion -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_DOUBLECONVERSION} vtk/include/vtkdoubleconversion
#
# # expat
# SOURCES_EXPAT=`find ./vtk-src/IO/XMLParser -type f -name "*.c" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
# HEADERS_IO_XMLPARSER=`find ./vtk-src/ThirdParty/expat/vtkexpat/lib -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include/vtkexpat/lib
#
# # kwiml (header-only)
# HEADERS_KWIML=`find ./vtk-src/Utilities/KWIML/vtkkwiml -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include/vtkkwiml
#
# # loguru
# SOURCES_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
#
# # lz4
# SOURCES_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
# HEADERS_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include
#
# # lzma
# SOURCES_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
# HEADERS_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include
#
# # sys
# SOURCES_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
# HEADERS_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include
#
# # zlib
# SOURCES_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.cxx" | xargs`
# echo "SOURCES_IO_XMLPARSER=${SOURCES_IO_XMLPARSER}" >> Makevars
# HEADERS_IO_XMLPARSER=`find ./vtk-src/IO/XMLParser -type f -name "*.h" -o -name "*.hxx" -o -name "*.txx" | xargs`
# cp ${HEADERS_IO_XMLPARSER} vtk/include

OBJECTS_VTK_ALL="OBJECTS_VTK_ALL = `find vtk-build -name "*.o" -o -name "*.obj" | xargs`"
echo ${OBJECTS_VTK_ALL} >> Makevars
echo "" >> Makevars
echo "all: \$(SHLIB)" >> Makevars
echo "" >> Makevars
echo "\$(SHLIB): ./vtk/lib/libvtk_all.a" >> Makevars
echo "" >> Makevars
echo "./vtk/lib/libvtk_all.a: \$(OBJECTS_VTK_ALL)" >> Makevars
echo "	  \$(AR) -crvs ./vtk/lib/libvtk_all.a \$(OBJECTS_VTK_ALL)" >> Makevars
echo "	  \$(RANLIB) \$@" >> Makevars
echo "" >> Makevars
echo "clean:" >> Makevars
echo "	  rm -f \$(OBJECTS_VTK_ALL) *.dll *.exe vtk/lib/libvtk.a" >> Makevars
echo "	  rm -fr vtk-build" >> Makevars
