library(daimondstats)
expect_error <- function(expr, message) {
  err <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(err, "error"), grepl(message, conditionMessage(err), fixed = TRUE))
}

# The sample holds a postponed entry and its later final entry under one ID,
# plus a doubleheader. The postponed entry must not create a second game.
path <- system.file("extdata", "schedule_sample.json", package = "daimondstats")
twins <- season_games(path, 142)
stopifnot(nrow(twins) == 4L, !anyDuplicated(twins$game_id),
          identical(twins$game_id[1], "746335"), twins$runs[1] == 4L,
          twins$runs_allowed[1] == 1L, twins$win[1] == 1, !twins$home[1],
          identical(twins$opponent[1], "Kansas City Royals"),
          all(twins$run_diff == twins$runs - twins$runs_allowed),
          all(twins$win == (twins$runs > twins$runs_allowed)),
          sum(twins$game_id == "745927") == 1L,
          twins$game_date[twins$game_id == "745927"] == as.Date("2024-08-09"))
# Parsed input gives the same result as a path; the opponent's view mirrors it.
parsed <- jsonlite::fromJSON(path, simplifyVector = FALSE)
stopifnot(identical(season_games(parsed, 142), twins))
royals <- season_games(path, 118)
stopifnot(nrow(royals) == 1L, royals$run_diff == -3L, royals$home)
expect_error(season_games(path, 999), "No final regular-season games")
expect_error(season_games(path, "142"), "single whole number")
expect_error(season_games(list(a = 1), 142), "MLB schedule response")

# Packaged seasons: 162 games each, every reviewed scorecard game included.
s <- reviewed_team_seasons
counts <- table(s$team)
stopifnot(nrow(s) == 810L, all(counts == 162L), length(counts) == 5L,
          all(unique(reviewed_scorecards$game_id) %in% s$game_id))
wins <- tapply(s$win, s$team, sum)
stopifnot(wins[["Minnesota Twins"]] == 82, wins[["Arizona Diamondbacks"]] == 86)

# One personal game: the reference distribution is the season itself, so the
# percentile is that game's midrank within the season.
mn <- subset(s, team == "Minnesota Twins")
set.seed(457)
cmp <- compare_personal_season(mn, "746804", metric = "run_diff", strata = character(0),
                               simulations = 4000)
own <- mn$run_diff[mn$game_id == "746804"]
exact <- 100 * (mean(mn$run_diff < own) + 0.5 * mean(mn$run_diff == own))
stopifnot(cmp$summary$personal_mean == own, abs(cmp$summary$reference_percentile - exact) < 3)
