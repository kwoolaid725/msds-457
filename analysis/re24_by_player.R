# Run from the repository root after installing daimondstats 0.0.4:
# Rscript analysis/re24_by_player.R
library(daimondstats)
impact <- calculate_run_impact(reviewed_base_out, run_expectancy_fangraphs)
png(file.path("analysis", "re24_by_player.png"), width = 1400, height = 900, res = 150)
totals <- plot_run_impact(impact, top = 12,
                          main = "RE24 by player, five reviewed scorecards")
dev.off()
print(aggregate(cbind(runs_scored, re24) ~ team, impact, sum))
print(totals)
