# Full regular seasons for the five reviewed scorecard teams

Every completed regular-season game for the team and season of each
reviewed scorecard: 2026 Arizona Diamondbacks, Cleveland Guardians, New
York Mets and St. Louis Cardinals, and 2024 Minnesota Twins. Each
team-season has 162 games, and each reviewed scorecard game appears in
its team's season. Built with
[`season_games()`](https://kwoolaid725.github.io/msds-457/reference/season_games.md).

## Usage

``` r
reviewed_team_seasons
```

## Format

A data frame with 810 rows and 10 columns:

- game_id:

  Character MLB game identifier (gamePk).

- team:

  Character team name.

- season:

  Integer season.

- game_date:

  Date of the game.

- home:

  Logical, TRUE for home games.

- opponent:

  Character opponent name.

- runs, runs_allowed:

  Integer runs scored and allowed.

- run_diff:

  Integer runs minus runs allowed.

- win:

  Numeric 1 for a win, 0 for a loss.

## Source

MLB Stats API regular-season schedules retrieved November 8, 2026, kept
in data-raw/schedules/ in the source repository and processed by
data-raw/team-seasons.R. URL pattern:
<https://statsapi.mlb.com/api/v1/schedule?sportId=1&teamId=142&season=2024&gameType=R>.

## Details

Win and loss totals match the final league record reported in each
schedule. Filter to one team before calling
[`compare_personal_season()`](https://kwoolaid725.github.io/msds-457/reference/compare_personal_season.md),
which compares within one team-season.

## Examples

``` r
aggregate(cbind(games = 1, win) ~ team + season, reviewed_team_seasons, sum)
#>                   team season games win
#> 1      Minnesota Twins   2024   162  82
#> 2 Arizona Diamondbacks   2026   162  86
#> 3  Cleveland Guardians   2026   162  85
#> 4        New York Mets   2026   162  74
#> 5  St. Louis Cardinals   2026   162  77
twins <- subset(reviewed_team_seasons, team == "Minnesota Twins")
set.seed(457)
compare_personal_season(twins, "746804", metric = "run_diff")$summary
#>     metric selected_games other_games personal_mean other_mean season_mean
#> 1 run_diff              1         161             1 0.03726708  0.04320988
#>   difference reference_low reference_high reference_percentile
#> 1  0.9627329           -11              8                   58
```
