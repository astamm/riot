#! /bin/sh

# Generate the Makevars file

VTK_VERSION=$1

echo "PKG_CPPFLAGS = \$(CPPFLAGS) -Ivtk/include/vtk-${VTK_VERSION}" > Makevars
echo "PKG_LIBS = -Lvtk/lib -lvtk" >> Makevars
echo "VTK_LIB = vtk/lib/libvtk.a" >> Makevars
echo "" >> Makevars
echo "PKG_CXXFLAGS = \$(CXX_VISIBILITY)" >> Makevars
echo "PKG_CFLAGS = \$(C_VISIBILITY)" >> Makevars
echo "" >> Makevars
TRIO_LIBS="BIN_LIBS = `find vtk-build -name "*.o"`"
echo ${TRIO_LIBS} >> Makevars
echo "" >> Makevars
echo ".PHONY: all" >> Makevars
echo "" >> Makevars
echo "all: \$(SHLIB)" >> Makevars
echo "" >> Makevars
echo "\$(SHLIB): \$(VTK_LIB)" >> Makevars
echo "" >> Makevars
echo "\$(VTK_LIB): \$(BIN_LIBS)" >> Makevars
echo "	\$(AR) rcs \$(VTK_LIB) \$(BIN_LIBS)" >> Makevars
echo "" >> Makevars
echo "clean:" >> Makevars
echo "	rm -f \$(BIN_LIBS) \$(SHLIB) \$(OBJECTS) \$(VTK_LIB)" >> Makevars
