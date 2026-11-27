# Store a dAImond Inning API key for this session

Save a personal API key so
[`daimond_games()`](https://kwoolaid725.github.io/msds-457/reference/daimond_games.md)
can read your scorecards from the dAImond Inning app. Create a key in
the app under Settings, API keys. The key is kept in the
`DAIMOND_API_KEY` environment variable for the current R session only;
nothing is written to disk.

## Usage

``` r
daimond_auth(key = NULL)
```

## Arguments

- key:

  A personal API key beginning with `di_pat_`. When `NULL`, the existing
  `DAIMOND_API_KEY` environment variable is checked instead.

## Value

Invisibly, `TRUE` when a well-formed key is available.

## Details

To keep the key across sessions, add a line `DAIMOND_API_KEY=di_pat_...`
to your `.Renviron` file (for example with
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html)).
Never put the key in a script you share. A key gives read access to
every scorecard in the account, so revoke it in the app if it leaks.

## See also

[`daimond_games()`](https://kwoolaid725.github.io/msds-457/reference/daimond_games.md)

## Examples

``` r
if (FALSE) { # \dontrun{
daimond_auth("di_pat_your_key_here")
} # }
```
