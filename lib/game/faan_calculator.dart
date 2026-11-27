import 'meld.dart';
import 'tile_set.dart';
import 'win_checker.dart';

class FaanPattern {
  final String id;
  final String en;
  final String zh;
  final int faan;

  const FaanPattern(this.id, this.en, this.zh, this.faan);
}

class WinScore {
  final int faan;
  final List<FaanPattern> patterns;
  final int discardPayout;
  final int selfDrawEach;

  const WinScore({
    required this.faan,
    required this.patterns,
    required this.discardPayout,
    required this.selfDrawEach,
  });

  int get selfDrawTotal => selfDrawEach * 3;
}

const _discardPayouts = <int, int>{
  3: 8,
  4: 16,
  5: 24,
  6: 32,
  7: 48,
  8: 64,
  9: 96,
  10: 128,
};

int? payoutForFaan(int faan) => _discardPayouts[faan.clamp(3, 10)];

int? selfDrawShareForFaan(int faan) {
  final payout = payoutForFaan(faan);
  return payout == null ? null : payout ~/ 2;
}

/// Scores a complete hand. Returns null when the hand is not complete or is
/// worth fewer than the table minimum of three faan.
WinScore? scoreWin({
  required List<String> concealed,
  required List<Meld> melds,
  required List<String> flowers,
  required String seatWind,
  required String roundWind,
  required bool selfDraw,
}) {
  final decompositions = decomposeHands(concealed, meldCount: melds.length);
  if (decompositions.isEmpty) return null;

  WinScore? best;
  for (final decomposition in decompositions) {
    final score = _scoreDecomposition(
      concealed: concealed,
      melds: melds,
      flowers: flowers,
      seatWind: seatWind,
      roundWind: roundWind,
      selfDraw: selfDraw,
      decomposition: decomposition,
    );
    if (best == null || score.faan > best.faan) best = score;
  }
  if (best == null || best.faan < 3) return null;
  return best;
}

WinScore _scoreDecomposition({
  required List<String> concealed,
  required List<Meld> melds,
  required List<String> flowers,
  required String seatWind,
  required String roundWind,
  required bool selfDraw,
  required HandDecomposition decomposition,
}) {
  final patterns = <FaanPattern>[];
  final allSets = <HandSet>[
    ...decomposition.sets,
    for (final meld in melds)
      HandSet(
        meld.kind == MeldKind.chow ? HandSetKind.chow : HandSetKind.pung,
        meld.tiles,
      ),
  ];
  final allTiles = [...concealed, for (final meld in melds) ...meld.tiles];
  final numbered = allTiles.where(TileSet.isNumber);
  final suits = numbered.map(TileSet.suitOf).toSet();
  final hasHonors = allTiles.any(TileSet.isHonor);

  void add(FaanPattern pattern) => patterns.add(pattern);

  if (selfDraw) {
    add(const FaanPattern('selfDraw', 'Self-draw', '自摸', 1));
  }
  if (melds.every((m) => m.concealed)) {
    add(const FaanPattern('concealed', 'Concealed hand', '門前清', 1));
  }
  if (flowers.isEmpty) {
    add(const FaanPattern('noFlowers', 'No flowers', '無花', 1));
  }
  final seatFlower = TileSet.seatFlowerFor(seatWind);
  final seatFlowerCount = flowers.where((f) => f == seatFlower).length;
  if (seatFlowerCount > 0) {
    add(FaanPattern(
      'seatFlower',
      'Seat flower ×$seatFlowerCount',
      '正花 ×$seatFlowerCount',
      seatFlowerCount,
    ));
  }
  if (flowers.length == 7) {
    add(const FaanPattern('smallFlowers', 'Small flower hand', '小花糊', 3));
  } else if (flowers.length >= 8) {
    add(const FaanPattern('bigFlowers', 'Big flower hand', '大花糊', 10));
  }

  final dragonSets = allSets
      .where((s) => s.kind == HandSetKind.pung && TileSet.isDragon(s.tiles.first))
      .length;
  for (final set in allSets) {
    if (set.kind != HandSetKind.pung) continue;
    final tile = set.tiles.first;
    if (TileSet.isDragon(tile)) {
      add(const FaanPattern('dragonPung', 'Dragon pung', '三元牌', 1));
    }
    if (tile == seatWind) {
      add(const FaanPattern('seatWind', 'Seat wind pung', '門風', 1));
    }
    if (tile == roundWind) {
      add(const FaanPattern('roundWind', 'Round wind pung', '圈風', 1));
    }
  }

  final allChows = allSets.every((s) => s.kind == HandSetKind.chow);
  final allPungs = allSets.every((s) => s.kind == HandSetKind.pung);
  if (decomposition.thirteenOrphans) {
    add(const FaanPattern('thirteenOrphans', 'Thirteen orphans', '十三么', 10));
  } else if (decomposition.sevenPairs) {
    add(const FaanPattern('sevenPairs', 'Seven pairs', '七對', 3));
  } else {
    if (allChows) {
      add(const FaanPattern('allChows', 'All chows', '平糊', 1));
    }
    if (allPungs) {
      add(const FaanPattern('allPungs', 'All pungs', '對對糊', 3));
    }
    if (allTiles.every(TileSet.isHonor)) {
      add(const FaanPattern('allHonors', 'All honours', '字一色', 10));
    } else if (suits.length == 1) {
      if (hasHonors) {
        add(const FaanPattern('mixedSuit', 'Mixed one suit', '混一色', 3));
      } else {
        add(const FaanPattern('clearSuit', 'Clear one suit', '清一色', 7));
      }
    }
    if (allTiles.every(TileSet.isTerminal)) {
      add(const FaanPattern('allTerminals', 'All terminals', '清么九', 10));
    }

    if (dragonSets == 3) {
      add(const FaanPattern('bigDragons', 'Big three dragons', '大三元', 5));
    } else if (dragonSets == 2 && TileSet.isDragon(decomposition.pair)) {
      add(const FaanPattern('smallDragons', 'Small three dragons', '小三元', 3));
    }

    final windSets = allSets
        .where((s) => s.kind == HandSetKind.pung && TileSet.isWind(s.tiles.first))
        .length;
    if (windSets == 4) {
      add(const FaanPattern('bigWinds', 'Big four winds', '大四喜', 10));
    } else if (windSets == 3 && TileSet.isWind(decomposition.pair)) {
      add(const FaanPattern('smallWinds', 'Small four winds', '小四喜', 10));
    }

    if (melds.where((m) => m.kind == MeldKind.kong).length == 4) {
      add(const FaanPattern('eighteenArhats', 'Eighteen arhats', '十八羅漢', 10));
    }
    if (melds.isEmpty && _isNineGates(concealed)) {
      add(const FaanPattern('nineGates', 'Nine gates', '九蓮寶燈', 10));
    }
  }

  final total = patterns.fold<int>(0, (sum, p) => sum + p.faan).clamp(0, 10);
  final payout = payoutForFaan(total) ?? 0;
  return WinScore(
    faan: total,
    patterns: List.unmodifiable(patterns),
    discardPayout: payout,
    selfDrawEach: payout ~/ 2,
  );
}

bool _isNineGates(List<String> concealed) {
  if (concealed.length != 14) return false;
  if (concealed.any((t) => !TileSet.isNumber(t))) return false;
  final suit = TileSet.suitOf(concealed.first);
  if (concealed.any((t) => TileSet.suitOf(t) != suit)) return false;
  final counts = <int, int>{for (var r = 1; r <= 9; r++) r: 0};
  for (final t in concealed) {
    counts[TileSet.rankOf(t)] = counts[TileSet.rankOf(t)]! + 1;
  }
  const base = [3, 1, 1, 1, 1, 1, 1, 1, 3];
  for (var i = 0; i < 9; i++) {
    if (counts[i + 1]! < base[i]) return false;
  }
  return true;
}
