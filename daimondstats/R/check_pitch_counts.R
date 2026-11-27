#' Check youth pitch counts against Pitch Smart guidelines
#'
#' Apply the MLB/USA Baseball Pitch Smart daily maximums and required rest
#' days to a log of pitching appearances. Each pitcher's days are checked in
#' date order, so a pitcher who returns before the required rest is flagged
#' along with any day over the age group's maximum.
#'
#' @param appearances A data frame with one row per pitching appearance and
#'   columns `pitcher` (nonempty character), `age` (whole number from 7 to
#'   18 on the game date), `date` (a `Date` or `"YYYY-MM-DD"` text), and
#'   `pitches` (nonnegative whole number). Extra columns are ignored.
#' @param rules A rules table with the columns of [pitch_smart_rules]. Leagues
#'   with stricter limits can pass an edited copy.
#' @return One row per pitcher and date, ordered by pitcher and date, with
#'   `pitcher`, `date`, `age`, `pitches`, `appearances` (rows combined that
#'   day), `daily_max`, `rest_days`, `next_eligible` (first date the pitcher
#'   may pitch again), `over_max`, `short_rest`, and `status`, which is `"ok"`,
#'   `"over daily max"`, `"short rest"`, or both joined by `"; "`.
#' @details The daily maximum applies to a calendar day, so two appearances
#'   on the same date (for example, a doubleheader) are added together before
#'   checking. Required rest is counted in calendar days: two days of rest
#'   after pitching on Saturday means the pitcher is next eligible on Tuesday.
#'   A day over the maximum still receives the largest rest band.
#'
#'   Pitch counts come from the scorecard's pitcher box. A missed or
#'   misread count changes the result, so review the counts first. The check
#'   only covers the games in `appearances`; pitching for another team or
#'   league is invisible to it. Ages 19 to 22 are not supported because the
#'   published rest table does not cover their full daily maximum.
#' @references Major League Baseball and USA Baseball. n.d. "Pitching
#'   Guidelines." Pitch Smart. Accessed November 26, 2026.
#'   <https://www.mlb.com/pitch-smart/pitching-guidelines>.
#' @seealso [pitch_smart_rules]
#' @examples
#' log <- data.frame(
#'   pitcher = c("Ava", "Ava", "Ben", "Ben"),
#'   age = c(11, 11, 12, 12),
#'   date = c("2026-05-02", "2026-05-04", "2026-05-02", "2026-05-03"),
#'   pitches = c(60, 30, 90, 10)
#' )
#' check_pitch_counts(log)
#' @export
check_pitch_counts <- function(appearances, rules = daimondstats::pitch_smart_rules) {
  required <- c("pitcher", "age", "date", "pitches")
  if (!is.data.frame(appearances) || !all(required %in% names(appearances))) {
    stop("`appearances` must be a data frame with pitcher, age, date, pitches.",
         call. = FALSE)
  }
  rule_cols <- c("age_min", "age_max", "daily_max", "pitches_min",
                 "pitches_max", "rest_days")
  if (!is.data.frame(rules) || !all(rule_cols %in% names(rules)) ||
      nrow(rules) == 0L || anyNA(rules[rule_cols])) {
    stop("`rules` must be a complete table like pitch_smart_rules.", call. = FALSE)
  }
  x <- appearances
  if (!is.character(x$pitcher) || anyNA(x$pitcher) || any(!nzchar(trimws(x$pitcher)))) {
    stop("`pitcher` must contain nonempty character values.", call. = FALSE)
  }
  whole <- function(v) is.numeric(v) && !anyNA(v) && all(v == floor(v))
  if (!whole(x$pitches) || any(x$pitches < 0)) {
    stop("`pitches` must be nonnegative whole numbers without missing values.",
         call. = FALSE)
  }
  if (!whole(x$age) || any(x$age < min(rules$age_min) | x$age > max(rules$age_max))) {
    stop("`age` must be whole numbers covered by `rules` (", min(rules$age_min),
         " to ", max(rules$age_max), ").", call. = FALSE)
  }
  date <- if (inherits(x$date, "Date")) x$date else
    as.Date(as.character(x$date), format = "%Y-%m-%d", optional = TRUE)
  if (anyNA(date)) {
    stop("`date` must be Date values or YYYY-MM-DD text.", call. = FALSE)
  }
  x <- data.frame(pitcher = trimws(x$pitcher), date = date, age = x$age,
                  pitches = x$pitches, stringsAsFactors = FALSE)

  out_cols <- c("pitcher", "date", "age", "pitches", "appearances", "daily_max",
                "rest_days", "next_eligible", "over_max", "short_rest", "status")
  if (nrow(x) == 0L) {
    empty <- data.frame(pitcher = character(), date = as.Date(character()),
                        age = numeric(), pitches = numeric(), appearances = integer(),
                        daily_max = integer(), rest_days = integer(),
                        next_eligible = as.Date(character()), over_max = logical(),
                        short_rest = logical(), status = character())
    return(empty[out_cols])
  }
  key <- paste(x$pitcher, x$date)
  ages <- tapply(x$age, key, function(a) length(unique(a)))
  if (any(ages > 1L)) {
    stop("A pitcher has two different ages on the same date.", call. = FALSE)
  }
  days <- stats::aggregate(list(pitches = x$pitches), x[c("pitcher", "date", "age")], sum)
  days$appearances <- as.integer(stats::aggregate(
    list(n = x$pitches), x[c("pitcher", "date", "age")], length)$n)
  days <- days[order(days$pitcher, days$date), , drop = FALSE]
  rownames(days) <- NULL

  group <- vapply(days$age, function(a) {
    which(rules$age_min <= a & rules$age_max >= a)[1]
  }, integer(1))
  days$daily_max <- as.integer(rules$daily_max[group])
  days$rest_days <- vapply(seq_len(nrow(days)), function(i) {
    band <- rules[rules$age_min <= days$age[i] & rules$age_max >= days$age[i], ]
    if (days$pitches[i] == 0) return(0L)
    hit <- band$rest_days[band$pitches_min <= days$pitches[i] &
                            band$pitches_max >= days$pitches[i]]
    as.integer(if (length(hit)) hit[1] else max(band$rest_days))
  }, integer(1))
  days$next_eligible <- days$date + days$rest_days + 1L
  days$over_max <- days$pitches > days$daily_max
  # A short outing does not cancel rest still owed from an earlier day, so
  # compare with the latest eligibility date among all earlier days.
  days$short_rest <- FALSE
  for (who in unique(days$pitcher)) {
    idx <- which(days$pitcher == who)
    if (length(idx) < 2L) next
    owed <- cummax(as.numeric(days$next_eligible[idx]))
    days$short_rest[idx[-1]] <- as.numeric(days$date[idx[-1]]) < owed[-length(idx)]
  }
  days$status <- ifelse(days$over_max & days$short_rest, "over daily max; short rest",
                        ifelse(days$over_max, "over daily max",
                               ifelse(days$short_rest, "short rest", "ok")))
  days[out_cols]
}
