# Fictional youth pitching log

One month of pitching for a fictional 12U team: 15 appearances by four
pitchers across nine dates, including a Saturday doubleheader. Built to
show each outcome of
[`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md):
clean weeks, a pitcher who returns before the required rest, and a day
over the daily maximum. These are not real players or games.

## Usage

``` r
demo_pitch_log
```

## Format

A data frame with 15 rows and 5 columns:

- pitcher:

  Fictional pitcher name.

- age:

  Age on the game date, 10 to 12.

- date:

  Game date (`Date`).

- game:

  Opponent label; doubleheader games share a date.

- pitches:

  Pitches thrown in that appearance.

## Source

Created for this package by `data-raw/demo-pitch-log.R`.

## Examples

``` r
check_pitch_counts(demo_pitch_log)
#>       pitcher       date age pitches appearances daily_max rest_days
#> 1    Jay Ruiz 2026-05-12  10      30           1        75         1
#> 2    Jay Ruiz 2026-05-20  10      20           1        75         0
#> 3    Leo Park 2026-05-02  11      24           1        85         1
#> 4    Leo Park 2026-05-09  11      47           1        85         2
#> 5    Leo Park 2026-05-12  11      52           1        85         3
#> 6    Leo Park 2026-05-16  11      66           1        85         4
#> 7    Leo Park 2026-05-23  11      88           1        85         4
#> 8  Mia Torres 2026-05-02  12      66           1        85         4
#> 9  Mia Torres 2026-05-06  12      33           1        85         1
#> 10 Mia Torres 2026-05-09  12      63           2        85         3
#> 11 Mia Torres 2026-05-16  12      49           1        85         2
#> 12 Sam Okafor 2026-05-06  12      61           1        85         3
#> 13 Sam Okafor 2026-05-12  12      18           1        85         0
#> 14 Sam Okafor 2026-05-20  12      72           1        85         4
#>    next_eligible over_max short_rest         status
#> 1     2026-05-14    FALSE      FALSE             ok
#> 2     2026-05-21    FALSE      FALSE             ok
#> 3     2026-05-04    FALSE      FALSE             ok
#> 4     2026-05-12    FALSE      FALSE             ok
#> 5     2026-05-16    FALSE      FALSE             ok
#> 6     2026-05-21    FALSE      FALSE             ok
#> 7     2026-05-28     TRUE      FALSE over daily max
#> 8     2026-05-07    FALSE      FALSE             ok
#> 9     2026-05-08    FALSE       TRUE     short rest
#> 10    2026-05-13    FALSE      FALSE             ok
#> 11    2026-05-19    FALSE      FALSE             ok
#> 12    2026-05-10    FALSE      FALSE             ok
#> 13    2026-05-13    FALSE      FALSE             ok
#> 14    2026-05-25    FALSE      FALSE             ok
```
