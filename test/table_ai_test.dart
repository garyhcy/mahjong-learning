import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/table_ai.dart';
import 'package:ludi/game/table_engine.dart';

void main() {
  test('keeps a pair instead of throwing one of its tiles', () {
    const ai = TableAI();
    final discard = ai.chooseDiscard([
      'east', 'east', 'm1', 'm2', 'm3', 'm4', 'm5', 'm6',
      'p2', 'p3', 'p4', 's7', 's8', 's9',
    ]);
    expect(discard, isNot('east'));
  });

  test('throws an isolated honour first', () {
    const ai = TableAI();
    final discard = ai.chooseDiscard([
      'm1', 'm2', 'm3', 'm4', 'm5', 'm6',
      'p2', 'p3', 'p4', 's7', 's8', 's9',
      'east', 'north',
    ]);
    expect(discard, anyOf('east', 'north'));
  });

  test('claims a win before any meld', () {
    const ai = TableAI();
    final choice = ai.chooseClaim(const [
      ClaimOption(player: 1, meld: null, tiles: ['s1'], isWin: true),
    ]);
    expect(choice!.isWin, isTrue);
  });
}
