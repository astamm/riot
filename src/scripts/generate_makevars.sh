#! /bin/sh

PKG_LIBS=$1

# Generate the Makevars file

echo "CXX_STD = CXX11" > Makevars
echo "PKG_CPPFLAGS = -I../inst/include" >> Makevars
echo ${PKG_LIBS} >> Makevars
echo "" >> Makevars
echo ".PHONY: all ./vtk\$(R_ARCH)/lib/libvtk.a" >> Makevars
echo "" >> Makevars
echo "SOURCES = fiberReaders.cpp RcppExports.cpp" >> Makevars
echo "" >> Makevars
echo "OBJECTS = \$(SOURCES:.cpp=.o)" >> Makevars
echo "" >> Makevars

OBJECTS_vtk="OBJECTS_vtk = `find vtk\$(R_ARCH)/lib -name "*.o" -o -name "*.obj" | xargs`"
echo ${OBJECTS_vtk} >> Makevars
echo "" >> Makevars
echo "all: \$(SHLIB)" >> Makevars
echo "" >> Makevars
echo "\$(SHLIB): ./vtk\$(R_ARCH)/lib/libvtk.a" >> Makevars
echo "" >> Makevars
echo "./vtk\$(R_ARCH)/lib/libvtk.a: \$(OBJECTS_vtk)" >> Makevars
echo "	  \$(AR) -crvs ./vtk\$(R_ARCH)/lib/libvtk.a \$(OBJECTS_vtk)" >> Makevars
echo "	  \$(RANLIB) \$@" >> Makevars
echo "" >> Makevars
echo "clean:" >> Makevars
echo "	  rm -f \$(OBJECTS) *.dll *.exe" >> Makevars
