# Import a play-level scorecard CSV

Read the standard dAImond Inning Plays CSV, retaining review
information. The original file is not modified. One file represents one
game, possibly containing both teams. Custom exports must retain the
original required column names. Player names identify players only
within a game and team.

## Usage

``` r
import_scorecards(path, game_id)
```

## Arguments

- path:

  Path to one UTF-8 CSV file.

- game_id:

  A nonempty character identifier supplied by the caller. Use the same
  identifier for both teams in a game and different identifiers for
  different games.

## Value

A data frame with character columns `game_id`, `team`, `player`,
`inning`, and `play`, numeric `confidence`, and logical `needs_review`.
Inning labels such as `8+` are retained. Confidence may be missing;
missing confidence forces review. Header-only files return zero rows.

## Details

Required CSV columns are `Team`, `Player`, `Inning`, `Play`,
`Confidence`, and `Needs Review`. Confidence is a number between zero
and one. Review values may be Yes/No, TRUE/FALSE, or 1/0; a blank flag
means false, matching the app export. Extra columns are ignored.

Human-readable play labels are converted to the app's canonical labels.
Unknown plays and bad crops raise errors instead of being treated as
outs. Explicit `no_at_bat` and automatic-runner markers are retained but
excluded by
[`calculate_batting_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_batting_stats.md).
The upstream CSV exporter omits blank and bad-crop cells, so this
function cannot detect those omitted readings.

## Examples

``` r
path <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
plays <- import_scorecards(path, game_id = "demo-01")
head(plays)
#>   game_id      team    player inning          play confidence needs_review
#> 1 demo-01 Demo Owls Alex Demo      1        single       0.99        FALSE
#> 2 demo-01 Demo Owls Alex Demo      3        double       0.98        FALSE
#> 3 demo-01 Demo Owls Alex Demo      5      home_run       0.99        FALSE
#> 4 demo-01 Demo Owls Alex Demo      7     strikeout       0.97        FALSE
#> 5 demo-01 Demo Owls Alex Demo      8          walk       0.98        FALSE
#> 6 demo-01 Demo Owls Alex Demo     8+ sacrifice_fly       0.96        FALSE
```
