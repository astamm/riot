io_stateful_tractogram <- NULL
io_streamline <- NULL

.onLoad <- function(libname, pkgname) {
  # On Windows, register the VTK bin directory as a DLL search path BEFORE
  # loading riot.dll, so that its VTK dependencies can be resolved from the
  # Rtools45/MSYS2 installation without bundling those DLLs inside the package.
  # NOTE: useDynLib is intentionally absent from NAMESPACE so that R does not
  # auto-load the DLL before this hook runs. We load it manually here instead.
  if (.Platform$OS.type == "windows") {
    cfg_file <- system.file("vtk_config", package = pkgname)
    if (nzchar(cfg_file)) {
      lines <- readLines(cfg_file, warn = FALSE)
      cfg <- stats::setNames(
        sub("^[^=]+=", "", lines),
        sub("=.*$", "", lines)
      )
      vtk_bin_dir <- cfg[["VTK_BIN_DIR"]]
      if (
        !is.null(vtk_bin_dir) && nzchar(vtk_bin_dir) && dir.exists(vtk_bin_dir)
      ) {
        add_dll_dir <- get0("addDLLDirectory", envir = asNamespace("base"))
        if (!is.null(add_dll_dir)) {
          tryCatch(add_dll_dir(vtk_bin_dir), error = function(e) NULL)
        } else {
          # Fallback for R < 4.0: prepend to PATH
          Sys.setenv(PATH = paste(vtk_bin_dir, Sys.getenv("PATH"), sep = ";"))
        }
      }
    }
  }
  # Load the native DLL now (after the VTK search path is registered on Windows).
  # During devtools::load_all() / pkgload, libname points to the source tree
  # parent rather than an installed library — library.dynam() would fail there.
  # An installed package always has a libs/ subdirectory; a source tree does not.
  pkg_libs_dir <- file.path(libname, pkgname, "libs")
  if (dir.exists(pkg_libs_dir) && is.null(getLoadedDLLs()[["riot"]])) {
    library.dynam("riot", pkgname, libname)
  }
  reticulate::py_require("fury")
  reticulate::py_require("dipy")
  io_stateful_tractogram <<- reticulate::import(
    "dipy.io.stateful_tractogram",
    delay_load = TRUE
  )
  io_streamline <<- reticulate::import("dipy.io.streamline", delay_load = TRUE)
}

.onUnload <- function(libpath) {
  library.dynam.unload("riot", libpath)
}
