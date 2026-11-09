#' Plot total run impact by player
#'
#' Draw a horizontal bar chart of summed RE24 for each player, using the
#' output of [calculate_run_impact()]. Positive bars are runs added above the
#' average expectation; negative bars are runs taken away.
#'
#' @param impact Data frame returned by [calculate_run_impact()], with
#'   character `player` and numeric `re24`. A `team` column, if present, is
#'   used to keep players on different teams apart.
#' @param top Positive whole number of players to show, chosen by largest
#'   absolute total. `Inf` shows everyone.
#' @param main Character plot title.
#' @return Invisibly, a data frame with `player`, optional `team`, `events`
#'   and `re24` for the plotted players, sorted from highest to lowest.
#' @details Uses base R graphics, so the plot can be saved with any graphics
#'   device such as [grDevices::png()]. Totals depend on the expectancy matrix
#'   and on how many events each player had; they are not rates.
#' @seealso [calculate_run_impact()], [reviewed_base_out]
#' @examples
#' impact <- calculate_run_impact(reviewed_base_out, run_expectancy_fangraphs)
#' plot_run_impact(impact, top = 12)
#' @export
plot_run_impact <- function(impact, top = 10, main = "Run impact (RE24) by player") {
  if (!is.data.frame(impact) || !all(c("player", "re24") %in% names(impact)) ||
      !is.character(impact$player) || !is.numeric(impact$re24) ||
      anyNA(impact$player) || anyNA(impact$re24)) {
    stop("impact must be calculate_run_impact() output with player and re24.", call. = FALSE)
  }
  if (nrow(impact) == 0L) {
    stop("impact has no events to plot.", call. = FALSE)
  }
  if (!is.numeric(top) || length(top) != 1L || is.na(top) || top < 1 ||
      (is.finite(top) && top != floor(top))) {
    stop("top must be a positive whole number or Inf.", call. = FALSE)
  }
  if (!is.character(main) || length(main) != 1L) {
    stop("main must be a single character string.", call. = FALSE)
  }
  keys <- if ("team" %in% names(impact)) c("player", "team") else "player"
  totals <- stats::aggregate(list(re24 = impact$re24), impact[keys], sum)
  totals$events <- stats::aggregate(list(n = impact$re24), impact[keys], length)$n
  totals <- totals[order(-abs(totals$re24)), , drop = FALSE]
  totals <- totals[seq_len(min(nrow(totals), top)), , drop = FALSE]
  totals <- totals[order(totals$re24), , drop = FALSE]

  labels <- totals$player
  if ("team" %in% keys && length(unique(impact$team)) > 1L) {
    labels <- paste0(labels, " (", totals$team, ")")
  }
  old <- graphics::par(mar = c(4.5, max(8, max(nchar(labels)) * 0.5), 3, 1))
  on.exit(graphics::par(old), add = TRUE)
  colours <- ifelse(totals$re24 >= 0, "#2864B4", "#C0504D")
  limit <- max(abs(totals$re24)) * 1.1
  graphics::barplot(totals$re24, names.arg = labels, horiz = TRUE, las = 1,
                    col = colours, border = NA, xlim = c(-limit, limit),
                    main = main, xlab = "Runs above average expectation",
                    cex.names = 0.8)
  graphics::abline(v = 0, col = "#555555")

  rownames(totals) <- NULL
  totals <- totals[rev(seq_len(nrow(totals))), c(keys, "events", "re24"), drop = FALSE]
  rownames(totals) <- NULL
  invisible(totals)
}
