path <- system.file("extdata", "schedule_sample.json", package = "daimondstats")

test_that("postponed entries and doubleheaders are handled", {
  # The sample holds a postponed entry and its later final entry under one ID,
  # plus a doubleheader. The postponed entry must not create a second game.
  twins <- season_games(path, 142)
  expect_equal(nrow(twins), 4L)
  expect_equal(anyDuplicated(twins$game_id), 0L)
  expect_identical(twins$game_id[1], "746335")
  expect_all(twins$runs[1] == 4L, twins$runs_allowed[1] == 1L, twins$win[1] == 1,
             !twins$home[1], twins$opponent[1] == "Kansas City Royals",
             twins$run_diff == twins$runs - twins$runs_allowed,
             twins$win == (twins$runs > twins$runs_allowed),
             sum(twins$game_id == "745927") == 1L,
             twins$game_date[twins$game_id == "745927"] == as.Date("2024-08-09"))
  parsed <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  expect_identical(season_games(parsed, 142), twins)
  royals <- season_games(path, 118)
  expect_all(nrow(royals) == 1L, royals$run_diff == -3L, royals$home)
})

test_that("season_games rejects bad input", {
  expect_error(season_games(path, 999), "No final regular-season games")
  expect_error(season_games(path, "142"), "single whole number")
  expect_error(season_games(list(a = 1), 142), "MLB schedule response")
})

test_that("packaged seasons are full and include every scored game", {
  s <- reviewed_team_seasons
  counts <- table(s$team)
  expect_equal(nrow(s), 810L)
  expect_true(all(counts == 162L))
  expect_equal(length(counts), 5L)
  expect_true(all(unique(reviewed_scorecards$game_id) %in% s$game_id))
  wins <- tapply(s$win, s$team, sum)
  expect_equal(wins[["Minnesota Twins"]], 82)
  expect_equal(wins[["Arizona Diamondbacks"]], 86)
})

test_that("one scored game lands at its midrank within the season", {
  mn <- subset(reviewed_team_seasons, team == "Minnesota Twins")
  set.seed(457)
  cmp <- compare_personal_season(mn, "746804", metric = "run_diff",
                                 strata = character(0), simulations = 4000)
  own <- mn$run_diff[mn$game_id == "746804"]
  exact <- 100 * (mean(mn$run_diff < own) + 0.5 * mean(mn$run_diff == own))
  expect_equal(cmp$summary$personal_mean, own)
  expect_lt(abs(cmp$summary$reference_percentile - exact), 3)
})
