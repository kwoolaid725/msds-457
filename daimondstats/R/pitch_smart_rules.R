#' Pitch Smart daily maximums and rest requirements
#'
#' The MLB/USA Baseball Pitch Smart guidelines for ages 7 to 18, in long form:
#' one row per age group and pitch-count band. Used by
#' [check_pitch_counts()].
#'
#' @format A data frame with 28 rows and 6 integer columns:
#' \describe{
#'   \item{age_min, age_max}{Age group, inclusive.}
#'   \item{daily_max}{Most pitches allowed in one day for the age group.}
#'   \item{pitches_min, pitches_max}{Pitch-count band, inclusive.}
#'   \item{rest_days}{Calendar days of rest required after a day in the band.}
#' }
#' @details Ages 19 to 22 are omitted because the published rest table stops
#'   at 105 pitches while their daily maximum is 120. Many state associations
#'   and leagues set their own limits; edit a copy of this table and pass it
#'   to [check_pitch_counts()] to use them.
#' @source Major League Baseball and USA Baseball. n.d. "Pitching Guidelines."
#'   Pitch Smart. Accessed November 26, 2026.
#'   <https://www.mlb.com/pitch-smart/pitching-guidelines>. Built by
#'   `data-raw/pitch-smart.R`.
#' @examples
#' pitch_smart_rules[pitch_smart_rules$age_min == 11, ]
"pitch_smart_rules"
