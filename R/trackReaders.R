#' Read tracts in VTP format
#'
#' @param file A path string to the `.vtp` file.
#'
#' @return A \code{\link[tibble]{tibble}} storing the set of tracts.
#' @export
#'
#' @examples
read_vtp <- function(file) {
  file <- normalizePath(file)
  res <- ReadVTP(file)
  tibble::as_tibble(res)
}

#' Read tracts in VTK format
#'
#' @param filename A path string to the `.vtk` file.
#'
#' @return A \code{\link[tibble]{tibble}} storing the set of tracts.
#' @export
#'
#' @examples
read_vtk <- function(filename) {
  if (!file.exists(filename))
    stop("Cannot read: ", filename)

  con <- file(filename, open = "rb", encoding = "ASCII")
  on.exit(close(con))

  header <- readLines(con, n = 1)
  if (regexpr("# vtk DataFile Version [234]", header, ignore.case = TRUE) < 0)
    stop("Bad header line in file: ", filename)

  title <- readLines(con, 1)

  encoding <- readLines(con, 1)
  if (regexpr("ASCII", encoding, ignore.case = TRUE) < 0)
    stop("Can only read ASCII encoded VTK pointsets")

  dataset_header <- toupper(readLines(con, 1))
  if (regexpr("^DATASET", dataset_header) < 0)
    stop("Missing DATASET line")

  dataset_type <- sub("DATASET\\s+(\\w+)", "\\1", dataset_header)

  validDatasetTypes<-c("STRUCTURED_POINTS", "STRUCTURED_GRID",
                       "UNSTRUCTURED_GRID", "POLYDATA", "RECTILINEAR_GRID", "FIELD")
  if (!dataset_type %in% validDatasetTypes)
    stop(dataset_type," is not a valid VTK dataset type")
  if (dataset_type != "POLYDATA")
    stop("ReadVTKLandmarks can currently only read POLYDATA.",
         " See http://www.vtk.org/VTK/img/file-formats.pdf for details.")

  points_header <- toupper(readLines(con, 1))
  if (regexpr("POINTS", points_header) < 0)
    stop("Missing POINTS definition line")

  pts_info <- unlist(strsplit(points_header, "\\s+", perl = TRUE))
  if (length(pts_info) != 3)
    stop("Unable to extract points information from POINTS line", points_header)

  pts_n = as.integer(pts_info[2])
  if (is.na(pts_n))
    stop("Unable to extract number of points from POINTS line:", points_header)

  pts_dataType <- pts_info[3]
  validPointTypes <- toupper(c(
    "unsigned_char", "char",
    "unsigned_short", "short",
    "unsigned_int", "int",
    "unsigned_long", "long",
    "float", "double"
  ))
  if (!(pts_dataType %in% validPointTypes))
    stop("Unrecognised VTK datatype: ", pts_dataType)

  # VTK seems to be hardcoded for 3D
  points_data <- con %>%
    scan(what = 1.0, n = 3 * pts_n, quiet = TRUE) %>%
    matrix(ncol = 3, byrow = TRUE) %>%
    `colnames<-`(c("x", "y", "z")) %>%
    tibble::as_tibble()

  lines_header <- toupper(readLines(con, 1))

  if (length(lines_header) == 0) {
    warning("No data on lines found")
    return(NULL)
  }

  if(regexpr("LINES", lines_header) < 0)
    stop("Missing LINES definition line")

  lines_info <- unlist(strsplit(lines_header, "\\s+", perl = TRUE))
  if (length(lines_info) != 3)
    stop("Unable to extract connection information from LINES line:", lines_header)

  lines_n <- as.integer(lines_info[2])
  if (is.na(lines_n))
    stop("Unable to extract number of lines from LINES line:", lines_header)

  lines_data <- con %>%
    scan(what = "", nlines = lines_n, sep = "\n", quiet = TRUE) %>%
    stringr::str_split(" ") %>%
    purrr::map_chr(1) %>%
    as.integer()

  points_data %>%
    dplyr::mutate(
      streamline_id = lines_data %>%
        purrr::imap(~ rep(.y, .x)) %>%
        purrr::flatten_int(),
      point_id = lines_data %>%
        purrr::map(seq_len) %>%
        purrr::flatten_int()
    ) %>%
    dplyr::select(streamline_id, point_id, x, y, z)
}
