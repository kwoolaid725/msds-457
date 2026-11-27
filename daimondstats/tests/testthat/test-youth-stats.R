one_player <- function(plays, game_id = "g1", team = "Owls", player = "Ava") {
  data.frame(game_id = game_id, team = team, player = player,
             inning = as.character(seq_along(plays)), play = plays,
             confidence = 0.99, needs_review = FALSE, stringsAsFactors = FALSE)
}

test_that("OBPE, ISO, rates, and BABIP match hand calculations", {
  # 10 PA: 1B, 2B, HR, E, E, BB, HBP, K, GO, SF
  # AB = 7 (1B 2B HR E E K GO), H = 3, TB = 7, OBP den = 7 + 1 + 1 + 1 = 10
  p <- one_player(c("single", "double", "home_run", "error", "error", "walk",
                    "hit_by_pitch", "strikeout", "groundout", "sacrifice_fly"))
  y <- calculate_youth_stats(p, min_pa = 10)
  expect_all(y$PA == 10, y$AB == 7, y$H == 3, y$ROE == 2, y$HR == 1, y$SO == 1)
  expect_equal(y$OBP, 5 / 10)
  expect_equal(y$OBPE, 7 / 10)
  expect_equal(y$ISO, (7 - 3) / 7)
  expect_equal(y$K_rate, 1 / 10)
  expect_equal(y$BB_rate, 1 / 10)
  expect_equal(y$BABIP, (3 - 1) / (7 - 1 - 1 + 1))
  expect_false(y$small_sample)
})

test_that("pooling by player combines games but keeps teams apart", {
  p <- rbind(one_player(c("single", "error"), "g1"),
             one_player(c("walk", "groundout"), "g2"),
             one_player(c("single"), "g1", team = "Foxes"))
  pooled <- calculate_youth_stats(p)
  expect_equal(nrow(pooled), 2L)
  owls <- pooled[pooled$team == "Owls", ]
  expect_all(owls$G == 2, owls$PA == 4, owls$OBPE == 3 / 4, owls$small_sample)
  by_game <- calculate_youth_stats(p, by = "game")
  expect_equal(nrow(by_game), 3L)
  expect_true("game_id" %in% names(by_game))
})

test_that("edge cases: no at-bats, automatic runners, empty input", {
  walks <- calculate_youth_stats(one_player(c("walk", "sacrifice_bunt")))
  expect_true(is.na(walks$ISO))
  expect_true(is.na(walks$BABIP))
  expect_equal(walks$BB_rate, 1 / 2)
  runner <- one_player(c("manfred_runner", "no_at_bat"))
  expect_equal(nrow(calculate_youth_stats(runner)), 0L)
  empty <- calculate_youth_stats(reviewed_scorecards[0, ])
  expect_equal(nrow(empty), 0L)
  expect_true(all(c("OBPE", "small_sample") %in% names(empty)))
})

test_that("real reviewed games: OBPE equals OBP plus errors over the same base", {
  y <- calculate_youth_stats(reviewed_scorecards, min_pa = 0)
  expect_equal(sum(y$PA), 179)
  expect_equal(sum(y$ROE), sum(reviewed_scorecards$play == "error"))
  ok <- !is.na(y$OBP)
  den <- with(y, AB + BB + HBP + SF)[ok]
  expect_equal(y$OBPE[ok] - y$OBP[ok], y$ROE[ok] / den)
})

test_that("calculate_youth_stats rejects bad input", {
  p <- one_player(c("single", "walk"))
  expect_error(calculate_youth_stats(p, min_pa = -1), "min_pa")
  expect_error(calculate_youth_stats(p, min_pa = 2.5), "min_pa")
  expect_error(calculate_youth_stats(p, by = "season"), "should be one of")
  p$needs_review[1] <- TRUE
  expect_error(calculate_youth_stats(p), "Review flagged")
  expect_error(calculate_youth_stats(list()), "data frame")
})
