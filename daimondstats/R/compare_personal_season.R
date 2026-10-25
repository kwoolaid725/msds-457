#' Compare a personal game collection with a reference season
#'
#' Sample same-size game collections without replacement, optionally preserving
#' the personal collection's counts within strata such as home/away or opponent.
#' This is a descriptive reference distribution, not an estimate of the effect
#' of scorekeeping. Games are assumed exchangeable within each supplied stratum.
#'
#' @param games Data frame with unique character `game_id`, nonmissing `team`
#'   and `season`, a finite numeric metric, and any requested stratum columns.
#'   Must contain exactly one team's one season, including the selected games.
#' @param game_ids Unique character IDs of the personally recorded games.
#' @param metric Name of the numeric game-level measure to average. Default
#'   `win` requires 0/1 values, so the mean is winning percentage.
#' @param strata Character vector of columns to match jointly. Default `home`
#'   preserves home/away counts. Use `character(0)` for unrestricted sampling.
#' @param simulations Positive integer number of draws; default 2000.
#' @return A list containing `summary` (one row with sample sizes, selected,
#'   other-game and season means, selected-minus-other difference, 2.5th and
#'   97.5th reference percentiles, and a tie-adjusted percentile rank),
#'   `simulated_means`, and `settings`. The reference range is not a confidence
#'   interval for a causal effect or underlying player ability.
#' @details Supply complete game-level records, not one row per upload or team
#'   side. Duplicates and missing IDs are errors. At least one selected and one
#'   unselected game are required. Sampling includes the selected games in the
#'   reference population. Use `set.seed()` before calling for reproducibility.
#'   More detailed strata can leave little variation. Unmeasured selection
#'   differences remain, and this function does not test many patterns at once.
#' @examples
#' games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2025,
#'                     home = rep(c(TRUE, FALSE), 4), win = c(1, 0, 1, 1, 0, 0, 1, 0))
#' set.seed(457)
#' compare_personal_season(games, c("a", "b", "c"), simulations = 100)$summary
#' @export
compare_personal_season <- function(games, game_ids, metric = "win",
                                    strata = "home", simulations = 2000L) {
  if (!is.character(metric) || length(metric) != 1L || is.na(metric) ||
      !nzchar(metric) || !is.character(strata) || anyNA(strata) ||
      any(!nzchar(strata)) || anyDuplicated(strata)) {
    stop("Supply one metric column name and unique stratum column names.", call. = FALSE)
  }
  required <- unique(c("game_id", "team", "season", metric, strata))
  if (!is.data.frame(games) || anyDuplicated(names(games)) ||
      !all(required %in% names(games)) || nrow(games) < 2L) {
    stop("games must contain at least two rows and all required columns.", call. = FALSE)
  }
  for (nm in required) {
    x <- games[[nm]]
    if (!is.atomic(x) || !is.null(dim(x)) || anyNA(x) ||
        any(!nzchar(trimws(as.character(x))))) {
      stop("Missing or invalid values in ", nm, ".", call. = FALSE)
    }
  }
  if (!is.character(games$game_id) || anyDuplicated(games$game_id)) {
    stop("game_id must contain unique character IDs, one row per game.", call. = FALSE)
  }
  if (length(unique(games$team)) != 1L || length(unique(games$season)) != 1L) {
    stop("Supply one team and one season per comparison.", call. = FALSE)
  }
  values <- games[[metric]]
  if (!is.numeric(values) || any(!is.finite(values)) ||
      (metric == "win" && any(!values %in% c(0, 1)))) {
    stop("The metric must be finite numeric data; win must use 0 and 1.", call. = FALSE)
  }
  if (!is.character(game_ids) || !length(game_ids) || anyNA(game_ids) ||
      anyDuplicated(game_ids) || !all(game_ids %in% games$game_id)) {
    stop("game_ids must be unique IDs present in games.", call. = FALSE)
  }
  selected <- games$game_id %in% game_ids
  if (all(selected)) stop("Include at least one unselected reference game.", call. = FALSE)
  if (!is.numeric(simulations) || length(simulations) != 1L ||
      is.na(simulations) || !is.finite(simulations) || simulations < 1 ||
      simulations != floor(simulations) || simulations > .Machine$integer.max) {
    stop("simulations must be a positive integer.", call. = FALSE)
  }
  groups <- if (length(strata)) {
    do.call(interaction, c(lapply(games[strata], as.factor),
                          list(drop = TRUE, lex.order = TRUE)))
  } else rep(1L, nrow(games))
  pools <- split(seq_len(nrow(games)), groups)
  sizes <- vapply(pools, function(pool) sum(selected[pool]), integer(1))
  simulated <- replicate(simulations, {
    sampled <- unlist(lapply(seq_along(pools), function(i) {
      pool <- pools[[i]]
      pool[sample.int(length(pool), sizes[i], replace = FALSE)]
    }), use.names = FALSE)
    mean(values[sampled])
  })
  observed <- mean(values[selected])
  other <- mean(values[!selected])
  bounds <- stats::quantile(simulated, c(0.025, 0.975), names = FALSE)
  # Ties use midranks, so a constant reference distribution gives 50, not 100.
  percentile <- 100 * (mean(simulated < observed) + 0.5 * mean(simulated == observed))
  list(summary = data.frame(
    metric = metric, selected_games = sum(selected), other_games = sum(!selected),
    personal_mean = observed, other_mean = other, season_mean = mean(values),
    difference = observed - other, reference_low = bounds[1],
    reference_high = bounds[2], reference_percentile = percentile
  ), simulated_means = simulated,
  settings = list(strata = strata, simulations = simulations,
                  reference = "Same-size subsets of supplied games, matched on strata"))
}
