import 'tile_set.dart';

enum HandSetKind { chow, pung }

class HandSet {
  final HandSetKind kind;
  final List<String> tiles;

  const HandSet(this.kind, this.tiles);
}

class HandDecomposition {
  final String pair;
  final List<HandSet> sets;
  final bool sevenPairs;
  final bool thirteenOrphans;

  const HandDecomposition({
    required this.pair,
    required this.sets,
    this.sevenPairs = false,
    this.thirteenOrphans = false,
  });
}

/// Returns true when [concealed] plus [meldCount] exposed sets forms a complete
/// 14-tile hand. Kongs count as one set (three structural tiles).
bool isWinningHand(List<String> concealed, {int meldCount = 0}) =>
    decomposeHands(concealed, meldCount: meldCount).isNotEmpty;

/// All unique structural decompositions of a complete hand.
List<HandDecomposition> decomposeHands(
  List<String> concealed, {
  int meldCount = 0,
}) {
  if (meldCount < 0 || meldCount > 4) return const [];
  final needed = 14 - meldCount * 3;
  if (concealed.length != needed) return const [];

  final flowers = concealed.where(TileSet.isFlower).toList();
  if (flowers.isNotEmpty) return const [];

  final counts = <String, int>{for (final t in TileSet.allTileCodes) t: 0};
  for (final tile in concealed) {
    if (!counts.containsKey(tile)) return const [];
    counts[tile] = counts[tile]! + 1;
  }

  final result = <HandDecomposition>[];

  if (meldCount == 0 && _isThirteenOrphans(counts)) {
    result.add(const HandDecomposition(
      pair: '',
      sets: [],
      thirteenOrphans: true,
    ));
  }
  if (meldCount == 0 && _isSevenPairs(counts)) {
    result.add(const HandDecomposition(pair: '', sets: [], sevenPairs: true));
  }

  final setsNeeded = 4 - meldCount;
  for (final pair in TileSet.allTileCodes) {
    if ((counts[pair] ?? 0) < 2) continue;
    counts[pair] = counts[pair]! - 2;
    final found = <List<HandSet>>[];
    _searchSets(counts, setsNeeded, <HandSet>[], found);
    for (final sets in found) {
      result.add(HandDecomposition(pair: pair, sets: sets));
    }
    counts[pair] = counts[pair]! + 2;
  }

  return result;
}

bool _isSevenPairs(Map<String, int> counts) {
  var pairs = 0;
  var singles = 0;
  for (final count in counts.values) {
    if (count == 0) continue;
    if (count % 2 == 0) {
      pairs += count ~/ 2;
    } else {
      pairs += count ~/ 2;
      singles++;
    }
  }
  return pairs == 7 && singles == 0;
}

bool _isThirteenOrphans(Map<String, int> counts) {
  const required = [
    'm1',
    'm9',
    's1',
    's9',
    'p1',
    'p9',
    'east',
    'south',
    'west',
    'north',
    'red',
    'green',
    'white',
  ];
  var pair = 0;
  for (final entry in counts.entries) {
    if (entry.value == 0) continue;
    if (!required.contains(entry.key)) return false;
    if (entry.value == 2 && pair == 0) {
      pair = 1;
    } else if (entry.value != 1) {
      return false;
    }
  }
  return pair == 1;
}

void _searchSets(
  Map<String, int> counts,
  int needed,
  List<HandSet> prefix,
  List<List<HandSet>> out,
) {
  if (needed == 0) {
    if (counts.values.every((c) => c == 0)) out.add(List.of(prefix));
    return;
  }

  String? first;
  for (final tile in TileSet.allTileCodes) {
    if ((counts[tile] ?? 0) > 0) {
      first = tile;
      break;
    }
  }
  if (first == null) return;

  if (counts[first]! >= 3) {
    counts[first] = counts[first]! - 3;
    prefix.add(HandSet(HandSetKind.pung, [first, first, first]));
    _searchSets(counts, needed - 1, prefix, out);
    prefix.removeLast();
    counts[first] = counts[first]! + 3;
  }

  if (TileSet.isNumber(first)) {
    final rank = TileSet.rankOf(first);
    final suit = TileSet.suitOf(first);
    if (rank <= 7) {
      final two = '$suit${rank + 1}';
      final three = '$suit${rank + 2}';
      if ((counts[two] ?? 0) > 0 && (counts[three] ?? 0) > 0) {
        counts[first] = counts[first]! - 1;
        counts[two] = counts[two]! - 1;
        counts[three] = counts[three]! - 1;
        prefix.add(HandSet(HandSetKind.chow, [first, two, three]));
        _searchSets(counts, needed - 1, prefix, out);
        prefix.removeLast();
        counts[first] = counts[first]! + 1;
        counts[two] = counts[two]! + 1;
        counts[three] = counts[three]! + 1;
      }
    }
  }
}
