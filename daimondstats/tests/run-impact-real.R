library(daimondstats)

expect_error <- function(expr, message) {
  err <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(err, "error"), grepl(message, conditionMessage(err), fixed = TRUE))
}
b <- reviewed_base_out
m <- run_expectancy_fangraphs
stopifnot(nrow(b) == 188L, sum(b$batting_event) == 179L, all(b$verified),
          !anyDuplicated(b[c("game_id", "event_id")]),
          nrow(m) == 24L, !anyDuplicated(m[c("outs", "bases")]))

# Every reviewed plate appearance has exactly one batting event, same batter.
bat <- b[b$batting_event, ]
joined <- merge(reviewed_scorecards, bat, by = c("game_id", "event_id"),
                suffixes = c("_card", "_feed"))
stopifnot(nrow(joined) == 179L, all(joined$batter_id == joined$player_id))

impact <- calculate_run_impact(b, m)
# An inning starts empty with no outs and ends with three outs and zero
# expectancy, so a team's RE24 equals runs minus 0.461 per inning batted.
innings <- aggregate(inning ~ game_id, b, function(x) length(unique(x)))
team <- aggregate(cbind(runs_scored, re24) ~ game_id, impact, sum)
team <- merge(team, innings, by = "game_id")
stopifnot(all(abs(team$re24 - (team$runs_scored - 0.461 * team$inning)) < 1e-9))
official_runs <- c("746804" = 3, "822782" = 1, "823644" = 6, "823774" = 4, "825071" = 4)
stopifnot(identical(as.numeric(team$runs_scored), unname(official_runs[team$game_id])))

# Hand-calculated events from the FanGraphs matrix.
re <- function(id) impact$re24[impact$game_id == "825071" & impact$event_id == id]
stopifnot(abs(re("30") - (1 + 0.489 - 0.865)) < 1e-9,    # RBI single, runner on third
          abs(re("29.2") - (1.426 - 0.831)) < 1e-9,      # steal plus error to third
          abs(re("54.1") - (0.243 - 0.831)) < 1e-9)      # picked off first

# Plot returns sorted totals and validates its inputs.
grDevices::pdf(NULL)
shown <- plot_run_impact(impact, top = 5)
all_players <- plot_run_impact(impact, top = Inf)
grDevices::dev.off()
stopifnot(nrow(shown) == 5L, !is.unsorted(rev(shown$re24)),
          abs(sum(all_players$re24) - sum(impact$re24)) < 1e-9,
          sum(all_players$events) == 188L)
expect_error(plot_run_impact(impact, top = 0), "positive whole number")
expect_error(plot_run_impact(impact[0, ]), "no events")
expect_error(plot_run_impact(data.frame(player = "A")), "player and re24")
