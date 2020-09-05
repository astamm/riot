#! /bin/sh

echo "PKG_CPPFLAGS = -Ivtk/include/vtk-9.0" > Makevars
VTK_LIBS=`find vtk/lib -type f -name "*.a" | xargs`
echo "PKG_LIBS = ${VTK_LIBS}" >> Makevars

# # Generate the Makevars file
# VTK_LIBNAME=$1
#
# echo "PKG_CPPFLAGS = \$(CPPFLAGS) -Ivtk/include" > Makevars
# echo "PKG_LIBS = vtk/lib/${VTK_LIBNAME}" >> Makevars
# echo "" >> Makevars
# echo "PKG_CXXFLAGS = \$(CXX_VISIBILITY)" >> Makevars
# echo "PKG_CFLAGS = \$(C_VISIBILITY)" >> Makevars
# echo "" >> Makevars
# TRIO_LIBS="VTK_LIBS = `find vtk/lib -type f -name "*.o" -o -name "*.obj" | xargs`"
# echo ${TRIO_LIBS} >> Makevars
# echo "" >> Makevars
# echo ".PHONY: all" >> Makevars
# echo "" >> Makevars
# echo "all: \$(SHLIB)" >> Makevars
# echo "" >> Makevars
# echo "\$(SHLIB): \$(PKG_LIBS)" >> Makevars
# echo "" >> Makevars
# echo "\$(PKG_LIBS): \$(VTK_LIBS)" >> Makevars
# echo "	\$(AR) rcs \$(PKG_LIBS) \$(VTK_LIBS)" >> Makevars
# echo "" >> Makevars
# echo "clean:" >> Makevars
# echo "	rm -f \$(VTK_LIBS) \$(SHLIB) \$(OBJECTS) \$(PKG_LIBS)" >> Makevars
