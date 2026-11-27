# Writes inst/extdata/youth_analytics_parity.json: inputs plus R results for
# calculate_youth_stats() and check_pitch_counts(). The dAImond Inning app's
# Python port (pipeline/10_output/youth_analytics.py) is tested against a
# copy of this file, so the app and the package always report the same numbers.
devtools::load_all(".", quiet = TRUE)
plays <- reviewed_scorecards[c("game_id", "team", "player", "inning", "play")]
extra <- data.frame(
  game_id = "fixture", team = "Owls", player = c(rep("Ava", 10), "Ben", "Ben"),
  inning = as.character(1:12),
  play = c("single", "double", "home_run", "error", "error", "walk",
           "hit_by_pitch", "strikeout", "groundout", "sacrifice_fly",
           "manfred_runner", "sacrifice_bunt"))
plays <- rbind(plays, extra)
full <- transform(plays, confidence = 1, needs_review = FALSE)
youth <- calculate_youth_stats(full, min_pa = 5)
pitch_log <- data.frame(
  pitcher = c("Ava", "Ava", "Ben", "Ben", "Cy", "Cy", "Dee", "Dee", "Dee", "Dee",
              "Eli", "Eli", "Fay", "Gus", "Hal", "Ivy"),
  age = c(11, 11, 12, 12, 15, 15, 12, 12, 12, 12, 9, 9, 17, 7, 13, 18),
  date = c("2026-05-02", "2026-05-04", "2026-05-02", "2026-05-03",
           "2026-05-02", "2026-05-02", "2026-06-01", "2026-06-02",
           "2026-06-04", "2026-06-06", "2026-06-01", "2026-06-02",
           "2026-06-03", "2026-06-03", "2026-06-03", "2026-06-03"),
  pitches = c(60, 30, 90, 10, 40, 30, 70, 10, 10, 10, 40, 80, 61, 0, 95, 106))
checks <- check_pitch_counts(pitch_log)
checks$date <- format(checks$date)
checks$next_eligible <- format(checks$next_eligible)
jsonlite::write_json(list(
  source = "daimondstats 0.1.0 (R reference implementation)",
  youth_min_pa = 5, plays = plays, youth_stats = youth,
  pitch_log = pitch_log, pitch_checks = checks),
  "inst/extdata/youth_analytics_parity.json", digits = NA, na = "null",
  auto_unbox = TRUE, pretty = TRUE)
