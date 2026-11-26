import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/providers/game_state.dart';
import 'package:ludi/widgets/daily_goal_card.dart';

void main() {
  testWidgets('daily goal card shows streak, tasks and start button', (
    tester,
  ) async {
    final game = GameState();
    var started = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyGoalCard(game: game, onStartLesson: () => started = true),
        ),
      ),
    );

    expect(find.text('0 day streak'), findsOneWidget);
    expect(find.text('Complete 1 Lesson'), findsOneWidget);
    expect(find.text('Start a lesson'), findsOneWidget);

    await tester.tap(find.text('Start a lesson'));
    expect(started, isTrue);
  });

  testWidgets('daily goal card fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyGoalCard(game: GameState(), onStartLesson: () {}),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
