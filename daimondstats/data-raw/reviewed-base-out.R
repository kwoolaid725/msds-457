# Run from the package root after base-out-states.py.
reviewed_base_out <- read.csv(
  "data-raw/reviewed-base-out.csv", fileEncoding = "UTF-8", encoding = "UTF-8",
  colClasses = c(game_id = "character", event_id = "character",
                batting_event = "logical", verified = "logical")
)
stopifnot(nrow(reviewed_base_out) == 188L, sum(reviewed_base_out$batting_event) == 179L,
          all(reviewed_base_out$verified),
          !anyDuplicated(reviewed_base_out[c("game_id", "event_id")]))
save(reviewed_base_out, file = "data/reviewed_base_out.rda", version = 2,
     compress = "xz")

# FanGraphs RE24 matrix (Weinberg 2014), run environment 4.15 runs per game.
# Base masks: 1 = first, 2 = second, 4 = third.
run_expectancy_fangraphs <- data.frame(
  outs = rep(0:2, times = 8),
  bases = rep(c(0, 1, 2, 3, 4, 5, 6, 7), each = 3),
  expected_runs = c(0.461, 0.243, 0.095,  # empty
                    0.831, 0.489, 0.214,  # 1 _ _
                    1.068, 0.644, 0.305,  # _ 2 _
                    1.373, 0.908, 0.343,  # 1 2 _
                    1.426, 0.865, 0.413,  # _ _ 3
                    1.798, 1.140, 0.471,  # 1 _ 3
                    1.920, 1.352, 0.570,  # _ 2 3
                    2.282, 1.520, 0.736)  # 1 2 3
)
run_expectancy_fangraphs$outs <- as.integer(run_expectancy_fangraphs$outs)
run_expectancy_fangraphs$bases <- as.integer(run_expectancy_fangraphs$bases)
save(run_expectancy_fangraphs, file = "data/run_expectancy_fangraphs.rda",
     version = 2, compress = "xz")
