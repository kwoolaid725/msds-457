library(daimondstats)
expect_error <- function(expr, message) {
  err <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(err, "error"), grepl(message, conditionMessage(err), fixed = TRUE))
}

# All home games won, all away games lost: matching home/away must remove
# the apparent unusualness of selecting mostly home games.
games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2025,
                    home = rep(c(TRUE, FALSE), each = 4), win = rep(c(1, 0), each = 4))
ids <- c("a", "b", "c", "e")
set.seed(457)
result <- compare_personal_season(games, ids, simulations = 100)
stopifnot(result$summary$personal_mean == .75, result$summary$other_mean == .25,
          result$summary$difference == .5, result$summary$season_mean == .5,
          all(result$simulated_means == .75), result$summary$reference_percentile == 50)
set.seed(457)
unmatched <- compare_personal_season(games, ids, strata = character(0))
stopifnot(abs(mean(unmatched$simulated_means) - .5) < .03,
          all(unmatched$simulated_means %in% seq(0, 1, .25)))
set.seed(457)
stopifnot(identical(unmatched, compare_personal_season(games, ids, strata = character(0))))

# One selected row, no replacement, singleton strata, and joint matching.
games$bucket <- games$game_id
fixed <- compare_personal_season(games, ids, strata = c("home", "bucket"), simulations = 5)
stopifnot(all(fixed$simulated_means == .75))
stopifnot(all(compare_personal_season(games, "a", simulations = 10)$simulated_means == 1))
games$runs <- 1:8
runs <- compare_personal_season(games, ids, metric = "runs", simulations = 5)
stopifnot(runs$summary$personal_mean == 2.75, runs$summary$other_mean == 6.25)
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

# Fictional reference matrix. Hand-calculated complete inning: single,
# two-run home run, three outs. Summed impact = runs minus starting RE.
reference <- expand.grid(outs = 0:2, bases = 0:7)
reference$expected_runs <- (3 - reference$outs) * .2 + reference$bases * .1
plays <- data.frame(game_id = "demo", event_id = as.character(1:5),
                    player = c("A", "B", "C", "D", "E"),
                    outs_before = c(0, 0, 0, 1, 2), bases_before = c(0, 1, 0, 0, 0),
                    outs_after = c(0, 0, 1, 2, 3), bases_after = c(1, 0, 0, 0, 0),
                    runs_scored = c(0, 2, 0, 0, 0), verified = TRUE)
impact <- calculate_run_impact(plays, reference)
stopifnot(isTRUE(all.equal(impact$re24, c(.1, 1.9, -.2, -.2, -.2))),
          isTRUE(all.equal(sum(impact$re24), 2 - .6)), impact$re_after[5] == 0)
stopifnot(identical(impact, calculate_run_impact(plays, reference[24:1, ])))
stopifnot(nrow(calculate_run_impact(plays[0, ], reference)) == 0L)
expect_error(calculate_run_impact(rbind(plays, plays[1, ]), reference), "Duplicate")
stopifnot(nrow(calculate_run_impact(rbind(plays, transform(plays, game_id = "other")), reference)) == 10)
bad <- plays
bad$verified[1] <- FALSE
expect_error(calculate_run_impact(bad, reference), "verified")
bad$verified[1] <- NA
expect_error(calculate_run_impact(bad, reference), "verified")
bad <- plays
bad$outs_after[3] <- 4
expect_error(calculate_run_impact(bad, reference), "outs_after")
bad <- plays
bad$outs_after[4] <- 0
expect_error(calculate_run_impact(bad, reference), "cannot decrease")
bad <- plays
bad$bases_before[1] <- 8
expect_error(calculate_run_impact(bad, reference), "bases_before")
bad <- plays
bad$runs_scored[1] <- -1
expect_error(calculate_run_impact(bad, reference), "runs_scored")
expect_error(calculate_run_impact(plays, reference[-1, ]), "24 unique")
expect_error(calculate_run_impact(plays, reference[rep(1, 24), ]), "24 unique")
bad <- reference
bad$expected_runs[1] <- NA_real_
expect_error(calculate_run_impact(plays, bad), "24 unique")
cat("Personal-season reference sampling and RE24 checks passed.\n")
