/// One question in the onboarding placement check.
class PlacementQuestion {
  const PlacementQuestion({
    required this.tier,
    required this.lessonId,
    required this.prompt,
    this.options = const [],
    this.correctIndexes = const [],
    this.acceptedAnswers = const [],
  });

  final int tier;
  final String lessonId;
  final String prompt;
  final List<String> options;
  final List<int> correctIndexes;
  final List<String> acceptedAnswers;

  bool get isFill => acceptedAnswers.isNotEmpty && correctIndexes.isEmpty;
  bool get isMulti => correctIndexes.length > 1;
  int get correctIndex => correctIndexes.first;
}
