
## -*- mode: autoconf; autoconf-indentation: 4; -*-
##
##  fiberIO configure.ac
##
##  fiberIO -- An Input/Output Module for Fiber Analysis in R
##
##  Copyright (C) 2014-2022  Dirk Eddelbuettel
##
## This file is licensed under the GPL-2 or later just like most of my
## Open Source code, and is granted an exemption (should it be needed)
## for inclusion into fiberIO

# require at least autoconf 2.61
AC_PREREQ([2.69])
AC_INIT([fiberIO],[2.0.0])

## Set R_HOME, respecting an environment variable if set
: ${R_HOME=$(R RHOME)}
if test -z "${R_HOME}"; then
   AC_MSG_ERROR([Could not determine R_HOME.])
fi

CXX=`"${R_HOME}/bin/R" CMD config CXX`
if test -z "${CXX}"; then
    AC_MSG_ERROR([No C++ compiler available])
fi
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`
CPPFLAGS=`"${R_HOME}/bin/R" CMD config CPPFLAGS`
CXX11FLAGS=`"${R_HOME}/bin/R" CMD config CXX11FLAGS`
AC_LANG(C++)
AC_REQUIRE_CPP
AC_PROG_CXX

## Default to build from source
need_to_build="yes"

## But: Can we use pkg-config?
AC_PATH_PROG(have_pkg_config, pkg-config, no)
## If yes, also check for whether pkg-config knows vtk
if test x"${have_pkg_config}" != x"no"; then
    AC_MSG_CHECKING([if pkg-config knows VTK])
    if pkg-config --exists vtk; then
        AC_MSG_RESULT([yes])
        vtk_include=$(pkg-config --cflags vtk)
        vtk_libs=$(pkg-config --libs vtk)
        AC_SUBST([VTK_INCLUDE], "${vtk_include}")
        AC_SUBST([VTK_LIBS],    "${vtk_libs}")
    else
        AC_MSG_RESULT([no])
        have_pkg_config="no"
    fi
fi

## And if we have pkg-config, use it to test minimal version
if test x"${have_pkg_config}" != x"no"; then
    AC_MSG_CHECKING([for pkg-config checking VTK version])
    if pkg-config --atleast-version=9.0.0 vtk; then
        AC_MSG_RESULT([>= 9.0.0])
        need_to_build="no"
    else
        AC_MSG_RESULT([insufficient: VTK 9.0.0 or later is preferred.])
    fi
fi

## So do we need to build
if test x"${need_to_build}" != x"no"; then
    machine=`"${R_HOME}/bin/Rscript" -e 'cat(Sys.info()[["machine"]])'`
    AC_MSG_RESULT([using VTK via local cmake build on ${machine} ])
    tools/cmake_call.sh
    vtk_include="-Ivtk/include/vtk"
    vtk_libs="-Lvtk/lib -lvtkCommonCore -lvtkCommonDataModel -lvtkCommonExecutionModel -lvtkCommonMath -lvtkCommonMisc -lvtkCommonSystem -lvtkCommonTransforms -lvtkdoubleconversion -lvtkexpat -lvtkIOCore -lvtkIOLegacy -lvtkIOXML -lvtkIOXMLParser -lvtkkissfft -lvtklz4 -lvtklzma -lvtkpugixml -lvtksys -lvtkzlib"
fi

## Now use all the values
AC_SUBST([VTK_CPPFLAGS],["$vtk_include"])
AC_SUBST([VTK_LIBS],["$vtk_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
