io_stateful_tractogram <- NULL
io_streamline <- NULL

.onLoad <- function(libname, pkgname) {
  # On Windows, register the VTK bin directory as a DLL search path so that
  # riot.dll can resolve its VTK dependencies from the Rtools45/MSYS2
  # installation without bundling those DLLs inside the package.
  if (.Platform$OS.type == "windows") {
    lib_dir <- file.path(libname, pkgname, "libs", .Platform$r_arch)
    cfg_file <- file.path(lib_dir, "vtk_config")
    if (file.exists(cfg_file)) {
      lines <- readLines(cfg_file, warn = FALSE)
      cfg <- setNames(
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
