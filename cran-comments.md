## riot v1.3.0

This release introduces three changes.

### New `streamline` / `bundle` data model

The previous `maf_df` tibble representation (columns `X`, `Y`, `Z`,
`PointId`, `StreamlineId`) is replaced by two new S3 classes:

- `streamline`: a numeric matrix (rows = points, columns ≥ `X Y Z`) for a
  single fibre tract. `PointId` is implicit in row order.
- `bundle`: an ordered list of `streamline` objects for a collection of
  tracts. `StreamlineId` is implicit in list position.

`read_tractogram()` returns a `streamline` for single-tract files and a
`bundle` otherwise. `write_tractogram()` accepts both. The `readr` package
dependency has been removed.

### Elimination of intermediate CSV temp files

The C++ reader/writer functions previously serialised data to a temporary CSV
file on disk before handing it back to R (or reading it from R). Readers now
return a `cpp11::writable::list` directly and writers accept a `cpp11::list`
directly, removing all temporary file I/O.

### VTK bindings delegated to `rvtk`

VTK discovery, compilation flags, and pre-built static library distribution
are now handled entirely by the `rvtk` package (https://github.com/astamm/rvtk),
which is pending its own CRAN submission. `rvtk` supplies pre-compiled VTK
headers and static libraries so that no manual VTK installation is required on
most platforms. It is listed in `Imports`; the `Remotes: astamm/rvtk` field
in `DESCRIPTION` will be removed once `rvtk` is available on CRAN. We intend
to submit `rvtk` to CRAN concurrently with or before this package.

## Test environments

**Local:**
* macOS, R 4.7.0

**Continuous integration via GitHub Actions (`R-CMD-check.yaml`):**
* macOS latest, R release, with system VTK (Homebrew)
* Windows latest, R release (Rtools45+, UCRT64), with system VTK
* Ubuntu latest, R devel, with system VTK
* Ubuntu latest, R release, with system VTK
* Ubuntu latest, R oldrel-1, with system VTK
* Ubuntu latest, R release, without system VTK (VTK built from source via `rvtk`)

**Win-builder:**
* [win-builder](https://win-builder.r-project.org/) R release
* [win-builder](https://win-builder.r-project.org/) R-devel

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs.

## Notes for CRAN reviewers

* `Remotes: astamm/rvtk` is present because `rvtk` is not yet on CRAN. A
  separate submission for `rvtk` will be made concurrently. If preferred, we
  can hold this submission until `rvtk` clears CRAN review.
