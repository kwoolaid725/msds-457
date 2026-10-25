# Run from the repository/course root: Rscript "module 5/Kim_Module5_batting_stats.R"
library(ggplot2)
lib <- file.path(tempdir(), "lib")
dir.create(lib, showWarnings = FALSE)
install.packages("daimondstats", repos = NULL, type = "source", lib = lib, quiet = TRUE)
library(daimondstats, lib.loc = lib)

d <- reviewed_scorecards
stats <- calculate_batting_stats(d)
counts <- c("PA", "AB", "H", "BB", "HBP", "SF", "SH", "CI", "TB")
s <- aggregate(stats[counts], stats[c("game_id", "team")], sum)
meta <- unique(d[c("game_id", "game_date", "opponent")])
s <- merge(s, meta, by = "game_id")
s$OBP <- with(s, (H + BB + HBP) / (AB + BB + HBP + SF))
s$SLG <- s$TB / s$AB
stopifnot(nrow(s) == 5, sum(s$PA) == 179,
          !anyDuplicated(d[c("game_id", "event_id")]), !any(d$needs_review),
          abs(s$OBP[s$game_id == "825071"] - 12/35) < 1e-12,
          abs(s$OBP[s$game_id == "823644"] - 14/41) < 1e-12)
print(s[, c("team", "game_date", "PA", "H", "BB", "HBP", "OBP", "SLG")], digits = 4)
write.csv(s, file.path("module 5", "Kim_Module5_game_summary.csv"), row.names = FALSE)

team <- c("Arizona Diamondbacks" = "Diamondbacks", "St. Louis Cardinals" = "Cardinals",
          "Minnesota Twins" = "Twins", "Cleveland Guardians" = "Guardians",
          "New York Mets" = "Mets")
opponent <- c("Los Angeles Angels" = "Angels", "Toronto Blue Jays" = "Blue Jays",
              "Chicago White Sox" = "White Sox", "Milwaukee Brewers" = "Brewers",
              "Athletics" = "Athletics")
s$label <- paste0(team[s$team], " vs ", opponent[s$opponent], "\n", s$game_date)
s$label <- factor(s$label, levels = s$label[order(s$OBP)])
s$rate_label <- paste0("OBP ", sub("^0", "", sprintf("%.3f", s$OBP)))
long <- data.frame(label = rep(s$label, 4),
  result = factor(rep(c("Hit", "Walk", "Hit by pitch", "Other PA"), each = nrow(s)),
                  levels = c("Other PA", "Hit by pitch", "Walk", "Hit")),
  n = c(s$H, s$BB, s$HBP, s$PA - s$H - s$BB - s$HBP))
stopifnot(all(long$n >= 0), sum(long$n) == 179)
p <- ggplot(long, aes(n, label, fill = result)) +
  geom_col(width = 0.62, colour = "white", linewidth = 0.3) +
  geom_text(data = s, aes(PA, label, label = rate_label), inherit.aes = FALSE,
            hjust = -0.12, size = 3.1, colour = "#333333") +
  scale_fill_manual(values = c("Hit" = "#2864B4", "Walk" = "#128273",
                               "Hit by pitch" = "#DDA33D", "Other PA" = "#C6CBD2"),
                    breaks = c("Hit", "Walk", "Hit by pitch", "Other PA")) +
  scale_x_continuous(limits = c(0, 53), breaks = seq(0, 40, 10),
                     expand = expansion(mult = c(0, 0))) +
  labs(title = "Batting outcomes in five reviewed scorecards",
       subtitle = "179 plate appearances | one team's side of each game | 2024 and 2026",
       x = "Plate appearances", y = NULL, fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank())
ggsave(file.path("module 5", "Kim_Module5_batting_stats.png"), p,
       width = 7, height = 3.5, dpi = 300, bg = "white")
