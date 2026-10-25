"""Extract a real saved scorecard and its cached MLB reference for package data.

Run from the package root:
python3 data-raw/extract-twins-scorecard.py /path/to/dAImondInning
"""

import csv
import json
from pathlib import Path
import sys

app_dir = Path(sys.argv[1])
result_path = app_dir / "uploads/7617d135a223/result_full.json"
feed_path = app_dir / "data/mlb_cache/game_746804.json"
result = json.loads(result_path.read_text())
feed = json.loads(feed_path.read_text())
context = result["game_context"]["mlb"]
assert context["game"]["gamePk"] == feed["gamePk"] == 746804
assert context["side"] == "away"
assert feed["gameData"]["datetime"]["officialDate"] == "2024-04-29"
official_plays = [p for p in feed["liveData"]["plays"]["allPlays"]
                  if p["about"]["isTopInning"]]
official_keys = [(p["matchup"]["batter"]["id"], p["about"]["inning"])
                 for p in official_plays]
assert len(official_keys) == len(set(official_keys)) == 35

rows = []
matched_keys = []
for row in sorted(result["grid"], key=int):
    for col in sorted(result["grid"][row], key=int):
        cell = result["grid"][row][col]
        play = cell.get("play")
        if play in (None, "", "no_at_bat", "bad_crop", "empty"):
            continue
        references = context["official_cells"].get(f"r{int(row)+1}c{int(col)+1}", [])
        assert len(references) == 1, "Each included cell must have one reference event."
        reference = references[0]
        matched_keys.append((reference["batter_id"], reference["inning"]))
        agrees = play == reference["play"]
        confidence = cell.get("play_conf")
        rows.append({
            "game_id": "746804",
            "team": feed["gameData"]["teams"]["away"]["name"],
            "player": reference["batter"],
            "inning": str(cell["inning_label"]),
            "play": play,
            "confidence": confidence,
            "needs_review": bool(cell.get("low_conf") or cell.get("needs_fallback")
                                 or confidence is None or not agrees),
            "game_date": "2024-04-29",
            "reference_play": reference["play"],
            "play_matches_reference": agrees,
        })

assert sorted(matched_keys) == sorted(official_keys)
assert len(rows) == 35 and sum(r["play_matches_reference"] for r in rows) == 34
destination = Path(__file__).with_name("twins-scorecard-2024.csv")
with destination.open("w", newline="", encoding="utf-8") as output:
    writer = csv.DictWriter(output, fieldnames=list(rows[0]))
    writer.writeheader()
    writer.writerows(rows)
print(f"Saved {len(rows)} real scorecard entries to {destination}")
