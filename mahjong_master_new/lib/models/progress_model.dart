class SavedProgress {
  final int xp;
  final int hearts;
  final int streak;
  final String? currentLessonId;
  final int dialogueIndex;
  final int questionIndex;
  final Map<String, bool> lessonCompleted;
  final String? lastHeartRefillDate;
  final bool onboardingSeen;
  final String? dailyDoneDate;
  final int dailyDoneCount;
  final List<String> analyticsEvents;
  final String? seenReleaseNoteVersion;
  final bool demoModeEnabled;

  const SavedProgress({
    required this.xp,
    required this.hearts,
    required this.streak,
    required this.currentLessonId,
    required this.dialogueIndex,
    required this.questionIndex,
    required this.lessonCompleted,
    required this.lastHeartRefillDate,
    required this.onboardingSeen,
    required this.dailyDoneDate,
    required this.dailyDoneCount,
    required this.analyticsEvents,
    required this.seenReleaseNoteVersion,
    required this.demoModeEnabled,
  });
}
