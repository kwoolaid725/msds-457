# Check youth pitch counts against Pitch Smart guidelines

Apply the MLB/USA Baseball Pitch Smart daily maximums and required rest
days to a log of pitching appearances. Each pitcher's days are checked
in date order, so a pitcher who returns before the required rest is
flagged along with any day over the age group's maximum.

## Usage

``` r
check_pitch_counts(appearances, rules = daimondstats::pitch_smart_rules)
```

## Arguments

- appearances:

  A data frame with one row per pitching appearance and columns
  `pitcher` (nonempty character), `age` (whole number from 7 to 18 on
  the game date), `date` (a `Date` or `"YYYY-MM-DD"` text), and
  `pitches` (nonnegative whole number). Extra columns are ignored.

- rules:

  A rules table with the columns of
  [pitch_smart_rules](https://kwoolaid725.github.io/msds-457/reference/pitch_smart_rules.md).
  Leagues with stricter limits can pass an edited copy.

## Value

One row per pitcher and date, ordered by pitcher and date, with
`pitcher`, `date`, `age`, `pitches`, `appearances` (rows combined that
day), `daily_max`, `rest_days`, `next_eligible` (first date the pitcher
may pitch again), `over_max`, `short_rest`, and `status`, which is
`"ok"`, `"over daily max"`, `"short rest"`, or both joined by `"; "`.

## Details

The daily maximum applies to a calendar day, so two appearances on the
same date (for example, a doubleheader) are added together before
checking. Required rest is counted in calendar days: two days of rest
after pitching on Saturday means the pitcher is next eligible on
Tuesday. A day over the maximum still receives the largest rest band.

Pitch counts come from the scorecard's pitcher box. A missed or misread
count changes the result, so review the counts first. The check only
covers the games in `appearances`; pitching for another team or league
is invisible to it. Ages 19 to 22 are not supported because the
published rest table does not cover their full daily maximum.

## References

Major League Baseball and USA Baseball. n.d. "Pitching Guidelines."
Pitch Smart. Accessed November 26, 2026.
<https://www.mlb.com/pitch-smart/pitching-guidelines>.

## See also

[pitch_smart_rules](https://kwoolaid725.github.io/msds-457/reference/pitch_smart_rules.md)

## Examples

``` r
log <- data.frame(
  pitcher = c("Ava", "Ava", "Ben", "Ben"),
  age = c(11, 11, 12, 12),
  date = c("2026-05-02", "2026-05-04", "2026-05-02", "2026-05-03"),
  pitches = c(60, 30, 90, 10)
)
check_pitch_counts(log)
#>   pitcher       date age pitches appearances daily_max rest_days next_eligible
#> 1     Ava 2026-05-02  11      60           1        85         3    2026-05-06
#> 2     Ava 2026-05-04  11      30           1        85         1    2026-05-06
#> 3     Ben 2026-05-02  12      90           1        85         4    2026-05-07
#> 4     Ben 2026-05-03  12      10           1        85         0    2026-05-04
#>   over_max short_rest         status
#> 1    FALSE      FALSE             ok
#> 2    FALSE       TRUE     short rest
#> 3     TRUE      FALSE over daily max
#> 4    FALSE       TRUE     short rest
```
