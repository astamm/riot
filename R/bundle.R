# ---- S7 class: streamline ---------------------------------------------------

#' The streamline S7 class
#'
#' A `streamline` represents a single fibre tract. It stores three data
#' compartments that mirror the conceptual levels found in tractography file
#' formats:
#' - `@points` — an \eqn{n \times 3} numeric matrix whose columns are named
#'   `"X"`, `"Y"`, and `"Z"`, holding the ordered 3-D coordinates of the
#'   \eqn{n} points along the tract.
#' - `@point_data` — a named list of numeric vectors, each of length \eqn{n},
#'   holding per-point scalar attributes (e.g. fractional anisotropy sampled
#'   at every point).
#' - `@streamline_data` — a named list of numeric scalars (length-1 vectors)
#'   holding per-streamline attributes (e.g. a tract-level weight or mean FA).
#'
#' Use the [new_streamline()] constructor to create instances. Slots are
#' accessed with the `@` operator: `sl@points`, `sl@point_data`,
#' `sl@streamline_data`.
#'
#' @param points A numeric matrix with columns `"X"`, `"Y"`, and `"Z"`.
#' @param point_data A named list of per-point numeric vectors.
#' @param streamline_data A named list of per-streamline numeric scalars.
#'
#' @export
streamline <- S7::new_class(
  name = "streamline",
  package = "riot",
  properties = list(
    points = S7::class_any,
    point_data = S7::class_list,
    streamline_data = S7::class_list
  ),
  validator = function(self) {
    if (!is.matrix(self@points) || !is.numeric(self@points)) {
      return("@points must be a numeric matrix.")
    }
    cn <- colnames(self@points)
    if (is.null(cn) || !all(c("X", "Y", "Z") %in% cn)) {
      return("@points must have column names including 'X', 'Y', and 'Z'.")
    }
    n_pts <- nrow(self@points)
    for (nm in names(self@point_data)) {
      v <- self@point_data[[nm]]
      if (!is.numeric(v) || length(v) != n_pts) {
        return(sprintf(
          "@point_data[[\"%s\"]] must be a numeric vector of length %d.",
          nm,
          n_pts
        ))
      }
    }
    for (nm in names(self@streamline_data)) {
      v <- self@streamline_data[[nm]]
      if (!is.numeric(v) || length(v) != 1L) {
        return(sprintf(
          "@streamline_data[[\"%s\"]] must be a numeric scalar (length 1).",
          nm
        ))
      }
    }
    NULL
  }
)

# ---- S7 class: bundle -------------------------------------------------------

#' The bundle S7 class
#'
#' A `bundle` is an ordered collection of [streamline] objects representing a
#' tractogram or white-matter bundle.  It stores two compartments:
#' - `@streamlines` — a list of [streamline] objects.
#' - `@bundle_data` — a named list of bundle-level metadata (arbitrary R
#'   objects, e.g. the affine transform used during tracking).
#'
#' Use the [new_bundle()] constructor to create instances.
#'
#' @param streamlines A list of [streamline] objects.
#' @param bundle_data A named list of bundle-level metadata.
#'
#' @export
bundle <- S7::new_class(
  name = "bundle",
  package = "riot",
  properties = list(
    streamlines = S7::class_list,
    bundle_data = S7::class_list
  ),
  validator = function(self) {
    bad <- !vapply(
      self@streamlines,
      function(x) S7::S7_inherits(x, streamline),
      logical(1L)
    )
    if (any(bad)) {
      return("All elements of @streamlines must be <riot::streamline> objects.")
    }
    NULL
  }
)

# ---- constructors -----------------------------------------------------------

#' Create a streamline object
#'
#' A convenience constructor that wraps the [streamline] S7 class.
#'
#' @param points A numeric matrix with at least three columns named `"X"`,
#'   `"Y"`, and `"Z"`. Rows correspond to ordered points along the tract.
#' @param point_data A named list of numeric vectors, each of length
#'   `nrow(points)`, holding per-point scalar attributes.  Defaults to an
#'   empty list.
#' @param streamline_data A named list of numeric scalars (length-1 vectors)
#'   holding per-streamline attributes.  Defaults to an empty list.
#'
#' @return An object of class `<riot::streamline>`.
#' @export
#' @seealso [new_bundle()]
new_streamline <- function(
  points,
  point_data = list(),
  streamline_data = list()
) {
  streamline(
    points = points,
    point_data = point_data,
    streamline_data = streamline_data
  )
}

#' Create a bundle object
#'
#' A convenience constructor that wraps the [bundle] S7 class.
#'
#' @param streamlines A list of [streamline] objects.
#' @param bundle_data A named list of bundle-level metadata.  Defaults to an
#'   empty list.
#'
#' @return An object of class `<riot::bundle>`.
#' @export
#' @seealso [new_streamline()]
new_bundle <- function(streamlines, bundle_data = list()) {
  bundle(streamlines = streamlines, bundle_data = bundle_data)
}

# ---- predicates -------------------------------------------------------------

#' Check whether an object is a streamline
#'
#' @param x An object.
#' @return `TRUE` if `x` is of class `<riot::streamline>`, otherwise `FALSE`.
#' @export
is_streamline <- function(x) S7::S7_inherits(x, streamline)

#' Check whether an object is a bundle
#'
#' @param x An object.
#' @return `TRUE` if `x` is of class `<riot::bundle>`, otherwise `FALSE`.
#' @export
is_bundle <- function(x) S7::S7_inherits(x, bundle)

# ---- helper: number of points -----------------------------------------------

#' Number of points in a streamline
#'
#' @param x A [streamline] object.
#' @return Integer scalar giving the number of points.
#' @keywords internal
n_points <- function(x) nrow(x@points)

# ---- format / print ---------------------------------------------------------

S7::method(format, streamline) <- function(x, ...) {
  pd <- names(x@point_data)
  sld <- names(x@streamline_data)
  pd_str <- if (length(pd) > 0L) {
    paste0(" | point: ", paste(pd, collapse = ", "))
  } else {
    ""
  }
  sld_str <- if (length(sld) > 0L) {
    paste0(" | streamline: ", paste(sld, collapse = ", "))
  } else {
    ""
  }
  paste0("<streamline [", n_points(x), " pts]", pd_str, sld_str, ">")
}

S7::method(print, streamline) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

S7::method(format, bundle) <- function(x, ...) {
  n <- length(x@streamlines)
  if (n == 0L) {
    return("<bundle [0 streamlines]>")
  }
  npts <- vapply(x@streamlines, n_points, integer(1L))
  pd_keys <- unique(unlist(lapply(x@streamlines, function(s) {
    names(s@point_data)
  })))
  sld_keys <- unique(unlist(lapply(x@streamlines, function(s) {
    names(s@streamline_data)
  })))
  bd_keys <- names(x@bundle_data)
  pd_str <- if (length(pd_keys) > 0L) {
    paste0(" | point: ", paste(pd_keys, collapse = ", "))
  } else {
    ""
  }
  sld_str <- if (length(sld_keys) > 0L) {
    paste0(" | streamline: ", paste(sld_keys, collapse = ", "))
  } else {
    ""
  }
  bd_str <- if (length(bd_keys) > 0L) {
    paste0(" | bundle: ", paste(bd_keys, collapse = ", "))
  } else {
    ""
  }
  paste0(
    "<bundle [",
    n,
    " streamlines | ",
    min(npts),
    "\u2013",
    max(npts),
    " pts/streamline]",
    pd_str,
    sld_str,
    bd_str,
    ">"
  )
}

S7::method(print, bundle) <- function(x, ...) {
  cat(format(x, ...), "\n")
  invisible(x)
}

# ---- length / indexing for bundle -------------------------------------------

S7::method(length, bundle) <- function(x) length(x@streamlines)

S7::method(`[[`, bundle) <- function(x, i, ...) x@streamlines[[i]]

S7::method(`[`, bundle) <- function(x, i, j, ..., drop = TRUE) {
  new_bundle(x@streamlines[i], bundle_data = x@bundle_data)
}

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
#' Returns a `streamline` when the data contain exactly one streamline,
#' otherwise a `bundle`.
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

    new_streamline(pts, point_data = pd, streamline_data = sld)
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
#' extra per-point attribute columns and per-streamline attributes broadcast to
#' all points) expected by `WriteVTK()`, `WriteVTP()`, and `WriteFDS()`.
#'
#' @param x A [bundle] or [streamline].
#'
#' @return A named list suitable for passing to the C++ writer functions.
#' @keywords internal
bundle_to_flat_list <- function(x) {
  if (is_streamline(x)) {
    x <- new_bundle(list(x))
  }

  n_streamlines <- length(x@streamlines)
  parts <- lapply(seq_len(n_streamlines), function(i) {
    sl <- x@streamlines[[i]]
    n_pts <- n_points(sl)
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
