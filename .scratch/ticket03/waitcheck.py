#!/usr/bin/env python3
"""Brute-force Hong Kong mahjong hand checker for course authoring.

Given 13 tiles it lists every tile that completes the hand, and given 14
tiles it says whether the hand is complete. Used to verify the wait-reading
and out-counting lessons mechanically instead of trusting hand-written
answers.

Tile vocabulary matches the app's asset ids: m1..m9, p1..p9, s1..s9 for the
three suits, and east/south/west/north/red/green/white for honours. Flowers
never take part in a hand.

Usage:
    python3 .scratch/ticket03/waitcheck.py m2 m3 m4 m5 m6 p5 p6 p7 s3 s4 s5 east east
    python3 .scratch/ticket03/waitcheck.py --outs m2 m3 ... east east
"""
import sys
from collections import Counter
from itertools import product

SUITED = {
    'm': ['m%d' % i for i in range(1, 10)],
    'p': ['p%d' % i for i in range(1, 10)],
    's': ['s%d' % i for i in range(1, 10)],
}
HONOURS = ['east', 'south', 'west', 'north', 'red', 'green', 'white']
ALL_TILES = SUITED['m'] + SUITED['p'] + SUITED['s'] + HONOURS


def is_standard_win(counts: Counter) -> bool:
    """True when the tiles form 4 melds + one pair (any meld mix)."""
    if sum(counts.values()) % 3 != 2:
        return False
    for pair_tile in list(counts):
        if counts[pair_tile] < 2:
            continue
        rest = counts.copy()
        rest[pair_tile] -= 2
        if _can_form_melds(rest):
            return True
    return False


def _can_form_melds(counts: Counter) -> bool:
    if not any(counts.values()):
        return True
    tile = next(t for t in ALL_TILES if counts[t])
    # triplet
    if counts[tile] >= 3:
        counts[tile] -= 3
        if _can_form_melds(counts):
            counts[tile] += 3
            return True
        counts[tile] += 3
    # run
    if tile[0] in SUITED and len(tile) == 2 and tile[1] in '1234567':
        suit, rank = tile[0], int(tile[1])
        nxt = ['%s%d' % (suit, rank + 1), '%s%d' % (suit, rank + 2)]
        if counts[nxt[0]] and counts[nxt[1]]:
            for t in [tile] + nxt:
                counts[t] -= 1
            if _can_form_melds(counts):
                for t in [tile] + nxt:
                    counts[t] += 1
                return True
            for t in [tile] + nxt:
                counts[t] += 1
    return False


def is_seven_pairs(counts: Counter) -> bool:
    return sum(counts.values()) == 14 and sorted(counts.values()) == [2] * 7


def is_thirteen_orphans(counts: Counter) -> bool:
    needed = ['m1', 'm9', 'p1', 'p9', 's1', 's9'] + HONOURS
    if sum(counts[t] for t in needed) != 14:
        return False
    if any(counts[t] for t in counts if t not in needed):
        return False
    for tile in needed:
        if counts[tile] < 1:
            return False
    return all(counts[t] in (1, 2) for t in needed)


def is_win(tiles) -> bool:
    counts = Counter(tiles)
    return (is_standard_win(counts) or is_seven_pairs(counts)
            or is_thirteen_orphans(counts))


def winning_tiles(tiles) -> list:
    """Every tile that turns this 13-tile hand into a complete hand."""
    base = Counter(tiles)
    found = []
    for tile in ALL_TILES:
        if base[tile] >= 4:
            continue
        if is_win(list(tiles) + [tile]):
            found.append(tile)
    return found


def outs(tiles) -> int:
    """Live copies of every winning tile, ignoring what has been discarded."""
    base = Counter(tiles)
    return sum(4 - base[t] for t in winning_tiles(tiles))


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    flags = {a for a in sys.argv[1:] if a.startswith('--')}
    bad = [t for t in args if t not in ALL_TILES]
    if bad:
        raise SystemExit('unknown tiles: %s' % bad)

    if len(args) == 14:
        print('complete hand:', is_win(args))
        if is_win(args):
            print('seven pairs:', is_seven_pairs(Counter(args)),
                  '| thirteen orphans:', is_thirteen_orphans(Counter(args)))
        return

    if len(args) != 13:
        raise SystemExit('give 13 tiles (waits) or 14 tiles (complete check)')

    waits = winning_tiles(args)
    print('hand:', ' '.join(args))
    print('waits:', ' '.join(waits) if waits else 'none')
    print('out count:', outs(args))
    if '--outs' in flags:
        for tile in waits:
            print('  %-6s %d left' % (tile, 4 - Counter(args)[tile]))


if __name__ == '__main__':
    main()
