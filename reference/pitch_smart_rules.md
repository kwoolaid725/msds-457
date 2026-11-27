# Pitch Smart daily maximums and rest requirements

The MLB/USA Baseball Pitch Smart guidelines for ages 7 to 18, in long
form: one row per age group and pitch-count band. Used by
[`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md).

## Usage

``` r
pitch_smart_rules
```

## Format

A data frame with 28 rows and 6 integer columns:

- age_min, age_max:

  Age group, inclusive.

- daily_max:

  Most pitches allowed in one day for the age group.

- pitches_min, pitches_max:

  Pitch-count band, inclusive.

- rest_days:

  Calendar days of rest required after a day in the band.

## Source

Major League Baseball and USA Baseball. n.d. "Pitching Guidelines."
Pitch Smart. Accessed November 26, 2026.
<https://www.mlb.com/pitch-smart/pitching-guidelines>. Built by
`data-raw/pitch-smart.R`.

## Details

Ages 19 to 22 are omitted because the published rest table stops at 105
pitches while their daily maximum is 120. Many state associations and
leagues set their own limits; edit a copy of this table and pass it to
[`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md)
to use them.

## Examples

``` r
pitch_smart_rules[pitch_smart_rules$age_min == 11, ]
#>    age_min age_max daily_max pitches_min pitches_max rest_days
#> 9       11      12        85           1          20         0
#> 10      11      12        85          21          35         1
#> 11      11      12        85          36          50         2
#> 12      11      12        85          51          65         3
#> 13      11      12        85          66          85         4
```
