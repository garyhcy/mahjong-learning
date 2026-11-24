import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/models/mahjong_data.dart';
import 'package:ludi/models/quiz_answer.dart';
import 'package:ludi/providers/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<GameState> buildState() async {
    final state = GameState();
    await state.loadFromStorage();
    return state;
  }

  test('submitAnswer scores every question type through the provider', () async {
    final state = await buildState();

    final questions = <QuizQuestion>[
      QuizQuestion(
        question: 'Single?',
        options: ['a', 'b', 'c'],
        correctIndex: 1,
        type: QuizType.singleChoice,
      ),
      QuizQuestion(
        question: 'Multi?',
        options: ['a', 'b', 'c', 'd'],
        correctIndex: 0,
        correctIndexes: [0, 2],
        type: QuizType.multiChoice,
      ),
      QuizQuestion(
        question: 'Fill?',
        options: [],
        correctIndex: 0,
        type: QuizType.fillBlank,
        acceptedAnswers: ['four players', '4'],
      ),
      QuizQuestion(
        question: 'Match?',
        options: [],
        correctIndex: 0,
        type: QuizType.matching,
        pairs: [
          QuestionPair(left: 'East', right: 'Spring'),
          QuestionPair(left: 'South', right: 'Summer'),
        ],
      ),
      QuizQuestion(
        question: 'Order?',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m1', 'm2', 'm3'],
      ),
    ];

    state.startQuiz(questions);

    // wrong single choice
    expect(state.submitAnswer(const QuizAnswer.choice([0]), questions[0]),
        isFalse);
    expect(state.currentQuestionIndex, 1);

    // right multi choice (order independent)
    expect(state.submitAnswer(const QuizAnswer.choice([2, 0]), questions[1]),
        isTrue);
    expect(state.currentQuestionIndex, 2);

    // right fill blank, different casing/wording
    expect(
        state.submitAnswer(const QuizAnswer.text('Four Players.'), questions[2]),
        isTrue);

    // wrong matching
    expect(
      state.submitAnswer(
        const QuizAnswer.matching({'East': 'Summer', 'South': 'Summer'}),
        questions[3],
      ),
      isFalse,
    );

    // right ordering
    expect(
      state.submitAnswer(
        const QuizAnswer.ordering(['m1', 'm2', 'm3']),
        questions[4],
      ),
      isTrue,
    );

    expect(state.correctAnswers, 3);
    expect(state.wrongAnswers.length, 2);
    expect(state.wrongAnswers.first.userOrderJson, isNotNull);
  });

  test('submitAnswer survives a review-mode wrong answer', () async {
    final state = await buildState();
    final question = QuizQuestion(
      question: 'Fill?',
      options: [],
      correctIndex: 0,
      type: QuizType.fillBlank,
      acceptedAnswers: ['144'],
    );
    state.startQuiz([question]);
    expect(state.submitAnswer(const QuizAnswer.text('136'), question), isFalse);
  });
}
