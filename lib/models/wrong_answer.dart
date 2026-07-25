/// Record of a wrong answer for review
class WrongAnswer {
  final String lessonId;
  final int questionIndex;
  final List<int> selectedIndices;
  final String? userOrderJson; // for tileOrdering: JSON-encoded list of tile codes
  final DateTime timestamp;

  WrongAnswer({
    required this.lessonId,
    required this.questionIndex,
    required this.selectedIndices,
    this.userOrderJson,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'questionIndex': questionIndex,
        'selectedIndices': selectedIndices,
        'userOrderJson': userOrderJson,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WrongAnswer.fromJson(Map<String, dynamic> json) => WrongAnswer(
        lessonId: json['lessonId'] as String,
        questionIndex: json['questionIndex'] as int,
        selectedIndices: (json['selectedIndices'] as List).cast<int>(),
        userOrderJson: json['userOrderJson'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
