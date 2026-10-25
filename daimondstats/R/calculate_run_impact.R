#' Calculate run expectancy added for verified events
#'
#' Apply a supplied reference matrix to verified base-out transitions.
#' RE24 equals runs scored plus ending expectancy minus starting expectancy.
#'
#' @param plays Data frame containing character `game_id`, `event_id`, `player`;
#'   integer-valued `outs_before`, `bases_before`, `outs_after`, `bases_after`,
#'   `runs_scored`; and logical `verified`. All events must be verified.
#'   Base masks use 1 for first, 2 for second and 4 for third, added together.
#' @param expectancy Data frame with all 24 distinct combinations of `outs`
#'   (0:2) and `bases` (0:7), plus finite nonnegative numeric `expected_runs`.
#' @return The input data frame with numeric `re_before`, `re_after`, and `re24`
#'   columns. Three outs sets ending expectancy to zero. Empty input returns
#'   the same columns with zero rows. Sum `re24` over the desired events.
#' @details The caller chooses a documented reference matrix appropriate to
#'   the league and run environment. This function neither estimates that matrix
#'   nor infers runner movement. `verified` is a caller assertion, not automatic
#'   verification. Incomplete or assumed states must not be marked verified.
#'   Duplicate game/event IDs and invalid states are errors. Standalone runner
#'   events need the responsible runner in `player`; do not credit them to the
#'   batter. Walk-off states use the supplied base-out expectancy, not forced
#'   zero simply because the game ended. RE24 describes situational value,
#'   not a prediction or proof of clutch ability. Original columns are retained.
#' @references Weinberg, Neil. 2014. "RE24." FanGraphs, July 30.
#'   https://library.fangraphs.com/misc/re24/
#' @examples
#' # Fictional matrix for demonstrating the interface, not an MLB estimate.
#' reference <- expand.grid(outs = 0:2, bases = 0:7)
#' reference$expected_runs <- (3 - reference$outs) * 0.2 + reference$bases * 0.1
#' plays <- data.frame(game_id = "demo", event_id = "1", player = "Demo Batter",
#'   outs_before = 0, bases_before = 0, outs_after = 0, bases_after = 0,
#'   runs_scored = 1, verified = TRUE)
#' calculate_run_impact(plays, reference)$re24
#' @export
calculate_run_impact <- function(plays, expectancy) {
  numeric_fields <- c("outs_before", "bases_before", "outs_after", "bases_after", "runs_scored")
  fields <- c("game_id", "event_id", "player", numeric_fields, "verified")
  if (!is.data.frame(plays) || anyDuplicated(names(plays)) ||
      !all(fields %in% names(plays))) {
    stop("plays must contain identifiers, before/after states, runs_scored and verified.", call. = FALSE)
  }
  for (nm in c("game_id", "event_id", "player")) {
    if (!is.character(plays[[nm]]) || anyNA(plays[[nm]]) ||
        any(!nzchar(trimws(plays[[nm]])))) {
      stop(nm, " must contain nonempty character values.", call. = FALSE)
    }
  }
  if (anyDuplicated(plays[c("game_id", "event_id")])) {
    stop("Duplicate game/event IDs are not allowed.", call. = FALSE)
  }
  integer_between <- function(x, lo, hi) {
    is.numeric(x) && is.null(dim(x)) && !anyNA(x) &&
      all(is.finite(x) & x == floor(x) & x >= lo & x <= hi)
  }
  limits <- list(c(0, 2), c(0, 7), c(0, 3), c(0, 7), c(0, Inf))
  for (i in seq_along(numeric_fields)) {
    if (!integer_between(plays[[numeric_fields[i]]], limits[[i]][1], limits[[i]][2])) {
      stop("Invalid integer values in ", numeric_fields[i], ".", call. = FALSE)
    }
  }
  if (any(plays$outs_after < plays$outs_before)) {
    stop("Outs cannot decrease within an event.", call. = FALSE)
  }
  if (!is.logical(plays$verified) || anyNA(plays$verified) || !all(plays$verified)) {
    stop("All events must have verified = TRUE before assigning run impact.", call. = FALSE)
  }
  if (!is.data.frame(expectancy) || anyDuplicated(names(expectancy)) ||
      !all(c("outs", "bases", "expected_runs") %in% names(expectancy)) ||
      nrow(expectancy) != 24L || !integer_between(expectancy$outs, 0, 2) ||
      !integer_between(expectancy$bases, 0, 7) ||
      anyDuplicated(expectancy[c("outs", "bases")]) ||
      !is.numeric(expectancy$expected_runs) || anyNA(expectancy$expected_runs) ||
      any(!is.finite(expectancy$expected_runs) | expectancy$expected_runs < 0)) {
    stop("expectancy must contain 24 unique valid states and nonnegative expected_runs.", call. = FALSE)
  }
  keys <- expectancy$outs * 8 + expectancy$bases
  plays$re_before <- expectancy$expected_runs[match(plays$outs_before * 8 + plays$bases_before, keys)]
  plays$re_after <- expectancy$expected_runs[match(plays$outs_after * 8 + plays$bases_after, keys)]
  plays$re_after[plays$outs_after == 3] <- 0
  plays$re24 <- plays$runs_scored + plays$re_after - plays$re_before
  plays
}
