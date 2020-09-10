#! /bin/sh

# Generate the Makevars file

# First find Rtools install folder
# RTOOLS_HOME=`${R_HOME}/bin${R_ARCH_BIN}/Rscript.exe -e "invisible(install.packages("pkgbuild")); invisible(pkgbuild::has_rtools()); cat(pkgbuild::rtools_path())"`

echo "PKG_CPPFLAGS = -Ivtk/include" > Makevars
echo "PKG_LIBS = \$(LAPACK_LIBS) \$(BLAS_LIBS) \$(FLIBS) -Lvtk/lib -lvtk_all -lwsock32 -lws2_32 -lgdi32 -lpsapi" >> Makevars
echo "" >> Makevars
echo ".PHONY: all ./vtk/lib/libvtk_all.a" >> Makevars
echo "" >> Makevars
echo "SOURCES = trackReaders.cpp RcppExports.cpp" >> Makevars
echo "" >> Makevars
echo "OBJECTS = \$(SOURCES:.cpp=.o)" >> Makevars
echo "" >> Makevars

OBJECTS_VTK_ALL="OBJECTS_VTK_ALL = `find vtk/lib -name "*.obj" | xargs`"
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
echo "	  rm -f \$(OBJECTS) *.dll *.exe" >> Makevars
echo "	  rm -fr vtk" >> Makevars
