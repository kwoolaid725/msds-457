# daimondstats

An early R package for analyzing a fan's personal collection of baseball games.
Version 0.0.2 adds personal-season comparisons and situational run value (RE24).
The original scorecard importer and batting calculator remain supporting tools.
It uses base R, with no extra runtime packages.

Source: [MSDS 457 final-project package](https://github.com/kwoolaid725/msds-457/tree/main/daimondstats).

## Personal-season analytics

- `compare_personal_season(games, game_ids, metric = "win", strata = "home")`
  compares selected games with the other games in one team's reference season.
  It samples same-size collections without replacement, matching home/away
  counts by default. Outputs include means, differences, simulated means,
  a 95% reference range, and a tie-adjusted percentile. This range describes
  hypothetical game collections, not uncertainty in a causal effect. Sampling
  assumes exchangeability within the supplied strata; selection bias may remain.
- `calculate_run_impact(plays, expectancy)` applies a supplied 24-state reference
  matrix to verified before/after base-out states. It returns RE24 for each event:
  runs scored + ending expectancy - starting expectancy. Three outs sets ending
  expectancy to zero. `verified` is the caller's assertion; this function does
  not verify the events against MLB records or infer runner movement.

See `?compare_personal_season` and `?calculate_run_impact` for runnable examples
and the full input contracts. The new functions operate on prepared data frames;
the scorecard CSV does not contain enough fields to supply them directly.
Their current examples and tests are fictional. A real scorecard dataset is
included below. Season-wide feed adapters, documented historical reference
matrices, and validation of RE24 on real events remain work for the next milestone.

## Real scorecard data

`twins_scorecard_2024` contains 35 recorded plays involving 12 Minnesota Twins
players against the Chicago White Sox on April 29, 2024. It was extracted from
a saved dAImondInning result and includes the original predictions and confidence
scores alongside cached MLB reference labels. One label differs from its
reference and is flagged for review; the original prediction is preserved.

```r
str(daimondstats::twins_scorecard_2024)
subset(daimondstats::twins_scorecard_2024, needs_review,
       select = c(player, inning, play, reference_play))
```

The dataset is documented in `R/twins_scorecard_2024.R`. Its extraction script,
CSV snapshot, and R build script are in `data-raw/`. It does not include the
base-out states needed to calculate RE24 directly.

## Try it

From the directory containing this package:

```sh
R CMD INSTALL daimondstats
```

```r
library(daimondstats)
csv <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
plays <- import_scorecards(csv, game_id = "demo-01")
calculate_batting_stats(plays)
# Or use the included, documented fictional dataset:
calculate_batting_stats(demo_scorecards)
```

The example contains 11 entries, two fictional players, and seven normalized
columns. It is a teaching/test dataset, not an analysis of an actual game.
Alex Demo's six plate appearances include three hits, a strikeout, a walk,
and a sacrifice fly: AB = 4, H = 3, TB = 7, BA = .750, OBP = 4/6,
SLG = 1.750. Sam Demo has no at-bats; BA and SLG are missing, not zero.

## Functions and input contract

- `import_scorecards(path, game_id)` accepts the standard **Plays** CSV from
  dAImond Inning. Keep the original Team, Player, Inning, Play, Confidence, and
  Needs Review headers when customizing exports. Supply a game ID yourself:
  the export has no game-ID column. Extra columns are ignored. JSON, player
  summary sheets, and older Row/Col-only CSVs are outside this first version.
- `calculate_batting_stats(scorecards)` calculates game/team/player totals
  and BA, OBP, SLG, OPS from that data frame. It also accepts data frames
  prepared independently using the documented seven-column contract.

Review flags are preserved. The calculator stops for flagged rows or missing
confidence rather than dropping them and presenting an incomplete batting line.
Correct readings against the original card before clearing flags. Confidence
is not a replacement for human review and is not used to weight statistics.

Unknown outcomes cause errors. Walks, sacrifice flies, bunts, errors, catcher
interference, and automatic runners receive distinct scoring treatment. Rates
are unrounded, and undefined rates are `NA`, not `0` or `NaN`.

Player names are grouped only within each game/team. Reusing a name for two
different players on one team is not resolved. Legitimate repeated events are
retained; the caller must not import the same game twice. The app already omits
blank and bad-crop cells from its Plays CSV, so missing upstream observations
cannot be detected by this importer. Supported labels are explicit in the code;
other event types require further work.

## Development and checks

All four public functions have roxygen comments in `R/` and matching installed
help files in `man/`. The initial Rd files are maintained alongside the comments;
roxygen2 generation can replace them when that development dependency is added.
`tests/core.R` and `tests/personal-season.R` use base-R assertions and error
checks. No test framework is required.

```sh
R CMD build daimondstats
R CMD check --no-manual daimondstats_0.0.2.tar.gz
```

The suite checks hand-calculated outcomes, every supported play category,
zero-denominator rates, empty inputs, repeated appearances, grouping, review
flags, malformed files, missing columns, and invalid confidence values.
Additional tests verify matched game sampling, reproducibility with `set.seed`,
constant reference distributions, duplicate IDs, verified-event requirements,
inning-ending RE24, and the complete-inning run-value identity.

Build and `R CMD check --no-manual` completed with final status **OK** on
October 24, 2026, using R 4.5.1, including examples and both test scripts.
Repository-index lookups were unavailable; PDF manual generation was not checked.
The real dataset's UTF-8 encoding was corrected before this check, preserving
all data values and the accented player name.

Still planned: additional reviewed games and official-record comparisons,
documented expectancy data, cautious scorebook-pattern discovery, a plot function,
a vignette, and the final project guides. WPA and lineup
simulation are later possibilities. This is not the completed final package.

## Sources

Weinberg, Neil. 2014. "RE24." FanGraphs, July 30.
https://library.fangraphs.com/misc/re24/.

Wickham, Hadley, and Jennifer Bryan. 2023. *R Packages*. 2nd ed. O'Reilly Media.
Chapter 13, "Testing Basics." https://r-pkgs.org/testing-basics.html.

Data shape inspected in the local dAImond Inning app's
`pipeline/10_output/scorecard_reports.py` (`build_result_tables`) and
`pipeline/10_output/interpreter.py` (`PLAY_LABELS`) on October 9, 2026.

Development assistance: ChatGPT helped inspect the export format, implement
these functions, write checks and documentation, and prepare discussion notes.
