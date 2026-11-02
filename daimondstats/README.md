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
R CMD INSTALL daimondstats
```

The runtime uses only packages distributed with R (`stats` and `utils`).
`roxygen2` is an optional development dependency for generating help files.

## Basic usage

```r
library(daimondstats)
# Included reviewed plays from five team scorecards:
batting <- calculate_batting_stats(reviewed_scorecards)
head(batting)
# Fictional eight-game reference season for learning the interface:
games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2026,
  home = rep(c(TRUE, FALSE), 4), win = c(1, 0, 1, 1, 0, 0, 1, 0))
set.seed(457)
result <- compare_personal_season(games, c("a", "b", "c"), simulations = 100)
result$summary
```

The comparison returns observed averages, a simulated reference range, and a
percentile. The range describes sampled game collections, not a causal effect.

## Available functions

- `import_scorecards()` reads a Plays CSV and retains review flags.
- `calculate_batting_stats()` returns player/game counts and BA, OBP, SLG, OPS.
- `compare_personal_season()` samples comparable game collections.
- `calculate_run_impact()` adds RE24 using a supplied 24-state expectancy table.

## Data and current limits

`reviewed_scorecards` contains 179 plate appearances from five team scorecards,
spanning multiple teams and seasons. It is not a complete reference season and
has no base-out transitions for RE24. The analytical examples are fictional.
Two smaller datasets support learning and testing: `demo_scorecards` (11
fictional entries for checking formulas by hand) and `twins_scorecard_2024`
(35 Twins plays from April 29, 2024).
Run-impact inputs must be independently verified by the caller. Review flagged
plays before calculating batting statistics and avoid duplicate game imports.

See `?compare_personal_season` and `?calculate_run_impact` for input contracts,
runnable examples, return values, and interpretation limits. The
[scorecard data guide](inst/doc/scorecard-data-guide.md) retains detailed
provenance, validation rules, and development checks.

## Development status and license

Version 0.0.3 is preliminary. Complete-season adapters, a real-event RE24
example, a plotting function, and a vignette remain planned. From the
repository root, regenerate documentation with
`roxygen2::roxygenise("daimondstats")`. The package uses the MIT license; see
`LICENSE`. ChatGPT assisted with implementation and documentation, including
this documentation review on November 1, 2026.
