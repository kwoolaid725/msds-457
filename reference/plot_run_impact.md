# Plot total run impact by player

Draw a horizontal bar chart of summed RE24 for each player, using the
output of
[`calculate_run_impact()`](https://kwoolaid725.github.io/msds-457/reference/calculate_run_impact.md).
Positive bars are runs added above the average expectation; negative
bars are runs taken away.

## Usage

``` r
plot_run_impact(impact, top = 10, main = "Run impact (RE24) by player")
```

## Arguments

- impact:

  Data frame returned by
  [`calculate_run_impact()`](https://kwoolaid725.github.io/msds-457/reference/calculate_run_impact.md),
  with character `player` and numeric `re24`. A `team` column, if
  present, is used to keep players on different teams apart.

- top:

  Positive whole number of players to show, chosen by largest absolute
  total. `Inf` shows everyone.

- main:

  Character plot title.

## Value

Invisibly, a data frame with `player`, optional `team`, `events` and
`re24` for the plotted players, sorted from highest to lowest.

## Details

Uses base R graphics, so the plot can be saved with any graphics device
such as [`grDevices::png()`](https://rdrr.io/r/grDevices/png.html).
Totals depend on the expectancy matrix and on how many events each
player had; they are not rates.

## See also

[`calculate_run_impact()`](https://kwoolaid725.github.io/msds-457/reference/calculate_run_impact.md),
[reviewed_base_out](https://kwoolaid725.github.io/msds-457/reference/reviewed_base_out.md)

## Examples

``` r
impact <- calculate_run_impact(reviewed_base_out, run_expectancy_fangraphs)
plot_run_impact(impact, top = 12)
```
