# src/install.libs.R -- called by R CMD INSTALL instead of the default
# shared-object copy step.  It copies riot.dll and all required VTK DLLs
# (including transitive runtime dependencies) into the final installation
# directory.
#
# Environment variables provided by R CMD INSTALL:
#   R_PACKAGE_NAME   - "riot"
#   R_PACKAGE_SOURCE - path to the package source
#   R_PACKAGE_DIR    - path to the target installation directory
#   R_ARCH           - arch suffix, e.g. "/x64" on 64-bit Windows
#   SHLIB_EXT        - shared library extension, e.g. ".dll"
#   WINDOWS          - TRUE on Windows

# 1. Copy the package DLL itself (the default behaviour we must replicate)
dest <- file.path(R_PACKAGE_DIR, paste0("libs", R_ARCH))
dir.create(dest, recursive = TRUE, showWarnings = FALSE)

dll <- paste0(R_PACKAGE_NAME, SHLIB_EXT)
file.copy(dll, dest, overwrite = TRUE)
message("Installed: ", dll)

# 2. On Windows, also copy VTK DLLs so they are found at runtime
if (WINDOWS) {
  # Read VTK bin dir written by configure.win
  cfg_file <- file.path(R_PACKAGE_SOURCE, "src", "vtk_config")
  if (!file.exists(cfg_file)) {
    stop("src/vtk_config not found -- was configure.win run?")
  }

  # Parse shell-style KEY=VALUE file (read.dcf is not suitable here)
  lines <- readLines(cfg_file)
  cfg <- setNames(
    sub("^[^=]+=", "", lines),
    sub("=.*$", "", lines)
  )

  vtk_bin_dir <- cfg[["VTK_BIN_DIR"]]

  # ---------------------------------------------------------------------------
  # Helper: use objdump to get the direct DLL dependencies of a single DLL.
  # Returns lowercase DLL names only (filters out Windows system DLLs).
  # ---------------------------------------------------------------------------
  dll_imports <- function(dll_path) {
    objdump <- Sys.which("objdump")
    if (nchar(objdump) == 0L) {
      return(character(0))
    }
    out <- tryCatch(
      system2(
        objdump,
        args = c("-p", shQuote(dll_path)),
        stdout = TRUE,
        stderr = FALSE
      ),
      error = function(e) character(0)
    )
    # Lines like:  "	DLL Name: libfoo.dll"
    lines <- grep("DLL Name:", out, value = TRUE, ignore.case = TRUE)
    tolower(trimws(sub(".*DLL Name:\\s*", "", lines, ignore.case = TRUE)))
  }

  # Windows system DLLs that ship with every Windows installation and must
  # NOT be bundled with the package.
  system_dll_pattern <- paste0(
    "^(kernel32|user32|gdi32|advapi32|shell32|ole32|oleaut32|ntdll|",
    "msvcrt|ucrtbase|vcruntime|msvcp|api-ms-win|ext-ms-win|",
    "winmm|winspool|comdlg32|comctl32|ws2_32|crypt32|secur32|",
    "rpcrt4|shlwapi|version|dbghelp|psapi|setupapi|cfgmgr32|",
    "imm32|netapi32|userenv|wtsapi32|iphlpapi|dnsapi|mswsock)\\.dll$"
  )
  is_system_dll <- function(name) {
    grepl(system_dll_pattern, name, perl = TRUE, ignore.case = TRUE)
  }

  # ---------------------------------------------------------------------------
  # Recursively collect all non-system DLLs needed by `start_dll`, searching
  # `search_dirs` for each dependency.
  # ---------------------------------------------------------------------------
  collect_dlls <- function(start_dll, search_dirs) {
    visited <- character(0) # DLL names already resolved
    resolved <- character(0) # full paths of DLLs to copy
    queue <- start_dll # full paths to inspect next

    while (length(queue) > 0L) {
      current <- queue[[1L]]
      queue <- queue[-1L]
      name <- tolower(basename(current))
      if (name %in% visited) {
        next
      }
      visited <- c(visited, name)

      deps <- dll_imports(current)
      for (dep in deps) {
        if (dep %in% visited || is_system_dll(dep)) {
          next
        }
        # Search for the dependency in the provided directories
        found <- NA_character_
        for (d in search_dirs) {
          candidate <- file.path(d, dep)
          if (file.exists(candidate)) {
            found <- candidate
            break
          }
          # Also try the exact-case name from the directory listing
          entries <- list.files(d)
          match <- entries[tolower(entries) == dep]
          if (length(match) > 0L) {
            found <- file.path(d, match[[1L]])
            break
          }
        }
        if (!is.na(found)) {
          resolved <- c(resolved, found)
          queue <- c(queue, found)
        }
      }
    }
    unique(resolved)
  }

  # Directories to search for dependency DLLs
  search_dirs <- vtk_bin_dir

  # Seed with the package DLL (compiled in the current working directory = src/)
  # to collect all VTK + runtime transitive deps.
  seed_dll <- normalizePath(dll, mustWork = FALSE)
  all_deps <- collect_dlls(seed_dll, search_dirs)

  for (dep_path in all_deps) {
    dep_name <- basename(dep_path)
    if (file.copy(dep_path, file.path(dest, dep_name), overwrite = TRUE)) {
      message("Installed DLL: ", dep_name)
    }
  }
}
