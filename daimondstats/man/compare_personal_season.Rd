\name{compare_personal_season}
\alias{compare_personal_season}
\title{Compare a Personal Game Collection with a Reference Season}
\usage{
compare_personal_season(games, game_ids, metric = "win",
  strata = "home", simulations = 2000L)
}
\arguments{
\item{games}{Data frame with unique character game_id, team, season, a finite
numeric metric, and any stratum columns. Supply one team's one season.}
\item{game_ids}{Unique character IDs of the personally recorded games.}
\item{metric}{Numeric game-level column to average. Default win requires 0/1.}
\item{strata}{Column names to match jointly; default home preserves home/away
counts. Use character(0) for unrestricted sampling.}
\item{simulations}{Positive integer number of draws, default 2000.}
}
\description{Draw same-size collections without replacement from the supplied
games, preserving selected counts within strata.}
\details{Requires at least one selected and one unselected game. Duplicate game
IDs and missing values are errors. Sampling includes selected games in the
reference population. Use set.seed() for reproducibility. Games are assumed
exchangeable within strata. Detailed strata may leave little variation, and
unmeasured selection differences remain. This function does not test multiple
patterns or estimate a causal effect of scorekeeping.}
\value{A list with summary, simulated_means, and settings. The one-row summary
contains metric, selected_games, other_games, personal_mean, other_mean,
season_mean, difference (personal minus other), reference_low and reference_high
(2.5th and 97.5th percentiles), and reference_percentile (midrank for ties).
The reference range is a distribution of sampled collections, not a confidence
interval for an effect or player ability.}
\examples{
games <- data.frame(game_id = letters[1:8], team = "Demo", season = 2025,
  home = rep(c(TRUE, FALSE), 4), win = c(1, 0, 1, 1, 0, 0, 1, 0))
set.seed(457)
compare_personal_season(games, c("a", "b", "c"), simulations = 100)$summary
}
