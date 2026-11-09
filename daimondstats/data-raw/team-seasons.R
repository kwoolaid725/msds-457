# Run from the package root. Schedules in data-raw/schedules/ were downloaded
# on November 8, 2026 from
# https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=ID&season=YEAR&gameType=R
pkgload::load_all(quiet = TRUE)
teams <- data.frame(team_id = c(109, 138, 142, 114, 121),
                    season = c(2026, 2026, 2024, 2026, 2026))
reviewed_team_seasons <- do.call(rbind, lapply(seq_len(nrow(teams)), function(i) {
  path <- sprintf("data-raw/schedules/schedule_%d_%d.json", teams$team_id[i], teams$season[i])
  games <- season_games(path, teams$team_id[i])
  # The final league record in the schedule is an independent check on wins.
  raw <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  last <- Filter(function(g) g$gamePk == as.integer(utils::tail(games$game_id, 1)),
                 unlist(lapply(raw$dates, `[[`, "games"), recursive = FALSE))[[1]]
  side <- if (last$teams$home$team$id == teams$team_id[i]) "home" else "away"
  record <- last$teams[[side]]$leagueRecord
  stopifnot(sum(games$win) == record$wins, sum(1 - games$win) == record$losses)
  games
}))
rownames(reviewed_team_seasons) <- NULL
stopifnot(all(unique(reviewed_scorecards$game_id) %in% reviewed_team_seasons$game_id),
          !anyDuplicated(reviewed_team_seasons[c("team", "game_id")]))
print(aggregate(cbind(games = 1, win) ~ team + season, reviewed_team_seasons, sum))
save(reviewed_team_seasons, file = "data/reviewed_team_seasons.rda", version = 2,
     compress = "xz")
