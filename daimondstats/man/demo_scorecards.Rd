\name{demo_scorecards}
\alias{demo_scorecards}
\docType{data}
\title{Fictional Scorecard Plays for Learning and Testing}
\description{Eleven entries for two fictional players in one game, including
an automatic-runner marker. The players, outcomes, and confidence values are
illustrative, not observations from a real game.}
\format{A data frame with 11 rows and 7 columns:
\describe{
\item{game_id}{Game identifier, demo-01.}
\item{team}{Fictional team name.}
\item{player}{Fictional player name.}
\item{inning}{Character inning label, including an 8+ continuation.}
\item{play}{Canonical play label.}
\item{confidence}{Illustrative confidence between zero and one.}
\item{needs_review}{Logical flag. All entries are reviewed examples.}
}}
\source{Created for this package using dAImond Inning Plays export headers and
labels inspected October 9, 2026.}
\usage{demo_scorecards}
\examples{calculate_batting_stats(demo_scorecards)}
\keyword{datasets}
