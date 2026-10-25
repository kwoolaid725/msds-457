library(daimondstats)

# Small, hand-calculated examples verify baseball rules independently of code.
expect_error <- function(expr, message) {
  err <- tryCatch({ force(expr); NULL }, error = identity)
  stopifnot(inherits(err, "error"), grepl(message, conditionMessage(err), fixed = TRUE))
}
csv <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
plays <- import_scorecards(csv, "demo-01")
stopifnot(nrow(plays) == 11L, plays$inning[6] == "8+",
          identical(plays$play[1], "single"), !any(plays$needs_review))
stats <- calculate_batting_stats(plays)
stopifnot(nrow(stats) == 2L)
alex <- stats[stats$player == "Alex Demo", ]
sam <- stats[stats$player == "Sam Demo", ]
stopifnot(alex$PA == 6, alex$AB == 4, alex$H == 3, alex$TB == 7,
          alex$BA == 3/4, alex$OBP == 4/6, alex$SLG == 7/4,
          alex$OPS == 4/6 + 7/4)
stopifnot(sam$PA == 4, sam$AB == 0, sam$BB == 1, sam$HBP == 1,
          sam$SH == 1, sam$CI == 1, sam$OBP == 1,
          is.na(sam$BA), is.na(sam$SLG), is.na(sam$OPS))

# Same player name on another team or in another game must not be merged.
other_game <- transform(plays, game_id = "demo-02")
other_team <- transform(plays, team = "Demo Foxes")
stopifnot(nrow(calculate_batting_stats(rbind(plays, other_game, other_team))) == 6L)
stopifnot(identical(calculate_batting_stats(plays)$BA, stats$BA))

# Same inning can have more than one appearance; do not deduplicate real PAs.
twice <- rbind(plays[1, ], plays[1, ])
stopifnot(calculate_batting_stats(twice)$PA == 2)

# Other supported outs are at-bats. Error/FC are not times on base for OBP.
outs <- plays[rep(1, 7), ]
outs$play <- c("error", "fielder's_choice", "double_play", "flyout", "lineout", "strikeout_looking", "groundout")
out_stats <- calculate_batting_stats(outs)
stopifnot(out_stats$AB == 7, out_stats$PA == 7, out_stats$H == 0, out_stats$OBP == 0)
triple <- plays[1, ]
triple$play <- "triple"
stopifnot(calculate_batting_stats(triple)$TB == 3)
walk <- plays[5, ]
stopifnot(calculate_batting_stats(walk)$OBP == 1, is.na(calculate_batting_stats(walk)$BA))
fly <- plays[6, ]
stopifnot(calculate_batting_stats(fly)$OBP == 0, is.na(calculate_batting_stats(fly)$BA))
bunt <- plays[9, ]
stopifnot(is.na(calculate_batting_stats(bunt)$OBP))

# Empty and non-appearance inputs have consistent, zero-row results.
stopifnot(nrow(calculate_batting_stats(plays[0, ])) == 0L,
          identical(names(calculate_batting_stats(plays[0, ])), names(stats)))
blank <- plays[1, ]
blank$play <- "no_at_bat"
stopifnot(nrow(calculate_batting_stats(blank)) == 0L,
          nrow(calculate_batting_stats(plays[11, ])) == 0L)

# Both entry points validate inputs instead of guessing what the user meant.
expect_error(import_scorecards(tempfile(), "demo"), "existing CSV")
expect_error(import_scorecards(csv, ""), "game_id")
expect_error(import_scorecards(csv, 10), "game_id")
expect_error(calculate_batting_stats(list()), "data frame")
expect_error(calculate_batting_stats(plays[-1]), "data frame")
bad <- plays
bad$player[1] <- NA_character_
expect_error(calculate_batting_stats(bad), "player")
bad <- plays
bad$play[1] <- "bad_crop"
expect_error(calculate_batting_stats(bad), "Unrecognized play")
bad <- plays
bad$needs_review[1] <- TRUE
expect_error(calculate_batting_stats(bad), "Review flagged")
bad$needs_review[1] <- NA
expect_error(calculate_batting_stats(bad), "needs_review")
bad <- plays
bad$confidence[1] <- NA_real_
expect_error(calculate_batting_stats(bad), "missing confidence")
bad$confidence[1] <- Inf
expect_error(calculate_batting_stats(bad), "confidence")

# CSV problems: BOM, reordered columns, whitespace, malformed flags and values.
raw <- utils::read.csv(csv, check.names = FALSE, colClasses = "character", na.strings = "")
tmp <- tempfile(fileext = ".csv")
write_csv <- function(x) utils::write.csv(x, tmp, row.names = FALSE, na = "")
write_csv(raw[0, ])
stopifnot(nrow(import_scorecards(tmp, "demo")) == 0L)
write_csv(raw[rev(names(raw))])
stopifnot(identical(import_scorecards(tmp, "demo-01"), plays))
write_csv(raw[-1])
expect_error(import_scorecards(tmp, "demo"), "Missing CSV columns: Team")
bad <- raw
bad$Play[1] <- "mystery event"
write_csv(bad)
expect_error(import_scorecards(tmp, "demo"), "Unrecognized play")
bad$Play[1] <- ""
write_csv(bad)
expect_error(import_scorecards(tmp, "demo"), "play")
bad <- raw
bad$Confidence[1] <- "97%"
write_csv(bad)
expect_error(import_scorecards(tmp, "demo"), "Confidence")
bad$Confidence[1] <- "1.1"
write_csv(bad)
expect_error(import_scorecards(tmp, "demo"), "Confidence")
bad$Confidence[1] <- ""
write_csv(bad)
stopifnot(import_scorecards(tmp, "demo")$needs_review[1])
bad <- raw
bad[["Needs Review"]][1] <- "maybe"
write_csv(bad)
expect_error(import_scorecards(tmp, "demo"), "Needs Review")
bad[["Needs Review"]][1] <- "Yes"
write_csv(bad)
expect_error(calculate_batting_stats(import_scorecards(tmp, "demo")), "Review flagged")
bad <- raw
bad$Play[1] <- "  Single (1B) "
write_csv(bad)
stopifnot(import_scorecards(tmp, "demo")$play[1] == "single")
write_csv(raw)
bytes <- readBin(tmp, "raw", n = file.info(tmp)$size)
writeBin(c(as.raw(c(239, 187, 191)), bytes), tmp)
stopifnot(identical(import_scorecards(tmp, "demo-01"), plays))
unlink(tmp)

stopifnot(identical(demo_scorecards, plays))
cat("All scorecard import and batting-statistics checks passed.\n")
