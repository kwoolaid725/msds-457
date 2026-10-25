# Run from the package root after extracting the saved dAImondInning scorecard.
twins_scorecard_2024 <- read.csv(
  "data-raw/twins-scorecard-2024.csv",
  colClasses = c("character", "character", "character", "character",
                "character", "numeric", "logical", "character",
                "character", "logical"),
  fileEncoding = "UTF-8", encoding = "UTF-8"
)
twins_scorecard_2024$game_date <- as.Date(twins_scorecard_2024$game_date)
stopifnot(
  nrow(twins_scorecard_2024) == 35L,
  ncol(twins_scorecard_2024) == 10L,
  length(unique(twins_scorecard_2024$player)) == 12L,
  sum(twins_scorecard_2024$play_matches_reference) == 34L,
  sum(twins_scorecard_2024$needs_review) == 1L,
  all(twins_scorecard_2024$confidence >= 0 & twins_scorecard_2024$confidence <= 1)
)
save(twins_scorecard_2024, file = "data/twins_scorecard_2024.rda",
     version = 2, compress = "xz")
