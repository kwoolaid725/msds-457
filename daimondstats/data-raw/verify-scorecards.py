"""Build reviewed data from saved cards and independently downloaded MLB feeds.

From the package root: python3 data-raw/verify-scorecards.py APP_DIR FEED_DIR
FEED_DIR must contain game_GAMEID.json from the MLB feed URLs in the manifest.
Original app files are read only. Acceptance decisions include visual card review.
"""
import csv
import hashlib
import json
from collections import Counter
from pathlib import Path
import sys

ACCEPTED = {'09a49fc97cd5', '5d18c8b00122', 'b1650de36896',
            '7617d135a223', 'ba3de17ca246/scorecard_2'}
CORRECTIONS = {
    ('7617d135a223', 'r7c9'): ('flyout', 'lineout', 'Official lineout; card records an out as F8.'),
    ('b1650de36896', 'r1c5'): ('walk', 'double', 'Card shows 2B; MLB describes a double.'),
    ('b1650de36896', 'r7c7'): ('strikeout', 'strikeout_looking', 'Called strikeout confirmed by MLB; strikeout count unchanged.'),
    ('ba3de17ca246/scorecard_2', 'r1c5'): ('walk', 'single', 'Card single/run diamond; MLB confirms a single.'),
    ('ba3de17ca246/scorecard_2', 'r2c6'): ('groundout', "fielder's_choice", 'MLB force out: preceding runner out and batter reaches first; batting counts unchanged.'),
    ('ba3de17ca246/scorecard_2', 'r3c3'): ('walk', "fielder's_choice", 'Card force-out notation; MLB confirms batter reached on a force out.'),
    ('ba3de17ca246/scorecard_2', 'r3c7'): ('walk', 'home_run', 'Card filled run diamond and HR notation; MLB confirms home run.'),
    ('ba3de17ca246/scorecard_2', 'r4c3'): ('single', 'walk', 'Card BB notation; MLB confirms walk.'),
    ('ba3de17ca246/scorecard_2', 'r6c6'): ('walk', 'home_run', 'Card filled run diamond and HR notation; MLB confirms home run.'),
    ('ba3de17ca246/scorecard_2', 'r7c4'): ('walk', 'single', 'Card single notation; MLB confirms single.'),
}
EXCLUDED = {
    '730a13795325': 'Card credits Peraza with a single where MLB records an error; unresolved scoring conflict.',
    '161ebc873c15': '35 detected entries for 34 official PA, with many low-confidence reads.',
    '3169d5742447': 'Incomplete card coverage and numerous conflicting labels.',
    '6cb0e0da0861': 'Extra detections; duplicate processing of the Seattle game.',
    '7213a40f4b96': 'Extra detections outside the 41 official PA; duplicate Seattle processing.',
    'ab3fbbe3e40f/scorecard_2': '41 detected PA for 42 official PA; incomplete coverage.',
}
COUNT_FIELDS = {'PA': 'plateAppearances', 'AB': 'atBats', 'H': 'hits',
                'BB': 'baseOnBalls', 'HBP': 'hitByPitch', 'SF': 'sacFlies',
                'SH': 'sacBunts', 'CI': 'catchersInterference', 'TB': 'totalBases'}


def canonical(play):
    event = play['result']['eventType']
    desc = play['result'].get('description', '').lower()
    if event in ('strikeout', 'strikeout_double_play'):
        pitches = [p for p in play.get('playEvents', []) if p.get('isPitch')]
        called = pitches and pitches[-1].get('details', {}).get('call', {}).get('code') == 'C'
        return 'strikeout_looking' if called or 'called out on strikes' in desc else 'strikeout'
    if event == 'field_out':
        if 'lines out' in desc: return 'lineout'
        if 'flies out' in desc or 'pops out' in desc: return 'flyout'
        return 'groundout'
    mapping = {'force_out': "fielder's_choice", 'fielders_choice': "fielder's_choice",
               'field_error': 'error', 'intent_walk': 'intentional_walk',
               'grounded_into_double_play': 'double_play', 'sac_fly': 'sacrifice_fly',
               'sac_bunt': 'sacrifice_bunt', 'catcher_interf': 'catcher_interference'}
    return mapping.get(event, event)


def counts(labels):
    hits = {'single': 1, 'double': 2, 'triple': 3, 'home_run': 4}
    no_ab = {'walk', 'intentional_walk', 'hit_by_pitch', 'sacrifice_fly',
             'sacrifice_bunt', 'catcher_interference'}
    return dict(PA=len(labels), AB=sum(p not in no_ab for p in labels),
                H=sum(p in hits for p in labels), BB=sum(p in ('walk', 'intentional_walk') for p in labels),
                HBP=labels.count('hit_by_pitch'), SF=labels.count('sacrifice_fly'),
                SH=labels.count('sacrifice_bunt'), CI=labels.count('catcher_interference'),
                TB=sum(hits.get(p, 0) for p in labels))


def write_csv(path, rows):
    with path.open('w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows({k: ('TRUE' if v else 'FALSE') if isinstance(v, bool) else v
                     for k, v in row.items()} for row in rows)


def main(app_dir, feed_dir):
    app, feeds = Path(app_dir), Path(feed_dir)
    dest = Path(__file__).resolve().parent
    rows, audit, totals, players, manifest = [], [], [], [], []
    seen, used_corrections = set(), set()
    paths = sorted((app / 'uploads').glob('*/result_full.json'))
    for path in paths:
        result = json.loads(path.read_text())
        cards = [(path.parent.name, result)] if not result.get('teams') else [
            (f'{path.parent.name}/scorecard_{i+1}', t) for i, t in enumerate(result['teams'])]
        for card_id, card in cards:
            mlb = (card.get('game_context') or {}).get('mlb') or {}
            game = mlb.get('game') or {}; gid = game.get('gamePk'); refs = mlb.get('official_cells') or {}
            record = dict(source_result=card_id, game_id=gid or '', side=mlb.get('side') or '',
                          accepted=False, reason=EXCLUDED.get(card_id, 'No verified event-level mapping.'))
            if card_id not in ACCEPTED:
                audit.append(record); continue
            feed_path = feeds / f'game_{gid}.json'; body = feed_path.read_bytes(); feed = json.loads(body)
            side = mlb['side']; date = feed['gameData']['datetime']['officialDate']
            assert feed['gamePk'] == gid and feed['gameData']['status']['detailedState'] == 'Final'
            assert game.get('date', date) == date
            for s in ['home', 'away']: assert game[s] == feed['gameData']['teams'][s]['name']
            assert (gid, side) not in seen, 'Duplicate game/team import'
            seen.add((gid, side))
            official = [p for p in feed['liveData']['plays']['allPlays']
                        if p['about']['isTopInning'] == (side == 'away')]
            by_key = {}
            for p in official:
                key = (p['matchup']['batter']['id'], p['about']['inning'], p['result']['description'])
                assert key not in by_key, 'Ambiguous same-inning event identity'
                by_key[key] = p
            team = feed['gameData']['teams'][side]['name']
            opponent = feed['gameData']['teams']['home' if side == 'away' else 'away']['name']
            selected, event_ids = [], []
            for r, cells in sorted(card['grid'].items(), key=lambda item: int(item[0])):
                for c, cell in sorted(cells.items(), key=lambda item: int(item[0])):
                    source_play = cell.get('play')
                    if source_play in (None, '', 'no_at_bat', 'bad_crop', 'empty'): continue
                    key = f'r{int(r)+1}c{int(c)+1}'; ref = refs.get(key, [])
                    assert len(ref) == 1, (card_id, key, 'missing/ambiguous reference')
                    ref = ref[0]
                    event = by_key[(ref['batter_id'], ref['inning'], ref['description'])]
                    assert ref['half_inning'] == event['about']['halfInning']
                    assert int(cell['inning_label']) == event['about']['inning']
                    assert ref['event'] == event['result']['eventType']
                    verified_play = canonical(event)
                    app_flagged = bool(cell.get('low_conf') or cell.get('needs_fallback') or
                                       cell.get('play_conf') is None or source_play != ref['play'])
                    note = 'Matched to the MLB event.'
                    if source_play != verified_play:
                        expected, replacement, note = CORRECTIONS[(card_id, key)]
                        assert (source_play, verified_play) == (expected, replacement)
                        used_corrections.add((card_id, key))
                    elif ref['play'] != verified_play:
                        note = 'Force out retained as fielder choice; cached groundout label corrected.'
                    confidence = cell.get('play_conf')
                    assert confidence is not None and 0 <= confidence <= 1
                    event_id = str(event['about']['atBatIndex']); event_ids.append(event_id)
                    selected.append(dict(game_id=str(gid), team=team, player=event['matchup']['batter']['fullName'],
                        inning=str(event['about']['inning']), play=verified_play, confidence=confidence,
                        needs_review=False, game_date=date, side=side, opponent=opponent,
                        batter_id=event['matchup']['batter']['id'], event_id=event_id,
                        source_result=card_id, source_cell=key, source_play=source_play,
                        source_needs_review=app_flagged, reference_play=verified_play, review_note=note))
            assert len(event_ids) == len(set(event_ids)) == len(official)
            assert set(event_ids) == {str(p['about']['atBatIndex']) for p in official}
            box = feed['liveData']['boxscore']['teams'][side]
            expected = {k: box['teamStats']['batting'].get(v, 0) for k, v in COUNT_FIELDS.items()}
            assert counts([r['play'] for r in selected]) == expected, (gid, 'team totals mismatch')
            for bid in sorted({r['batter_id'] for r in selected}):
                group = [r for r in selected if r['batter_id'] == bid]
                official_stats = box['players'][f'ID{bid}']['stats']['batting']
                player_counts = {k: official_stats.get(v, 0) for k, v in COUNT_FIELDS.items()}
                assert counts([r['play'] for r in group]) == player_counts, (gid, bid, 'player totals mismatch')
                players.append(dict(game_id=str(gid), team=team, player=group[0]['player'], **player_counts))
            rows.extend(selected)
            totals.append(dict(game_id=str(gid), team=team, game_date=date, opponent=opponent, **expected))
            manifest.append(dict(game_id=gid, source_result=card_id, side=side, date=date,
                feed_url=f'https://statsapi.mlb.com/api/v1.1/game/{gid}/feed/live',
                feed_sha256=hashlib.sha256(body).hexdigest(), result_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                verified_on='2026-10-25', pa=len(selected), source_label_changes=sum(r['play'] != r['source_play'] for r in selected)))
            record.update(accepted=True, reason='Full unique PA coverage; reviewed labels; player and team counting totals match live MLB feed.')
            audit.append(record)
    assert len(seen) == len(ACCEPTED) == 5 and len(rows) == 179
    assert used_corrections == set(CORRECTIONS)
    write_csv(dest / 'reviewed-scorecards.csv', rows)
    write_csv(dest / 'scorecard-audit.csv', audit)
    ext = dest.parent / 'inst/extdata'
    write_csv(ext / 'reviewed_game_totals.csv', totals)
    write_csv(ext / 'reviewed_player_totals.csv', players)
    (dest / 'verification-manifest.json').write_text(json.dumps(dict(
        verified_on='2026-10-25', saved_results=len(paths), component_cards=len(audit),
        cards_with_references=sum(bool(((t.get('game_context') or {}).get('mlb') or {}).get('official_cells'))
            for p in paths for t in (json.loads(p.read_text()).get('teams') or [json.loads(p.read_text())])),
        accepted=manifest, method='Card review plus unique batter/inning/description matching and live MLB box-score counts; not a model-accuracy evaluation.'), indent=2))
    print(f'Accepted {len(seen)} team scorecards, {len(rows)} PA, {len(players)} player/game rows; {len(audit)} component cards audited.')
    print(json.dumps(totals, indent=2))


if __name__ == '__main__':
    assert len(sys.argv) == 3, __doc__
    main(*sys.argv[1:])
