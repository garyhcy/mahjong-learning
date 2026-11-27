import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/table_engine.dart';
import 'package:ludi/game/tile_set.dart';

void main() {
  test('deals thirteen tiles each and fourteen to the dealer', () {
    final engine = TableEngine(seed: 7)..start();
    expect(engine.players[0].hand.length, 14);
    expect(engine.players[1].hand.length, 13);
    expect(engine.players[2].hand.length, 13);
    expect(engine.players[3].hand.length, 13);
    expect(engine.currentPlayer, 0);
    expect(engine.canCurrentDiscard, isTrue);
  });

  test('conserves all 144 tiles after the deal', () {
    final engine = TableEngine(seed: 11)..start();
    final total = engine.wall.length +
        engine.players.fold<int>(
          0,
          (sum, p) => sum + p.hand.length + p.flowers.length + p.discards.length,
        );
    expect(total, 144);
  });

  test('discard removes the tile and records it', () {
    final engine = TableEngine(seed: 3)..start();
    final tile = engine.players[0].hand.first;
    expect(engine.discardTile(0, tile), isTrue);
    expect(engine.players[0].hand.length, 13);
    expect(engine.players[0].discards, contains(tile));
    expect(engine.lastDiscard, tile);
  });

  test('a pong claim removes two tiles and exposes a meld', () {
    final engine = TableEngine(seed: 5)..start();
    engine.setHandForTesting(0, [
      's1', 'm2', 'm3', 'm4', 'm5', 'm6', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'east',
    ]);
    engine.setHandForTesting(1, [
      's1', 's1', 'm2', 'm3', 'm4', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'north',
    ]);
    engine.players[1].flowers.clear();
    engine.discardTile(0, 's1');
    final pong = engine.pendingClaims.where(
      (c) => c.player == 1 && c.meld?.name == 'pong',
    );
    expect(pong, isNotEmpty);
    engine.applyClaim(pong.first);
    expect(engine.players[1].melds.length, 1);
    expect(engine.players[1].hand.length, 11);
    expect(engine.currentPlayer, 1);
    expect(engine.canCurrentDiscard, isTrue);
  });

  test('chow is only available to the next player', () {
    final engine = TableEngine(seed: 9)..start();
    engine.setHandForTesting(0, [
      's3', 'm2', 'm3', 'm4', 'm5', 'm6', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'east',
    ]);
    engine.setHandForTesting(1, [
      's1', 's2', 'm2', 'm3', 'm4', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'north',
    ]);
    engine.setHandForTesting(2, [
      's1', 's2', 'm2', 'm3', 'm4', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'north',
    ]);
    engine.discardTile(0, 's3');
    expect(engine.pendingClaims.where((c) => c.meld?.name == 'chow').every(
          (c) => c.player == 1,
        ), isTrue);
    expect(engine.pendingClaims.where((c) => c.meld?.name == 'chow'), isNotEmpty);
  });

  test('a valid discard win is offered and finishes the hand', () {
    final engine = TableEngine(seed: 13)..start();
    engine.setHandForTesting(0, [
      's9', 'm2', 'm3', 'm4', 'm5', 'm6', 'p2', 'p3', 'p4',
      's7', 's8', 'east', 'east', 'north',
    ]);
    engine.setHandForTesting(1, [
      'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'p2', 'p3', 'p4',
      's7', 's8', 'east', 'east',
    ]);
    engine.players[1].flowers.clear();
    engine.discardTile(0, 's9');
    final win = engine.pendingClaims.firstWhere((c) => c.isWin);
    engine.applyClaim(win);
    expect(engine.phase, TablePhase.finished);
    expect(engine.winnerIndex, 1);
    expect(engine.winScore!.faan, greaterThanOrEqualTo(3));
  });

  test('passing an AI claim advances the turn', () {
    final engine = TableEngine(seed: 15)..start();
    engine.setHandForTesting(0, [
      's1', 'm2', 'm3', 'm4', 'm5', 'm6', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'east',
    ]);
    engine.setHandForTesting(1, [
      's1', 's1', 'm2', 'm3', 'm4', 'p2', 'p3', 'p4',
      's7', 's8', 's9', 'east', 'north',
    ]);
    engine.discardTile(0, 's1');
    engine.passClaims();
    expect(engine.phase, TablePhase.playing);
    expect(engine.currentPlayer, 1);
    expect(engine.players[1].melds.length, 1);
  });
}
