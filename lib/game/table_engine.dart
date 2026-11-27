import 'dart:math';

import 'faan_calculator.dart';
import 'meld.dart';
import 'tile_set.dart';
import 'win_checker.dart';

enum TablePhase { playing, awaitingClaim, finished }

class TablePlayer {
  final int seatIndex;
  final String seatWind;
  final bool isHuman;
  final List<String> hand = [];
  final List<Meld> melds = [];
  final List<String> flowers = [];
  final List<String> discards = [];

  TablePlayer({
    required this.seatIndex,
    required this.seatWind,
    required this.isHuman,
  });

  int get effectiveHandSize => hand.length + melds.length * 3;
}

class ClaimOption {
  final int player;
  final MeldKind? meld;
  final List<String> tiles;
  final bool isWin;
  final WinScore? score;

  const ClaimOption({
    required this.player,
    this.meld,
    this.tiles = const [],
    this.isWin = false,
    this.score,
  });
}

class TableEngine {
  TableEngine({this.seed = 1, this.playerIsDealer = true});

  final int seed;
  final bool playerIsDealer;

  final List<TablePlayer> players = [
    TablePlayer(seatIndex: 0, seatWind: 'east', isHuman: true),
    TablePlayer(seatIndex: 1, seatWind: 'south', isHuman: false),
    TablePlayer(seatIndex: 2, seatWind: 'west', isHuman: false),
    TablePlayer(seatIndex: 3, seatWind: 'north', isHuman: false),
  ];
  final List<String> wall = [];
  final List<ClaimOption> pendingClaims = [];

  TablePhase phase = TablePhase.playing;
  int currentPlayer = 0;
  String? lastDiscard;
  int? lastDiscarder;
  int? winnerIndex;
  bool isDraw = false;
  bool selfDraw = false;
  String? winningTile;
  WinScore? winScore;
  String? _lastDrawn;

  bool _canDiscard = false;
  final List<String> _log = [];

  List<String> get log => List.unmodifiable(_log);
  int get dealerIndex => playerIsDealer ? 0 : 1;
  String get roundWind => 'east';

  bool get canCurrentDiscard => _canDiscard && phase == TablePhase.playing;
  TablePlayer get current => players[currentPlayer];

  void start() {
    final random = Random(seed);
    final tiles = <String>[
      for (final tile in TileSet.allTileCodes) ...List.filled(4, tile),
      ...TileSet.flowers,
    ]..shuffle(random);
    wall
      ..clear()
      ..addAll(tiles);
    for (final p in players) {
      p.hand.clear();
      p.melds.clear();
      p.flowers.clear();
      p.discards.clear();
    }
    pendingClaims.clear();
    phase = TablePhase.playing;
    isDraw = false;
    winnerIndex = null;
    winScore = null;
    winningTile = null;
    lastDiscard = null;
    lastDiscarder = null;

    for (var round = 0; round < 13; round++) {
      for (final p in players) {
        p.hand.add(wall.removeAt(0));
      }
    }
    for (final p in players) {
      _replaceFlowers(p);
      p.hand.sort(TileSet.compare);
    }

    currentPlayer = dealerIndex;
    _drawForPlayer(currentPlayer);
    _canDiscard = true;
    _log
      ..clear()
      ..add('East opens the table. Your turn.');
    if (players[dealerIndex].isHuman) {
      _log.add('Tap a tile, then Discard.');
    }
  }

  /// Draws for the current player at the start of their turn.
  void drawForCurrent() {
    if (phase != TablePhase.playing) return;
    _drawForPlayer(currentPlayer);
    _canDiscard = true;
  }

  void _drawForPlayer(int index) {
    if (wall.isEmpty) {
      _finishDraw();
      return;
    }
    final player = players[index];
    final tile = wall.removeAt(0);
    player.hand.add(tile);
    _replaceFlowers(player);
    player.hand.sort(TileSet.compare);
    _lastDrawn = player.hand.last;
  }

  void _replaceFlowers(TablePlayer player) {
    var safety = 0;
    while (safety++ < 20) {
      final flowerIndex = player.hand.indexWhere(TileSet.isFlower);
      if (flowerIndex < 0) return;
      final flower = player.hand.removeAt(flowerIndex);
      player.flowers.add(flower);
      if (wall.isEmpty) {
        _finishDraw();
        return;
      }
      player.hand.add(wall.removeLast());
    }
  }

  void _finishDraw() {
    phase = TablePhase.finished;
    isDraw = true;
    winnerIndex = null;
    _canDiscard = false;
    _log.add('The wall is empty. This hand is a draw.');
  }

  /// Discards [tile] for [player]. Returns false when the move is illegal.
  bool discardTile(int player, String tile) {
    if (phase != TablePhase.playing || player != currentPlayer) return false;
    if (!_canDiscard) return false;
    final p = players[player];
    final index = p.hand.indexOf(tile);
    if (index < 0) return false;
    p.hand.removeAt(index);
    p.discards.add(tile);
    lastDiscard = tile;
    lastDiscarder = player;
    _canDiscard = false;
    _log.add('${p.seatWind.toUpperCase()} discards ${_tileLabel(tile)}.');
    pendingClaims
      ..clear()
      ..addAll(_claimsFor(player, tile));
    if (pendingClaims.isNotEmpty) {
      phase = TablePhase.awaitingClaim;
    } else {
      _advanceTurn();
    }
    return true;
  }

  void setHandForTesting(int player, List<String> tiles) {
    players[player].hand
      ..clear()
      ..addAll(tiles);
  }

  /// Ends the hand on a self-draw when [player] has a legal winning hand.
  bool finishSelfDraw(int player) {
    final score = scoreSelfDrawFor(player);
    if (score == null) return false;
    winnerIndex = player;
    winScore = score;
    winningTile = _lastDrawn ?? players[player].hand.last;
    selfDraw = true;
    phase = TablePhase.finished;
    _canDiscard = false;
    _log.add('${players[player].seatWind.toUpperCase()} wins by self-draw!');
    return true;
  }

  WinScore? scoreSelfDrawFor(int player) {
    final p = players[player];
    return scoreWin(
      concealed: p.hand,
      melds: p.melds,
      flowers: p.flowers,
      seatWind: p.seatWind,
      roundWind: roundWind,
      selfDraw: true,
    );
  }

  List<ClaimOption> _claimsFor(int discarder, String tile) {
    final options = <ClaimOption>[];
    for (final p in players) {
      if (p.seatIndex == discarder) continue;
      final wouldWin = [...p.hand, tile];
      final score = scoreWin(
        concealed: wouldWin,
        melds: p.melds,
        flowers: p.flowers,
        seatWind: p.seatWind,
        roundWind: roundWind,
        selfDraw: false,
      );
      if (score != null) {
        options.add(ClaimOption(
          player: p.seatIndex,
          isWin: true,
          tiles: [tile],
          score: score,
        ));
      }
    }

    for (final p in players) {
      if (p.seatIndex == discarder) continue;
      final count = p.hand.where((t) => t == tile).length;
      if (count >= 3) {
        options.add(ClaimOption(
          player: p.seatIndex,
          meld: MeldKind.kong,
          tiles: [tile, tile, tile, tile],
        ));
      } else if (count >= 2) {
        options.add(ClaimOption(
          player: p.seatIndex,
          meld: MeldKind.pong,
          tiles: [tile, tile, tile],
        ));
      }
    }

    final next = (discarder + 1) % 4;
    final r = players[next];
    if (TileSet.isNumber(tile)) {
      final rank = TileSet.rankOf(tile);
      final suit = TileSet.suitOf(tile);
      final shapes = <List<String>>[];
      for (var start = rank - 2; start <= rank; start++) {
        if (start < 1 || start > 7) continue;
        final a = '$suit$start';
        final b = '$suit${start + 1}';
        final c = '$suit${start + 2}';
        final needed = [a, b, c].where((t) => t != tile).toList();
        if (needed.every(r.hand.contains)) {
          shapes.add(TileSet.sortTiles([a, b, c]));
        }
      }
      for (final shape in shapes) {
        options.add(ClaimOption(
          player: next,
          meld: MeldKind.chow,
          tiles: shape,
        ));
      }
    }

    options.sort((a, b) {
      if (a.isWin != b.isWin) return a.isWin ? -1 : 1;
      final rankA = a.meld == MeldKind.kong ? 0 : a.meld == MeldKind.pong ? 1 : 2;
      final rankB = b.meld == MeldKind.kong ? 0 : b.meld == MeldKind.pong ? 1 : 2;
      if (rankA != rankB) return rankA.compareTo(rankB);
      return _distance(discarder, a.player)
          .compareTo(_distance(discarder, b.player));
    });
    return options;
  }

  int _distance(int from, int to) => (to - from + 4) % 4;

  void applyClaim(ClaimOption option) {
    if (phase != TablePhase.awaitingClaim) return;
    if (option.isWin) {
      winnerIndex = option.player;
      winScore = option.score;
      winningTile = lastDiscard;
      selfDraw = false;
      phase = TablePhase.finished;
      _log.add('${players[option.player].seatWind.toUpperCase()} wins on the discard!');
      pendingClaims.clear();
      return;
    }

    final p = players[option.player];
    final kind = option.meld!;
    final tile = lastDiscard!;
    final from = lastDiscarder!;
    if (kind == MeldKind.pong) {
      p.hand.remove(tile);
      p.hand.remove(tile);
    } else if (kind == MeldKind.kong) {
      p.hand.remove(tile);
      p.hand.remove(tile);
      p.hand.remove(tile);
    } else {
      for (final t in option.tiles) {
        if (t != tile) p.hand.remove(t);
      }
    }
    p.melds.add(Meld(
      kind: kind,
      tiles: option.tiles,
      fromPlayer: from,
    ));
    players[from].discards.removeLast();
    lastDiscard = null;
    lastDiscarder = null;
    pendingClaims.clear();
    currentPlayer = option.player;
    phase = TablePhase.playing;
    _canDiscard = false;
    _log.add('${p.seatWind.toUpperCase()} calls ${kind.name}.');
    if (kind == MeldKind.kong) {
      _drawReplacement(p);
    }
    _canDiscard = true;
  }

  void _drawReplacement(TablePlayer player) {
    if (wall.isEmpty) {
      _finishDraw();
      return;
    }
    player.hand.add(wall.removeLast());
    _replaceFlowers(player);
    player.hand.sort(TileSet.compare);
  }

  /// Applies the best non-human claim, or moves to the next player.
  void passClaims() {
    if (phase != TablePhase.awaitingClaim) return;
    final aiClaims = pendingClaims.where((c) => !players[c.player].isHuman).toList();
    if (aiClaims.isEmpty) {
      pendingClaims.clear();
      phase = TablePhase.playing;
      _advanceTurn();
      return;
    }
    applyClaim(aiClaims.first);
  }

  void _advanceTurn() {
    if (phase == TablePhase.finished) return;
    currentPlayer = (currentPlayer + 1) % 4;
    phase = TablePhase.playing;
    drawForCurrent();
  }

  String _tileLabel(String tile) => TileSet.isFlower(tile) ? tile : tile.toUpperCase();
}
