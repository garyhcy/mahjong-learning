import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/models/mahjong_data.dart';
import 'package:ludi/widgets/stage_map.dart';

LearningStage _stage(
  String id,
  String title, {
  int lessons = 8,
  int done = 0,
  bool unlocked = true,
}) {
  return LearningStage(
    id: id,
    title: title,
    subtitle: 'Subtitle',
    icon: Icons.school_rounded,
    color: const Color(0xFF4CAF50),
    lessonCount: lessons,
    completedLessons: done,
    isUnlocked: unlocked,
  );
}

void main() {
  testWidgets('renders completed, current and locked tiles', (tester) async {
    final stages = [
      _stage('s1', 'Basics', done: 8),
      _stage('s2', 'Sequences', done: 3),
      _stage('s3', 'Winning', unlocked: false),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StageMap(
              stages: stages,
              currentIndex: 1,
              onStageTap: (_) {},
              onLockedTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Sequences'), findsOneWidget);
    expect(find.text('Winning'), findsOneWidget);
    expect(find.text('Cleared'), findsOneWidget);
    expect(find.text('3 / 8 lessons'), findsOneWidget);
    expect(find.text('Clear Sequences first'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('locked tile reports to onLockedTap', (tester) async {
    LearningStage? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StageMap(
            stages: [
              _stage('s1', 'Basics', done: 8),
              _stage('s2', 'Locked', unlocked: false),
            ],
            currentIndex: 1,
            onStageTap: (_) {},
            onLockedTap: (stage) => tapped = stage,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.lock_rounded));
    expect(tapped?.id, 's2');
  });

  testWidgets('available tile reports to onStageTap', (tester) async {
    LearningStage? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StageMap(
            stages: [
              _stage('s1', 'Basics', done: 8),
              _stage('s2', 'Next', done: 2),
            ],
            currentIndex: 1,
            onStageTap: (stage) => tapped = stage,
            onLockedTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.school_rounded).last);
    expect(tapped?.id, 's2');
  });
}
