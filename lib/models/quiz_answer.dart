import 'mahjong_data.dart';

/// The user's answer to a [QuizQuestion], whatever its type.
///
/// One bag of possible inputs so every question type can be validated (and
/// replayed from a [WrongAnswer]) through the same entry point.
class QuizAnswer {
  /// Selected option indices (single/multi choice, tile selection).
  final List<int> selectedIndexes;

  /// Tile codes in the user's order (tile ordering).
  final List<String>? order;

  /// Free text the user typed (fill in the blank).
  final String? text;

  /// Matching answers: left item -> right item the user connected it to.
  final Map<String, String>? matches;

  const QuizAnswer({
    this.selectedIndexes = const <int>[],
    this.order,
    this.text,
    this.matches,
  });

  const QuizAnswer.choice(List<int> indexes)
      : selectedIndexes = indexes,
        order = null,
        text = null,
        matches = null;

  const QuizAnswer.ordering(List<String> tiles)
      : selectedIndexes = const <int>[],
        order = tiles,
        text = null,
        matches = null;

  const QuizAnswer.text(String value)
      : selectedIndexes = const <int>[],
        order = null,
        text = value,
        matches = null;

  const QuizAnswer.matching(Map<String, String> pairings)
      : selectedIndexes = const <int>[],
        order = null,
        text = null,
        matches = pairings;

  /// Serializable form, stored with a [WrongAnswer] for the review history.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'selected': selectedIndexes,
        if (order != null) 'order': order,
        if (text != null) 'text': text,
        if (matches != null) 'matches': matches,
      };
}

/// Normalizes free text before comparison: ignores case, all whitespace and
/// trailing punctuation, so `"Four players."`, `"four players"` and
/// `"四位玩家"` style answers are compared fairly in both English and Chinese.
String normalizeQuizText(String value) {
  var text = value.toLowerCase();
  text = text.replaceAll(RegExp(r'\s+'), '');
  text = text.replaceAll(RegExp(r'''[。．.，,、;；:：!！?？"“”'‘’]'''), '');
  return text;
}

/// Single source of truth for "is this answer right?".
///
/// Every screen and provider goes through here so a new question type only has
/// to be added once.
bool isQuizAnswerCorrect(QuizQuestion question, QuizAnswer answer) {
  switch (question.type) {
    case QuizType.singleChoice:
    case QuizType.tileSelection:
      return answer.selectedIndexes.length == 1 &&
          answer.selectedIndexes.first == question.correctIndex;

    case QuizType.multiChoice:
      final correct = question.allCorrectIndexes.toSet();
      final selected = answer.selectedIndexes.toSet();
      if (selected.isEmpty || selected.length != correct.length) return false;
      return selected.containsAll(correct);

    case QuizType.tileOrdering:
      final correctOrder = question.tiles ?? const <String>[];
      final userOrder = answer.order ?? const <String>[];
      if (correctOrder.isEmpty || userOrder.length != correctOrder.length) {
        return false;
      }
      for (var i = 0; i < correctOrder.length; i++) {
        if (correctOrder[i] != userOrder[i]) return false;
      }
      return true;

    case QuizType.fillBlank:
      final normalized = normalizeQuizText(answer.text ?? '');
      if (normalized.isEmpty) return false;
      final accepted = (question.acceptedAnswers != null &&
              question.acceptedAnswers!.isNotEmpty)
          ? question.acceptedAnswers!
          : (question.correctIndex >= 0 &&
                  question.correctIndex < question.options.length)
              ? <String>[question.options[question.correctIndex]]
              : const <String>[];
      return accepted
          .any((candidate) => normalizeQuizText(candidate) == normalized);

    case QuizType.matching:
      final correctPairs = question.pairs ?? const <QuestionPair>[];
      final matches = answer.matches ?? const <String, String>{};
      if (correctPairs.isEmpty) return false;
      for (final pair in correctPairs) {
        final chosen = matches[pair.left];
        if (chosen == null) return false;
        if (normalizeQuizText(chosen) != normalizeQuizText(pair.right)) {
          return false;
        }
      }
      return true;
  }
}
