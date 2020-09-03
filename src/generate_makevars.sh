#! /bin/sh

# Generate the Makevars file

echo "PKG_CPPFLAGS = \$(CPPFLAGS) -Ivtk/include" > Makevars
echo "PKG_LIBS = vtk/lib/libvtk.a" >> Makevars
echo "" >> Makevars
echo "PKG_CXXFLAGS = \$(CXX_VISIBILITY)" >> Makevars
echo "PKG_CFLAGS = \$(C_VISIBILITY) \$(subst 64,-D__USE_MINGW_ANSI_STDIO,\$(subst 32,64,\$(WIN)))" >> Makevars
echo "" >> Makevars
echo "VTK_LIBS = `find vtk/lib -type f -name "*.o" -o -name "*.obj" | xargs`" >> Makevars
echo "" >> Makevars
echo ".PHONY: all" >> Makevars
echo "" >> Makevars
echo "all: \$(SHLIB)" >> Makevars
echo "" >> Makevars
echo "\$(SHLIB): \$(PKG_LIBS)" >> Makevars
echo "" >> Makevars
echo "\$(PKG_LIBS): \$(VTK_LIBS)" >> Makevars
echo "	\$(AR) rcs \$(PKG_LIBS) \$(VTK_LIBS)" >> Makevars
echo "" >> Makevars
echo "clean:" >> Makevars
echo "	rm -f \$(VTK_LIBS) \$(SHLIB) \$(OBJECTS) \$(PKG_LIBS)" >> Makevars
