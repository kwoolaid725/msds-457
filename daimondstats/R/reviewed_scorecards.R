#' Five reviewed team scorecards matched to MLB game records
#'
#' A collection of 179 plate appearances from Arizona, St. Louis, Minnesota,
#' Cleveland, and New York Mets scorecards. Each included card covers every
#' plate appearance for one team in one game. Event identities and batting
#' counts were checked against independently retrieved MLB feeds on
#' October 25, 2026. The original Twins example remains available separately.
#'
#' @format A data frame with 179 rows and 18 columns:
#' \describe{
#'   \item{game_id}{Character MLB game identifier.}
#'   \item{team}{Character batting team name from MLB.}
#'   \item{player}{Character batter name from MLB.}
#'   \item{inning}{Character inning number; rows follow card layout.}
#'   \item{play}{Character reviewed canonical event label.}
#'   \item{confidence}{Numeric score retained from the saved app export;
#'     not a probability that the reviewed label is correct.}
#'   \item{needs_review}{Logical, FALSE for all accepted rows.}
#'   \item{game_date}{Date of the game.}
#'   \item{side}{Character, home or away.}
#'   \item{opponent}{Character opponent name.}
#'   \item{batter_id}{Integer MLB batter identifier.}
#'   \item{event_id}{Character MLB atBatIndex, unique within each game.}
#'   \item{source_result}{Character saved-result identifier and child card if applicable.}
#'   \item{source_cell}{Character one-based card row/column identifier.}
#'   \item{source_play}{Character label retained from the original saved export.}
#'   \item{source_needs_review}{Logical flag reconstructed from saved app
#'     confidence/review indicators and its cached label disagreement.}
#'   \item{reference_play}{Character canonical label independently derived
#'     from the retrieved MLB event.}
#'   \item{review_note}{Character review decision or correction explanation.}
#' }
#' @details
#' Accepted games are 746804 (Twins, April 29, 2024), 823644 (Mets, April 11,
#' 2026), 825071 (Diamondbacks, June 15, 2026), 823774 (Guardians, June 17,
#' 2026), and 822782 (Cardinals, July 31, 2026). Only the named team's side
#' is included. There are 49 distinct game/team/player combinations.
#'
#' Review included card images, unique batter/inning/description matching,
#' complete event coverage, and player/team counting totals. Ten saved labels
#' differ from their reviewed values. Force outs where the batter reaches
#' first are fielder choices, not ordinary groundouts. Original saved labels
#' remain in source_play. Saved exports may already contain contextual
#' corrections; label agreement is not an independent model-accuracy estimate.
#'
#' Incomplete cards, extra detections, duplicate processing runs, unresolved
#' game assignments, and a card/official hit-versus-error conflict were excluded.
#' The data contain no complete season and do not establish comparative team
#' strength or a causal effect. Base-out transitions required for RE24 are
#' not included. Do not combine this dataset with twins_scorecard_2024 without
#' deduplicating the overlapping Twins game.
#'
#' @source Local dAImond Inning saved results and MLB Stats API game feeds,
#' retrieved October 25, 2026. Source IDs, feed URLs and SHA-256 hashes are in
#' data-raw/verification-manifest.json in the source repository. The original
#' app files are not required to rebuild the R data from its source CSV.
#' MLB feed URL pattern: \url{https://statsapi.mlb.com/api/v1.1/game/746804/feed/live}.
#' Official counting totals used for validation are installed in
#' inst/extdata/reviewed_game_totals.csv and reviewed_player_totals.csv.
#'
#' @examples
#' str(reviewed_scorecards)
#' batting <- calculate_batting_stats(reviewed_scorecards)
#' aggregate(PA ~ game_id + team, batting, sum)
"reviewed_scorecards"
