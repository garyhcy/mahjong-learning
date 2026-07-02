// Basic smoke test for Ludi.
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/providers/game_state.dart';

void main() {
  test('GameState initializes with default values', () {
    final game = GameState();
    expect(game.xp, 0);
    expect(game.maxHearts, 3);
    expect(game.isPremium, false);
  });
}
