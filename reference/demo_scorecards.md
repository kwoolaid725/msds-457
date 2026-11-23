# Fictional scorecard plays for learning and testing

Eleven scorecard entries for two fictional players in one game,
including an automatic-runner marker that is not a plate appearance.
Designed for checking formulas by hand; these are not observations from
an actual game or measured classifier confidence values.

## Usage

``` r
demo_scorecards
```

## Format

A data frame with 11 rows and 7 columns:

- game_id:

  Game identifier, demo-01.

- team:

  Fictional team name.

- player:

  Fictional player name.

- inning:

  Character inning label, including an 8+ continuation.

- play:

  Canonical play label.

- confidence:

  Illustrative confidence between zero and one.

- needs_review:

  Logical review flag. All entries are reviewed examples.

## Source

Created for this package. CSV headers and display labels follow dAImond
Inning's Plays exporter, inspected October 9, 2026.

## Examples

``` r
calculate_batting_stats(demo_scorecards)
#>   game_id      team    player PA AB H BB HBP SF SH CI TB   BA       OBP  SLG
#> 1 demo-01 Demo Owls Alex Demo  6  4 3  1   0  1  0  0  7 0.75 0.6666667 1.75
#> 2 demo-01 Demo Owls  Sam Demo  4  0 0  1   1  0  1  1  0   NA 1.0000000   NA
#>        OPS
#> 1 2.416667
#> 2       NA
```
