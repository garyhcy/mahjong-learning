import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/analytics_service.dart';
import 'table_ai.dart';
import 'table_engine.dart';

class TableController extends ChangeNotifier {
  TableController({
    int? seed,
    this.aiDelay = const Duration(milliseconds: 550),
  }) : _baseSeed = seed;

  final int? _baseSeed;
  final Duration aiDelay;
  final TableAI _ai = const TableAI();
  late TableEngine engine;
  Timer? _aiTimer;
  String? selectedTile;
  bool _disposed = false;

  int get humanSeat => 0;
  bool get isHumanTurn =>
      engine.phase == TablePhase.playing && engine.currentPlayer == humanSeat;
  bool get canDiscard => isHumanTurn && engine.canCurrentDiscard;
  bool get canDeclareWin =>
      canDiscard && engine.scoreSelfDrawFor(humanSeat) != null;
  List<ClaimOption> get humanClaims => engine.pendingClaims
      .where((c) => c.player == humanSeat)
      .toList(growable: false);
  bool get hasHumanClaim => humanClaims.isNotEmpty;
  String get lastMessage => engine.log.isEmpty ? '' : engine.log.last;
  bool get finished => engine.phase == TablePhase.finished;

  void startNewHand() {
    _aiTimer?.cancel();
    selectedTile = null;
    final seed = _baseSeed ?? (DateTime.now().millisecondsSinceEpoch & 0x7fffffff);
    engine = TableEngine(seed: seed)..start();
    AnalyticsService.instance.log('table_start', {'seed': seed});
    _afterTransition();
  }

  void selectTile(String tile) {
    if (!canDiscard) return;
    selectedTile = selectedTile == tile ? null : tile;
    notifyListeners();
  }

  void discardSelected() {
    final tile = selectedTile;
    if (tile == null || !canDiscard) return;
    selectedTile = null;
    engine.discardTile(humanSeat, tile);
    _afterTransition();
  }

  void declareSelfDraw() {
    if (!canDeclareWin) return;
    engine.finishSelfDraw(humanSeat);
    AnalyticsService.instance.log('table_win', {
      'method': 'self_draw',
      'faan': engine.winScore?.faan ?? 0,
    });
    _notify();
  }

  void claim(ClaimOption option) {
    if (engine.phase != TablePhase.awaitingClaim) return;
    engine.applyClaim(option);
    selectedTile = null;
    if (engine.phase == TablePhase.finished && engine.winnerIndex == humanSeat) {
      AnalyticsService.instance.log('table_win', {
        'method': 'discard',
        'faan': engine.winScore?.faan ?? 0,
      });
    }
    _afterTransition();
  }

  void passClaim() {
    if (engine.phase != TablePhase.awaitingClaim) return;
    engine.passClaims();
    _afterTransition();
  }

  void _afterTransition() {
    if (_disposed) return;
    if (engine.phase == TablePhase.finished) {
      _notify();
      return;
    }
    if (engine.phase == TablePhase.awaitingClaim) {
      if (hasHumanClaim) {
        _notify();
      } else {
        _resolveAiClaim();
      }
      return;
    }
    if (engine.currentPlayer == humanSeat) {
      _notify();
      return;
    }
    _scheduleAi();
    _notify();
  }

  void _resolveAiClaim() {
    final options = engine.pendingClaims
        .where((c) => !engine.players[c.player].isHuman)
        .toList();
    final choice = _ai.chooseClaim(options);
    if (choice == null) {
      engine.passClaims();
    } else {
      engine.applyClaim(choice);
      if (engine.phase == TablePhase.finished) {
        AnalyticsService.instance.log('table_lose', {
          'faan': engine.winScore?.faan ?? 0,
        });
      }
    }
    _afterTransition();
  }

  void _scheduleAi() {
    _aiTimer?.cancel();
    _aiTimer = Timer(aiDelay, _runAiTurn);
  }

  void _runAiTurn() {
    if (_disposed) return;
    if (engine.phase == TablePhase.awaitingClaim) {
      _resolveAiClaim();
      return;
    }
    if (engine.phase != TablePhase.playing || engine.currentPlayer == humanSeat) {
      _notify();
      return;
    }
    if (!engine.canCurrentDiscard) {
      engine.drawForCurrent();
      if (engine.phase == TablePhase.finished) {
        _notify();
        return;
      }
    }
    if (engine.canCurrentDiscard) {
      final player = engine.currentPlayer;
      if (engine.scoreSelfDrawFor(player) != null) {
        engine.finishSelfDraw(player);
        AnalyticsService.instance.log('table_lose', {
          'faan': engine.winScore?.faan ?? 0,
        });
        _notify();
        return;
      }
      final tile = _ai.chooseDiscard(engine.current.hand);
      if (tile.isEmpty) {
        _notify();
        return;
      }
      engine.discardTile(player, tile);
      _afterTransition();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _aiTimer?.cancel();
    super.dispose();
  }
}
