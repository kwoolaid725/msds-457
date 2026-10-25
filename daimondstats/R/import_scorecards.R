#' Import a play-level scorecard CSV
#'
#' Read the standard dAImond Inning Plays CSV, retaining review information.
#' The original file is not modified. One file represents one game, possibly
#' containing both teams. Custom exports must retain the original required
#' column names. Player names identify players only within a game and team.
#'
#' @param path Path to one UTF-8 CSV file.
#' @param game_id A nonempty character identifier supplied by the caller.
#'   Use the same identifier for both teams in a game and different identifiers
#'   for different games.
#' @return A data frame with character columns `game_id`, `team`, `player`,
#'   `inning`, and `play`, numeric `confidence`, and logical `needs_review`.
#'   Inning labels such as `8+` are retained. Confidence may be missing; missing
#'   confidence forces review. Header-only files return zero rows.
#' @details Required CSV columns are `Team`, `Player`, `Inning`, `Play`,
#'   `Confidence`, and `Needs Review`. Confidence is a number between zero and
#'   one. Review values may be Yes/No, TRUE/FALSE, or 1/0; a blank flag means
#'   false, matching the app export. Extra columns are ignored.
#'
#'   Human-readable play labels are converted to the app's canonical labels.
#'   Unknown plays and bad crops raise errors instead of being treated as outs.
#'   Explicit `no_at_bat` and automatic-runner markers are retained but excluded
#'   by [calculate_batting_stats()]. The upstream CSV exporter omits blank and
#'   bad-crop cells, so this function cannot detect those omitted readings.
#' @examples
#' path <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
#' plays <- import_scorecards(path, game_id = "demo-01")
#' head(plays)
#' @export
import_scorecards <- function(path, game_id) {
  valid_text <- function(x) {
    is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x))
  }
  if (!valid_text(path) || !file.exists(path) || dir.exists(path)) {
    stop("`path` must identify an existing CSV file.", call. = FALSE)
  }
  if (!valid_text(game_id)) {
    stop("`game_id` must be one nonempty character identifier.", call. = FALSE)
  }
  raw <- utils::read.csv(
    path, colClasses = "character", check.names = FALSE,
    na.strings = "", fileEncoding = "UTF-8-BOM", strip.white = TRUE
  )
  required <- c("Team", "Player", "Inning", "Play", "Confidence", "Needs Review")
  if (anyDuplicated(names(raw))) {
    stop("CSV column names must be unique.", call. = FALSE)
  }
  missing <- setdiff(required, names(raw))
  if (length(missing)) {
    stop("Missing CSV columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  raw[] <- lapply(raw, trimws)
  confidence <- suppressWarnings(as.numeric(raw$Confidence))
  invalid_conf <- !is.na(raw$Confidence) & nzchar(raw$Confidence) &
    (is.na(confidence) | !is.finite(confidence) | confidence < 0 | confidence > 1)
  if (any(invalid_conf)) {
    stop("Confidence must be numeric between 0 and 1, or blank.", call. = FALSE)
  }
  flag <- tolower(raw[["Needs Review"]])
  flag[is.na(flag)] <- ""
  if (any(!flag %in% c("", "yes", "no", "true", "false", "1", "0"))) {
    stop("Needs Review must be Yes/No, TRUE/FALSE, 1/0, or blank.", call. = FALSE)
  }
  aliases <- c(
    "single (1b)" = "single", "double (2b)" = "double",
    "triple (3b)" = "triple", "home run (hr)" = "home_run",
    "walk (bb)" = "walk", "intentional walk (ibb)" = "intentional_walk",
    "hit by pitch (hbp)" = "hit_by_pitch", "strikeout (k)" = "strikeout",
    "strikeout looking (kc)" = "strikeout_looking", "ground out" = "groundout",
    "fly out" = "flyout", "line out" = "lineout", "double play (dp)" = "double_play",
    "fielder's choice (fc)" = "fielder's_choice", "error (e)" = "error",
    "sacrifice fly (sf)" = "sacrifice_fly", "sacrifice bunt (sac)" = "sacrifice_bunt",
    "catcher interference (ci)" = "catcher_interference",
    "automatic runner (mr)" = "manfred_runner"
  )
  play <- tolower(raw$Play)
  matched <- play %in% names(aliases)
  play[matched] <- unname(aliases[play[matched]])
  out <- data.frame(
    game_id = rep(trimws(game_id), nrow(raw)), team = raw$Team,
    player = raw$Player, inning = raw$Inning, play = play,
    confidence = confidence,
    needs_review = flag %in% c("yes", "true", "1") | is.na(confidence),
    stringsAsFactors = FALSE
  )
  validate_scorecards(out)
  out
}
