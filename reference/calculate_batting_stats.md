# Calculate batting statistics from reviewed plays

Calculate counting and rate statistics for each game, team, and player.
Input can come from
[`import_scorecards()`](https://kwoolaid725.github.io/msds-457/reference/import_scorecards.md)
or another source that follows the same column contract. Rows represent
distinct scorecard entries; identical-looking rows are not automatically
deduplicated.

## Usage

``` r
calculate_batting_stats(scorecards)
```

## Arguments

- scorecards:

  A data frame with the seven columns returned by
  [`import_scorecards()`](https://kwoolaid725.github.io/msds-457/reference/import_scorecards.md).
  All entries must have `needs_review = FALSE` and known confidence.
  Review uncertain entries before calculation.

## Value

One row per `game_id`, `team`, and `player`, in first-appearance order.
Counting columns are `PA`, `AB`, `H`, `BB` (including intentional
walks), `HBP`, `SF`, `SH`, `CI`, and `TB`. Rate columns are `BA`, `OBP`,
`SLG`, and `OPS`, without rounding. Zero denominators produce
`NA_real_`. No rows are returned for players with only
blank/automatic-runner markers.

## Details

BA = H/AB; OBP = (H+BB+HBP)/(AB+BB+HBP+SF); SLG = TB/AB; OPS = OBP+SLG.
Sacrifice bunts and catcher interference count as plate appearances but
are excluded from AB and the OBP denominator. Sacrifice flies are
excluded from AB but included in the OBP denominator. Errors and
fielder's choices count as at-bats, not hits. Double plays contribute
one batter at-bat. Automatic runners are not plate appearances.

Only the explicitly supported play labels are accepted. An unrecognized
event must be reviewed rather than silently dropped. This first version
does not estimate missing plays or resolve duplicate player names.

## Examples

``` r
path <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
plays <- import_scorecards(path, "demo-01")
calculate_batting_stats(plays)
#>   game_id      team    player PA AB H BB HBP SF SH CI TB   BA       OBP  SLG
#> 1 demo-01 Demo Owls Alex Demo  6  4 3  1   0  1  0  0  7 0.75 0.6666667 1.75
#> 2 demo-01 Demo Owls  Sam Demo  4  0 0  1   1  0  1  1  0   NA 1.0000000   NA
#>        OPS
#> 1 2.416667
#> 2       NA
```
