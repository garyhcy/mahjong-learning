import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/providers/game_state.dart';
import 'package:ludi/screens/placement_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('skipping placement starts at Stage 1', (tester) async {
    final game = GameState();
    var done = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PlacementScreen(game: game, onDone: () => done = true),
      ),
    );

    expect(find.text('Find your level'), findsOneWidget);
    await tester.tap(find.text("I'm new — start at Stage 1"));
    await tester.pumpAndSettle();

    expect(game.placementDone, isTrue);
    expect(game.placementStartStage, 0);
    expect(find.text('Start at Stage 1'), findsOneWidget);

    await tester.tap(find.text('Start learning'));
    expect(done, isTrue);
  });

  testWidgets('answering a question advances the check', (tester) async {
    final game = GameState();

    await tester.pumpWidget(
      MaterialApp(
        home: PlacementScreen(game: game, onDone: () {}),
      ),
    );

    await tester.tap(find.text('Start the check'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 16'), findsOneWidget);
    await tester.tap(find.text('42'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 16'), findsOneWidget);
  });
}
