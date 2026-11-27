#' Calculate amateur batting statistics across games
#'
#' Summarize each player's scored games with statistics suited to amateur and
#' youth baseball, where fielding errors are common and samples are small.
#' Includes on-base percentage with errors (OBPE), isolated power, strikeout
#' and walk rates, and batting average on balls in play.
#'
#' @param scorecards A data frame with the seven columns returned by
#'   [import_scorecards()] or [daimond_games()]. All entries must be reviewed
#'   (`needs_review = FALSE`) with known confidence.
#' @param by `"player"` (default) to pool each player's games within a team,
#'   or `"game"` for one row per game, team, and player.
#' @param min_pa Nonnegative whole number. Rows with fewer plate appearances
#'   are marked `small_sample = TRUE`. The default, 25, is a rule of thumb, not
#'   a statistical threshold.
#' @return One row per team and player (plus `game_id` when `by = "game"`),
#'   in first-appearance order, with counting columns `G`, `PA`, `AB`, `H`,
#'   `HR`, `ROE`, `BB`, `HBP`, `SO`, `SF`, `TB`; rate columns `OBP`, `OBPE`,
#'   `ISO`, `K_rate`, `BB_rate`, `BABIP`; and logical `small_sample`.
#'   Zero denominators produce `NA_real_`.
#' @details Formulas:
#'   * OBP = (H + BB + HBP) / (AB + BB + HBP + SF)
#'   * OBPE = (H + BB + HBP + ROE) / (AB + BB + HBP + SF), where ROE counts
#'     plays scored as `error`. Errors are an out the defense failed to make,
#'     so in youth games OBPE shows how often a batter puts pressure on the
#'     defense. The idea follows McBride (UC Irvine 2025), who reports that
#'     on-base with errors predicted youth scoring better than standard OBP;
#'     the exact formula here is this package's definition.
#'   * ISO = (TB - H) / AB, extra bases per at-bat.
#'   * K_rate = SO / PA and BB_rate = (BB, including intentional) / PA.
#'   * BABIP = (H - HR) / (AB - SO - HR + SF).
#'
#'   Pooling with `by = "player"` matches players by exact team and player
#'   name, so the same name on two teams stays separate, and spelling must be
#'   consistent across scorecards. Automatic-runner and blank markers are not
#'   plate appearances. Quality at-bats need pitch-by-pitch counts, which
#'   paper scorecard cells do not record, so they are not calculated.
#' @references UC Irvine School of Social Sciences. 2025. "Coaching Youth
#'   Baseball and Softball with Sabermetrics." March 11.
#'   <https://www.socsci.uci.edu/newsevents/news/2025/2025-03-11-mcbride-sabermetrics.php>.
#' @seealso [calculate_batting_stats()] for per-game BA, SLG, and OPS.
#' @examples
#' youth <- calculate_youth_stats(reviewed_scorecards)
#' head(youth[order(-youth$OBPE), c("team", "player", "PA", "OBP", "OBPE")])
#' @export
calculate_youth_stats <- function(scorecards, by = c("player", "game"), min_pa = 25) {
  validate_scorecards(scorecards)
  by <- match.arg(by)
  if (!is.numeric(min_pa) || length(min_pa) != 1L || is.na(min_pa) ||
      min_pa < 0 || min_pa != floor(min_pa)) {
    stop("`min_pa` must be one nonnegative whole number.", call. = FALSE)
  }
  if (any(scorecards$needs_review | is.na(scorecards$confidence))) {
    stop("Review flagged entries and missing confidence before calculating statistics.",
         call. = FALSE)
  }
  keys <- if (by == "game") c("game_id", "team", "player") else c("team", "player")
  plays <- scorecards[!scorecards$play %in% c("no_at_bat", "manfred_runner"), ,
                      drop = FALSE]
  out <- unique(plays[keys])
  rownames(out) <- NULL
  counts <- c("G", "PA", "AB", "H", "HR", "ROE", "BB", "HBP", "SO", "SF", "TB")
  rates <- c("OBP", "OBPE", "ISO", "K_rate", "BB_rate", "BABIP")
  for (nm in c(counts, rates)) out[[nm]] <- numeric(nrow(out))

  hit_bases <- c(single = 1, double = 2, triple = 3, home_run = 4)
  no_ab <- c("walk", "intentional_walk", "hit_by_pitch", "sacrifice_fly",
             "sacrifice_bunt", "catcher_interference")
  divide <- function(n, d) if (d == 0) NA_real_ else n / d
  row_key <- do.call(paste, c(plays[keys], sep = "\r"))
  out_key <- do.call(paste, c(out[keys], sep = "\r"))
  for (i in seq_len(nrow(out))) {
    selected <- row_key == out_key[i]
    p <- plays$play[selected]
    ab <- sum(!p %in% no_ab)
    h <- sum(p %in% names(hit_bases))
    hr <- sum(p == "home_run")
    roe <- sum(p == "error")
    bb <- sum(p %in% c("walk", "intentional_walk"))
    hbp <- sum(p == "hit_by_pitch")
    so <- sum(p %in% c("strikeout", "strikeout_looking"))
    sf <- sum(p == "sacrifice_fly")
    tb <- sum(hit_bases[p[p %in% names(hit_bases)]])
    pa <- length(p)
    obp_den <- ab + bb + hbp + sf
    out[i, counts] <- list(length(unique(plays$game_id[selected])), pa, ab, h,
                          hr, roe, bb, hbp, so, sf, tb)
    out[i, rates] <- list(
      divide(h + bb + hbp, obp_den), divide(h + bb + hbp + roe, obp_den),
      divide(tb - h, ab), divide(so, pa), divide(bb, pa),
      divide(h - hr, ab - so - hr + sf)
    )
  }
  out$small_sample <- out$PA < min_pa
  out
}
