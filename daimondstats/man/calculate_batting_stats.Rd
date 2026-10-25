\name{calculate_batting_stats}
\alias{calculate_batting_stats}
\title{Calculate Batting Statistics from Reviewed Plays}
\usage{calculate_batting_stats(scorecards)}
\arguments{
\item{scorecards}{A data frame with the seven columns returned by
\code{\link{import_scorecards}}. Entries must have known confidence and
needs_review set to FALSE following review.}
}
\description{Calculate counting and rate statistics for each game, team, and player.}
\details{
BA = H/AB; OBP = (H+BB+HBP)/(AB+BB+HBP+SF); SLG = TB/AB; OPS = OBP+SLG.
Walks include intentional walks. Sacrifice bunts and catcher interference count
as plate appearances but are excluded from AB and the OBP denominator. Sacrifice
flies are excluded from AB but included in the OBP denominator. Errors and
fielder's choices are at-bats, not hits. Double plays contribute one batter
at-bat. Automatic runners and no_at_bat markers are not plate appearances.
Unknown plays cause errors. Flagged entries must be reviewed before calculation.
Duplicate-looking rows are retained because a player may have multiple plate
appearances in an inning. Callers must avoid importing the same game twice.
This version does not estimate missing plays or resolve duplicate player names.
}
\value{One row per game_id, team, and player, in first-appearance order, with
PA, AB, H, BB, HBP, SF, SH, CI, TB, BA, OBP, SLG, and OPS. Rate statistics
are unrounded and are NA when their denominator is zero. Players with only
non-appearance markers produce no output row.}
\examples{
path <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
plays <- import_scorecards(path, "demo-01")
calculate_batting_stats(plays)
}
\seealso{\code{\link{import_scorecards}}}
