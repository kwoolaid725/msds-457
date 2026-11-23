# Five reviewed team scorecards matched to MLB game records

A collection of 179 plate appearances from Arizona, St. Louis,
Minnesota, Cleveland, and New York Mets scorecards. Each included card
covers every plate appearance for one team in one game. Event identities
and batting counts were checked against independently retrieved MLB
feeds on October 25, 2026. The original Twins example remains available
separately.

## Usage

``` r
reviewed_scorecards
```

## Format

A data frame with 179 rows and 18 columns:

- game_id:

  Character MLB game identifier.

- team:

  Character batting team name from MLB.

- player:

  Character batter name from MLB.

- inning:

  Character inning number; rows follow card layout.

- play:

  Character reviewed canonical event label.

- confidence:

  Numeric score retained from the saved app export; not a probability
  that the reviewed label is correct.

- needs_review:

  Logical, FALSE for all accepted rows.

- game_date:

  Date of the game.

- side:

  Character, home or away.

- opponent:

  Character opponent name.

- batter_id:

  Integer MLB batter identifier.

- event_id:

  Character MLB atBatIndex, unique within each game.

- source_result:

  Character saved-result identifier and child card if applicable.

- source_cell:

  Character one-based card row/column identifier.

- source_play:

  Character label retained from the original saved export.

- source_needs_review:

  Logical flag reconstructed from saved app confidence/review indicators
  and its cached label disagreement.

- reference_play:

  Character canonical label independently derived from the retrieved MLB
  event.

- review_note:

  Character review decision or correction explanation.

## Source

Local dAImond Inning saved results and MLB Stats API game feeds,
retrieved October 25, 2026. Source IDs, feed URLs and SHA-256 hashes are
in data-raw/verification-manifest.json in the source repository. The
original app files are not required to rebuild the R data from its
source CSV. MLB feed URL pattern:
<https://statsapi.mlb.com/api/v1.1/game/746804/feed/live>. Official
counting totals used for validation are installed in
inst/extdata/reviewed_game_totals.csv and reviewed_player_totals.csv.

## Details

Accepted games are 746804 (Twins, April 29, 2024), 823644 (Mets, April
11, 2026), 825071 (Diamondbacks, June 15, 2026), 823774 (Guardians, June
17, 2026), and 822782 (Cardinals, July 31, 2026). Only the named team's
side is included. There are 49 distinct game/team/player combinations.

Review included card images, unique batter/inning/description matching,
complete event coverage, and player/team counting totals. Ten saved
labels differ from their reviewed values. Force outs where the batter
reaches first are fielder choices, not ordinary groundouts. Original
saved labels remain in source_play. Saved exports may already contain
contextual corrections; label agreement is not an independent
model-accuracy estimate.

Incomplete cards, extra detections, duplicate processing runs,
unresolved game assignments, and a card/official hit-versus-error
conflict were excluded. The data contain no complete season and do not
establish comparative team strength or a causal effect. Base-out
transitions for RE24 are in the companion dataset reviewed_base_out,
which joins by game_id and event_id. Do not combine this dataset with
twins_scorecard_2024 without deduplicating the overlapping Twins game.

## Examples

``` r
str(reviewed_scorecards)
#> 'data.frame':    179 obs. of  18 variables:
#>  $ game_id            : chr  "825071" "825071" "825071" "825071" ...
#>  $ team               : chr  "Arizona Diamondbacks" "Arizona Diamondbacks" "Arizona Diamondbacks" "Arizona Diamondbacks" ...
#>  $ player             : chr  "Ketel Marte" "Ketel Marte" "Ketel Marte" "Ketel Marte" ...
#>  $ inning             : chr  "1" "3" "5" "7" ...
#>  $ play               : chr  "flyout" "groundout" "groundout" "single" ...
#>  $ confidence         : num  0.949 0.947 0.949 0.951 0.948 ...
#>  $ needs_review       : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ game_date          : Date, format: "2026-06-15" "2026-06-15" ...
#>  $ side               : chr  "home" "home" "home" "home" ...
#>  $ opponent           : chr  "Los Angeles Angels" "Los Angeles Angels" "Los Angeles Angels" "Los Angeles Angels" ...
#>  $ batter_id          : int  606466 606466 606466 606466 672695 672695 672695 672695 682998 682998 ...
#>  $ event_id           : chr  "5" "23" "40" "56" ...
#>  $ source_result      : chr  "09a49fc97cd5" "09a49fc97cd5" "09a49fc97cd5" "09a49fc97cd5" ...
#>  $ source_cell        : chr  "r1c1" "r1c3" "r1c5" "r1c7" ...
#>  $ source_play        : chr  "flyout" "groundout" "groundout" "single" ...
#>  $ source_needs_review: logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
#>  $ reference_play     : chr  "flyout" "groundout" "groundout" "single" ...
#>  $ review_note        : chr  "Matched to the MLB event." "Matched to the MLB event." "Matched to the MLB event." "Matched to the MLB event." ...
batting <- calculate_batting_stats(reviewed_scorecards)
aggregate(PA ~ game_id + team, batting, sum)
#>   game_id                 team PA
#> 1  825071 Arizona Diamondbacks 35
#> 2  823774  Cleveland Guardians 33
#> 3  746804      Minnesota Twins 35
#> 4  823644        New York Mets 41
#> 5  822782  St. Louis Cardinals 35
```
