#! /bin/sh

# Generate the Makevars file

VTK_VERSION=$1
MAKEVARS_EXTENSION=$2

echo "PKG_CPPFLAGS = \$(CPPFLAGS) -Ivtk/include/vtk-${VTK_VERSION}" > Makevars${MAKEVARS_EXTENSION}
echo "PKG_LIBS = -Lvtk/lib -lvtk" >> Makevars${MAKEVARS_EXTENSION}
echo "VTK_LIB = vtk/lib/libvtk.a" >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
echo "PKG_CXXFLAGS = \$(CXX_VISIBILITY)" >> Makevars${MAKEVARS_EXTENSION}
echo "PKG_CFLAGS = \$(C_VISIBILITY)" >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
TRIO_LIBS="BIN_LIBS = `find vtk-build -name "*.o"`"
echo ${TRIO_LIBS} >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
echo ".PHONY: all" >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
echo "all: \$(SHLIB)" >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
echo "\$(SHLIB): \$(VTK_LIB)" >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
echo "\$(VTK_LIB): \$(BIN_LIBS)" >> Makevars${MAKEVARS_EXTENSION}
echo "	\$(AR) rcs \$(VTK_LIB) \$(BIN_LIBS)" >> Makevars${MAKEVARS_EXTENSION}
echo "" >> Makevars${MAKEVARS_EXTENSION}
echo "clean:" >> Makevars${MAKEVARS_EXTENSION}
echo "	rm -f \$(BIN_LIBS) \$(SHLIB) \$(OBJECTS) \$(VTK_LIB)" >> Makevars${MAKEVARS_EXTENSION}
