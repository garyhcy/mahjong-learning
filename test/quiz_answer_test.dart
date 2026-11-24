import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/models/mahjong_data.dart';
import 'package:ludi/models/quiz_answer.dart';
import 'package:ludi/widgets/quiz/question_inputs.dart';

QuizQuestion _q({
  QuizType type = QuizType.singleChoice,
  List<String> options = const ['a', 'b', 'c'],
  int correctIndex = 1,
  List<int>? correctIndexes,
  List<String>? tiles,
  List<String>? acceptedAnswers,
  List<QuestionPair>? pairs,
}) {
  return QuizQuestion(
    question: 'Q?',
    options: options,
    correctIndex: correctIndex,
    type: type,
    correctIndexes: correctIndexes,
    tiles: tiles,
    acceptedAnswers: acceptedAnswers,
    pairs: pairs,
  );
}

void main() {
  group('singleChoice', () {
    test('only the correct index passes', () {
      final q = _q(correctIndex: 1);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([1])), isTrue);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([0])), isFalse);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([])), isFalse);
    });
  });

  group('multiChoice', () {
    test('requires every correct option and nothing else', () {
      final q = _q(
        type: QuizType.multiChoice,
        correctIndexes: [0, 2],
      );
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([2, 0])), isTrue);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([0])), isFalse);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([0, 1, 2])), isFalse);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.choice([])), isFalse);
    });
  });

  group('tileSelection', () {
    test('one tile must match', () {
      final q = _q(
        type: QuizType.tileSelection,
        options: ['char_1', 'circle_1', 'bamboo_1'],
        correctIndex: 0,
      );
      expect(
          isQuizAnswerCorrect(q, const QuizAnswer.choice([0])), isTrue);
      expect(
          isQuizAnswerCorrect(q, const QuizAnswer.choice([1])), isFalse);
    });
  });

  group('tileOrdering', () {
    test('order must match exactly', () {
      final q = _q(
        type: QuizType.tileOrdering,
        tiles: ['char_1', 'char_2', 'char_3'],
      );
      expect(
        isQuizAnswerCorrect(
            q, const QuizAnswer.ordering(['char_1', 'char_2', 'char_3'])),
        isTrue,
      );
      expect(
        isQuizAnswerCorrect(
            q, const QuizAnswer.ordering(['char_2', 'char_1', 'char_3'])),
        isFalse,
      );
      expect(
        isQuizAnswerCorrect(q, const QuizAnswer.ordering(['char_1'])),
        isFalse,
      );
    });
  });

  group('fillBlank', () {
    final q = _q(
      type: QuizType.fillBlank,
      acceptedAnswers: ['four players', '4 players', '四位玩家'],
    );

    test('ignores case, spacing and punctuation', () {
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('Four Players.')),
          isTrue);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('  four   players ')),
          isTrue);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('4 players')), isTrue);
    });

    test('accepts Chinese answers', () {
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('四位玩家。')), isTrue);
    });

    test('empty or wrong answers fail', () {
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('')), isFalse);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('  ')), isFalse);
      expect(isQuizAnswerCorrect(q, const QuizAnswer.text('three players')),
          isFalse);
    });

    test('falls back to the option at correctIndex when no answers listed', () {
      final fallback = _q(
        type: QuizType.fillBlank,
        options: ['136', '144'],
        correctIndex: 1,
      );
      expect(isQuizAnswerCorrect(fallback, const QuizAnswer.text('144')), isTrue);
      expect(isQuizAnswerCorrect(fallback, const QuizAnswer.text('136')), isFalse);
    });
  });

  group('matching', () {
    final q = _q(
      type: QuizType.matching,
      pairs: const [
        QuestionPair(left: '萬', right: 'Characters'),
        QuestionPair(left: '筒', right: 'Circles'),
      ],
    );

    test('all pairs must be right', () {
      expect(
        isQuizAnswerCorrect(
          q,
          const QuizAnswer.matching(
              {'萬': 'Characters', '筒': 'Circles'}),
        ),
        isTrue,
      );
      expect(
        isQuizAnswerCorrect(
          q,
          const QuizAnswer.matching(
              {'萬': 'Circles', '筒': 'Circles'}),
        ),
        isFalse,
      );
      expect(
        isQuizAnswerCorrect(
            q, const QuizAnswer.matching({'萬': 'Characters'})),
        isFalse,
      );
    });
  });

  group('normalizeQuizText', () {
    test('strips spaces, case and punctuation', () {
      expect(normalizeQuizText('  Four Players. '), 'fourplayers');
      expect(normalizeQuizText('四位玩家。'), '四位玩家');
    });
  });

  group('question input widgets render', () {
    QuestionInputConfig config(QuizQuestion q,
        {Set<int> selected = const {},
        String text = '',
        Map<String, String> matches = const {},
        bool feedback = false,
        bool? correct}) {
      return QuestionInputConfig(
        selected: selected,
        orderingTiles: q.tiles ?? const [],
        answerText: text,
        matches: matches,
        feedbackActive: feedback,
        feedbackCorrect: correct,
        pressedOption: null,
        onOptionTap: (_) {},
        onPressedOption: (_) {},
        onReorder: (_, __) {},
        onTextChanged: (_) {},
        onMatch: (_, __) {},
        onSubmit: () {},
      );
    }

    Future<void> pump(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
      await tester.pumpAndSettle();
    }

    testWidgets('single choice shows options and a submit button',
        (tester) async {
      final q = _q();
      await pump(tester,
          buildQuestionInput(question: q, config: config(q, selected: {1})));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('Submit Answer'), findsOneWidget);
    });

    testWidgets('fill blank shows a text field', (tester) async {
      final q = _q(type: QuizType.fillBlank, acceptedAnswers: ['4']);
      await pump(tester,
          buildQuestionInput(question: q, config: config(q, text: '4')));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('matching shows every left item', (tester) async {
      final q = _q(type: QuizType.matching, pairs: const [
        QuestionPair(left: '萬', right: 'Characters'),
        QuestionPair(left: '筒', right: 'Circles'),
      ]);
      await pump(tester, buildQuestionInput(question: q, config: config(q)));
      expect(find.text('萬'), findsOneWidget);
      expect(find.text('筒'), findsOneWidget);
    });
  });
}
