# ---- streamline -------------------------------------------------------------

#' Create a streamline object
#'
#' A `streamline` is a numeric matrix whose rows are ordered 3-D points along a
#' single fibre tract. The first three columns must be named `"X"`, `"Y"`, and
#' `"Z"`. Any additional columns carry per-point scalar or vector attributes.
#'
#' @param mat A numeric matrix with at least three columns named `"X"`, `"Y"`,
#'   and `"Z"`.
#'
#' @return An object of class `streamline`.
#' @export
new_streamline <- function(mat) {
  if (!is.matrix(mat) || !is.numeric(mat)) {
    cli::cli_abort("{.arg mat} must be a numeric matrix.")
  }
  cn <- colnames(mat)
  if (is.null(cn) || !all(c("X", "Y", "Z") %in% cn)) {
    cli::cli_abort(
      "{.arg mat} must have column names including 'X', 'Y', and 'Z'."
    )
  }
  structure(mat, class = c("streamline", "matrix", "array"))
}

#' Check whether an object is a streamline
#'
#' @param x An object.
#' @return `TRUE` if `x` inherits from `"streamline"`, otherwise `FALSE`.
#' @export
is_streamline <- function(x) inherits(x, "streamline")

#' @export
format.streamline <- function(x, ...) {
  extra <- setdiff(colnames(x), c("X", "Y", "Z"))
  extra_str <- if (length(extra) == 0L) {
    ""
  } else {
    paste0(" | attributes: ", paste(extra, collapse = ", "))
  }
  paste0("<streamline [", nrow(x), " points]", extra_str, ">")
}

#' @export
print.streamline <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

# ---- bundle -----------------------------------------------------------------

#' Create a bundle object
#'
#' A `bundle` is an ordered list of [streamline][new_streamline] objects
#' representing a collection of fibre tracts (a tractogram or white-matter
#' bundle).
#'
#'
#' @param streamlines A list of objects of class `streamline`.
#'
#' @return An object of class `bundle`.
#' @export
new_bundle <- function(streamlines) {
  if (!is.list(streamlines)) {
    cli::cli_abort("{.arg streamlines} must be a list.")
  }
  if (!all(vapply(streamlines, is_streamline, logical(1L)))) {
    cli::cli_abort(
      "All elements of {.arg streamlines} must be {.cls streamline} objects."
    )
  }
  structure(streamlines, class = c("bundle", "list"))
}

#' Check whether an object is a bundle
#'
#' @param x An object.
#' @return `TRUE` if `x` inherits from `"bundle"`, otherwise `FALSE`.
#' @export
is_bundle <- function(x) inherits(x, "bundle")

#' @export
format.bundle <- function(x, ...) {
  n <- length(x)
  if (n == 0L) {
    return("<bundle [0 streamlines]>")
  }
  npts <- vapply(x, nrow, integer(1L))
  extra <- setdiff(colnames(x[[1L]]), c("X", "Y", "Z"))
  extra_str <- if (length(extra) == 0L) {
    ""
  } else {
    paste0(" | attributes: ", paste(extra, collapse = ", "))
  }
  paste0(
    "<bundle [",
    n,
    " streamlines | ",
    min(npts),
    "\u2013",
    max(npts),
    " pts/streamline]",
    extra_str,
    ">"
  )
}

#' @export
print.bundle <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

#' @export
length.bundle <- function(x) {
  NextMethod()
}

# ---- conversion helpers -----------------------------------------------------

#' Convert a flat named list (C++ output) to a streamline or bundle
#'
#' The input is the named list returned by `ReadVTK()`, `ReadVTP()`, or
#' `ReadFDS()`, which has at minimum columns `"X"`, `"Y"`, `"Z"`,
#' `"PointId"`, and `"StreamlineId"`. Each streamline is assembled as a
#' numeric matrix with columns `"X"`, `"Y"`, `"Z"` plus any extra per-point
#' attribute columns. `PointId` and `StreamlineId` are dropped — they are
#' implicit in the row order and list position respectively.
#'
#' Returns a `streamline` when the data contain exactly one streamline,
#' otherwise a `bundle`.
#'
#' @param lst A named list with at least the columns `"X"`, `"Y"`, `"Z"`,
#'   `"PointId"`, and `"StreamlineId"`.
#'
#' @return A [streamline][new_streamline] or [bundle][new_bundle].
#' @keywords internal
flat_list_to_bundle <- function(lst) {
  # Accept either a list or a data-frame-like object (e.g. from read_mrtrix/read_trk)
  X <- lst[["X"]]
  Y <- lst[["Y"]]
  Z <- lst[["Z"]]
  sid <- lst[["StreamlineId"]]

  extra_cols <- setdiff(names(lst), c("X", "Y", "Z", "PointId", "StreamlineId"))

  ids <- sort(unique(sid))

  streamlines <- lapply(ids, function(i) {
    rows <- sid == i
    mat <- cbind(X = X[rows], Y = Y[rows], Z = Z[rows])
    for (col in extra_cols) {
      mat <- cbind(mat, lst[[col]][rows])
    }
    if (length(extra_cols) > 0L) {
      colnames(mat) <- c("X", "Y", "Z", extra_cols)
    }
    new_streamline(mat)
  })

  if (length(streamlines) == 1L) {
    streamlines[[1L]]
  } else {
    new_bundle(streamlines)
  }
}

#' Convert a bundle (or streamline) to a flat named list for the C++ writers
#'
#' Reconstructs the `X`, `Y`, `Z`, `PointId`, `StreamlineId` columns (plus any
#' extra per-point attribute columns) expected by `WriteVTK()`, `WriteVTP()`,
#' and `WriteFDS()`.
#'
#' @param x A [bundle][new_bundle] or [streamline][new_streamline].
#'
#' @return A named list suitable for passing to the C++ writer functions.
#' @keywords internal
bundle_to_flat_list <- function(x) {
  # Normalise: wrap a lone streamline into a length-1 list
  if (is_streamline(x)) {
    x <- list(x)
  }

  n_streamlines <- length(x)
  parts <- lapply(seq_len(n_streamlines), function(i) {
    sl <- x[[i]]
    n_pts <- nrow(sl)
    extra_cols <- setdiff(colnames(sl), c("X", "Y", "Z"))
    out <- list(
      X = sl[, "X"],
      Y = sl[, "Y"],
      Z = sl[, "Z"],
      PointId = seq_len(n_pts),
      StreamlineId = rep(i, n_pts)
    )
    for (col in extra_cols) {
      out[[col]] <- sl[, col]
    }
    out
  })

  # Combine row-wise across all streamlines
  nms <- names(parts[[1L]])
  out <- lapply(nms, function(col) {
    unlist(lapply(parts, `[[`, col), use.names = FALSE)
  })
  names(out) <- nms
  out
}
