## -*- mode: autoconf; autoconf-indentation: 4; -*-
##
##  riot configure.ac
##
##  riot -- R input/output interface to tractography data
##
##  Copyright (C) 2025 Aymeric Stamm

# require at least autoconf 2.69
AC_PREREQ([2.69])
AC_INIT([riot],[1.1.1])

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

## 1. Can we use pkg-config?
AC_PATH_PROG(have_pkg_config, pkg-config, no)
## If yes, also check for whether pkg-config knows vtk
if test x"${have_pkg_config}" != x"no"; then
    AC_MSG_CHECKING([if pkg-config knows VTK])
    if pkg-config --exists vtk; then
        AC_MSG_RESULT([yes])
        ## Since vtk has been found, test for minimal version requirement
        AC_MSG_CHECKING([for pkg-config checking VTK version])
        if pkg-config --atleast-version=9.5.0 vtk; then
            AC_MSG_RESULT([>= 9.5.0])
            vtk_include=$(pkg-config --cflags vtk)
            vtk_libs=$(pkg-config --libs vtk)
        else
            AC_MSG_RESULT([insufficient: VTK 9.5.0 or later is preferred.])
        fi
    else
        AC_MSG_RESULT([no])
    fi
fi

## 2. Can we use brew?
AC_PATH_PROG(have_brew, brew, no)
if test x"${have_brew}" != x"no"; then
    AC_MSG_CHECKING([if brew knows VTK])
    if brew --prefix vtk > /dev/null 2>&1; then
        AC_MSG_RESULT([yes])
        vtk_include="-I$(brew --prefix vtk)/include/vtk-9.5"
        vtk_libs="-L$(brew --prefix vtk)/lib -lvtkIOCellGrid-9.5 -lvtkIOCore-9.5 -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkIOXMLParser-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtkCommonExecutionModel-9.5 -lvtkCommonMath-9.5 -lvtkCommonMisc-9.5 -lvtkCommonSystem-9.5 -lvtkCommonTransforms-9.5 -lvtkFiltersCellGrid-9.5 -lvtkFiltersCore-9.5 -lvtkFiltersReduction-9.5 -lvtkdoubleconversion-9.5 -lvtkexpat-9.5 -lvtkkissfft-9.5 -lvtklz4-9.5 -lvtklzma-9.5 -lvtkpugixml-9.5 -lvtksys-9.5 -lvtktoken-9.5 -lvtkzlib-9.5"
    else
        AC_MSG_RESULT([no])
    fi
fi

else
    AC_MSG_RESULT([pkg-config not found])
    AC_MSG_RESULT([will try to find VTK manually through environment variable VTK_DIR])
    # 2. Try to use VTK_DIR
    if test -n "${VTK_DIR}"; then
        AC_MSG_CHECKING([for VTK_DIR at ${VTK_DIR}])
        if test -d "${VTK_DIR}/include/vtk-9.5"; then
            AC_MSG_RESULT([found])
            vtk_include="-I${VTK_DIR}/include/vtk-9.5"
            vtk_libs="-L${VTK_DIR}/lib -lvtkIOCellGrid-9.5 -lvtkIOCore-9.5 -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkIOXMLParser-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtkCommonExecutionModel-9.5 -lvtkCommonMath-9.5 -lvtkCommonMisc-9.5 -lvtkCommonSystem-9.5 -lvtkCommonTransforms-9.5 -lvtkFiltersCellGrid-9.5 -lvtkFiltersCore-9.5 -lvtkFiltersReduction-9.5 -lvtkdoubleconversion-9.5 -lvtkexpat-9.5 -lvtkkissfft-9.5 -lvtklz4-9.5 -lvtklzma-9.5 -lvtkpugixml-9.5 -lvtksys-9.5 -lvtktoken-9.5 -lvtkzlib-9.5"
        else
            AC_MSG_RESULT([not found])
        fi
    else
        AC_MSG_ERROR([VTK_DIR not set])
    fi
fi

## Now use all the values
AC_SUBST([VTK_CPPFLAGS],["$vtk_include"])
AC_SUBST([VTK_LIBS],["$vtk_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
