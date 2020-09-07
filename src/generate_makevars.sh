#! /bin/sh

# Generate the Makevars file

echo "PKG_CPPFLAGS = -Ivtk/include -Ivtk/lib" > Makevars
echo "PKG_LIBS = -Lvtk/lib -lvtk_all" >> Makevars
echo "" >> Makevars
VTK_OBJECTS="OBJECTS_VTK_ALL = `find vtk/lib -name "*.o" -o -name "*.obj" | xargs`"
echo ${VTK_OBJECTS} >> Makevars
echo "" >> Makevars
echo ".PHONY: all" >> Makevars
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
