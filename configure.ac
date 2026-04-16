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

## ── Minimum required VTK version ─────────────────────────────────────────────
## Change this single variable to raise or lower the requirement.
VTK_MIN_VERSION="9.1.0"

## Helper: given a prefix, find the VTK include dir and set:
##   vtk_version_suffix  – e.g. "9.5" (versioned) or "" (unversioned)
##   vtk_include_dir     – full path to the include directory
## Returns 0 if a qualifying installation is found, 1 otherwise.
vtk_detect_from_prefix() {
    _prefix="$1"
    _min_suffix="$(echo "${VTK_MIN_VERSION}" | sed 's/\([[0-9]]*\)\.\([[0-9]]*\)\..*/\1.\2/')"

    ## ── Try versioned directories first (vtk-X.Y) ────────────────────────────
    _found_dir="$(find "${_prefix}/include" -maxdepth 1 -name "vtk-*" -type d 2>/dev/null \
        | sort -V | tail -1)"
    if test -n "${_found_dir}"; then
        _suffix="$(basename "${_found_dir}" | sed 's/^vtk-//')"
        if printf '%s\n%s\n' "${_min_suffix}" "${_suffix}" | sort -V | head -1 \
                | grep -qx "${_min_suffix}"; then
            vtk_version_suffix="${_suffix}"
            vtk_include_dir="${_found_dir}"
            return 0
        fi
        ## Found a versioned dir but it is too old — do not fall through to the
        ## unversioned check, as that would risk using an even older install.
        return 1
    fi

    ## ── Fall back to unversioned vtk/ directory ───────────────────────────────
    if test -d "${_prefix}/include/vtk"; then
        _ver_header="${_prefix}/include/vtk/vtkVersion.h"
        if test -f "${_ver_header}"; then
            _major="$(grep '#define VTK_MAJOR_VERSION' "${_ver_header}" | awk '{print $3}')"
            _minor="$(grep '#define VTK_MINOR_VERSION' "${_ver_header}" | awk '{print $3}')"
            if test -n "${_major}" && test -n "${_minor}"; then
                _detected="${_major}.${_minor}"
                if printf '%s\n%s\n' "${_min_suffix}" "${_detected}" | sort -V | head -1 \
                        | grep -qx "${_min_suffix}"; then
                    vtk_version_suffix=""
                    vtk_include_dir="${_prefix}/include/vtk"
                    return 0
                fi
                ## Unversioned install is too old
                return 1
            fi
        fi
        ## Cannot read version header — accept with a warning
        AC_MSG_WARN([Could not determine VTK version from ${_ver_header}; proceeding anyway])
        vtk_version_suffix=""
        vtk_include_dir="${_prefix}/include/vtk"
        return 0
    fi

    return 1
}

## Helper: given a base prefix, build vtk_include and vtk_libs using the
## already-set vtk_version_suffix and vtk_include_dir variables.
## Usage: vtk_build_flags <lib_prefix> [rpath]
vtk_build_flags() {
    _lib_prefix="$1"
    _rpath="$2"
    ## Libraries are named -lvtkFoo-X.Y when suffixed, -lvtkFoo otherwise.
    if test -n "${vtk_version_suffix}"; then
        _s="-${vtk_version_suffix}"
    else
        _s=""
    fi
    vtk_include="-isystem${vtk_include_dir}"
    vtk_libs="-L${_lib_prefix}/lib"
    vtk_libs="${vtk_libs} -lvtkIOLegacy${_s}"
    vtk_libs="${vtk_libs} -lvtkIOXML${_s}"
    vtk_libs="${vtk_libs} -lvtkCommonCore${_s}"
    vtk_libs="${vtk_libs} -lvtkCommonDataModel${_s}"
    vtk_libs="${vtk_libs} -lvtksys${_s}"
    if test -n "${_rpath}"; then
        vtk_libs="${vtk_libs} -Wl,-rpath,${_rpath}"
    fi
}

vtk_found="no"

## ── 1. VTK_DIR (user-supplied, highest priority) ──────────────────────────────
AC_MSG_CHECKING([if a custom VTK installation is specified via VTK_DIR])
if test -n "${VTK_DIR}"; then
    AC_MSG_RESULT([found VTK_DIR at ${VTK_DIR}])
    AC_MSG_CHECKING([if VTK_DIR satisfies the minimum version requirement (>= ${VTK_MIN_VERSION})])
    if vtk_detect_from_prefix "${VTK_DIR}"; then
        if test -n "${vtk_version_suffix}"; then
            AC_MSG_RESULT([yes (vtk-${vtk_version_suffix})])
        else
            AC_MSG_RESULT([yes (unversioned)])
        fi
        vtk_build_flags "${VTK_DIR}" "${VTK_DIR}/lib"
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
                AC_MSG_CHECKING([if Homebrew VTK satisfies the minimum version requirement (>= ${VTK_MIN_VERSION})])
                if vtk_detect_from_prefix "${brew_vtk_prefix}"; then
                    if test -n "${vtk_version_suffix}"; then
                        AC_MSG_RESULT([yes (vtk-${vtk_version_suffix})])
                    else
                        AC_MSG_RESULT([yes (unversioned)])
                    fi
                    vtk_build_flags "${brew_vtk_prefix}"
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
                AC_MSG_CHECKING([if pkg-config VTK (${vtk_pc_name}) satisfies the minimum version requirement (>= ${VTK_MIN_VERSION})])
                if pkg-config --atleast-version="${VTK_MIN_VERSION}" "${vtk_pc_name}"; then
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
        ## Try well-known system prefix paths (covers manually installed or
        ## distro-packaged VTK that is not registered with pkg-config).
        for _base in /usr /usr/local; do
            if vtk_detect_from_prefix "${_base}"; then
                AC_MSG_NOTICE([found VTK headers at ${vtk_include_dir}])
                vtk_build_flags "${_base}" "${_base}/lib"
                vtk_found="yes"
                break
            fi
        done

        ## If still not found, emit a distro-aware installation hint
        if test x"${vtk_found}" = x"no"; then
            vtk_install_hint="Please install VTK >= ${VTK_MIN_VERSION} development libraries."
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
        AC_MSG_ERROR([Cannot find a suitable VTK installation (>= ${VTK_MIN_VERSION}). Please set the VTK_DIR environment variable to your VTK install prefix, or install VTK via your system package manager.])
    fi
fi

## Now use all the values
AC_SUBST([VTK_CPPFLAGS],["$vtk_include"])
AC_SUBST([VTK_LIBS],["$vtk_libs"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
