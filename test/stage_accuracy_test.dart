// Tests for the progress system (ticket 01): per-stage accuracy tracking and
// Duolingo-style progression (a stage unlocks when the previous stage is
// completed — accuracy is shown but never gates progression).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/models/mahjong_data.dart';
import 'package:ludi/providers/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final stage1 = defaultStages.first;
  final stage1Lessons =
      allLessonsData.where((l) => l.stageId == stage1.id).toList();

  /// Loads a GameState with [completedCount] lessons of stage 1 marked done,
  /// each with the given best [accuracy].
  Future<GameState> loadStateWith({
    required int completedCount,
    required int accuracy,
  }) async {
    final completed = <String, bool>{};
    final bestAccuracy = <String, int>{};
    for (int i = 0; i < stage1Lessons.length; i++) {
      final lesson = stage1Lessons[i];
      final done = i < completedCount;
      completed[lesson.id] = done;
      bestAccuracy[lesson.id] = accuracy;
    }
    SharedPreferences.setMockInitialValues({
      'progress_lessons_completed': jsonEncode(completed),
      'progress_lesson_best_accuracy': jsonEncode(bestAccuracy),
    });
    final game = GameState();
    await game.loadFromStorage();
    return game;
  }

  test('stage accuracy reflects the stored per-lesson best accuracy', () async {
    final game = await loadStateWith(
      completedCount: stage1Lessons.length,
      accuracy: 80,
    );
    expect(game.getStageAccuracy(stage1.id), 80);
  });

  test('completing the stage unlocks the next one, whatever the accuracy',
      () async {
    final game = await loadStateWith(
      completedCount: stage1Lessons.length,
      accuracy: 0,
    );
    expect(game.stages[1].isUnlocked, isTrue);
  });

  test('next stage stays locked while the previous stage is incomplete',
      () async {
    final game = await loadStateWith(
      completedCount: stage1Lessons.length - 1,
      accuracy: 100,
    );
    expect(game.stages[1].isUnlocked, isFalse);
  });

  test('accuracy only counts completed lessons', () async {
    final game = await loadStateWith(completedCount: 0, accuracy: 90);
    expect(game.getStageAccuracy(stage1.id), 0);
    expect(game.stages[1].isUnlocked, isFalse);
  });
}
