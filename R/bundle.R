# ---- conversion helpers -----------------------------------------------------

#' Convert a flat named list (C++ output) to a streamline or bundle
#'
#' The input is the named list returned by `ReadVTK()`, `ReadVTP()`, or
#' `ReadFDS()`, which has at minimum columns `"X"`, `"Y"`, `"Z"`,
#' `"PointId"`, and `"StreamlineId"`. Columns named in `streamline_cols` are
#' treated as per-streamline attributes: one value is stored per streamline
#' (taken from the first occurrence in each group rather than broadcast).
#' All remaining extra columns are treated as per-point attributes.
#'
#' Returns a [streamline] when the data contain exactly one streamline,
#' otherwise a [bundle].
#'
#' @param lst A named list with at least the columns `"X"`, `"Y"`, `"Z"`,
#'   `"PointId"`, and `"StreamlineId"`.
#' @param streamline_cols Character vector of column names to store as
#'   per-streamline data.  Defaults to `character(0)`.
#'
#' @return A [streamline] or [bundle].
#' @keywords internal
flat_list_to_bundle <- function(lst, streamline_cols = character(0L)) {
  X <- lst[["X"]]
  Y <- lst[["Y"]]
  Z <- lst[["Z"]]
  sid <- lst[["StreamlineId"]]

  all_extra <- setdiff(names(lst), c("X", "Y", "Z", "PointId", "StreamlineId"))
  point_cols <- setdiff(all_extra, streamline_cols)
  sl_cols <- intersect(streamline_cols, all_extra)

  ids <- sort(unique(sid))

  streamlines <- lapply(ids, function(i) {
    rows <- sid == i
    pts <- cbind(X = X[rows], Y = Y[rows], Z = Z[rows])

    pd <- if (length(point_cols) > 0L) {
      setNames(
        lapply(point_cols, function(col) lst[[col]][rows]),
        point_cols
      )
    } else {
      list()
    }

    sld <- if (length(sl_cols) > 0L) {
      setNames(
        lapply(sl_cols, function(col) lst[[col]][which(rows)[1L]]),
        sl_cols
      )
    } else {
      list()
    }

    fiber::new_streamline(pts, point_data = pd, streamline_data = sld)
  })

  if (length(streamlines) == 1L) {
    streamlines[[1L]]
  } else {
    fiber::new_bundle(streamlines)
  }
}

#' Convert a bundle (or streamline) to a flat named list for the C++ writers
#'
#' Reconstructs the `X`, `Y`, `Z`, `PointId`, `StreamlineId` columns (plus any
#' extra per-point attribute columns and per-streamline attributes broadcast to
#' all points) expected by `WriteVTK()`, `WriteVTP()`, and `WriteFDS()`.
#'
#' @param x A [bundle] or [streamline].
#'
#' @return A named list suitable for passing to the C++ writer functions.
#' @keywords internal
bundle_to_flat_list <- function(x) {
  if (fiber::is_streamline(x)) {
    x <- fiber::new_bundle(list(x))
  }

  n_streamlines <- length(x@streamlines)
  parts <- lapply(seq_len(n_streamlines), function(i) {
    sl <- x@streamlines[[i]]
    n_pts <- nrow(sl@points)
    out <- list(
      X = sl@points[, "X"],
      Y = sl@points[, "Y"],
      Z = sl@points[, "Z"],
      PointId = seq_len(n_pts),
      StreamlineId = rep(i, n_pts)
    )
    for (nm in names(sl@point_data)) {
      out[[nm]] <- sl@point_data[[nm]]
    }
    # Per-streamline scalars are broadcast so C++ writers see a full-length
    # column (their file format stores them separately, but the flat-list
    # convention requires one value per row).
    for (nm in names(sl@streamline_data)) {
      out[[nm]] <- rep(sl@streamline_data[[nm]], n_pts)
    }
    out
  })

  nms <- names(parts[[1L]])
  out <- lapply(nms, function(col) {
    unlist(lapply(parts, `[[`, col), use.names = FALSE)
  })
  names(out) <- nms
  out
}
