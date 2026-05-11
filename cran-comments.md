## riot v2.0.0

This is a major release. It introduces breaking changes to the data model
(S3 → S7), additional API improvements, and internal C++ refactoring.

### New S7 data model for `streamline` and `bundle`

The previous `maf_df` tibble representation (columns `X`, `Y`, `Z`,
`PointId`, `StreamlineId`) and the interim S3 classes are replaced by two
full **S7** classes:

- `streamline`: three typed slots accessed with `@`:
  - `@points` — $n \times 3$ numeric matrix (`"X"`, `"Y"`, `"Z"` columns).
  - `@point_data` — named list of per-point numeric vectors (length $n$).
  - `@streamline_data` — named list of per-streamline numeric scalars.
- `bundle`: two typed slots:
  - `@streamlines` — list of `streamline` objects.
  - `@bundle_data` — named list of bundle-level metadata.

S7 methods are provided for `format`, `print`, `length`, `[[`, and `[`.
`read_bundle()` returns a `streamline` for single-tract files and a `bundle`
otherwise. `write_bundle()` accepts both. The `readr` dependency has been
removed.

### API rename: `read_bundle()` and `write_bundle()`

`read_tractogram()` and `write_tractogram()` are renamed to `read_bundle()` and
`write_bundle()` for consistency with the `bundle` data model.

### DIPY dependency declaration modernised

The optional DIPY Python dependency is now declared via
`reticulate::py_require("dipy")` (reticulate ≥ 1.41) instead of the previous
manual `py_module_available()` + abort pattern. Reticulate will automatically
provision DIPY in an ephemeral virtual environment when a DIPY-backed format
(`.trx`, `.fib`, `.dpy`) is first used. DIPY is a Python package and therefore
cannot appear in `Imports`/`Suggests`; it is documented in `SystemRequirements`
and `reticulate` remains in `Suggests` as the R-side bridge.

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
