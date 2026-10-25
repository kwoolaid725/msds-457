# Module 5 figure: batting stats from the packaged Twins scorecard.
# Run from msds-457/: Rscript "module 5/Kim_Module5_batting_stats.R"
library(ggplot2)
lib <- file.path(tempdir(), "lib")
dir.create(lib, showWarnings = FALSE)
install.packages("daimondstats", repos = NULL, type = "source", lib = lib, quiet = TRUE)
library(daimondstats, lib.loc = lib)

plays <- twins_scorecard_2024
# Resolve the one flagged entry using the official MLB event (lineout).
flagged <- plays$needs_review
stopifnot(sum(flagged) == 1, plays$reference_play[flagged] == "lineout")
plays$play[flagged] <- plays$reference_play[flagged]
plays$needs_review[flagged] <- FALSE

stats <- calculate_batting_stats(plays)
stopifnot(sum(stats$PA) == 35, nrow(stats) == 12)
print(stats[, c("player", "PA", "AB", "H", "BB", "TB", "BA", "OBP", "SLG")], digits = 3)

# Split each player's plate appearances using the calculated counts.
long <- data.frame(
  player = rep(stats$player, 3),
  result = factor(rep(c("Hit", "Walk", "Out or error"), each = nrow(stats)),
                  levels = c("Out or error", "Walk", "Hit")),
  n = c(stats$H, stats$BB, stats$AB - stats$H)
)
order <- stats$player[order(stats$PA, stats$H + stats$BB)]
long$player <- factor(long$player, levels = order)
stats$player <- factor(stats$player, levels = order)
stats$label <- sprintf("OBP %s", sub("^0", "", sprintf("%.3f", stats$OBP)))
p <- ggplot(long, aes(n, player, fill = result)) +
  geom_col(width = 0.65, colour = "white", linewidth = 0.4) +
  geom_text(data = stats, aes(PA, player, label = label), inherit.aes = FALSE,
            hjust = -0.15, size = 3, colour = "#444444") +
  scale_fill_manual(values = c("Hit" = "#2864B4", "Walk" = "#128273",
                               "Out or error" = "#C6CBD2"),
                    breaks = c("Hit", "Walk", "Out or error")) +
  scale_x_continuous(limits = c(0, 5.3), breaks = 0:4,
                     expand = expansion(mult = c(0, 0))) +
  labs(title = "Plate appearances and on-base percentage by player",
       subtitle = "Twins at White Sox | April 29, 2024 | from calculate_batting_stats()",
       x = "Plate appearances", y = NULL, fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank())
ggsave(file.path("module 5", "Kim_Module5_batting_stats.png"), p,
       width = 7, height = 3.7, dpi = 300)
