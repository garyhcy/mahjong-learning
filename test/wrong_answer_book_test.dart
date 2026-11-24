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

  test('a wrong answer is recorded and leaves the book once reviewed right',
      () async {
    final state = await buildState();
    state.loadLesson('1-1');

    final questions = state.currentQuestions;
    final index = questions.indexWhere(
        (q) => q.type == QuizType.singleChoice && q.allCorrectIndexes.isNotEmpty);
    expect(index, isNot(-1), reason: 'lesson 1-1 should contain a single choice');

    final question = questions[index];
    state.startQuiz(questions);

    // Answer wrongly.
    final wrongPick = question.correctIndex == 0 ? 1 : 0;
    final firstCorrect =
        state.submitAnswer(QuizAnswer.choice([wrongPick]), question);
    expect(firstCorrect, isFalse);
    expect(state.wrongAnswers.length, 1);
    expect(state.wrongAnswers.first.lessonId, '1-1');
    expect(state.wrongAnswers.first.questionIndex, index);

    // Review it correctly: the entry should disappear (Gary D1a).
    state.startWrongAnswerReview();
    expect(state.reviewQuestions.length, 1);
    final reviewCorrect = state.submitAnswer(
        QuizAnswer.choice([question.correctIndex]), state.reviewQuestions.first);
    expect(reviewCorrect, isTrue);
    expect(state.wrongAnswers, isEmpty);
  });

  test('removeWrongAnswer drops a single entry only', () async {
    final state = await buildState();
    state.loadLesson('1-1');

    final questions = state.currentQuestions;
    final choiceIndexes = <int>[];
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].type == QuizType.singleChoice) choiceIndexes.add(i);
    }
    expect(choiceIndexes.length, greaterThanOrEqualTo(2));

    state.startQuiz(questions);
    final first = questions[choiceIndexes[0]];
    final second = questions[choiceIndexes[1]];
    state.submitAnswer(
        QuizAnswer.choice([first.correctIndex == 0 ? 1 : 0]), first);
    state.submitAnswer(
        QuizAnswer.choice([second.correctIndex == 0 ? 1 : 0]), second);
    expect(state.wrongAnswers.length, 2);

    state.removeWrongAnswer('1-1', choiceIndexes[0]);
    expect(state.wrongAnswers.length, 1);
    expect(state.wrongAnswers.first.questionIndex, choiceIndexes[1]);
  });
}
