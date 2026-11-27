# Download your scorecards from the dAImond Inning app

Fetch reviewed play-by-play and pitcher lines for the scorecards saved
in your dAImond Inning account. The plays use the same columns as
[`import_scorecards()`](https://kwoolaid725.github.io/msds-457/reference/import_scorecards.md),
so they work directly with every analysis function in this package.

## Usage

``` r
daimond_games(
  from = NULL,
  to = NULL,
  league = NULL,
  base_url = getOption("daimondstats.base_url", "https://daimondinning.com")
)
```

## Arguments

- from, to:

  Optional first and last game dates as `Date` or `"YYYY-MM-DD"` text.

- league:

  Optional league filter, such as `"mlb"` or a league name used in the
  app.

- base_url:

  App address. Defaults to the `daimondstats.base_url` option, or
  `https://daimondinning.com`.

## Value

A list with three data frames:

- `games`: one row per scorecard with `game_id`, `game_date`, `league`,
  `game_pk`, `home_team`, `away_team`, and `scored_side`.

- `plays`: the seven columns of
  [`import_scorecards()`](https://kwoolaid725.github.io/msds-457/reference/import_scorecards.md)
  plus `game_date`, `jersey`, and `lineup_slot`. `game_id` is the app's
  scorecard id.

- `pitchers`: `game_id`, `game_date`, `team`, `pitcher`, `outs`, `bf`,
  `pitches`, `h`, `bb`, `so`, and `needs_review`.

## Details

Requires an API key (see
[`daimond_auth()`](https://kwoolaid725.github.io/msds-457/reference/daimond_auth.md))
and an internet connection. Results are paged by the server and combined
here. Entries the app still marks for review keep `needs_review = TRUE`;
the analysis functions refuse them until they are corrected in the app.

Errors are reported in plain language: a missing or revoked key, a plan
without API access, too many requests, or the app being unreachable.

## See also

[`daimond_auth()`](https://kwoolaid725.github.io/msds-457/reference/daimond_auth.md),
[`calculate_youth_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_youth_stats.md),
[`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md)

## Examples

``` r
if (FALSE) { # \dontrun{
daimond_auth("di_pat_your_key_here")
season <- daimond_games(from = "2026-04-01", to = "2026-07-31")
calculate_youth_stats(season$plays)
} # }
```
