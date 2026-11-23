# Compare a personal game collection with a reference season

Sample same-size game collections without replacement, optionally
preserving the personal collection's counts within strata such as
home/away or opponent. This is a descriptive reference distribution, not
an estimate of the effect of scorekeeping. Games are assumed
exchangeable within each supplied stratum.

## Usage

``` r
compare_personal_season(
  games,
  game_ids,
  metric = "win",
  strata = "home",
  simulations = 2000L
)
```

## Arguments

- games:

  Data frame with unique character `game_id`, nonmissing `team` and
  `season`, a finite numeric metric, and any requested stratum columns.
  Must contain exactly one team's one season, including the selected
  games.

- game_ids:

  Unique character IDs of the personally recorded games.

- metric:

  Name of the numeric game-level measure to average. Default `win`
  requires 0/1 values, so the mean is winning percentage.

- strata:

  Character vector of columns to match jointly. Default `home` preserves
  home/away counts. Use `character(0)` for unrestricted sampling.

- simulations:

  Positive integer number of draws; default 2000.

## Value

A list containing `summary` (one row with sample sizes, selected,
other-game and season means, selected-minus-other difference, 2.5th and
97.5th reference percentiles, and a tie-adjusted percentile rank),
`simulated_means`, and `settings`. The reference range is not a
confidence interval for a causal effect or underlying player ability.
Summary fields include `personal_mean`, `other_mean`, `season_mean`,
`difference`, `reference_low`, `reference_high`, and
`reference_percentile`.

## Details

Supply complete game-level records, not one row per upload or team side.
Duplicates and missing IDs are errors. At least one selected and one
unselected game are required. Sampling includes the selected games in
the reference population. Use
[`set.seed()`](https://rdrr.io/r/base/Random.html) before calling for
reproducibility. More detailed strata can leave little variation.
Unmeasured selection differences remain, and this function does not test
many patterns at once.

## See also

[`season_games()`](https://kwoolaid725.github.io/msds-457/reference/season_games.md),
[reviewed_team_seasons](https://kwoolaid725.github.io/msds-457/reference/reviewed_team_seasons.md),
[`calculate_batting_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_batting_stats.md),
[`calculate_run_impact()`](https://kwoolaid725.github.io/msds-457/reference/calculate_run_impact.md)

## Examples

``` r
games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2026,
                    home = rep(c(TRUE, FALSE), 4), win = c(1, 0, 1, 1, 0, 0, 1, 0))
set.seed(457)
compare_personal_season(games, c("a", "b", "c"), simulations = 100)$summary
#>   metric selected_games other_games personal_mean other_mean season_mean
#> 1    win              3           5     0.6666667        0.4         0.5
#>   difference reference_low reference_high reference_percentile
#> 1  0.2666667     0.3333333              1                 64.5
```
