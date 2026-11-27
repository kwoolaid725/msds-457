# All home games won, all away games lost: matching home/away must remove
# the apparent unusualness of selecting mostly home games.
games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2025,
                    home = rep(c(TRUE, FALSE), each = 4), win = rep(c(1, 0), each = 4))
ids <- c("a", "b", "c", "e")

test_that("home/away matching removes the selection effect", {
  set.seed(457)
  result <- compare_personal_season(games, ids, simulations = 100)
  expect_all(result$summary$personal_mean == .75, result$summary$other_mean == .25,
             result$summary$difference == .5, result$summary$season_mean == .5,
             all(result$simulated_means == .75),
             result$summary$reference_percentile == 50)
})

test_that("unmatched sampling is centered and reproducible with a seed", {
  set.seed(457)
  unmatched <- compare_personal_season(games, ids, strata = character(0))
  expect_lt(abs(mean(unmatched$simulated_means) - .5), .03)
  expect_true(all(unmatched$simulated_means %in% seq(0, 1, .25)))
  set.seed(457)
  expect_identical(unmatched, compare_personal_season(games, ids, strata = character(0)))
})

test_that("singleton strata, one selected game, and other metrics work", {
  g <- games
  g$bucket <- g$game_id
  fixed <- compare_personal_season(g, ids, strata = c("home", "bucket"), simulations = 5)
  expect_true(all(fixed$simulated_means == .75))
  expect_true(all(compare_personal_season(g, "a", simulations = 10)$simulated_means == 1))
  g$runs <- 1:8
  runs <- compare_personal_season(g, ids, metric = "runs", simulations = 5)
  expect_all(runs$summary$personal_mean == 2.75, runs$summary$other_mean == 6.25)
})

test_that("compare_personal_season rejects invalid input", {
  expect_error(compare_personal_season(games, c("a", "a")), "unique IDs")
  expect_error(compare_personal_season(games, "missing"), "unique IDs")
  expect_error(compare_personal_season(games, character(0)), "unique IDs")
  expect_error(compare_personal_season(games, games$game_id), "unselected")
  expect_error(compare_personal_season(rbind(games, games[1, ]), ids), "unique character")
  expect_error(compare_personal_season(games[0, ], ids), "at least two")
  expect_error(compare_personal_season(games, ids, simulations = 1.5), "positive integer")
  expect_error(compare_personal_season(games, ids, simulations = 0), "positive integer")
  expect_error(compare_personal_season(games, ids, strata = "missing"), "required columns")
  bad <- games
  bad$team[1] <- "Other"
  expect_error(compare_personal_season(bad, ids), "one team")
  bad <- games
  bad$season[1] <- 2024
  expect_error(compare_personal_season(bad, ids), "one team")
  bad <- games
  bad$win[1] <- 2
  expect_error(compare_personal_season(bad, ids), "win must")
  bad$win[1] <- NA
  expect_error(compare_personal_season(bad, ids), "Missing")
})

# Fictional reference matrix. Hand-calculated complete inning: single,
# two-run home run, three outs. Summed impact = runs minus starting RE.
reference <- expand.grid(outs = 0:2, bases = 0:7)
reference$expected_runs <- (3 - reference$outs) * .2 + reference$bases * .1
inning <- data.frame(game_id = "demo", event_id = as.character(1:5),
                     player = c("A", "B", "C", "D", "E"),
                     outs_before = c(0, 0, 0, 1, 2), bases_before = c(0, 1, 0, 0, 0),
                     outs_after = c(0, 0, 1, 2, 3), bases_after = c(1, 0, 0, 0, 0),
                     runs_scored = c(0, 2, 0, 0, 0), verified = TRUE)

test_that("RE24 matches a hand-calculated inning", {
  impact <- calculate_run_impact(inning, reference)
  expect_equal(impact$re24, c(.1, 1.9, -.2, -.2, -.2))
  expect_equal(sum(impact$re24), 2 - .6)
  expect_equal(impact$re_after[5], 0)
  expect_identical(impact, calculate_run_impact(inning, reference[24:1, ]))
  expect_equal(nrow(calculate_run_impact(inning[0, ], reference)), 0L)
  two <- rbind(inning, transform(inning, game_id = "other"))
  expect_equal(nrow(calculate_run_impact(two, reference)), 10)
})

test_that("calculate_run_impact rejects unverified or impossible events", {
  expect_error(calculate_run_impact(rbind(inning, inning[1, ]), reference), "Duplicate")
  bad <- inning
  bad$verified[1] <- FALSE
  expect_error(calculate_run_impact(bad, reference), "verified")
  bad$verified[1] <- NA
  expect_error(calculate_run_impact(bad, reference), "verified")
  bad <- inning
  bad$outs_after[3] <- 4
  expect_error(calculate_run_impact(bad, reference), "outs_after")
  bad <- inning
  bad$outs_after[4] <- 0
  expect_error(calculate_run_impact(bad, reference), "cannot decrease")
  bad <- inning
  bad$bases_before[1] <- 8
  expect_error(calculate_run_impact(bad, reference), "bases_before")
  bad <- inning
  bad$runs_scored[1] <- -1
  expect_error(calculate_run_impact(bad, reference), "runs_scored")
  expect_error(calculate_run_impact(inning, reference[-1, ]), "24 unique")
  expect_error(calculate_run_impact(inning, reference[rep(1, 24), ]), "24 unique")
  bad <- reference
  bad$expected_runs[1] <- NA_real_
  expect_error(calculate_run_impact(inning, bad), "24 unique")
})
