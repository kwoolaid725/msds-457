# FanGraphs run expectancy matrix

Expected runs from a base-out state to the end of the inning, as
published in the FanGraphs RE24 library entry for a run environment of
4.15 runs per game. The format matches the `expectancy` argument of
[`calculate_run_impact()`](https://kwoolaid725.github.io/msds-457/reference/calculate_run_impact.md).

## Usage

``` r
run_expectancy_fangraphs
```

## Format

A data frame with 24 rows and 3 columns:

- outs:

  Integer outs, 0 to 2.

- bases:

  Integer base mask: 1 for first, 2 for second, 4 for third.

- expected_runs:

  Numeric expected runs to the end of the inning.

## Source

Weinberg, Neil. 2014. "RE24." FanGraphs, July 30.
<https://library.fangraphs.com/misc/re24/>. Values transcribed November
8, 2026.

## Details

One published matrix is applied to every game. Real run environments
differ by season and park, so RE24 totals from this table are
approximate. Callers can supply a season-specific matrix in the same
format.

## Examples

``` r
xtabs(expected_runs ~ bases + outs, run_expectancy_fangraphs)
#>      outs
#> bases     0     1     2
#>     0 0.461 0.243 0.095
#>     1 0.831 0.489 0.214
#>     2 1.068 0.644 0.305
#>     3 1.373 0.908 0.343
#>     4 1.426 0.865 0.413
#>     5 1.798 1.140 0.471
#>     6 1.920 1.352 0.570
#>     7 2.282 1.520 0.736
```
