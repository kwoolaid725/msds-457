# MSDS 457 final project: daimondstats

Woohyun Kim's R package for personal scorebook analysis. The current package is
[daimondstats 0.0.3](daimondstats/README.md).

[Module 5 progress update, two-page PDF](module%205/Kim_Final_Project_Progress_Update_v2.pdf)

## Reviewed real-game collection

The new `reviewed_scorecards` dataset contains **179 plate appearances from five
team scorecards**, with 49 player/game combinations. Each included event was
matched uniquely to an independently downloaded MLB game feed. Counting totals
match the official box score for every included player and team. Ten exported
labels were normalized, with original values and correction notes preserved.

| Team | Date | PA | H | BB | HBP | OBP |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Minnesota Twins | 2024-04-29 | 35 | 4 | 3 | 0 | .200 |
| New York Mets | 2026-04-11 | 41 | 10 | 4 | 0 | .341 |
| Arizona Diamondbacks | 2026-06-15 | 35 | 8 | 3 | 1 | .343 |
| Cleveland Guardians | 2026-06-17 | 33 | 3 | 3 | 0 | .182 |
| St. Louis Cardinals | 2026-07-31 | 35 | 5 | 3 | 0 | .229 |

![Batting outcomes in five reviewed scorecards](module%205/Kim_Module5_batting_stats.png)

This is a small convenience collection across teams and seasons. The chart
summarizes recorded games; it does not rank team strength or supply a complete
reference season. OBP uses pooled counts within each game. The original Twins
example remains available and overlaps the new collection.

## Structure and reproduction

```text
daimondstats/
  DESCRIPTION, NAMESPACE, LICENSE, README.md
  R/             # Four public functions and three dataset documents
  man/           # Installed help
  data/          # Reviewed collection, original Twins example, fictional demo
  data-raw/      # Source CSVs, audit, feed manifest, extraction/build scripts
  inst/extdata/  # Independent official game/player counting fixtures
  tests/         # Core, personal-season, and reviewed-data tests
module 5/        # Updated chart, R script, numerical summary, progress PDF
analysis/        # Earlier Week 4 inning plot and script
validation/      # Package-check log and verification explanation
```

From the repository root:

```sh
R CMD INSTALL daimondstats
R CMD build daimondstats
R CMD check --no-manual daimondstats_0.0.3.tar.gz
Rscript "module 5/Kim_Module5_batting_stats.R"
```

The chart script requires ggplot2; the package uses base R and requires R >= 4.1.0.
[Chart source](module%205/Kim_Module5_batting_stats.R) and
[numerical summary](module%205/Kim_Module5_game_summary.csv) are included.
Rebuild the reviewed R dataset from its included CSV by running
`Rscript data-raw/reviewed-scorecards.R` from the package root. The full source
verification additionally requires the saved app results and downloaded feeds.

## Verification and package checks

The audit inspected 155 saved result files, including multi-card children:
184 component cards, of which eleven had stored event references. Five passed
complete event coverage, card review, and live MLB counting-total checks.
Incomplete cards, extra detections, duplicate processing and unresolved scoring
conflicts were excluded. Source exports may already contain contextual
corrections; agreement is not an independent classifier-accuracy estimate.

- [Audit decisions](daimondstats/data-raw/scorecard-audit.csv)
- [Source and feed manifest with SHA-256 hashes](daimondstats/data-raw/verification-manifest.json)
- [Verification explanation](validation/README.md)
- [Official game totals](daimondstats/inst/extdata/reviewed_game_totals.csv)
- [Official player totals](daimondstats/inst/extdata/reviewed_player_totals.csv)

The October 25, 2026 `R CMD check --no-manual` on R 4.5.1 finished with
**status OK**, including examples and all three test scripts.
[Check log](validation/R-CMD-check.log). Repository-index access was unavailable;
PDF manual generation was not checked.

## Remaining work

Obtain a complete team reference season and verified base-out event data,
document an appropriate expectancy matrix, validate the season-comparison and
RE24 functions on real records, and finish the vignette, technical documentation,
nontechnical walkthroughs, and presentation. Current season-comparison and RE24
examples still use fictional inputs.

AI assistance: An OpenAI assistant helped with implementation, verification,
tests, documentation, the chart, and the progress update.
