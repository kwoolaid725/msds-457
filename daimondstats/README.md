# daimondstats

daimondstats analyzes a personal collection of baseball games. It compares
selected games with one team's reference season and calculates situational
run value, called RE24, from verified events. The separate dAImond Inning app
reads scorecard images; this R package works with structured data.

## Intended audience

The package is for baseball fans, scorekeepers, and sports analytics students
who use R. It helps answer questions such as whether the games someone scored
were unusual within a season. It does not establish that attending or scoring
a game changes its outcome.

## Installation

Requires R 4.1.0 or later. From the root of a local clone of the
[MSDS 457 repository](https://github.com/kwoolaid725/msds-457), run in a terminal:

```sh
R CMD build daimondstats
R CMD INSTALL daimondstats_0.0.5.tar.gz
```

Building first includes the vignette; `R CMD INSTALL daimondstats` also works
but skips it. Building the vignette needs `knitr` and `rmarkdown`.

The runtime uses `jsonlite` to read MLB schedules plus packages distributed
with R (`graphics`, `stats`, `utils`); the plot uses base R graphics. `roxygen2` is an optional development dependency for generating help files.

## Basic usage

```r
library(daimondstats)
# Included reviewed plays from five team scorecards:
batting <- calculate_batting_stats(reviewed_scorecards)
head(batting)
# Was the scored Twins game unusual within the 2024 Twins season?
twins <- subset(reviewed_team_seasons, team == "Minnesota Twins")
set.seed(457)
compare_personal_season(twins, "746804", metric = "run_diff")$summary
# Fictional eight-game reference season for learning the interface:
games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2026,
  home = rep(c(TRUE, FALSE), 4), win = c(1, 0, 1, 1, 0, 0, 1, 0))
set.seed(457)
result <- compare_personal_season(games, c("a", "b", "c"), simulations = 100)
result$summary
# Real RE24 for the five reviewed scorecards:
impact <- calculate_run_impact(reviewed_base_out, run_expectancy_fangraphs)
plot_run_impact(impact, top = 12)
```

The comparison returns observed averages, a simulated reference range, and a
percentile. The range describes sampled game collections, not a causal effect.

## Available functions

- `import_scorecards()` reads a Plays CSV and retains review flags.
- `calculate_batting_stats()` returns player/game counts and BA, OBP, SLG, OPS.
- `compare_personal_season()` samples comparable game collections.
- `calculate_run_impact()` adds RE24 using a supplied 24-state expectancy table.
- `plot_run_impact()` draws total RE24 by player and returns the totals.
- `season_games()` turns an MLB schedule into one row per completed game.

## Data and current limits

`reviewed_scorecards` contains 179 plate appearances from five team scorecards,
spanning multiple teams and seasons. It is not a complete reference season.
`reviewed_base_out` adds MLB base-out transitions for the same team sides (188
events, joined one to one with the 179 plate appearances), and
`run_expectancy_fangraphs` is the published FanGraphs matrix.
`reviewed_team_seasons` holds the full 162-game season for each scorecard
team, built from MLB schedules, for real season comparisons.
Two smaller datasets support learning and testing: `demo_scorecards` (11
fictional entries for checking formulas by hand) and `twins_scorecard_2024`
(35 Twins plays from April 29, 2024).
Run-impact inputs must be independently verified by the caller. Review flagged
plays before calculating batting statistics and avoid duplicate game imports.

The vignette, `vignette("from-scorecard-to-run-value")`, walks through the
five scorecards from batting lines to RE24. See `?compare_personal_season` and
`?calculate_run_impact` for input contracts,
runnable examples, return values, and interpretation limits. The
[scorecard data guide](inst/doc/scorecard-data-guide.md) retains detailed
provenance, validation rules, and development checks.

## Development status and license

Version 0.0.5 adds `season_games()` and real team seasons, so
`compare_personal_season()` now runs on real games. Version 0.0.4 added
real-event RE24 data, a plotting function, and a vignette. From the
repository root, regenerate documentation with
`roxygen2::roxygenise("daimondstats")`. The package uses the MIT license; see
`LICENSE`. ChatGPT assisted with implementation and documentation, including
the documentation review on November 1, 2026. Claude assisted with the
version 0.0.4 and 0.0.5 base-out data, plot function, vignette, and season adapter.
