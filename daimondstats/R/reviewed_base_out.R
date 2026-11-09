#' Base-out transitions for the five reviewed scorecard teams
#'
#' Every offensive event for the team side covered by `reviewed_scorecards`,
#' with outs and occupied bases before and after the event and runs scored on
#' it. The 179 batting events join one to one with `reviewed_scorecards` by
#' `game_id` and `event_id`. Nine further rows are runner events (stolen bases,
#' a wild pitch, a passed ball and a pickoff) that occur during a plate
#' appearance and are credited to the runner, not the batter.
#'
#' @format A data frame with 188 rows and 15 columns:
#' \describe{
#'   \item{game_id}{Character MLB game identifier.}
#'   \item{team}{Character batting team name from MLB.}
#'   \item{event_id}{Character event identifier. Batting events use the MLB
#'     atBatIndex; runner events append the play index, as in `"29.2"`.}
#'   \item{at_bat_index}{Integer MLB atBatIndex of the plate appearance.}
#'   \item{inning}{Integer inning number.}
#'   \item{event_type}{Character MLB event type, such as `single` or
#'     `stolen_base_2b`.}
#'   \item{batting_event}{Logical, TRUE for the plate-appearance result.}
#'   \item{player}{Character credited player: the batter for batting events,
#'     the moving runner for runner events.}
#'   \item{player_id}{Integer MLB identifier of the credited player.}
#'   \item{outs_before, outs_after}{Integer outs before (0 to 2) and after
#'     (0 to 3) the event.}
#'   \item{bases_before, bases_after}{Integer base mask: 1 for first, 2 for
#'     second, 4 for third, added together. Zero after the third out.}
#'   \item{runs_scored}{Integer runs scored on the event.}
#'   \item{verified}{Logical, TRUE for all rows; see Details.}
#' }
#' @details
#' States were replayed from each play's runner movements in the MLB feed.
#' A row is marked verified only when the replayed outs and occupied bases match
#' the feed's own post-play values for that plate appearance, and the replayed
#' runs for each half-inning match the official linescore. All 188 rows passed.
#' Batting events include runner advances on the same play, such as an advance
#' on a throw after a single, following the usual RE24 convention.
#'
#' Base-out states come from MLB records, not from reading the scorecard. The
#' scorecard reader does not record runner positions.
#'
#' @source MLB Stats API game feeds retrieved November 8, 2026. Feed URLs and
#'   SHA-256 hashes are in data-raw/base-out-manifest.json in the source
#'   repository, and data-raw/base-out-states.py rebuilds the CSV.
#' @seealso [run_expectancy_fangraphs], [calculate_run_impact()]
#' @examples
#' impact <- calculate_run_impact(reviewed_base_out, run_expectancy_fangraphs)
#' aggregate(re24 ~ team, impact, sum)
"reviewed_base_out"

#' FanGraphs run expectancy matrix
#'
#' Expected runs from a base-out state to the end of the inning, as published
#' in the FanGraphs RE24 library entry for a run environment of 4.15 runs per
#' game. The format matches the `expectancy` argument of
#' [calculate_run_impact()].
#'
#' @format A data frame with 24 rows and 3 columns:
#' \describe{
#'   \item{outs}{Integer outs, 0 to 2.}
#'   \item{bases}{Integer base mask: 1 for first, 2 for second, 4 for third.}
#'   \item{expected_runs}{Numeric expected runs to the end of the inning.}
#' }
#' @details One published matrix is applied to every game. Real run
#'   environments differ by season and park, so RE24 totals from this table
#'   are approximate. Callers can supply a season-specific matrix in the same
#'   format.
#' @source Weinberg, Neil. 2014. "RE24." FanGraphs, July 30.
#'   \url{https://library.fangraphs.com/misc/re24/}. Values transcribed
#'   November 8, 2026.
#' @examples
#' xtabs(expected_runs ~ bases + outs, run_expectancy_fangraphs)
"run_expectancy_fangraphs"
