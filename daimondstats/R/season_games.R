#' Build a team's reference season from an MLB schedule
#'
#' Convert an MLB Stats API regular-season schedule into one row per completed
#' game for one team, in the format [compare_personal_season()] expects.
#'
#' @param schedule Path or URL of a schedule JSON file, or the same response
#'   already parsed with `jsonlite::fromJSON(simplifyVector = FALSE)`. Request
#'   it from `https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=ID&season=YEAR&gameType=R`.
#' @param team_id MLB team identifier, such as 142 for the Minnesota Twins.
#' @return A data frame sorted by date with character `game_id`, `team`,
#'   integer `season`, Date `game_date`, logical `home`, character `opponent`,
#'   integer `runs`, `runs_allowed` and `run_diff`, and 0/1 `win`.
#' @details Only games played to completion are kept (coded status `F`),
#'   including games completed early. A postponed game appears in the schedule
#'   more than once under the same `game_id`, and its postponed entry also
#'   reports a final abstract state; it is kept once, when it was played. Ties and
#'   duplicated final games are errors. Reading a URL needs a network
#'   connection, so save the file first for reproducible work.
#' @seealso [compare_personal_season()], [reviewed_team_seasons]
#' @examples
#' path <- system.file("extdata", "schedule_sample.json", package = "daimondstats")
#' season_games(path, team_id = 142)
#' @export
season_games <- function(schedule, team_id) {
  if (!is.numeric(team_id) || length(team_id) != 1L || is.na(team_id) ||
      team_id != floor(team_id)) {
    stop("team_id must be a single whole number.", call. = FALSE)
  }
  if (is.character(schedule) && length(schedule) == 1L && !is.na(schedule)) {
    schedule <- jsonlite::fromJSON(schedule, simplifyVector = FALSE)
  }
  if (!is.list(schedule) || !is.list(schedule$dates)) {
    stop("schedule must be an MLB schedule response or a path to one.", call. = FALSE)
  }
  games <- unlist(lapply(schedule$dates, `[[`, "games"), recursive = FALSE)
  rows <- lapply(games, function(g) {
    # Postponed games also report abstractGameState "Final"; codedGameState
    # "F" marks games actually played to completion.
    if (!identical(g$status$codedGameState, "F") ||
        !identical(g$gameType, "R")) return(NULL)
    side <- if (isTRUE(g$teams$home$team$id == team_id)) "home" else
      if (isTRUE(g$teams$away$team$id == team_id)) "away" else return(NULL)
    other <- if (side == "home") "away" else "home"
    data.frame(game_id = as.character(g$gamePk),
               team = g$teams[[side]]$team$name,
               season = as.integer(g$season),
               game_date = as.Date(g$officialDate),
               home = side == "home",
               opponent = g$teams[[other]]$team$name,
               runs = as.integer(g$teams[[side]]$score),
               runs_allowed = as.integer(g$teams[[other]]$score))
  })
  out <- do.call(rbind, rows)
  if (is.null(out)) {
    stop("No final regular-season games found for team_id ", team_id, ".", call. = FALSE)
  }
  if (anyDuplicated(out$game_id)) {
    stop("Duplicated final games in schedule.", call. = FALSE)
  }
  if (any(out$runs == out$runs_allowed)) {
    stop("Tied final games are not supported.", call. = FALSE)
  }
  if (length(unique(out$season)) != 1L || length(unique(out$team)) != 1L) {
    stop("Supply one team's schedule for one season.", call. = FALSE)
  }
  out$run_diff <- out$runs - out$runs_allowed
  out$win <- as.numeric(out$runs > out$runs_allowed)
  out <- out[order(out$game_date, out$game_id), , drop = FALSE]
  rownames(out) <- NULL
  out
}
