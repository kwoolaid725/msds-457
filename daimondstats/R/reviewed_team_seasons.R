#' Full regular seasons for the five reviewed scorecard teams
#'
#' Every completed regular-season game for the team and season of each
#' reviewed scorecard: 2026 Arizona Diamondbacks, Cleveland Guardians, New York
#' Mets and St. Louis Cardinals, and 2024 Minnesota Twins. Each team-season has
#' 162 games, and each reviewed scorecard game appears in its team's season.
#' Built with [season_games()].
#'
#' @format A data frame with 810 rows and 10 columns:
#' \describe{
#'   \item{game_id}{Character MLB game identifier (gamePk).}
#'   \item{team}{Character team name.}
#'   \item{season}{Integer season.}
#'   \item{game_date}{Date of the game.}
#'   \item{home}{Logical, TRUE for home games.}
#'   \item{opponent}{Character opponent name.}
#'   \item{runs, runs_allowed}{Integer runs scored and allowed.}
#'   \item{run_diff}{Integer runs minus runs allowed.}
#'   \item{win}{Numeric 1 for a win, 0 for a loss.}
#' }
#' @details Win and loss totals match the final league record reported in
#'   each schedule. Filter to one team before calling
#'   [compare_personal_season()], which compares within one team-season.
#' @source MLB Stats API regular-season schedules retrieved November 8, 2026,
#'   kept in data-raw/schedules/ in the source repository and processed by
#'   data-raw/team-seasons.R. URL pattern:
#'   \url{https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=142&season=2024&gameType=R}.
#' @examples
#' aggregate(cbind(games = 1, win) ~ team + season, reviewed_team_seasons, sum)
#' twins <- subset(reviewed_team_seasons, team == "Minnesota Twins")
#' set.seed(457)
#' compare_personal_season(twins, "746804", metric = "run_diff")$summary
"reviewed_team_seasons"
