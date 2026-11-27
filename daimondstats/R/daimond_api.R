#' Store a dAImond Inning API key for this session
#'
#' Save a personal API key so [daimond_games()] can read your scorecards from
#' the dAImond Inning app. Create a key in the app under Settings, API keys.
#' The key is kept in the `DAIMOND_API_KEY` environment variable for the
#' current R session only; nothing is written to disk.
#'
#' @param key A personal API key beginning with `di_pat_`. When `NULL`, the
#'   existing `DAIMOND_API_KEY` environment variable is checked instead.
#' @return Invisibly, `TRUE` when a well-formed key is available.
#' @details To keep the key across sessions, add a line
#'   `DAIMOND_API_KEY=di_pat_...` to your `.Renviron` file (for example with
#'   `usethis::edit_r_environ()`). Never put the key in a script you share.
#'   A key gives read access to every scorecard in the account, so revoke it
#'   in the app if it leaks.
#' @seealso [daimond_games()]
#' @examples
#' \dontrun{
#' daimond_auth("di_pat_your_key_here")
#' }
#' @export
daimond_auth <- function(key = NULL) {
  if (is.null(key)) {
    key <- Sys.getenv("DAIMOND_API_KEY", "")
    if (!nzchar(key)) {
      stop("No API key found. Create one in dAImond Inning under Settings > API keys, ",
           "then call daimond_auth(\"di_pat_...\").", call. = FALSE)
    }
  }
  if (!is.character(key) || length(key) != 1L || is.na(key) ||
      !grepl("^di_pat_[A-Za-z0-9_-]{20,}$", key)) {
    stop("`key` must be one dAImond Inning API key starting with di_pat_.",
         call. = FALSE)
  }
  Sys.setenv(DAIMOND_API_KEY = key)
  invisible(TRUE)
}

#' Download your scorecards from the dAImond Inning app
#'
#' Fetch reviewed play-by-play and pitcher lines for the scorecards saved in
#' your dAImond Inning account. The plays use the same columns as
#' [import_scorecards()], so they work directly with every analysis function
#' in this package.
#'
#' @param from,to Optional first and last game dates as `Date` or
#'   `"YYYY-MM-DD"` text.
#' @param league Optional league filter, such as `"mlb"` or a league name used
#'   in the app.
#' @param base_url App address. Defaults to the `daimondstats.base_url` option,
#'   or `https://daimondinning.com`.
#' @return A list with three data frames:
#'   * `games`: one row per scorecard with `game_id`, `game_date`, `league`,
#'     `game_pk`, `home_team`, `away_team`, and `scored_side`.
#'   * `plays`: the seven columns of [import_scorecards()] plus `game_date`,
#'     `jersey`, and `lineup_slot`. `game_id` is the app's scorecard id.
#'   * `pitchers`: `game_id`, `game_date`, `team`, `pitcher`, `outs`, `bf`,
#'     `pitches`, `h`, `bb`, `so`, and `needs_review`.
#' @details Requires an API key (see [daimond_auth()]) and an internet
#'   connection. Results are paged by the server and combined here. Entries
#'   the app still marks for review keep `needs_review = TRUE`; the analysis
#'   functions refuse them until they are corrected in the app.
#'
#'   Errors are reported in plain language: a missing or revoked key, a plan
#'   without API access, too many requests, or the app being unreachable.
#' @seealso [daimond_auth()], [calculate_youth_stats()], [check_pitch_counts()]
#' @examples
#' \dontrun{
#' daimond_auth("di_pat_your_key_here")
#' season <- daimond_games(from = "2026-04-01", to = "2026-07-31")
#' calculate_youth_stats(season$plays)
#' }
#' @export
daimond_games <- function(from = NULL, to = NULL, league = NULL,
                          base_url = getOption("daimondstats.base_url",
                                               "https://daimondinning.com")) {
  key <- Sys.getenv("DAIMOND_API_KEY", "")
  if (!nzchar(key)) {
    stop("No API key set. Run daimond_auth(\"di_pat_...\") first.", call. = FALSE)
  }
  as_day <- function(value, name) {
    if (is.null(value)) return(NULL)
    day <- if (inherits(value, "Date")) value else
      as.Date(as.character(value), format = "%Y-%m-%d", optional = TRUE)
    if (length(day) != 1L || is.na(day)) {
      stop("`", name, "` must be one Date or YYYY-MM-DD value.", call. = FALSE)
    }
    format(day, "%Y-%m-%d")
  }
  from <- as_day(from, "from")
  to <- as_day(to, "to")
  if (!is.null(from) && !is.null(to) && from > to) {
    stop("`from` must be on or before `to`.", call. = FALSE)
  }
  if (!is.null(league) && (!is.character(league) || length(league) != 1L ||
                           is.na(league) || !nzchar(league))) {
    stop("`league` must be one nonempty character value.", call. = FALSE)
  }
  if (!is.character(base_url) || length(base_url) != 1L ||
      !grepl("^https?://", base_url)) {
    stop("`base_url` must be one http(s) address.", call. = FALSE)
  }

  games <- list()
  cursor <- NULL
  repeat {
    req <- httr2::request(sub("/+$", "", base_url))
    req <- httr2::req_url_path_append(req, "api", "v1", "games")
    req <- httr2::req_url_query(req, from = from, to = to, league = league,
                                cursor = cursor)
    req <- httr2::req_auth_bearer_token(req, key)
    req <- httr2::req_user_agent(
      req, paste0("daimondstats/", utils::packageVersion("daimondstats")))
    req <- httr2::req_error(req, is_error = function(resp) FALSE)
    resp <- tryCatch(httr2::req_perform(req), httr2_failure = function(e) {
      stop("Could not reach dAImond Inning at ", base_url, ": ",
           conditionMessage(e), call. = FALSE)
    })
    status <- httr2::resp_status(resp)
    if (status != 200L) stop(api_error_message(resp, status), call. = FALSE)
    body <- httr2::resp_body_json(resp, simplifyVector = FALSE)
    if (!identical(as.integer(body$api_version), 1L)) {
      stop("This version of daimondstats does not understand the app's reply. ",
           "Update the package.", call. = FALSE)
    }
    games <- c(games, body$games)
    cursor <- body$next_cursor
    if (!is.character(cursor) || length(cursor) != 1L || !nzchar(cursor)) break
  }
  games_to_frames(games)
}

api_error_message <- function(resp, status) {
  detail <- tryCatch(httr2::resp_body_json(resp)$error, error = function(e) NULL)
  base <- switch(
    as.character(status),
    "401" = "The API key was not accepted. It may be mistyped or revoked; create a new one in the app.",
    "403" = "Your dAImond Inning plan does not include API access.",
    "429" = "Too many requests. Wait a minute and try again.",
    paste0("dAImond Inning returned HTTP ", status, ".")
  )
  if (is.character(detail) && length(detail) == 1L && nzchar(detail)) {
    paste0(sub("\\.$", "", base), " (", detail, ").")
  } else {
    base
  }
}

# Flatten the v1 JSON into the package's column contract. Missing fields
# become NA rather than failing, except the ones the analysis needs.
games_to_frames <- function(games) {
  pick <- function(x, name, empty) {
    v <- x[[name]]
    if (is.null(v) || length(v) == 0L) empty else v
  }
  text <- function(x, name) as.character(pick(x, name, NA_character_))
  number <- function(x, name) as.numeric(pick(x, name, NA_real_))
  game_rows <- lapply(games, function(g) data.frame(
    game_id = text(g, "scorecard_id"), game_date = text(g, "game_date"),
    league = text(g, "league"), game_pk = text(g, "game_pk"),
    home_team = text(g, "home_team"), away_team = text(g, "away_team"),
    scored_side = text(g, "scored_side"), stringsAsFactors = FALSE))
  play_rows <- unlist(lapply(games, function(g) lapply(g$plays, function(p) data.frame(
    game_id = text(g, "scorecard_id"), team = text(p, "team"),
    player = text(p, "player"), inning = text(p, "inning"), play = text(p, "play"),
    confidence = number(p, "confidence"),
    needs_review = isTRUE(pick(p, "needs_review", FALSE)),
    game_date = text(g, "game_date"), jersey = text(p, "jersey"),
    lineup_slot = number(p, "lineup_slot"), stringsAsFactors = FALSE))),
    recursive = FALSE)
  pitcher_rows <- unlist(lapply(games, function(g) lapply(g$pitchers, function(p) data.frame(
    game_id = text(g, "scorecard_id"), game_date = text(g, "game_date"),
    team = text(p, "team"), pitcher = text(p, "pitcher"),
    outs = number(p, "outs"), bf = number(p, "bf"), pitches = number(p, "pitches"),
    h = number(p, "h"), bb = number(p, "bb"), so = number(p, "so"),
    needs_review = isTRUE(pick(p, "needs_review", FALSE)),
    stringsAsFactors = FALSE))), recursive = FALSE)

  bind <- function(rows, template) {
    if (length(rows)) do.call(rbind, rows) else template
  }
  plays <- bind(play_rows, data.frame(
    game_id = character(), team = character(), player = character(),
    inning = character(), play = character(), confidence = numeric(),
    needs_review = logical(), game_date = character(), jersey = character(),
    lineup_slot = numeric(), stringsAsFactors = FALSE))
  plays$game_date <- as.Date(plays$game_date)
  pitchers <- bind(pitcher_rows, data.frame(
    game_id = character(), game_date = character(), team = character(),
    pitcher = character(), outs = numeric(), bf = numeric(), pitches = numeric(),
    h = numeric(), bb = numeric(), so = numeric(), needs_review = logical(),
    stringsAsFactors = FALSE))
  pitchers$game_date <- as.Date(pitchers$game_date)
  games <- bind(game_rows, data.frame(
    game_id = character(), game_date = character(), league = character(),
    game_pk = character(), home_team = character(), away_team = character(),
    scored_side = character(), stringsAsFactors = FALSE))
  games$game_date <- as.Date(games$game_date)
  validate_scorecards(plays)
  list(games = games, plays = plays, pitchers = pitchers)
}
