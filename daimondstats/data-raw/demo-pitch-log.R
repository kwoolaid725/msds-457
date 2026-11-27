# Fictional 12U pitching log for one month (four pitchers, 11 games,
# including a Saturday doubleheader). Built to show every check outcome:
# clean weeks, a short-rest return, and a day over the daily maximum.
demo_pitch_log <- data.frame(
  pitcher = c("Mia Torres", "Leo Park", "Mia Torres", "Sam Okafor", "Leo Park",
              "Mia Torres", "Mia Torres", "Leo Park", "Sam Okafor", "Jay Ruiz",
              "Leo Park", "Mia Torres", "Sam Okafor", "Jay Ruiz", "Leo Park"),
  age = c(12, 11, 12, 12, 11, 12, 12, 11, 12, 10, 11, 12, 12, 10, 11),
  date = as.Date(c("2026-05-02", "2026-05-02", "2026-05-06", "2026-05-06",
                   "2026-05-09", "2026-05-09", "2026-05-09", "2026-05-12",
                   "2026-05-12", "2026-05-12", "2026-05-16", "2026-05-16",
                   "2026-05-20", "2026-05-20", "2026-05-23")),
  game = c("vs Hawks", "vs Hawks", "at Rays", "at Rays", "DH game 1 vs Owls",
           "DH game 1 vs Owls", "DH game 2 vs Owls", "at Cubs", "at Cubs",
           "at Cubs", "vs Foxes", "vs Foxes", "at Bears", "at Bears", "vs Jays"),
  pitches = c(66, 24, 33, 61, 47, 22, 41, 52, 18, 30, 66, 49, 72, 20, 88),
  stringsAsFactors = FALSE
)
save(demo_pitch_log, file = "data/demo_pitch_log.rda", compress = "bzip2")
