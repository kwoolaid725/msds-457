# Calculate run expectancy added for verified events

Apply a supplied reference matrix to verified base-out transitions. RE24
equals runs scored plus ending expectancy minus starting expectancy.

## Usage

``` r
calculate_run_impact(plays, expectancy)
```

## Arguments

- plays:

  Data frame containing character `game_id`, `event_id`, `player`;
  integer-valued `outs_before`, `bases_before`, `outs_after`,
  `bases_after`, `runs_scored`; and logical `verified`. All events must
  be verified. Base masks use 1 for first, 2 for second and 4 for third,
  added together. Before outs must be 0:2, after outs 0:3, and base
  masks 0:7. Outs cannot decrease and runs scored must be nonnegative.

- expectancy:

  Data frame with all 24 distinct combinations of `outs` (0:2) and
  `bases` (0:7), plus finite nonnegative numeric `expected_runs`.

## Value

The input data frame with numeric `re_before`, `re_after`, and `re24`
columns. Three outs sets ending expectancy to zero. Empty input returns
the same columns with zero rows. Sum `re24` over the desired events.

## Details

The caller chooses a documented reference matrix appropriate to the
league and run environment. This function neither estimates that matrix
nor infers runner movement. `verified` is a caller assertion, not
automatic verification. Incomplete or assumed states must not be marked
verified. Duplicate game/event IDs and invalid states are errors.
Standalone runner events need the responsible runner in `player`; do not
credit them to the batter. Walk-off states use the supplied base-out
expectancy, not forced zero simply because the game ended. RE24
describes situational value, not a prediction or proof of clutch
ability. Original columns are retained.

## References

Weinberg, Neil. 2014. "RE24." FanGraphs, July 30.
https://library.fangraphs.com/misc/re24/

## See also

[`compare_personal_season()`](https://kwoolaid725.github.io/msds-457/reference/compare_personal_season.md)

## Examples

``` r
# Fictional matrix for demonstrating the interface, not an MLB estimate.
reference <- expand.grid(outs = 0:2, bases = 0:7)
reference$expected_runs <- (3 - reference$outs) * 0.2 + reference$bases * 0.1
plays <- data.frame(game_id = "demo", event_id = "1", player = "Demo Batter",
  outs_before = 0, bases_before = 0, outs_after = 0, bases_after = 0,
  runs_scored = 1, verified = TRUE)
calculate_run_impact(plays, reference)$re24
#> [1] 1
```
