# Build a team's reference season from an MLB schedule

Convert an MLB Stats API regular-season schedule into one row per
completed game for one team, in the format
[`compare_personal_season()`](https://kwoolaid725.github.io/msds-457/reference/compare_personal_season.md)
expects.

## Usage

``` r
season_games(schedule, team_id)
```

## Arguments

- schedule:

  Path or URL of a schedule JSON file, or the same response already
  parsed with `jsonlite::fromJSON(simplifyVector = FALSE)`. Request it
  from
  `https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=ID&season=YEAR&gameType=R`.

- team_id:

  MLB team identifier, such as 142 for the Minnesota Twins.

## Value

A data frame sorted by date with character `game_id`, `team`, integer
`season`, Date `game_date`, logical `home`, character `opponent`,
integer `runs`, `runs_allowed` and `run_diff`, and 0/1 `win`.

## Details

Only games played to completion are kept (coded status `F`), including
games completed early. A postponed game appears in the schedule more
than once under the same `game_id`, and its postponed entry also reports
a final abstract state; it is kept once, when it was played. Ties and
duplicated final games are errors. Reading a URL needs a network
connection, so save the file first for reproducible work.

## See also

[`compare_personal_season()`](https://kwoolaid725.github.io/msds-457/reference/compare_personal_season.md),
[reviewed_team_seasons](https://kwoolaid725.github.io/msds-457/reference/reviewed_team_seasons.md)

## Examples

``` r
path <- system.file("extdata", "schedule_sample.json", package = "daimondstats")
season_games(path, team_id = 142)
#>   game_id            team season  game_date  home            opponent runs
#> 1  746335 Minnesota Twins   2024 2024-03-28 FALSE  Kansas City Royals    4
#> 2  746804 Minnesota Twins   2024 2024-04-29 FALSE   Chicago White Sox    3
#> 3  745871 Minnesota Twins   2024 2024-08-09  TRUE Cleveland Guardians    6
#> 4  745927 Minnesota Twins   2024 2024-08-09  TRUE Cleveland Guardians    4
#>   runs_allowed run_diff win
#> 1            1        3   1
#> 2            2        1   1
#> 3            3        3   1
#> 4            2        2   1
```
