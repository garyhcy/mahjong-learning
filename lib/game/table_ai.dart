import 'meld.dart';
import 'table_engine.dart';
import 'tile_set.dart';

/// A deliberately simple opponent: keep pairs and connected tiles, throw the
/// most isolated tile, and claim wins/kongs/pongs when they are free.
class TableAI {
  const TableAI();

  String chooseDiscard(List<String> hand) {
    if (hand.isEmpty) return '';
    final counts = <String, int>{};
    for (final tile in hand) {
      counts[tile] = (counts[tile] ?? 0) + 1;
    }

    var best = hand.first;
    var bestScore = double.infinity;
    for (final tile in hand.toSet()) {
      var score = 0.0;
      final count = counts[tile] ?? 1;
      score += (count - 1) * 4.0;
      if (TileSet.isHonor(tile)) {
        score -= 0.5;
      } else {
        final suit = TileSet.suitOf(tile);
        final rank = TileSet.rankOf(tile);
        for (final delta in [-2, -1, 1, 2]) {
          final neighbour = '$suit${rank + delta}';
          if (counts.containsKey(neighbour)) {
            score += delta.abs() == 1 ? 2.0 : 0.8;
          }
        }
        if (rank == 1 || rank == 9) score -= 0.2;
      }
      if (score < bestScore) {
        bestScore = score;
        best = tile;
      }
    }
    return best;
  }

  ClaimOption? chooseClaim(List<ClaimOption> options) {
    if (options.isEmpty) return null;
    for (final option in options) {
      if (option.isWin) return option;
    }
    for (final option in options) {
      if (option.meld == MeldKind.kong) return option;
    }
    for (final option in options) {
      if (option.meld == MeldKind.pong) return option;
    }
    return null;
  }
}
