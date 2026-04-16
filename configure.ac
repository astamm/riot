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

## Helper: set vtk_include/vtk_libs from a known VTK install prefix
## Usage: call with prefix and version suffix, e.g. vtk_set_from_prefix /usr/local 9.5
vtk_found="no"

## ── 1. VTK_DIR (user-supplied, highest priority) ──────────────────────────────
AC_MSG_CHECKING([if a custom VTK installation is specified via VTK_DIR])
if test -n "${VTK_DIR}"; then
    AC_MSG_RESULT([found VTK_DIR at ${VTK_DIR}])
    AC_MSG_CHECKING([if VTK_DIR satisfies the minimum version requirement (>= 9.5.0)])
    if test -d "${VTK_DIR}/include/vtk-9.5"; then
        AC_MSG_RESULT([yes])
        vtk_include="-isystem${VTK_DIR}/include/vtk-9.5"
        vtk_libs="-L${VTK_DIR}/lib -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtksys-9.5"
        vtk_libs="${vtk_libs} -Wl,-rpath,${VTK_DIR}/lib"
        vtk_found="yes"
    else
        AC_MSG_RESULT([no — falling back to automatic detection])
    fi
else
    AC_MSG_RESULT([not set])
fi

## ── 2. Platform-specific + pkg-config discovery ───────────────────────────────
if test x"${vtk_found}" = x"no"; then
    ## Detect the OS
    os_type="$(uname -s)"

    ## ── 2a. macOS: try Homebrew ───────────────────────────────────────────────
    if test x"${os_type}" = x"Darwin"; then
        AC_PATH_PROG([have_brew], [brew], [no])
        if test x"${have_brew}" != x"no"; then
            AC_MSG_CHECKING([if Homebrew has VTK])
            if brew --prefix vtk > /dev/null 2>&1; then
                brew_vtk_prefix="$(brew --prefix vtk)"
                AC_MSG_RESULT([yes, at ${brew_vtk_prefix}])
                AC_MSG_CHECKING([if Homebrew VTK satisfies the minimum version requirement (>= 9.5.0)])
                if test -d "${brew_vtk_prefix}/include/vtk-9.5"; then
                    AC_MSG_RESULT([yes])
                    vtk_include="-isystem${brew_vtk_prefix}/include/vtk-9.5"
                    vtk_libs="-L${brew_vtk_prefix}/lib -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtksys-9.5"
                    vtk_found="yes"
                else
                    AC_MSG_RESULT([no])
                    AC_MSG_WARN([Homebrew VTK is too old; run: brew upgrade vtk])
                fi
            else
                AC_MSG_RESULT([no])
            fi
        fi
    fi

    ## ── 2b. pkg-config (macOS and Linux) ─────────────────────────────────────
    if test x"${vtk_found}" = x"no"; then
        AC_PATH_PROG([have_pkg_config], [pkg-config], [no])
        if test x"${have_pkg_config}" != x"no"; then
            ## pkg-config may use names like "vtk", "vtk-9.5", "VTK", etc.
            vtk_pc_name=""
            for _name in vtk vtk-9.5 vtk9 VTK; do
                if pkg-config --exists "${_name}" 2>/dev/null; then
                    vtk_pc_name="${_name}"
                    break
                fi
            done

            if test -n "${vtk_pc_name}"; then
                AC_MSG_CHECKING([if pkg-config VTK (${vtk_pc_name}) satisfies the minimum version requirement (>= 9.5.0)])
                if pkg-config --atleast-version=9.5.0 "${vtk_pc_name}"; then
                    AC_MSG_RESULT([yes])
                    vtk_include="$(pkg-config --cflags ${vtk_pc_name} | sed 's/-I/-isystem/g')"
                    vtk_libs="$(pkg-config --libs ${vtk_pc_name})"
                    vtk_found="yes"
                else
                    AC_MSG_RESULT([no — installed version is too old])
                fi
            else
                AC_MSG_NOTICE([pkg-config could not find VTK])
            fi
        else
            AC_MSG_NOTICE([pkg-config not available])
        fi
    fi

    ## ── 2c. Linux: distro-specific fallback ──────────────────────────────────
    if test x"${vtk_found}" = x"no" && test x"${os_type}" = x"Linux"; then
        ## Try well-known system include paths first (covers manually installed
        ## or distro-packaged VTK that is not registered with pkg-config).
        for _candidate in \
                /usr/include/vtk-9.5 \
                /usr/local/include/vtk-9.5 \
                /usr/include/vtk \
                /usr/local/include/vtk; do
            if test -d "${_candidate}"; then
                _vtk_base="$(echo "${_candidate}" | sed 's|/include/.*||')"
                AC_MSG_NOTICE([found VTK headers at ${_candidate}])
                vtk_include="-isystem${_candidate}"
                vtk_libs="-L${_vtk_base}/lib -lvtkIOLegacy-9.5 -lvtkIOXML-9.5 -lvtkCommonCore-9.5 -lvtkCommonDataModel-9.5 -lvtksys-9.5"
                vtk_libs="${vtk_libs} -Wl,-rpath,${_vtk_base}/lib"
                vtk_found="yes"
                break
            fi
        done

        ## If still not found, emit a distro-aware installation hint
        if test x"${vtk_found}" = x"no"; then
            vtk_install_hint="Please install VTK >= 9.5.0 development libraries."
            if test -f /etc/debian_version || (command -v apt-get > /dev/null 2>&1); then
                vtk_install_hint="${vtk_install_hint} On Debian/Ubuntu: sudo apt-get install libvtk9-dev"
            elif test -f /etc/fedora-release || (command -v dnf > /dev/null 2>&1); then
                vtk_install_hint="${vtk_install_hint} On Fedora: sudo dnf install vtk-devel"
            elif test -f /etc/redhat-release || (command -v yum > /dev/null 2>&1); then
                vtk_install_hint="${vtk_install_hint} On RHEL/CentOS: sudo yum install vtk-devel (EPEL may be required)"
            elif test -f /etc/SuSE-release || (command -v zypper > /dev/null 2>&1); then
                vtk_install_hint="${vtk_install_hint} On openSUSE: sudo zypper install vtk-devel"
            elif (command -v pacman > /dev/null 2>&1); then
                vtk_install_hint="${vtk_install_hint} On Arch Linux: sudo pacman -S vtk"
            fi
            AC_MSG_ERROR([${vtk_install_hint}])
        fi
    fi

    ## ── 2d. Generic fallback error (non-Linux, non-macOS or macOS without brew/pkg-config) ──
    if test x"${vtk_found}" = x"no"; then
        AC_MSG_ERROR([Cannot find a suitable VTK installation (>= 9.5.0). Please set the VTK_DIR environment variable to your VTK install prefix, or install VTK via your system package manager.])
    fi
fi

## Now use all the values
AC_SUBST([VTK_CPPFLAGS],["$vtk_include"])
AC_SUBST([VTK_LIBS],["$vtk_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
