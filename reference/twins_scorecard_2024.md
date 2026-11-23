# Minnesota Twins scorecard entries from April 29, 2024

Thirty-five recorded plays involving 12 Twins players in their game
against the Chicago White Sox. The play labels and confidence scores
come from a saved dAImondInning scorecard result. Player names and
comparison labels come from the MLB reference events stored with that
result.

## Usage

``` r
twins_scorecard_2024
```

## Format

A data frame with 35 rows and 10 columns:

- game_id:

  Character. MLB game identifier, `"746804"`.

- team:

  Character. Batting team, `"Minnesota Twins"`.

- player:

  Character. Batter name from the matched MLB reference event.

- inning:

  Character. Inning label retained from the scorecard result.

- play:

  Character. Original canonical play label predicted by the app.

- confidence:

  Numeric. The app's play-classification score, between zero and one;
  this is not a guarantee that the reading is correct.

- needs_review:

  Logical. TRUE when the app flagged the play, confidence is missing, or
  the play label differs from its reference label.

- game_date:

  Date. Game date, April 29, 2024.

- reference_play:

  Character. Canonical play label in the cached MLB reference event.

- play_matches_reference:

  Logical. Whether `play` equals `reference_play`.

## Source

dAImondInning saved result `uploads/7617d135a223/result_full.json`,
extracted October 18, 2026. The corresponding MLB feed is cached as
`data/mlb_cache/game_746804.json` in that app. MLB reference:
<https://statsapi.mlb.com/api/v1.1/game/746804/feed/live>.

## Details

Blank cells and bad-crop markers are excluded. Each retained cell has
one reference event matched by its scorecard row and column. Rows follow
the scorecard layout, not chronological play order. All 35 matched
batter/inning pairs were checked against the app's cached MLB game feed.

The original play predictions are retained. Thirty-four labels match the
reference; Willi Castro's ninth-inning play is classified as `flyout`
while the reference reports `lineout`. That row has
`needs_review = TRUE`. The seven columns required by
[`calculate_batting_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_batting_stats.md)
are included, but the flagged row must be reviewed before using that
function. Base-out states required for RE24 are not included.

## Examples

``` r
str(twins_scorecard_2024)
#> 'data.frame':    35 obs. of  10 variables:
#>  $ game_id               : chr  "746804" "746804" "746804" "746804" ...
#>  $ team                  : chr  "Minnesota Twins" "Minnesota Twins" "Minnesota Twins" "Minnesota Twins" ...
#>  $ player                : chr  "Ryan Jeffers" "Ryan Jeffers" "Ryan Jeffers" "Ryan Jeffers" ...
#>  $ inning                : chr  "1" "3" "6" "8" ...
#>  $ play                  : chr  "flyout" "flyout" "walk" "flyout" ...
#>  $ confidence            : num  0.945 0.949 0.948 0.946 0.947 ...
#>  $ needs_review          : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ game_date             : Date, format: "2024-04-29" "2024-04-29" ...
#>  $ reference_play        : chr  "flyout" "flyout" "walk" "flyout" ...
#>  $ play_matches_reference: logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
subset(twins_scorecard_2024, needs_review,
       select = c(player, inning, play, reference_play))
#>          player inning   play reference_play
#> 28 Willi Castro      9 flyout        lineout
```
