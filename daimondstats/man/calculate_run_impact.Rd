\name{calculate_run_impact}
\alias{calculate_run_impact}
\title{Calculate Run Expectancy Added for Verified Events}
\usage{calculate_run_impact(plays, expectancy)}
\arguments{
\item{plays}{Data frame with character game_id, event_id, player;
integer-valued outs_before, bases_before, outs_after, bases_after, runs_scored;
and logical verified. Base masks add 1 for first, 2 for second, 4 for third.}
\item{expectancy}{Data frame with 24 distinct combinations of outs (0:2), bases
(0:7), and finite nonnegative numeric expected_runs.}
}
\description{Apply a supplied reference matrix to verified transitions.
RE24 is runs scored plus ending expectancy minus starting expectancy.}
\details{Use a documented matrix appropriate to the league and run environment.
The function does not estimate the matrix or infer runner movement. All rows
must have verified = TRUE, which is a caller assertion, not automatic validation
against an official record. Duplicate game/event IDs and invalid states are
errors. Standalone runner events must identify the responsible runner, not the
batter. Walk-off states use the supplied base-out expectancy; game end alone
does not force zero. RE24 describes situational value, not predictive ability.}
\value{Input rows with added re_before, re_after, and re24 columns. Three outs
sets re_after to zero. Empty inputs return zero rows with consistent columns.
Sum re24 over the desired events. Other input columns are retained.}
\references{Weinberg, Neil. 2014. "RE24." FanGraphs, July 30.
\url{https://library.fangraphs.com/misc/re24/}}
\examples{
# Fictional demonstration matrix, not an MLB estimate.
reference <- expand.grid(outs = 0:2, bases = 0:7)
reference$expected_runs <- (3 - reference$outs) * 0.2 + reference$bases * 0.1
plays <- data.frame(game_id = "demo", event_id = "1", player = "Demo Batter",
  outs_before = 0, bases_before = 0, outs_after = 0, bases_after = 0,
  runs_scored = 1, verified = TRUE)
calculate_run_impact(plays, reference)$re24
}
