#' Fictional scorecard plays for learning and testing
#'
#' Eleven scorecard entries for two fictional players in one game, including
#' an automatic-runner marker that is not a plate appearance. Designed for
#' checking formulas by hand; these are not observations from an actual game
#' or measured classifier confidence values.
#'
#' @format A data frame with 11 rows and 7 columns:
#' \describe{
#'   \item{game_id}{Game identifier, demo-01.}
#'   \item{team}{Fictional team name.}
#'   \item{player}{Fictional player name.}
#'   \item{inning}{Character inning label, including an 8+ continuation.}
#'   \item{play}{Canonical play label.}
#'   \item{confidence}{Illustrative confidence between zero and one.}
#'   \item{needs_review}{Logical review flag. All entries are reviewed examples.}
#' }
#' @source Created for this package. CSV headers and display labels follow
#'   dAImond Inning's Plays exporter, inspected October 9, 2026.
#' @examples
#' calculate_batting_stats(demo_scorecards)
"demo_scorecards"
