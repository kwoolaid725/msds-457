#' Fictional youth pitching log
#'
#' One month of pitching for a fictional 12U team: 15 appearances by four
#' pitchers across nine dates, including a Saturday doubleheader. Built to
#' show each outcome of [check_pitch_counts()]: clean weeks, a pitcher who
#' returns before the required rest, and a day over the daily maximum. These
#' are not real players or games.
#'
#' @format A data frame with 15 rows and 5 columns:
#' \describe{
#'   \item{pitcher}{Fictional pitcher name.}
#'   \item{age}{Age on the game date, 10 to 12.}
#'   \item{date}{Game date (`Date`).}
#'   \item{game}{Opponent label; doubleheader games share a date.}
#'   \item{pitches}{Pitches thrown in that appearance.}
#' }
#' @source Created for this package by `data-raw/demo-pitch-log.R`.
#' @examples
#' check_pitch_counts(demo_pitch_log)
"demo_pitch_log"
