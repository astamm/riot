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

AC_MSG_CHECKING([if a custom VTK installation is specified via VTK_DIR])
if test -n "${VTK_DIR}"; then
    # 1. If VTK_DIR is set (most probably in .Renviron), try to use it
    AC_MSG_RESULT([found VTK_DIR at ${VTK_DIR}])
    AC_MSG_CHECKING([if minimal version requirement is met (>= 9.5.0)])
    if test -d "${VTK_DIR}/include/vtk-9.5"; then
        AC_MSG_RESULT([yes])
        vtk_include="-I${VTK_DIR}/include/vtk-9.5"
        vtk_libs="-L${brew_prefix}/lib -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtksys-9.5"
    else
        AC_MSG_RESULT([no])
    fi
else
    AC_MSG_RESULT([not found])
    # Try Homebrew if available
    AC_PATH_PROG(have_brew, brew, no)
    vtk_brew_failed="yes"
    if test x"${have_brew}" != x"no"; then
        AC_MSG_CHECKING([if brew knows VTK])
        if brew --prefix vtk > /dev/null 2>&1; then
            AC_MSG_RESULT([yes])
            AC_MSG_CHECKING([if minimal version requirement is met (>= 9.5.0)])
            brew_prefix="$(brew --prefix vtk)"
            # checking for an include dir named vtk-9.5
            if test -d "${brew_prefix}/include/vtk-9.5"; then
                AC_MSG_RESULT([yes])
                vtk_include="-I${brew_prefix}/include/vtk-9.5"
                vtk_libs="-L${brew_prefix}/lib -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtksys-9.5"
                vtk_brew_failed="no"
            else
                AC_MSG_RESULT([no])
            fi
        else
            AC_MSG_RESULT([no])
        fi
    fi

    # If brew failed, try pkg-config
    if test x"${vtk_brew_failed}" = x"yes"; then
        AC_PATH_PROG(have_pkg_config, pkg-config, no)
        if test x"${have_pkg_config}" != x"no"; then
            AC_MSG_CHECKING([if pkg-config knows VTK])
            if pkg-config --exists vtk; then
                AC_MSG_RESULT([found via pkg-config])
                AC_MSG_CHECKING([if minimal version requirement is met])
                if pkg-config --atleast-version=9.5.0 vtk; then
                    AC_MSG_RESULT([>= 9.5.0])
                    vtk_include=$(pkg-config --cflags vtk)
                    vtk_libs=$(pkg-config --libs vtk)
                else
                    AC_MSG_RESULT([no])
                    AC_MSG_ERROR([VTK 9.5.0 or later is required])
                fi
            else
                AC_MSG_RESULT([no])
                AC_MSG_ERROR([Cannot find suitable VTK installation, aborting. Please set VTK_DIR environment variable to point to your VTK installation.])
            fi
        else
            AC_MSG_ERROR([Cannot find suitable VTK installation, aborting. Please set VTK_DIR environment variable to point to your VTK installation.])
        fi
    fi
fi

## Now use all the values
AC_SUBST([VTK_CPPFLAGS],["$vtk_include"])
AC_SUBST([VTK_LIBS],["$vtk_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
