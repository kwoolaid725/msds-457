test_that("reviewed scorecards are complete and match the MLB reference plays", {
  d <- reviewed_scorecards
  expect_equal(nrow(d), 179L)
  expect_equal(length(unique(d$game_id)), 5L)
  expect_equal(anyDuplicated(d[c("game_id", "event_id")]), 0L)
  expect_false(any(d$needs_review))
  expect_true(all(d$play == d$reference_play))
  expect_equal(sum(d$play != d$source_play), 10L)
})

test_that("batting totals equal independent MLB box-score fixtures", {
  # The fixtures include a hit-by-pitch and a sacrifice fly.
  game_expected <- read.csv(system.file("extdata", "reviewed_game_totals.csv",
                                        package = "daimondstats"),
                            colClasses = c(game_id = "character"), encoding = "UTF-8")
  player_expected <- read.csv(system.file("extdata", "reviewed_player_totals.csv",
                                          package = "daimondstats"),
                              colClasses = c(game_id = "character"), encoding = "UTF-8")
  actual <- calculate_batting_stats(reviewed_scorecards)
  count_names <- c("PA", "AB", "H", "BB", "HBP", "SF", "SH", "CI", "TB")
  for (expected in list(game_expected, player_expected)) {
    keys <- intersect(c("game_id", "team", "player"), names(expected))
    observed <- aggregate(actual[count_names], actual[keys], sum)
    expect_equal(nrow(observed), nrow(expected))
    combined <- merge(observed, expected, by = keys, suffixes = c("_actual", "_official"))
    expect_equal(nrow(combined), nrow(expected))
    for (nm in count_names) {
      expect_identical(as.numeric(combined[[paste0(nm, "_actual")]]),
                       as.numeric(combined[[paste0(nm, "_official")]]), label = nm)
    }
  }
  # Pool numerators and denominators; averaging individual OBPs is wrong.
  totals <- aggregate(actual[count_names], actual[c("game_id", "team")], sum)
  obp <- with(totals, (H + BB + HBP) / (AB + BB + HBP + SF))
  expect_equal(obp[totals$game_id == "825071"], 12/35)
  expect_equal(obp[totals$game_id == "823644"], 14/41)
  expect_equal(obp[totals$game_id == "823774"], 6/33)
})
