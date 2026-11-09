"""Build base-out transitions for the reviewed scorecard teams from MLB feeds.

From the package root: python3 data-raw/base-out-states.py FEED_DIR
FEED_DIR must contain game_GAMEID.json from the feed URLs in
verification-manifest.json. Writes data-raw/reviewed-base-out.csv.

States are replayed from each play's runner movements. A row is verified only
when the replayed outs and bases agree with the feed's own post-play outs and
occupied bases, and each half-inning's replayed runs agree with the linescore.
Movements before the play-ending pitch (steals, wild pitches, pickoffs) become
separate runner events credited to the moving runner, following FanGraphs.
"""
import csv
import json
from pathlib import Path
import sys

BASE_BITS = {'1B': 1, '2B': 2, '3B': 4}
MANIFEST = Path('data-raw/verification-manifest.json')
OUT = Path('data-raw/reviewed-base-out.csv')
FIELDS = ['game_id', 'team', 'event_id', 'at_bat_index', 'inning', 'event_type',
          'batting_event', 'player', 'player_id', 'outs_before', 'bases_before',
          'outs_after', 'bases_after', 'runs_scored', 'verified']


def mask(occupied):
    return sum(BASE_BITS[b] for b in occupied)


def segments(play):
    """Group runner movements by playEvents index, in order."""
    groups = {}
    for r in play['runners']:
        groups.setdefault(r['details'].get('playIndex'), []).append(r)
    return [groups[k] for k in sorted(groups, key=lambda x: -1 if x is None else x)]


def apply(group, occupied, outs):
    """Apply one group of movements; returns new bases, outs and runs."""
    runs = 0
    # A runner can have several movements in one group (single, then advance
    # on the throw); only the last one gives the final position.
    final = {r['details']['runner']['id']: r for r in group}
    occupied = {b: rid for b, rid in occupied.items() if rid not in final}
    for r in final.values():
        m = r['movement']
        if m['isOut']:
            outs += 1
        elif m['end'] == 'score':
            runs += 1
        elif m['end'] in BASE_BITS:
            occupied[m['end']] = r['details']['runner']['id']
    return occupied, outs, runs


def build(feed, team_side, game_id, team):
    rows, half_runs = [], {}
    plays = feed['liveData']['plays']['allPlays']
    occupied, outs, half = {}, 0, None
    for play in plays:
        about = play['about']
        if about['halfInning'] != team_side:
            continue
        key = (about['inning'], about['halfInning'])
        if key != half:
            occupied, outs, half = {}, 0, key
        last = play['playEvents'][-1]['index']
        batting = play['result']['type'] == 'atBat' and 'caught_stealing' not in play['result']['eventType'] \
            and 'pickoff' not in play['result']['eventType']
        for group in segments(play):
            final = group[0]['details'].get('playIndex') == last
            before = (outs, mask(occupied))
            occupied, outs, runs = apply(group, occupied, outs)
            if final and batting:
                event_id, player = str(about['atBatIndex']), play['matchup']['batter']
                event_type = play['result']['eventType']
            else:
                movers = [r['details']['runner'] for r in group]
                event_id = f"{about['atBatIndex']}.{group[0]['details'].get('playIndex')}"
                player = movers[0]
                event_type = group[0]['details']['eventType'] or group[0]['details']['event']
            rows.append({'game_id': game_id, 'team': team, 'event_id': event_id,
                         'at_bat_index': about['atBatIndex'], 'inning': about['inning'],
                         'event_type': event_type, 'batting_event': final and batting,
                         'player': player['fullName'], 'player_id': player['id'],
                         'outs_before': before[0], 'bases_before': before[1],
                         'outs_after': min(outs, 3), 'bases_after': mask(occupied) if outs < 3 else 0,
                         'runs_scored': runs, 'verified': True})
            half_runs[key] = half_runs.get(key, 0) + runs
        post = {b for b, f in (('1B', 'postOnFirst'), ('2B', 'postOnSecond'), ('3B', 'postOnThird'))
                if f in play['matchup']}
        state_ok = play['count']['outs'] == outs and (outs == 3 or post == set(occupied))
        if not state_ok:
            for row in rows:
                if row['at_bat_index'] == about['atBatIndex']:
                    row['verified'] = False
    side = 'away' if team_side == 'top' else 'home'
    for inning in feed['liveData']['linescore']['innings']:
        official = inning.get(side, {}).get('runs', 0) or 0
        if half_runs.get((inning['num'], team_side), 0) != official:
            for row in rows:
                if row['inning'] == inning['num']:
                    row['verified'] = False
    return rows


def main(feed_dir):
    manifest = json.loads(MANIFEST.read_text())
    rows = []
    for card in manifest['accepted']:
        gid = str(card['game_id'])
        feed = json.loads((Path(feed_dir) / f'game_{gid}.json').read_text())
        team = feed['gameData']['teams'][card['side']]['name']
        rows += build(feed, 'top' if card['side'] == 'away' else 'bottom', gid, team)
    with OUT.open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    bad = sum(not r['verified'] for r in rows)
    print(f'{len(rows)} events, {sum(r["batting_event"] for r in rows)} batting, {bad} unverified')


if __name__ == '__main__':
    main(sys.argv[1])
