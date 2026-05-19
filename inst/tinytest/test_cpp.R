library(riot)

# ---- helpers ----------------------------------------------------------------

# Write a minimal ASCII legacy-VTK POLYDATA file.
# points:       n x 3 numeric matrix (XYZ rows)
# cells:        list of integer vectors; each vector gives 1-based point indices
# vectors_data: optional n x 3 numeric matrix → written as a VECTORS array
#               named "tangent" (3-component; triggers nc > 1 branch in reader)
write_vtk_ascii <- function(path, points, cells, vectors_data = NULL) {
  n_pts <- nrow(points)
  cell_body <- vapply(
    cells,
    function(ids) paste(length(ids), paste(ids - 1L, collapse = " ")),
    character(1L)
  )
  cell_total <- sum(lengths(cells) + 1L)

  txt <- c(
    "# vtk DataFile Version 3.0",
    "toy data",
    "ASCII",
    "DATASET POLYDATA",
    sprintf("POINTS %d float", n_pts),
    apply(points, 1L, paste, collapse = " "),
    sprintf("LINES %d %d", length(cells), cell_total),
    cell_body
  )

  if (!is.null(vectors_data)) {
    txt <- c(
      txt,
      sprintf("POINT_DATA %d", n_pts),
      "VECTORS tangent float",
      apply(vectors_data, 1L, paste, collapse = " ")
    )
  }

  writeLines(txt, path)
}

# ---- fascicleReaders: singleton streamline cell -----------------------------
# PolyDataToList line 27: `continue` when streamlineSize == 1.
# PolyDataToList line 71: `continue` when streamlineId[i] == -1 (singleton's
#   point is skipped during coordinate assembly).
# VTK layout: 4 points.  Cell 0 = single-point line (singleton).
#                         Cell 1 = 3-point line (valid streamline).

f_sing <- tempfile(fileext = ".vtk")
pts_sing <- matrix(
  c(
    0,
    0,
    0, # point 0: uniq coord, belongs only to singleton cell
    1,
    0,
    0,
    2,
    0,
    0,
    3,
    0,
    0
  ),
  nrow = 4L,
  byrow = TRUE
)
write_vtk_ascii(
  f_sing,
  pts_sing,
  cells = list(c(1L), c(2L, 3L, 4L)) # 1-indexed; cell 0 = singleton
)

result_sing <- riot:::ReadVTK(f_sing)

# Only the 3-point streamline survives; the singleton is dropped.
expect_equal(length(result_sing$X), 3L)
# Coord (0,0,0) belonged to the singleton cell → must be absent.
expect_false(
  any(result_sing$X == 0 & result_sing$Y == 0 & result_sing$Z == 0),
  info = "singleton point must be excluded"
)
unlink(f_sing)

# ---- fascicleReaders + fascicleWriters: multi-component array roundtrip -----
# Build a flat list with '#'-named columns (3-component array "tangent").
# WriteVTK exercises the `else` branch in the '#'-detection while loop
#   (fascicleWriters lines ~50-65).
# ReadVTK back exercises the nc > 1 `else` branch in PolyDataToList
#   (fascicleReaders lines ~52-62), the per-point array copy (~83-88),
#   and the result push (~100).

flat_mc <- list(
  X = c(0.0, 1.0, 0.0, 1.0),
  Y = c(0.0, 0.0, 0.0, 0.0),
  Z = c(0.0, 0.0, 0.0, 0.0),
  PointId = c(1L, 2L, 1L, 2L),
  StreamlineId = c(1L, 1L, 2L, 2L),
  `tangent#0` = c(1.0, 0.7, 0.0, 0.5),
  `tangent#1` = c(0.0, 0.7, 1.0, 0.5),
  `tangent#2` = c(0.0, 0.0, 0.0, 0.0)
)

f_mc <- tempfile(fileext = ".vtk")
riot:::WriteVTK(flat_mc, f_mc)

result_mc <- riot:::ReadVTK(f_mc)
expect_true("tangent#0" %in% names(result_mc))
expect_true("tangent#1" %in% names(result_mc))
expect_true("tangent#2" %in% names(result_mc))
expect_equal(length(result_mc[["tangent#0"]]), 4L)
unlink(f_mc)

# ---- fascicleWriters: single-component extra column roundtrip ---------------
# write_bundle with a bundle that carries an "FA" per-point column.
# bundle_to_flat_list adds "FA" (no '#') → ListToPolyData enters while loop
#   `if` branch (single-component, fascicleWriters ~line 51-54) and emits
#   "Number of arrays: 1" message.

sl_fa <- matrix(
  c(0, 0, 0, 1, 0, 0, 2, 0, 0),
  ncol = 3L,
  byrow = TRUE,
  dimnames = list(NULL, c("X", "Y", "Z"))
)
b_fa <- fiber::bundle(list(fiber::streamline(
  sl_fa,
  point_data = list(FA = c(0.5, 0.6, 0.7))
)))
f_fa <- tempfile(fileext = ".vtk")
write_bundle(b_fa, f_fa)

result_fa <- riot:::ReadVTK(f_fa)
expect_true("FA" %in% names(result_fa))
expect_equal(length(result_fa$FA), 3L)
unlink(f_fa)

# ---- fascicleWriters: defensive error – fewer than 5 columns ---------------

expect_error(
  riot:::WriteVTK(
    list(X = 1.0, Y = 1.0, Z = 1.0),
    tempfile(fileext = ".vtk")
  )
)

# ---- fascicleWriters: defensive error – wrong column names -----------------

expect_error(
  riot:::WriteVTK(
    list(a = 1.0, b = 1.0, c = 1.0, d = 1L, e = 1L),
    tempfile(fileext = ".vtk")
  )
)

# ---- fascicleWriters: defensive error – unsupported column type -------------
# Character columns are neither REALSXP nor INTSXP → triggers the
# cpp11::stop("Unsupported column type in input data.") branch.

expect_error(
  riot:::WriteVTK(
    list(X = "bad", Y = 1.0, Z = 1.0, PointId = 1L, StreamlineId = 1L),
    tempfile(fileext = ".vtk")
  )
)

# ---- ReadFDS: corrupt XML → error ------------------------------------------

f_corrupt <- tempfile(fileext = ".fds")
writeLines("this is definitely not XML", f_corrupt)
expect_error(riot:::ReadFDS(f_corrupt))
unlink(f_corrupt)

# ---- ReadFDS: valid XML but no VTKFile element → error ---------------------

f_noroot <- tempfile(fileext = ".fds")
writeLines(c('<?xml version="1.0"?>', '<NotVTKFile/>'), f_noroot)
expect_error(riot:::ReadFDS(f_noroot))
unlink(f_noroot)

# ---- ReadFDS: VTKFile present but no vtkFiberDataSet child → error ---------

f_nodset <- tempfile(fileext = ".fds")
writeLines(
  c(
    '<?xml version="1.0"?>',
    '<VTKFile type="vtkFiberDataSet" version="1.0">',
    '  <SomethingElse/>',
    '</VTKFile>'
  ),
  f_nodset
)
expect_error(riot:::ReadFDS(f_nodset))
unlink(f_nodset)

# ---- ReadFDS: embedded file with unsupported extension → error -------------
# The Fibers element references "fibers.foo".  ReadFDS extracts the extension
# "foo", which is neither "vtk" nor "vtp" → cpp11::stop("Unsupported…").

td_unk <- tempdir()
f_unk <- file.path(td_unk, "test_unk.fds")
writeLines(
  c(
    '<?xml version="1.0"?>',
    '<VTKFile type="vtkFiberDataSet" version="1.0">',
    '<vtkFiberDataSet>',
    '  <Fibers index="0" file="fibers.foo"/>',
    '</vtkFiberDataSet>',
    '</VTKFile>'
  ),
  f_unk
)
expect_error(riot:::ReadFDS(f_unk))
unlink(f_unk)

# ---- ReadFDS: embedded .vtk file → exercises the `if (extensionName == "vtk")` branch

td_vtk <- file.path(tempdir(), "fds_vtk_test")
dir.create(td_vtk, showWarnings = FALSE)
f_fds_vtk <- file.path(td_vtk, "bundle.fds")

# Write a minimal inner .vtk polyline file (two-point streamline)
inner_vtk <- file.path(td_vtk, "bundle_0.vtk")
pts_inner <- matrix(c(0, 0, 0, 1, 0, 0), nrow = 2L, byrow = TRUE)
write_vtk_ascii(inner_vtk, pts_inner, cells = list(c(1L, 2L)))

# Write the .fds XML pointing to the inner .vtk (relative path, no directory prefix)
writeLines(
  c(
    '<?xml version="1.0"?>',
    '<VTKFile type="vtkFiberDataSet" version="1.0" byte_order="LittleEndian">',
    '<vtkFiberDataSet>',
    sprintf('  <Fibers index="0" file="%s"/>', "bundle_0.vtk"),
    '</vtkFiberDataSet>',
    '</VTKFile>'
  ),
  f_fds_vtk
)

result_fds_vtk <- riot:::ReadFDS(f_fds_vtk)
expect_equal(length(result_fds_vtk$X), 2L)
unlink(td_vtk, recursive = TRUE)
