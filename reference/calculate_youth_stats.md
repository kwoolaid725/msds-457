# Calculate amateur batting statistics across games

Summarize each player's scored games with statistics suited to amateur
and youth baseball, where fielding errors are common and samples are
small. Includes on-base percentage with errors (OBPE), isolated power,
strikeout and walk rates, and batting average on balls in play.

## Usage

``` r
calculate_youth_stats(scorecards, by = c("player", "game"), min_pa = 25)
```

## Arguments

- scorecards:

  A data frame with the seven columns returned by
  [`import_scorecards()`](https://kwoolaid725.github.io/msds-457/reference/import_scorecards.md)
  or
  [`daimond_games()`](https://kwoolaid725.github.io/msds-457/reference/daimond_games.md).
  All entries must be reviewed (`needs_review = FALSE`) with known
  confidence.

- by:

  `"player"` (default) to pool each player's games within a team, or
  `"game"` for one row per game, team, and player.

- min_pa:

  Nonnegative whole number. Rows with fewer plate appearances are marked
  `small_sample = TRUE`. The default, 25, is a rule of thumb, not a
  statistical threshold.

## Value

One row per team and player (plus `game_id` when `by = "game"`), in
first-appearance order, with counting columns `G`, `PA`, `AB`, `H`,
`HR`, `ROE`, `BB`, `HBP`, `SO`, `SF`, `TB`; rate columns `OBP`, `OBPE`,
`ISO`, `K_rate`, `BB_rate`, `BABIP`; and logical `small_sample`. Zero
denominators produce `NA_real_`.

## Details

Formulas:

- OBP = (H + BB + HBP) / (AB + BB + HBP + SF)

- OBPE = (H + BB + HBP + ROE) / (AB + BB + HBP + SF), where ROE counts
  plays scored as `error`. Errors are an out the defense failed to make,
  so in youth games OBPE shows how often a batter puts pressure on the
  defense. The idea follows McBride (UC Irvine 2025), who reports that
  on-base with errors predicted youth scoring better than standard OBP;
  the exact formula here is this package's definition.

- ISO = (TB - H) / AB, extra bases per at-bat.

- K_rate = SO / PA and BB_rate = (BB, including intentional) / PA.

- BABIP = (H - HR) / (AB - SO - HR + SF).

Pooling with `by = "player"` matches players by exact team and player
name, so the same name on two teams stays separate, and spelling must be
consistent across scorecards. Automatic-runner and blank markers are not
plate appearances. Quality at-bats need pitch-by-pitch counts, which
paper scorecard cells do not record, so they are not calculated.

## References

UC Irvine School of Social Sciences. 2025. "Coaching Youth Baseball and
Softball with Sabermetrics." March 11.
<https://www.socsci.uci.edu/newsevents/news/2025/2025-03-11-mcbride-sabermetrics.php>.

## See also

[`calculate_batting_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_batting_stats.md)
for per-game BA, SLG, and OPS.

## Examples

``` r
youth <- calculate_youth_stats(reviewed_scorecards)
head(youth[order(-youth$OBPE), c("team", "player", "PA", "OBP", "OBPE")])
#>                    team          player PA  OBP OBPE
#> 43        New York Mets     Bo Bichette  5 0.80 0.80
#> 2  Arizona Diamondbacks Geraldo Perdomo  4 0.75 0.75
#> 7  Arizona Diamondbacks   Jordan Lawlar  4 0.50 0.50
#> 8  Arizona Diamondbacks     Pavin Smith  4 0.50 0.50
#> 12  St. Louis Cardinals   Alec Burleson  4 0.50 0.50
#> 15  St. Louis Cardinals      Masyn Winn  4 0.50 0.50
```
