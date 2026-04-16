# Format and print methods for maf_df objects

Format and print methods for maf_df objects

## Usage

``` r
# S3 method for class 'maf_df'
format(x, ...)

# S3 method for class 'maf_df'
print(x, ...)
```

## Arguments

- x:

  A maf_df object

- ...:

  Additional arguments (not used)

## Value

A formatted string summarizing the maf_df object

## Examples

``` r
# Create a sample maf_df object
sample_data <- tibble::tibble(
  X = rnorm(100),
  Y = rnorm(100),
  Z = rnorm(100),
  PointId = rep(1:10, each = 10),
  StreamlineId = rep(1:10, times = 10)
)
class(sample_data) <- c("maf_df", class(sample_data))
format(sample_data)
#> ℹ Tractogram with 10 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 10, 10, 10, 10, 10, and 10.
print(sample_data)
#> ℹ Tractogram with 10 streamlines.
#> ℹ Distribution of the number of sampled points per streamline: 10, 10, 10, 10, 10, and 10.
#> cli-175-344 
```
