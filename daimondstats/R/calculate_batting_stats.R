#' Calculate batting statistics from reviewed plays
#'
#' Calculate counting and rate statistics for each game, team, and player.
#' Input can come from [import_scorecards()] or another source that follows
#' the same column contract. Rows represent distinct scorecard entries;
#' identical-looking rows are not automatically deduplicated.
#'
#' @param scorecards A data frame with the seven columns returned by
#'   [import_scorecards()]. All entries must have `needs_review = FALSE`
#'   and known confidence. Review uncertain entries before calculation.
#' @return One row per `game_id`, `team`, and `player`, in first-appearance order.
#'   Counting columns are `PA`, `AB`, `H`, `BB` (including intentional walks),
#'   `HBP`, `SF`, `SH`, `CI`, and `TB`. Rate columns are `BA`, `OBP`, `SLG`, and
#'   `OPS`, without rounding. Zero denominators produce `NA_real_`. No rows
#'   are returned for players with only blank/automatic-runner markers.
#' @details BA = H/AB; OBP = (H+BB+HBP)/(AB+BB+HBP+SF);
#'   SLG = TB/AB; OPS = OBP+SLG. Sacrifice bunts and catcher interference
#'   count as plate appearances but are excluded from AB and the OBP denominator.
#'   Sacrifice flies are excluded from AB but included in the OBP denominator.
#'   Errors and fielder's choices count as at-bats, not hits. Double plays
#'   contribute one batter at-bat. Automatic runners are not plate appearances.
#'
#'   Only the explicitly supported play labels are accepted. An unrecognized
#'   event must be reviewed rather than silently dropped. This first version
#'   does not estimate missing plays or resolve duplicate player names.
#' @examples
#' path <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
#' plays <- import_scorecards(path, "demo-01")
#' calculate_batting_stats(plays)
#' @export
calculate_batting_stats <- function(scorecards) {
  validate_scorecards(scorecards)
  if (any(scorecards$needs_review | is.na(scorecards$confidence))) {
    stop("Review flagged entries and missing confidence before calculating statistics.",
         call. = FALSE)
  }
  counts <- c("PA", "AB", "H", "BB", "HBP", "SF", "SH", "CI", "TB")
  rates <- c("BA", "OBP", "SLG", "OPS")
  keys <- c("game_id", "team", "player")
  plays <- scorecards[!scorecards$play %in% c("no_at_bat", "manfred_runner"), ]
  out <- unique(plays[keys])
  rownames(out) <- NULL
  for (nm in c(counts, rates)) out[[nm]] <- numeric(nrow(out))
  hit_bases <- c(single = 1, double = 2, triple = 3, home_run = 4)
  no_ab <- c("walk", "intentional_walk", "hit_by_pitch", "sacrifice_fly",
             "sacrifice_bunt", "catcher_interference")
  divide <- function(n, d) if (d == 0) NA_real_ else n / d
  for (i in seq_len(nrow(out))) {
    selected <- plays$game_id == out$game_id[i] & plays$team == out$team[i] &
      plays$player == out$player[i]
    p <- plays$play[selected]
    ab <- sum(!p %in% no_ab)
    h <- sum(p %in% names(hit_bases))
    bb <- sum(p %in% c("walk", "intentional_walk"))
    hbp <- sum(p == "hit_by_pitch")
    sf <- sum(p == "sacrifice_fly")
    tb <- sum(hit_bases[p[p %in% names(hit_bases)]])
    ba <- divide(h, ab)
    obp <- divide(h + bb + hbp, ab + bb + hbp + sf)
    slg <- divide(tb, ab)
    out[i, counts] <- list(length(p), ab, h, bb, hbp, sf,
                          sum(p == "sacrifice_bunt"), sum(p == "catcher_interference"), tb)
    out[i, rates] <- list(ba, obp, slg, obp + slg)
  }
  out
}

# Shared validation keeps direct data-frame calls as strict as CSV imports.
validate_scorecards <- function(x) {
  fields <- c("game_id", "team", "player", "inning", "play")
  required <- c(fields, "confidence", "needs_review")
  if (!is.data.frame(x) || anyDuplicated(names(x)) ||
      !all(required %in% names(x))) {
    stop("Use a data frame with game_id, team, player, inning, play, confidence, needs_review.",
         call. = FALSE)
  }
  for (nm in fields) {
    if (!is.character(x[[nm]]) || anyNA(x[[nm]]) || any(!nzchar(trimws(x[[nm]])))) {
      stop("`", nm, "` must contain nonempty character values.", call. = FALSE)
    }
  }
  if (!is.numeric(x$confidence) || any(is.nan(x$confidence)) ||
      any(!is.na(x$confidence) &
          (!is.finite(x$confidence) | x$confidence < 0 | x$confidence > 1))) {
    stop("`confidence` must be numeric between 0 and 1, or NA.", call. = FALSE)
  }
  if (!is.logical(x$needs_review) || anyNA(x$needs_review)) {
    stop("`needs_review` must contain TRUE or FALSE, without missing values.", call. = FALSE)
  }
  supported <- c(
    "single", "double", "triple", "home_run", "walk", "intentional_walk",
    "hit_by_pitch", "strikeout", "strikeout_looking", "groundout", "flyout",
    "lineout", "double_play", "fielder's_choice", "error", "sacrifice_fly",
    "sacrifice_bunt", "catcher_interference", "no_at_bat", "manfred_runner"
  )
  unknown <- unique(x$play[!x$play %in% supported])
  if (length(unknown)) {
    stop("Unrecognized play(s); review before use: ", paste(unknown, collapse = ", "),
         call. = FALSE)
  }
  invisible(x)
}
