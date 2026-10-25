# Scorecard verification on October 25, 2026

The audit reads saved dAImond Inning results without modifying the production
app. It checks child cards in multi-card uploads as well as top-level cards.
There are 155 saved result files containing 184 component cards. Eleven cards
have stored event-level references, representing ten distinct games. Five team
scorecards are accepted, covering 179 plate appearances and 49 player/game rows.

For each accepted card, the review confirms the game ID, date, teams and side;
inspects the card and discrepant cells; uniquely matches batter ID, inning and
event description to an independently downloaded live MLB feed; checks that
all and only that team's plate appearances are present; and compares every
player's and the team's PA, AB, H, BB, HBP, SF, SH, CI and TB with box-score counts.
The package tests independently repeat the counting comparisons using installed
MLB fixtures. They do not compare season-to-date rate fields with game rates.

The accepted cards are Arizona (825071), St. Louis (822782), Minnesota (746804),
Cleveland (823774), and the Mets child card (823644). Ten exported labels were
normalized. Examples include a double read as a walk, home runs read as walks,
called-strikeout detail, and force outs where the batter reached first. Original
labels and source review indicators are retained alongside reviewed values and
notes. The original Twins dataset remains unchanged for the earlier quizzes.

## Exclusions among cards with event references

- Colorado: 35 detections for 34 official PA and many low-confidence readings.
- San Francisco: incomplete coverage and numerous conflicting labels.
- Seattle: two processing runs of the same game, each with extra detections.
- Angels: the written card credits Peraza with a single while MLB records an
  error. This changes hit/OBP counts, so the card is excluded rather than
  silently treating its scoring as verified.
- Houston child card: 41 detected PA for 42 official PA, leaving incomplete coverage.

Other component cards lack sufficient verified event mappings. The full
per-component decisions are in `daimondstats/data-raw/scorecard-audit.csv`.
The source/feed manifest records source IDs, verification date, URLs and hashes.
The verifier is `daimondstats/data-raw/verify-scorecards.py`; rebuilding from the
included normalized CSV requires only R and does not need private app files.

Saved exports can already contain app context corrections. Matching an export
to MLB does not establish independent computer-vision accuracy. These five
team scorecards span different teams and seasons; they are not a complete
season, a causal study, or a ranking of team strength. Base-out transitions
needed for RE24 remain outside the reviewed dataset.
