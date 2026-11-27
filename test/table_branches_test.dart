import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/meld.dart';
import 'package:ludi/game/table_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a self-draw ends the hand with a legal score', () {
    final engine = TableEngine(seed: 7)..start();
    engine.setHandForTesting(0, [
      'm1',
      'm2',
      'm3',
      'm4',
      'm5',
      'm6',
      'p2',
      'p3',
      'p4',
      's7',
      's8',
      's9',
      'east',
      'east',
    ]);

    expect(engine.finishSelfDraw(0), isTrue);
    expect(engine.phase, TablePhase.finished);
    expect(engine.winnerIndex, 0);
    expect(engine.selfDraw, isTrue);
    expect(engine.winScore!.faan, greaterThanOrEqualTo(3));
  });

  test('a kong claim exposes four tiles and draws a replacement', () {
    final engine = TableEngine(seed: 11)..start();
    engine.setHandForTesting(0, ['m1']);
    engine.setHandForTesting(1, [
      'm1',
      'm1',
      'm1',
      'p1',
      'p2',
      'p3',
      's1',
      's2',
      's4',
    ]);

    expect(engine.discardTile(0, 'm1'), isTrue);
    final kong = engine.pendingClaims.firstWhere(
      (c) => c.player == 1 && c.meld == MeldKind.kong,
    );
    engine.applyClaim(kong);

    expect(engine.players[1].melds, hasLength(1));
    expect(engine.players[1].melds.single.kind, MeldKind.kong);
    expect(engine.players[1].melds.single.tiles, hasLength(4));
    expect(engine.currentPlayer, 1);
    expect(engine.phase, TablePhase.playing);
  });

  test('an empty wall ends the hand as a draw', () {
    final engine = TableEngine(seed: 3)..start();
    engine.wall.clear();

    engine.drawForCurrent();

    expect(engine.phase, TablePhase.finished);
    expect(engine.isDraw, isTrue);
    expect(engine.winnerIndex, isNull);
  });

  test('a two-faan winner is not offered as a discard claim', () {
    final engine = TableEngine(seed: 5)..start();
    engine.setHandForTesting(0, ['s4']);
    engine.setHandForTesting(1, [
      'm1',
      'm2',
      'm3',
      'm4',
      'm5',
      'm6',
      'p2',
      'p3',
      'p4',
      'east',
    ]);
    engine.players[1].melds.add(
      const Meld(
        kind: MeldKind.pong,
        tiles: ['red', 'red', 'red'],
        fromPlayer: 2,
      ),
    );
    engine.players[1].flowers.add('f_plum');

    engine.discardTile(0, 's4');

    expect(engine.pendingClaims.any((c) => c.player == 1 && c.isWin), isFalse);
  });

  test('win claims sort ahead of meld claims', () {
    final engine = TableEngine(seed: 9)..start();
    engine.setHandForTesting(0, ['east']);
    engine.setHandForTesting(1, ['s4', 's5']);
    engine.setHandForTesting(2, [
      'm1',
      'm2',
      'm3',
      'm4',
      'm5',
      'm6',
      'm7',
      'm8',
      'm9',
      'm1',
      'm2',
      'm3',
      'east',
    ]);

    expect(engine.discardTile(0, 'east'), isTrue);

    final options = engine.pendingClaims;
    final winIndex = options.indexWhere((c) => c.isWin);
    final meldIndex = options.indexWhere((c) => !c.isWin);
    expect(winIndex, greaterThanOrEqualTo(0));
    if (meldIndex >= 0) expect(meldIndex, greaterThan(winIndex));
  });
}
