# Base-out transitions for the five reviewed scorecard teams

Every offensive event for the team side covered by
`reviewed_scorecards`, with outs and occupied bases before and after the
event and runs scored on it. The 179 batting events join one to one with
`reviewed_scorecards` by `game_id` and `event_id`. Nine further rows are
runner events (stolen bases, a wild pitch, a passed ball and a pickoff)
that occur during a plate appearance and are credited to the runner, not
the batter.

## Usage

``` r
reviewed_base_out
```

## Format

A data frame with 188 rows and 15 columns:

- game_id:

  Character MLB game identifier.

- team:

  Character batting team name from MLB.

- event_id:

  Character event identifier. Batting events use the MLB atBatIndex;
  runner events append the play index, as in `"29.2"`.

- at_bat_index:

  Integer MLB atBatIndex of the plate appearance.

- inning:

  Integer inning number.

- event_type:

  Character MLB event type, such as `single` or `stolen_base_2b`.

- batting_event:

  Logical, TRUE for the plate-appearance result.

- player:

  Character credited player: the batter for batting events, the moving
  runner for runner events.

- player_id:

  Integer MLB identifier of the credited player.

- outs_before, outs_after:

  Integer outs before (0 to 2) and after (0 to 3) the event.

- bases_before, bases_after:

  Integer base mask: 1 for first, 2 for second, 4 for third, added
  together. Zero after the third out.

- runs_scored:

  Integer runs scored on the event.

- verified:

  Logical, TRUE for all rows; see Details.

## Source

MLB Stats API game feeds retrieved November 8, 2026. Feed URLs and
SHA-256 hashes are in data-raw/base-out-manifest.json in the source
repository, and data-raw/base-out-states.py rebuilds the CSV.

## Details

States were replayed from each play's runner movements in the MLB feed.
A row is marked verified only when the replayed outs and occupied bases
match the feed's own post-play values for that plate appearance, and the
replayed runs for each half-inning match the official linescore. All 188
rows passed. Batting events include runner advances on the same play,
such as an advance on a throw after a single, following the usual RE24
convention.

Base-out states come from MLB records, not from reading the scorecard.
The scorecard reader does not record runner positions.

## See also

[run_expectancy_fangraphs](https://kwoolaid725.github.io/msds-457/reference/run_expectancy_fangraphs.md),
[`calculate_run_impact()`](https://kwoolaid725.github.io/msds-457/reference/calculate_run_impact.md)

## Examples

``` r
impact <- calculate_run_impact(reviewed_base_out, run_expectancy_fangraphs)
aggregate(re24 ~ team, impact, sum)
#>                   team   re24
#> 1 Arizona Diamondbacks  0.312
#> 2  Cleveland Guardians -0.149
#> 3      Minnesota Twins -1.149
#> 4        New York Mets  1.851
#> 5  St. Louis Cardinals -3.149
```
