# Run from the package root after verify-scorecards.py.
reviewed_scorecards <- read.csv(
  "data-raw/reviewed-scorecards.csv", fileEncoding = "UTF-8", encoding = "UTF-8",
  colClasses = c(game_id = "character", inning = "character", event_id = "character",
                needs_review = "logical", source_needs_review = "logical")
)
reviewed_scorecards$game_date <- as.Date(reviewed_scorecards$game_date)
stopifnot(nrow(reviewed_scorecards) == 179L,
          length(unique(reviewed_scorecards$game_id)) == 5L,
          !anyDuplicated(reviewed_scorecards[c("game_id", "event_id")]),
          !any(reviewed_scorecards$needs_review),
          all(reviewed_scorecards$play == reviewed_scorecards$reference_play))
save(reviewed_scorecards, file = "data/reviewed_scorecards.rda", version = 2,
     compress = "xz")
