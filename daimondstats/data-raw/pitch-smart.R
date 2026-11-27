# Builds `pitch_smart_rules` from the MLB/USA Baseball Pitch Smart tables,
# transcribed from https://www.mlb.com/pitch-smart/pitching-guidelines
# (checked 2026-11-26). Ages 19-22 are left out: the published rest table
# stops at 105 pitches while the daily maximum is 120.
groups <- data.frame(
  age_min = c(7, 9, 11, 13, 15, 17),
  age_max = c(8, 10, 12, 14, 16, 18),
  daily_max = c(50, 75, 85, 95, 95, 105)
)
bands <- list(
  young = data.frame(pitches_min = c(1, 21, 36, 51, 66),
                     pitches_max = c(20, 35, 50, 65, NA), rest_days = 0:4),
  teen = data.frame(pitches_min = c(1, 31, 46, 61, 76),
                    pitches_max = c(30, 45, 60, 75, NA), rest_days = 0:4),
  older = data.frame(pitches_min = c(1, 31, 46, 61, 81),
                     pitches_max = c(30, 45, 60, 80, NA), rest_days = 0:4)
)
band_for <- c("young", "young", "young", "young", "teen", "older")
rows <- lapply(seq_len(nrow(groups)), function(i) {
  b <- bands[[band_for[i]]]
  b$pitches_max[is.na(b$pitches_max)] <- groups$daily_max[i]
  b <- b[b$pitches_min <= groups$daily_max[i], ]
  b$pitches_max <- pmin(b$pitches_max, groups$daily_max[i])
  cbind(groups[rep(i, nrow(b)), ], b)
})
pitch_smart_rules <- do.call(rbind, rows)
pitch_smart_rules[] <- lapply(pitch_smart_rules, as.integer)
rownames(pitch_smart_rules) <- NULL
stopifnot(nrow(pitch_smart_rules) == 28L)
save(pitch_smart_rules, file = "data/pitch_smart_rules.rda", compress = "bzip2")
