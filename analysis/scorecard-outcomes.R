library(ggplot2)
load("daimondstats/data/twins_scorecard_2024.rda")
d <- twins_scorecard_2024
d$inning <- factor(d$inning, levels = 1:9)
key <- c(single = "Hit", double = "Hit", home_run = "Hit", walk = "Walk",
         error = "Reached on error", groundout = "Out", flyout = "Out",
         lineout = "Out", strikeout = "Out", strikeout_looking = "Out")
d$outcome <- factor(key[d$play],
                   levels = c("Out", "Hit", "Walk", "Reached on error"))
stopifnot(nrow(d) == 35, !anyNA(d$inning), !anyNA(d$outcome))
# Retain the flagged flyout/lineout: either label is an out.
p <- ggplot(d, aes(inning, fill = outcome)) +
  geom_bar(width = 0.7, position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = c("Out" = "#C6CBD2", "Hit" = "#2864B4",
    "Walk" = "#128273", "Reached on error" = "#DDA33D")) +
  scale_y_continuous(breaks = 0:6, expand = expansion(mult = c(0, 0.05))) +
  labs(title = "Recorded plate appearances by inning",
       subtitle = "Twins at White Sox | April 29, 2024",
       x = "Inning", y = "Recorded plate appearances", fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())
ggsave("analysis/scorecard-outcomes.png", p, width = 7, height = 3.1, dpi = 300)
