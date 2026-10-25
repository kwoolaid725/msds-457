\name{import_scorecards}
\alias{import_scorecards}
\title{Import a Play-Level Scorecard CSV}
\usage{import_scorecards(path, game_id)}
\arguments{
\item{path}{Path to one UTF-8 CSV file.}
\item{game_id}{One nonempty character identifier supplied by the caller. Use a
consistent identifier for both teams in a game and distinct identifiers for different games.}
}
\description{Read the standard dAImond Inning Plays CSV without changing the source file.}
\details{
Required columns are Team, Player, Inning, Play, Confidence, and Needs Review.
Custom exports must retain these names. Extra columns are ignored. Confidence
must be a number between zero and one or blank. A missing confidence forces review.
Review flags accept Yes/No, TRUE/FALSE, 1/0, or blank (false, matching the app).
Human-readable play labels are converted to canonical app labels. Unknown plays
and bad crops raise errors. Explicit no_at_bat and automatic-runner markers are
retained but excluded from batting statistics. The upstream CSV exporter omits
blank and bad-crop cells; this importer cannot detect those omitted readings.
Player names identify players within a game and team, not across an entire career.
}
\value{A data frame with character columns game_id, team, player, inning, and
play, numeric confidence, and logical needs_review. Inning labels such as 8+
are retained. Header-only files return zero rows.}
\examples{
path <- system.file("extdata", "demo_plays.csv", package = "daimondstats")
plays <- import_scorecards(path, "demo-01")
head(plays)
}
\seealso{\code{\link{calculate_batting_stats}}}
