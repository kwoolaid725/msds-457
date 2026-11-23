# daimondstats 0.0.5

* New `season_games()` turns an MLB Stats API regular-season schedule into one
  row per completed game. It filters on the coded status `F`, because
  postponed games also report an abstract state of "Final".
* New dataset `reviewed_team_seasons`: full 162-game seasons for the five
  scorecard teams (810 rows). Win totals match each team's final record.
* `compare_personal_season()` now runs on real games. The vignette adds a
  section placing the scored Twins game within the 2024 Twins season.
* `jsonlite` added to Imports.
* Added this pkgdown website.

# daimondstats 0.0.4

* New dataset `reviewed_base_out`: 188 offensive events with base-out states
  rebuilt from MLB game feeds. Every row's outs, bases, and half-inning runs
  are checked against the feed.
* New dataset `run_expectancy_fangraphs`: the published FanGraphs 24-state
  run expectancy matrix.
* New `plot_run_impact()` draws total RE24 by player.
* New vignette, "From scorecard to run value".

# daimondstats 0.0.3

* New dataset `reviewed_scorecards`: 179 plate appearances from five team
  scorecards. Every player's and team's counting totals match official MLB
  box scores.
* Revised documentation for all functions and datasets.

# daimondstats 0.0.2

* New `compare_personal_season()` compares a set of scored games with
  same-size samples from one team's season, matched on home and away.
* New `calculate_run_impact()` computes event-level RE24 from base-out
  transitions and a 24-state run expectancy matrix.
* New dataset `twins_scorecard_2024`: 35 plays from one Twins game.

# daimondstats 0.0.1

* First version, with `import_scorecards()` and `calculate_batting_stats()`.
* Includes a small fictional demo dataset and base R tests.
