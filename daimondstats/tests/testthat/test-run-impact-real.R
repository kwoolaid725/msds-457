b <- reviewed_base_out
m <- run_expectancy_fangraphs
impact <- calculate_run_impact(b, m)

test_that("base-out data and matrix are complete and verified", {
  expect_equal(nrow(b), 188L)
  expect_equal(sum(b$batting_event), 179L)
  expect_true(all(b$verified))
  expect_equal(anyDuplicated(b[c("game_id", "event_id")]), 0L)
  expect_equal(nrow(m), 24L)
  expect_equal(anyDuplicated(m[c("outs", "bases")]), 0L)
  # Every reviewed plate appearance has exactly one batting event, same batter.
  joined <- merge(reviewed_scorecards, b[b$batting_event, ], by = c("game_id", "event_id"),
                  suffixes = c("_card", "_feed"))
  expect_equal(nrow(joined), 179L)
  expect_true(all(joined$batter_id == joined$player_id))
})

test_that("team RE24 equals runs minus 0.461 per inning batted", {
  # An inning starts empty with no outs and ends with three outs and zero
  # expectancy, so the inning's summed RE24 telescopes.
  innings <- aggregate(inning ~ game_id, b, function(x) length(unique(x)))
  team <- aggregate(cbind(runs_scored, re24) ~ game_id, impact, sum)
  team <- merge(team, innings, by = "game_id")
  expect_equal(team$re24, team$runs_scored - 0.461 * team$inning)
  official_runs <- c("746804" = 3, "822782" = 1, "823644" = 6, "823774" = 4, "825071" = 4)
  expect_identical(as.numeric(team$runs_scored), unname(official_runs[team$game_id]))
})

test_that("single events match the FanGraphs matrix by hand", {
  re <- function(id) impact$re24[impact$game_id == "825071" & impact$event_id == id]
  expect_equal(re("30"), 1 + 0.489 - 0.865)    # RBI single, runner on third
  expect_equal(re("29.2"), 1.426 - 0.831)      # steal plus error to third
  expect_equal(re("54.1"), 0.243 - 0.831)      # picked off first
})

test_that("plot_run_impact returns sorted totals and checks input", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  shown <- plot_run_impact(impact, top = 5)
  all_players <- plot_run_impact(impact, top = Inf)
  expect_equal(nrow(shown), 5L)
  expect_false(is.unsorted(rev(shown$re24)))
  expect_equal(sum(all_players$re24), sum(impact$re24))
  expect_equal(sum(all_players$events), 188L)
  expect_error(plot_run_impact(impact, top = 0), "positive whole number")
  expect_error(plot_run_impact(impact[0, ]), "no events")
  expect_error(plot_run_impact(data.frame(player = "A")), "player and re24")
})
