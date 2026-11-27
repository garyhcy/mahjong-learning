import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/faan_calculator.dart';
import 'package:ludi/game/meld.dart';

void main() {
  const winningHand = [
    'm1', 'm2', 'm3', 'm4', 'm5', 'm6',
    'p2', 'p3', 'p4', 's7', 's8', 's9',
    'east', 'east',
  ];

  test('all chows self draw with no flowers is four faan', () {
    final score = scoreWin(
      concealed: winningHand,
      melds: const [],
      flowers: const [],
      seatWind: 'east',
      roundWind: 'east',
      selfDraw: true,
    );
    expect(score, isNotNull);
    expect(score!.faan, 4);
    expect(score.selfDrawEach, 8);
    expect(score.patterns.map((p) => p.id), contains('allChows'));
  });

  test('same all-chow hand off a discard pays eight', () {
    final score = scoreWin(
      concealed: winningHand,
      melds: const [],
      flowers: const [],
      seatWind: 'east',
      roundWind: 'east',
      selfDraw: false,
    );
    expect(score!.faan, 3);
    expect(score.discardPayout, 8);
  });

  test('clear one suit is seven faan', () {
    final score = scoreWin(
      concealed: [
        'm1', 'm2', 'm3', 'm1', 'm2', 'm3',
        'm7', 'm8', 'm9', 'm4', 'm5', 'm6',
        'm5', 'm5',
      ],
      melds: const [],
      flowers: const ['f_orchid'],
      seatWind: 'east',
      roundWind: 'east',
      selfDraw: false,
    );
    expect(score!.patterns.map((p) => p.id), contains('clearSuit'));
    expect(score.faan, greaterThanOrEqualTo(7));
  });

  test('a valid hand with only two faan cannot win', () {
    final score = scoreWin(
      concealed: [
        'm1', 'm2', 'm3', 'm4', 'm5', 'm6',
        'p2', 'p3', 'p4', 'east', 'east',
      ],
      melds: const [
        Meld(
          kind: MeldKind.pong,
          tiles: ['red', 'red', 'red'],
          fromPlayer: 1,
        ),
      ],
      flowers: const ['f_plum'],
      seatWind: 'east',
      roundWind: 'east',
      selfDraw: false,
    );
    expect(score, isNull);
  });

  test('payout table is not exponential', () {
    expect(payoutForFaan(3), 8);
    expect(payoutForFaan(5), 24);
    expect(payoutForFaan(7), 48);
    expect(payoutForFaan(10), 128);
    expect(selfDrawShareForFaan(10), 64);
  });
}
