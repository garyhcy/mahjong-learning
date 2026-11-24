import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/models/mahjong_data.dart';

void main() {
  final questions = [
    for (final lesson in allLessonsData) ...lesson.questions,
  ];

  test('question bank is not empty', () {
    expect(questions, isNotEmpty);
  });

  test('every question has a usable answer definition', () {
    for (final q in questions) {
      final label = '${q.question} (${q.type.name})';
      switch (q.type) {
        case QuizType.singleChoice:
          expect(q.options.length, greaterThan(1), reason: label);
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
              reason: label);
          break;
        case QuizType.multiChoice:
          expect(q.options.length, greaterThan(1), reason: label);
          expect(q.allCorrectIndexes.length, greaterThan(1),
              reason: '$label should have at least 2 correct options');
          for (final i in q.allCorrectIndexes) {
            expect(i, inInclusiveRange(0, q.options.length - 1),
                reason: label);
          }
          break;
        case QuizType.tileSelection:
          expect(q.options.length, greaterThan(1), reason: label);
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
              reason: label);
          break;
        case QuizType.tileOrdering:
          expect(q.tiles, isNotNull, reason: label);
          expect(q.tiles!.length, greaterThan(1), reason: label);
          break;
        case QuizType.fillBlank:
          final answers = q.acceptedAnswers;
          if (answers != null) {
            expect(answers, isNotEmpty, reason: label);
            for (final a in answers) {
              expect(a.trim(), isNotEmpty, reason: label);
            }
          } else {
            expect(q.options.length, greaterThan(0),
                reason: '$label needs acceptedAnswers or an option fallback');
            expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
                reason: label);
          }
          break;
        case QuizType.matching:
          final pairs = q.pairs;
          expect(pairs, isNotNull, reason: label);
          expect(pairs!.length, greaterThan(1),
              reason: '$label needs at least 2 pairs');
          final rights = pairs.map((p) => p.right).toList();
          expect(rights.toSet().length, rights.length,
              reason: '$label has duplicate right-hand values');
          for (final p in pairs) {
            expect(p.left.trim(), isNotEmpty, reason: label);
            expect(p.right.trim(), isNotEmpty, reason: label);
          }
          break;
      }
    }
  });

  test('new question types are actually represented in the bank', () {
    int count(QuizType t) => questions.where((q) => q.type == t).length;
    expect(count(QuizType.fillBlank), greaterThanOrEqualTo(15));
    expect(count(QuizType.matching), greaterThanOrEqualTo(2));
    expect(count(QuizType.multiChoice), greaterThanOrEqualTo(2));
  });

  test('Stage 1-8 lessons carry 8-12 questions with 2+ types', () {
    const targetStages = {
      'stage1', 'stage2', 'stage3', 'stage4',
      'stage5', 'stage6', 'stage7', 'stage8',
    };
    final lessons = allLessonsData.where((l) => targetStages.contains(l.stageId));
    expect(lessons, isNotEmpty);
    for (final lesson in lessons) {
      final label = '${lesson.id} ${lesson.title}';
      expect(lesson.questions.length, inInclusiveRange(8, 12), reason: label);
      final types = lesson.questions.map((q) => q.type).toSet();
      expect(types.length, greaterThanOrEqualTo(2),
          reason: '$label has only ${types.map((t) => t.name).join(", ")}');
    }
  });
}
