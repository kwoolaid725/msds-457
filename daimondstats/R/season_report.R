#' Write a one-page season report
#'
#' Turn a season of reviewed scorecards into a single HTML file that can be
#' opened in any browser, printed, or emailed to a team. The report holds a
#' season summary, an amateur batting table from [calculate_youth_stats()],
#' a chart of on-base percentage with errors, and, when supplied, pitch-count
#' flags from [check_pitch_counts()].
#'
#' @param scorecards Reviewed plays with the columns of [import_scorecards()].
#' @param file Path of the HTML file to write. Its folder must exist.
#' @param title Character report title.
#' @param pitch_check Optional output of [check_pitch_counts()].
#' @param min_pa Passed to [calculate_youth_stats()] to mark small samples.
#' @param overwrite Logical. When `FALSE` (default), an existing file is not
#'   replaced.
#' @return Invisibly, the normalized path of the written file.
#' @details The file is self-contained: the chart is embedded as an image, so
#'   no internet connection or extra software is needed to open it. Players
#'   with fewer than `min_pa` plate appearances are shown in grey and left out
#'   of the chart, because a few games can swing their rates widely.
#' @seealso [calculate_youth_stats()], [check_pitch_counts()]
#' @examples
#' path <- file.path(tempdir(), "season.html")
#' season_report(reviewed_scorecards, path, title = "Five scored games",
#'               min_pa = 3, overwrite = TRUE)
#' @export
season_report <- function(scorecards, file, title = "Season report",
                          pitch_check = NULL, min_pa = 25, overwrite = FALSE) {
  if (!is.character(file) || length(file) != 1L || is.na(file) || !nzchar(file)) {
    stop("`file` must be one file path.", call. = FALSE)
  }
  if (!dir.exists(dirname(file))) {
    stop("The folder for `file` does not exist: ", dirname(file), call. = FALSE)
  }
  if (!isTRUE(overwrite) && !isFALSE(overwrite)) {
    stop("`overwrite` must be TRUE or FALSE.", call. = FALSE)
  }
  if (file.exists(file) && !overwrite) {
    stop("`file` already exists. Use overwrite = TRUE to replace it.", call. = FALSE)
  }
  if (!is.character(title) || length(title) != 1L || is.na(title)) {
    stop("`title` must be one character string.", call. = FALSE)
  }
  check_cols <- c("pitcher", "date", "pitches", "daily_max", "rest_days",
                  "next_eligible", "status")
  if (!is.null(pitch_check) &&
      (!is.data.frame(pitch_check) || !all(check_cols %in% names(pitch_check)))) {
    stop("`pitch_check` must be check_pitch_counts() output.", call. = FALSE)
  }
  youth <- calculate_youth_stats(scorecards, by = "player", min_pa = min_pa)
  if (nrow(youth) == 0L) {
    stop("`scorecards` has no plate appearances to report.", call. = FALSE)
  }
  youth <- youth[order(youth$small_sample, -youth$OBPE, youth$player), , drop = FALSE]

  esc <- function(x) {
    x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    gsub(">", "&gt;", x, fixed = TRUE)
  }
  rate <- function(x) ifelse(is.na(x), "&ndash;", sub("^0\\.", ".", sprintf("%.3f", x)))
  pct <- function(x) ifelse(is.na(x), "&ndash;", sprintf("%.0f%%", 100 * x))

  played <- scorecards[!scorecards$play %in% c("no_at_bat", "manfred_runner"), ]
  teams <- unique(played$team)
  summary <- sprintf(
    "%d game%s &middot; %d team%s &middot; %d plate appearances",
    length(unique(played$game_id)), if (length(unique(played$game_id)) == 1L) "" else "s",
    length(teams), if (length(teams) == 1L) "" else "s", nrow(played))

  multi_team <- length(teams) > 1L
  rows <- vapply(seq_len(nrow(youth)), function(i) {
    r <- youth[i, ]
    sprintf(paste0("<tr%s><td>%s</td>%s<td>%d</td><td>%d</td><td>%s</td>",
                   "<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%d</td></tr>"),
            if (r$small_sample) " class=\"small\"" else "", esc(r$player),
            if (multi_team) paste0("<td class=\"l\">", esc(r$team), "</td>") else "",
            as.integer(r$G), as.integer(r$PA), rate(r$OBP), rate(r$OBPE),
            rate(r$ISO), pct(r$K_rate), pct(r$BB_rate), as.integer(r$ROE))
  }, character(1))
  table <- paste0(
    "<table><thead><tr><th>Player</th>", if (multi_team) "<th class=\"l\">Team</th>" else "",
    "<th>G</th><th>PA</th><th>OBP</th><th>OBPE</th><th>ISO</th><th>K%</th>",
    "<th>BB%</th><th>ROE</th></tr></thead><tbody>",
    paste(rows, collapse = ""), "</tbody></table>")

  chart <- ""
  qualified <- youth[!youth$small_sample & !is.na(youth$OBPE), , drop = FALSE]
  if (nrow(qualified)) {
    png_file <- tempfile(fileext = ".png")
    on.exit(unlink(png_file), add = TRUE)
    shown <- utils::head(qualified[order(-qualified$OBPE), ], 15)
    shown <- shown[rev(seq_len(nrow(shown))), ]
    grDevices::png(png_file, width = 900, height = 120 + 32 * nrow(shown), res = 120)
    old <- graphics::par(mar = c(4, 10, 1, 1))
    graphics::barplot(rbind(shown$OBP, shown$OBPE - shown$OBP),
                      names.arg = shown$player, horiz = TRUE, las = 1,
                      col = c("#0875D1", "#9CC9F0"), border = NA, cex.names = 0.8,
                      xlim = c(0, 1), xlab = "On base (dark) plus reached on error (light)")
    graphics::par(old)
    grDevices::dev.off()
    chart <- paste0("<h2>Getting on base</h2><img alt=\"Bar chart of OBP and ",
                    "OBPE by player\" src=\"data:image/png;base64,",
                    jsonlite::base64_enc(readBin(png_file, "raw", file.info(png_file)$size)),
                    "\">")
  }

  pitching <- ""
  if (!is.null(pitch_check)) {
    flagged <- pitch_check[pitch_check$status != "ok", , drop = FALSE]
    pitching <- if (nrow(flagged)) {
      paste0("<h2>Pitch count flags</h2><table><thead><tr><th>Pitcher</th>",
             "<th>Date</th><th>Pitches</th><th>Daily max</th><th>Issue</th>",
             "</tr></thead><tbody>",
             paste(sprintf("<tr><td>%s</td><td>%s</td><td>%d</td><td>%d</td><td>%s</td></tr>",
                           esc(flagged$pitcher), format(flagged$date),
                           as.integer(flagged$pitches), as.integer(flagged$daily_max),
                           esc(flagged$status)), collapse = ""),
             "</tbody></table>")
    } else {
      sprintf("<h2>Pitch count flags</h2><p>All %d pitching days were within the guidelines.</p>",
              nrow(pitch_check))
    }
  }

  html <- paste0(
    "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
    "<title>", esc(title), "</title><style>",
    "body{font-family:-apple-system,Segoe UI,Helvetica,Arial,sans-serif;color:#101318;",
    "background:#fff;max-width:860px;margin:32px auto;padding:0 16px}",
    "h1{margin:0 0 4px}h2{margin-top:32px;font-size:18px}",
    ".meta{color:#555;margin:0 0 24px}table{border-collapse:collapse;width:100%;",
    "font-size:14px}th,td{padding:6px 8px;border-bottom:1px solid #E1E5EA;",
    "text-align:right}th:first-child,td:first-child{text-align:left}",
    "th{background:#F4F6F8}.l{text-align:left}tr.small td{color:#8a8f98}img{max-width:100%}",
    "footer{margin-top:32px;color:#555;font-size:12px}</style></head><body>",
    "<h1>", esc(title), "</h1><p class=\"meta\">", summary, "</p>",
    "<h2>Batting</h2>", table,
    "<p class=\"meta\">Grey rows have fewer than ", min_pa, " plate appearances. ",
    "OBPE counts reaching on an error as getting on base.</p>",
    chart, pitching,
    "<footer>Made with daimondstats ", esc(utils::packageVersion("daimondstats")),
    " on ", format(Sys.Date(), "%B %d, %Y"), ".</footer></body></html>")
  writeLines(html, file, useBytes = TRUE)
  invisible(normalizePath(file))
}
