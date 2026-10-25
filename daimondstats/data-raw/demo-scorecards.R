# Run from the package root. These are fictional examples, not MLB observations.
source("R/calculate_batting_stats.R")
source("R/import_scorecards.R")
demo_scorecards <- import_scorecards("inst/extdata/demo_plays.csv", "demo-01")
dir.create("data", showWarnings = FALSE)
save(demo_scorecards, file = "data/demo_scorecards.rda", version = 2, compress = "xz")
