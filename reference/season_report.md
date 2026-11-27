# Write a one-page season report

Turn a season of reviewed scorecards into a single HTML file that can be
opened in any browser, printed, or emailed to a team. The report holds a
season summary, an amateur batting table from
[`calculate_youth_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_youth_stats.md),
a chart of on-base percentage with errors, and, when supplied,
pitch-count flags from
[`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md).

## Usage

``` r
season_report(
  scorecards,
  file,
  title = "Season report",
  pitch_check = NULL,
  min_pa = 25,
  overwrite = FALSE
)
```

## Arguments

- scorecards:

  Reviewed plays with the columns of
  [`import_scorecards()`](https://kwoolaid725.github.io/msds-457/reference/import_scorecards.md).

- file:

  Path of the HTML file to write. Its folder must exist.

- title:

  Character report title.

- pitch_check:

  Optional output of
  [`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md).

- min_pa:

  Passed to
  [`calculate_youth_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_youth_stats.md)
  to mark small samples.

- overwrite:

  Logical. When `FALSE` (default), an existing file is not replaced.

## Value

Invisibly, the normalized path of the written file.

## Details

The file is self-contained: the chart is embedded as an image, so no
internet connection or extra software is needed to open it. Players with
fewer than `min_pa` plate appearances are shown in grey and left out of
the chart, because a few games can swing their rates widely.

## See also

[`calculate_youth_stats()`](https://kwoolaid725.github.io/msds-457/reference/calculate_youth_stats.md),
[`check_pitch_counts()`](https://kwoolaid725.github.io/msds-457/reference/check_pitch_counts.md)

## Examples

``` r
path <- file.path(tempdir(), "season.html")
season_report(reviewed_scorecards, path, title = "Five scored games",
              min_pa = 3, overwrite = TRUE)
```
