import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/faan_calculator.dart';
import 'package:ludi/game/meld.dart';
import 'package:ludi/game/table_controller.dart';
import 'package:ludi/game/table_engine.dart';
import 'package:ludi/screens/table_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the self-draw action and its result view', (tester) async {
    final controller = TableController(seed: 7)..startNewHand();
    addTearDown(controller.dispose);
    controller.engine.setHandForTesting(0, [
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

    await tester.pumpWidget(
      MaterialApp(home: TableScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.textContaining('Declare win'), findsOneWidget);
    await tester.tap(find.textContaining('Declare win'));
    await tester.pump();

    expect(find.textContaining('You win'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows human claim choices without hiding the hand', (
    tester,
  ) async {
    final controller = TableController(seed: 8)..startNewHand();
    addTearDown(controller.dispose);
    controller.engine
      ..phase = TablePhase.awaitingClaim
      ..lastDiscard = 'm1'
      ..lastDiscarder = 1;
    controller.engine.pendingClaims.add(
      const ClaimOption(
        player: 0,
        meld: MeldKind.pong,
        tiles: ['m1', 'm1', 'm1'],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: TableScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.textContaining('Pong'), findsOneWidget);
    expect(find.textContaining('Your hand'), findsOneWidget);
    expect(find.text('You can claim'), findsNWidgets(2));
    expect(find.textContaining('is thinking'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('applies a discard win and shows the result', (tester) async {
    final controller = TableController(seed: 10)..startNewHand();
    addTearDown(controller.dispose);
    controller.engine
      ..phase = TablePhase.awaitingClaim
      ..lastDiscard = 'east'
      ..lastDiscarder = 1;
    controller.engine.pendingClaims.add(
      const ClaimOption(
        player: 0,
        isWin: true,
        tiles: ['east'],
        score: WinScore(
          faan: 3,
          patterns: [],
          discardPayout: 8,
          selfDrawEach: 4,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: TableScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.textContaining('Win'), findsOneWidget);
    await tester.tap(find.textContaining('Win'));
    await tester.pump();

    expect(find.textContaining('You win'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a draw result', (tester) async {
    final controller = TableController(seed: 9)..startNewHand();
    addTearDown(controller.dispose);
    controller.engine
      ..phase = TablePhase.finished
      ..isDraw = true
      ..winnerIndex = null;

    await tester.pumpWidget(
      MaterialApp(home: TableScreen(controller: controller)),
    );
    await tester.pump();

    expect(find.textContaining('Draw'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.textContaining('Draw hand'), findsNothing);
    expect(find.textContaining('Your hand'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
