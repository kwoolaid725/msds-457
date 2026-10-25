library(daimondstats)

# Independent MLB box-score fixtures, including a hit-by-pitch and sacrifice fly.
game_expected <- read.csv(system.file("extdata", "reviewed_game_totals.csv",
                                     package = "daimondstats"),
                          colClasses = c(game_id = "character"), encoding = "UTF-8")
player_expected <- read.csv(system.file("extdata", "reviewed_player_totals.csv",
                                       package = "daimondstats"),
                            colClasses = c(game_id = "character"), encoding = "UTF-8")
d <- reviewed_scorecards
stopifnot(nrow(d) == 179L, length(unique(d$game_id)) == 5L,
          !anyDuplicated(d[c("game_id", "event_id")]),
          !any(d$needs_review), all(d$play == d$reference_play),
          sum(d$play != d$source_play) == 10L)
actual <- calculate_batting_stats(d)
count_names <- c("PA", "AB", "H", "BB", "HBP", "SF", "SH", "CI", "TB")
for (expected in list(game_expected, player_expected)) {
  keys <- intersect(c("game_id", "team", "player"), names(expected))
  observed <- aggregate(actual[count_names], actual[keys], sum)
  stopifnot(nrow(observed) == nrow(expected))
  combined <- merge(observed, expected, by = keys, suffixes = c("_actual", "_official"))
  stopifnot(nrow(combined) == nrow(expected))
  for (nm in count_names) {
    stopifnot(identical(as.numeric(combined[[paste0(nm, "_actual")]]),
                        as.numeric(combined[[paste0(nm, "_official")]])))
  }
}
# Pool numerators and denominators; averaging individual OBPs gives the wrong result.
totals <- aggregate(actual[count_names], actual[c("game_id", "team")], sum)
obp <- with(totals, (H + BB + HBP) / (AB + BB + HBP + SF))
stopifnot(abs(obp[totals$game_id == "825071"] - 12/35) < 1e-12,
          abs(obp[totals$game_id == "823644"] - 14/41) < 1e-12,
          abs(obp[totals$game_id == "823774"] - 6/33) < 1e-12)
