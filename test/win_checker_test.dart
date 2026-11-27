import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/win_checker.dart';

void main() {
  test('standard four sets and a pair wins', () {
    expect(
      isWinningHand([
        'm1', 'm2', 'm3',
        'm4', 'm5', 'm6',
        'p2', 'p3', 'p4',
        's7', 's8', 's9',
        'east', 'east',
      ]),
      isTrue,
    );
  });

  test('seven pairs wins', () {
    expect(
      isWinningHand([
        'm1', 'm1', 'm2', 'm2', 'm3', 'm3',
        'p1', 'p1', 'p2', 'p2', 's3', 's3',
        'east', 'east',
      ]),
      isTrue,
    );
  });

  test('thirteen orphans wins', () {
    expect(
      isWinningHand([
        'm1', 'm9', 'p1', 'p9', 's1', 's9',
        'east', 'south', 'west', 'north',
        'red', 'green', 'white', 'm1',
      ]),
      isTrue,
    );
  });

  test('one tile short does not win', () {
    expect(
      isWinningHand([
        'm1', 'm2', 'm3', 'm4', 'm5', 'm6',
        'p2', 'p3', 'p4', 's7', 's8', 's9',
        'east', 'south',
      ]),
      isFalse,
    );
  });

  test('eleven concealed tiles plus one exposed meld wins', () {
    expect(
      isWinningHand([
        'm4', 'm5', 'm6', 'p2', 'p3', 'p4',
        's7', 's8', 's9', 'east', 'east',
      ], meldCount: 1),
      isTrue,
    );
  });
}
