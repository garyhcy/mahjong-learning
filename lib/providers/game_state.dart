import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/achievement_def.dart';
import '../models/daily_task_def.dart';
import '../models/wrong_answer.dart';
import '../models/mahjong_data.dart';
import '../services/cloud_sync_service.dart';
import '../services/firebase_service.dart';
import '../services/progress_storage.dart';
import 'mixins/friends_mixin.dart';

class GameState extends ChangeNotifier with FriendsMixin {
  GameState({ProgressStorage? storage, CloudSyncService? cloudSyncService})
      : _storage = storage ?? ProgressStorage(),
        _cloudSyncService = cloudSyncService ?? CloudSyncService();

  final ProgressStorage _storage;
  final CloudSyncService _cloudSyncService;

  Timer? _cloudSyncTimer;
  bool _cloudSyncActive = false;

  int _xp = 0;
  int _streak = 0;
  int _hearts = 3;
  bool _isPremium = false;
  final int maxHearts = 3;
  DateTime? _lastHeartLossAt;
  String? _lastLessonDate;
  bool _isLoaded = false;

  final List<LearningStage> _stages = defaultStages.map((s) => s).toList();

  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _quizFinished = false;
  bool _showFailure = false;

  bool _hasSeenOnboarding = false;
  bool _showOnboarding = false;

  List<DialogueMessage> _dialogue = [];
  int _dialogueIndex = 0;

  String? _currentLessonId;
  final Map<String, bool> _lessonCompleted = {};
  List<QuizQuestion> _currentQuestions = [];
  DateTime? _lessonStartAt;

  String? _targetStageId;
  bool _cloudEnabled = false;
  String? _cloudUid;

  // ── New fields ──
  String? _lastLessonId;
  String _nickname = 'Player';
  String _avatarEmoji = '🐼';
  final Set<String> _unlockedAchievements = {};
  // ── Achievement tracking fields ──
  List<int> _lessonCompletionTimestamps = [];
  Set<String> _practiceModesCompleted = {};
  int _speedChallengeWins = 0;
  int _lastInactiveDays = 0; // days between last 2 active periods; used for comeback
  double _lastQuizCorrectRatio = 0.0; // ratio of correct answers in last completed quiz
  final Map<String, int> _dailyTasks = {};
  String _lastActiveDate = '';
  int _consecutiveCorrect = 0;
  String? _playerId;
  String _region = 'HK';
  int _dailyXpEarned = 0;
  int _lessonCompletedToday = 0;

  final List<WrongAnswer> _wrongAnswers = [];

  // ── Review mode ──
  bool _isReviewMode = false;
  List<QuizQuestion> _reviewQuestions = [];
  int _reviewCorrectCount = 0;
  // Track per-question result for review: index → true/false
  final Map<int, bool> _reviewResults = {};

  // ── Existing getters ──
  bool get isLoaded => _isLoaded;
  int get xp => _xp;
  int get streak => _streak;
  int get hearts => _hearts;
  bool get isPremium => _isPremium;
  int get maxHeartsVal => maxHearts;
  bool get isHeartsFull => _isPremium || _hearts >= maxHearts;
  List<LearningStage> get stages => _stages;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get correctAnswers => _correctAnswers;
  bool get quizFinished => _quizFinished;
  bool get showFailure => _showFailure;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get showOnboarding => _showOnboarding;
  List<DialogueMessage> get dialogue => _dialogue;
  int get dialogueIndex => _dialogueIndex;
  String? get currentLessonId => _currentLessonId;
  List<Lesson> get allLessons => allLessonsData;
  List<QuizQuestion> get currentQuestions => _currentQuestions;
  int get completedLessons =>
      _lessonCompleted.values.where((v) => v).length;
  bool isLessonCompleted(String id) => _lessonCompleted[id] ?? false;
  String? get targetStageId => _targetStageId;
  bool get cloudEnabled => _cloudEnabled;
  bool get cloudConnected => _cloudEnabled && _cloudUid != null;

  // ── New getters ──
  String? get lastLessonId => _lastLessonId;
  String get nickname => _nickname;
  String get avatarEmoji => _avatarEmoji;
  Set<String> get unlockedAchievements => _unlockedAchievements;
  Map<String, int> get dailyTasks => Map.unmodifiable(_dailyTasks);
  int get consecutiveCorrect => _consecutiveCorrect;
  int get dailyXpEarned => _dailyXpEarned;
  int get lessonCompletedToday => _lessonCompletedToday;
  String get lastActiveDate => _lastActiveDate;

  // Achievement tracking getters
  List<int> get lessonCompletionTimestamps => List.unmodifiable(_lessonCompletionTimestamps);
  Set<String> get practiceModesCompleted => Set.unmodifiable(_practiceModesCompleted);
  int get speedChallengeWins => _speedChallengeWins;
  int get lastInactiveDays => _lastInactiveDays;  double get lastQuizCorrectRatio => _lastQuizCorrectRatio;

  /// Lessons completed in last 30 minutes (for quick_learner achievement)
  int get lessonsCompletedInLast30Min {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - 30 * 60 * 1000;
    return _lessonCompletionTimestamps.where((ts) => ts >= cutoff).length;
  }

  String? get playerId => _playerId;
  String get region => _region;
  String? get currentUid => FirebaseService.currentUser?.uid ?? _cloudUid;
  // ── Wrong answer getters ──
  List<WrongAnswer> get wrongAnswers => List.unmodifiable(_wrongAnswers);
  int get wrongAnswerCount => _wrongAnswers.length;
  bool get isReviewMode => _isReviewMode;
  List<QuizQuestion> get reviewQuestions => _reviewQuestions;
  int get reviewCorrectCount => _reviewCorrectCount;
  Map<int, bool> get reviewResults => Map.unmodifiable(_reviewResults);

  Lesson? get currentLesson {
    if (_currentLessonId == null) return null;
    try {
      return allLessonsData.firstWhere((l) => l.id == _currentLessonId);
    } catch (_) {
      return null;
    }
  }

  /// Elapsed time of current lesson (seconds), for completion screen.
  int get lessonElapsedSeconds {
    if (_lessonStartAt == null) return 0;
    return DateTime.now().difference(_lessonStartAt!).inSeconds;
  }

  String get userLevel {
    if (_xp < 500) return 'Novice';
    if (_xp < 1500) return 'Amateur';
    return 'Expert';
  }

  int get xpToNextLevel {
    if (_xp < 500) return 500;
    if (_xp < 1500) return 1500;
    return 3000;
  }

  /// Skill Rating (MMR), 0–100. Used for Find a Match pairing.
  /// Blends lesson-completion progress, learning accuracy, and momentum.
  /// Independent from XP-based League (which rewards activity, not skill).
  int get skillRating {
    final totalLessons = allLessonsData.length;
    final progress =
        totalLessons == 0 ? 0.0 : (completedLessons / totalLessons);

    // Accuracy proxy: penalize accumulated wrong answers relative to attempts.
    final attempts = completedLessons + _wrongAnswers.length;
    final accuracy =
        attempts == 0 ? 0.6 : (completedLessons / attempts).clamp(0.0, 1.0);

    // Momentum: consecutive-correct streak, capped.
    final momentum = (_consecutiveCorrect.clamp(0, 10)) / 10.0;

    // Weighted blend → 0..100.
    final raw = progress * 60 + accuracy * 30 + momentum * 10;
    return raw.round().clamp(0, 100);
  }

  /// Skill tier label derived from [skillRating]. Shown to players as a goal.
  String get skillTier {
    final r = skillRating;
    if (r < 20) return 'Sparrow';
    if (r < 40) return 'Apprentice';
    if (r < 60) return 'Tactician';
    if (r < 80) return 'Sharp';
    return 'Master';
  }

  // ── Persistence ──

  Future<void> loadFromStorage() async {
    SavedProgress saved = await _storage.load();

    _cloudEnabled = await _cloudSyncService.isAvailable();
    if (_cloudEnabled) {
      _cloudUid = await _cloudSyncService.ensureAnonymousUser();
      if (_cloudUid != null) {
        final cloudSaved = await _cloudSyncService.load(_cloudUid!);
        if (cloudSaved != null) {
          saved = cloudSaved;
        }
      }
    }
    _xp = saved.xp;
    _hearts = saved.hearts.clamp(0, maxHearts);
    _isPremium = saved.isPremium;
    _lastHeartLossAt = saved.lastHeartLossAt == null
        ? null
        : DateTime.tryParse(saved.lastHeartLossAt!);
    _lastLessonDate = saved.lastLessonDate;
    _hasSeenOnboarding = saved.hasSeenOnboarding;
    _lessonCompleted
      ..clear()
      ..addAll(saved.lessonCompleted);

    // New fields
    _lastLessonId = saved.lastLessonId;
    _nickname = saved.nickname;
    _avatarEmoji = saved.avatarEmoji;
    _unlockedAchievements
      ..clear()
      ..addAll(saved.unlockedAchievements);
    _dailyTasks
      ..clear()
      ..addAll(saved.dailyTasks);
    _lastActiveDate = saved.lastActiveDate;
    _consecutiveCorrect = saved.consecutiveCorrect;
    _dailyXpEarned = saved.dailyXpEarned;

    // Achievement tracking fields
    _lessonCompletionTimestamps = List.from(saved.lessonCompletionTimestamps);
    _practiceModesCompleted = Set.from(saved.practiceModesCompleted);
    _speedChallengeWins = saved.speedChallengeWins;
    _lastInactiveDays = saved.lastInactiveDays;

    // Wrong answers
    _wrongAnswers.clear();
    for (final json in saved.wrongAnswersJsonList) {
      try {
        _wrongAnswers.add(WrongAnswer.fromJson(jsonDecode(json)));
      } catch (_) {
        // Skip corrupted entries
      }
    }

    _streak = _resolveStreak(saved.streak, saved.lastLessonDate);

    // ── Player ID: load from storage, regenerate if legacy format ──
    _playerId = await ProgressStorage.getPlayerId();
    final isPlayerIdValid =
        _playerId != null && RegExp(r'^LD\d{4}$').hasMatch(_playerId!);
    if (!isPlayerIdValid) {
      _playerId = FirebaseService.generatePlayerId();
      await ProgressStorage.savePlayerId(_playerId!);
    }
    if (_isPremium) {
      _hearts = maxHearts;
      _lastHeartLossAt = null;
    } else {
      _applyDailyHeartRefill();
    }
    _resetDailyTasksIfNeeded();
    _syncStageProgress();
    _updateStageUnlocks();
    _isLoaded = true;
    _persist();
    notifyListeners();
  }

  void _applyDailyHeartRefill() {
    if (_hearts >= maxHearts || _lastHeartLossAt == null) return;
    final today = _dateOnlyDate(DateTime.now());
    final lostDay = _dateOnlyDate(_lastHeartLossAt!);
    if (today.isAfter(lostDay)) {
      _hearts = maxHearts;
      _lastHeartLossAt = null;
    }
  }

  int _resolveStreak(int savedStreak, String? lastLessonDate) {
    if (lastLessonDate == null || savedStreak == 0) return 0;
    final lastDay = _dateOnlyDate(DateTime.parse(lastLessonDate));
    final today = _dateOnlyDate(DateTime.now());
    final gap = today.difference(lastDay).inDays;
    if (gap <= 1) return savedStreak;
    return 0;
  }

  String _dateKey(DateTime date) =>
      _dateOnlyDate(date).toIso8601String().split('T').first;

  // ── Daily task helpers ──

  void _resetDailyTasksIfNeeded() {
    final today = _dateKey(DateTime.now());
    if (_lastActiveDate != today) {
      _dailyTasks.clear();
      _dailyXpEarned = 0;
      _lessonCompletedToday = 0;
      _consecutiveCorrect = 0;
      _lastActiveDate = today;
    }
  }

  void _checkAndUpdateDailyTasks() {
    final today = _dateKey(DateTime.now());
    if (_lastActiveDate != today) {
      _dailyTasks.clear();
      _dailyXpEarned = 0;
      _lessonCompletedToday = 0;
      _consecutiveCorrect = 0;
      _lastActiveDate = today;
    }

    int prev = _dailyTasks['complete_lesson'] ?? 0;
    if (prev < 1 && _lessonCompletedToday >= 1) {
      _dailyTasks['complete_lesson'] = 1;
    }

    int prev3 = _dailyTasks['streak_3'] ?? 0;
    if (prev3 < 1 && _consecutiveCorrect >= 3) {
      _dailyTasks['streak_3'] = 1;
    }

    int prevXp = _dailyTasks['earn_50xp'] ?? 0;
    if (prevXp < 1 && _dailyXpEarned >= 50) {
      _dailyTasks['earn_50xp'] = 1;
    }
  }

  void claimDailyTaskReward(String taskId) {
    final def = dailyTaskDefs[taskId];
    if (def == null) return;
    final progress = _dailyTasks[taskId] ?? 0;
    if (progress != 1) return;
    if (_dailyTasks.containsKey('${taskId}_claimed')) return;

    _dailyTasks['${taskId}_claimed'] = 1;
    _xp += def.reward;
    _dailyXpEarned += def.reward;
    notifyListeners();
    _persist();
  }

  // ── Achievement checking (24 achievements, dynamic) ──

  void checkAchievements() {
    final before = Set<String>.from(_unlockedAchievements);

    // #1 first_lesson: complete 1 lesson
    if (completedLessons >= 1) {
      _unlockedAchievements.add('first_lesson');
    }
    // #2 early_bird: complete a lesson 06:00-09:00
    if (_hasLessonCompletedInHourRange(6, 9)) {
      _unlockedAchievements.add('early_bird');
    }
    // #3 streak_3: 3-day streak
    if (_streak >= 3) {
      _unlockedAchievements.add('streak_3');
    }
    // #4 streak_7: 7-day streak
    if (_streak >= 7) {
      _unlockedAchievements.add('streak_7');
    }
    // #5 perfect_quiz: 100% correct in a single quiz
    if (_lastQuizCorrectRatio == 1.0) {
      _unlockedAchievements.add('perfect_quiz');
    }
    // #6 five_lessons: complete 5 lessons
    if (completedLessons >= 5) {
      _unlockedAchievements.add('five_lessons');
    }
    // #7 first_stage: complete Stage 1
    if (_stages.isNotEmpty && _stages[0].completedLessons >= _stages[0].lessonCount) {
      _unlockedAchievements.add('first_stage');
    }
    // #8 quick_learner: complete 3 lessons within 30 minutes
    if (lessonsCompletedInLast30Min >= 3) {
      _unlockedAchievements.add('quick_learner');
    }
    // #9 comeback: complete a lesson after 7+ days inactive
    if (_lastInactiveDays >= 7) {
      _unlockedAchievements.add('comeback');
    }
    // #10 night_owl: complete a lesson 23:00-02:00
    if (_hasLessonCompletedInHourRange(23, 26)) {
      _unlockedAchievements.add('night_owl');
    }
    // #11 streak_14: 14-day streak
    if (_streak >= 14) {
      _unlockedAchievements.add('streak_14');
    }
    // #12 streak_30: 30-day streak
    if (_streak >= 30) {
      _unlockedAchievements.add('streak_30');
    }
    // #13 ten_lessons: complete 10 lessons
    if (completedLessons >= 10) {
      _unlockedAchievements.add('ten_lessons');
    }
    // #14 twenty_lessons: complete 20 lessons
    if (completedLessons >= 20) {
      _unlockedAchievements.add('twenty_lessons');
    }
    // #15 all_stages: complete all stages
    if (_stages.isNotEmpty && _stages.every((s) => s.completedLessons >= s.lessonCount)) {
      _unlockedAchievements.add('all_stages');
    }
    // #16 social_3: add 3 friends
    if (friends.length >= 3) {
      _unlockedAchievements.add('social_3');
    }
    // #17 social_10: add 10 friends
    if (friends.length >= 10) {
      _unlockedAchievements.add('social_10');
    }
    // #18-20 match series: permanently locked (Find a Match hidden)
    // #21 speed_demon: win speed challenge 10 times
    if (_speedChallengeWins >= 10) {
      _unlockedAchievements.add('speed_demon');
    }
    // #22 explorer: complete all 17 course types (12 stages + 5 practice modes)
    if (_isExplorerComplete()) {
      _unlockedAchievements.add('explorer');
    }
    // #23 gold_league: reach Gold league (1200+ XP)
    if (_xp >= leagueGoldXp) {
      _unlockedAchievements.add('gold_league');
    }
    // #24 diamond_league: reach Diamond league (4000+ XP)
    if (_xp >= leagueDiamondXp) {
      _unlockedAchievements.add('diamond_league');
    }

    if (_unlockedAchievements.length > before.length) {
      notifyListeners();
    }
  }

  bool _hasLessonCompletedInHourRange(int startHour, int endHour) {
    if (_lessonCompletionTimestamps.isEmpty) return false;
    for (final ts in _lessonCompletionTimestamps) {
      final dt = DateTime.fromMillisecondsSinceEpoch(ts);
      final h = dt.hour;
      if (startHour <= endHour) {
        if (h >= startHour && h < endHour) return true;
      } else {
        // wraps midnight (e.g., 23-26 -> 23:00-02:00)
        if (h >= startHour || h < (endHour % 24)) return true;
      }
    }
    return false;
  }

  bool _isExplorerComplete() {
    // 12 Learning Stages completed at least once
    final stagesComplete = _stages.isNotEmpty &&
        _stages.every((s) => s.completedLessons >= 1);
    if (!stagesComplete) return false;
    // 5 practice modes completed at least once
    const requiredPracticeModes = {
      'tile_recognition',
      'tile_matching',
      'sequence_sorting',
      'rules_quiz',
      'speed_challenge',
    };
    return requiredPracticeModes.every((m) => _practiceModesCompleted.contains(m));
  }

  // ── Core gameplay ──

  void init() {
    if (!_hasSeenOnboarding) {
      _showOnboarding = true;
    }
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    _showOnboarding = false;
    loadLesson('1-1');
    _persist();
  }

  void loadLesson(String lessonId) {
    final lesson = allLessonsData.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => allLessonsData.first,
    );
    _currentLessonId = lesson.id;
    _lastLessonId = lesson.id;
    _dialogue = List.from(lesson.localizedDialogues);
    _dialogueIndex = 0;
    _currentQuestions = List.from(lesson.localizedQuestions);
    _quizFinished = false;
    _showFailure = false;
    _isReviewMode = false;
    _reviewQuestions = [];
    _reviewResults.clear();
    _reviewCorrectCount = 0;
    // P0 #1: 心心跨課程持續 - 不在 loadLesson 重置，僅每日 00:00 回血
    if (!_isPremium) {
      _applyDailyHeartRefill();
    }
    _lessonStartAt = DateTime.now();
    _persist();
    notifyListeners();
  }

  void loadDialogue(List<DialogueMessage> messages) {
    _dialogue = messages;
    _dialogueIndex = 0;
    notifyListeners();
  }

  bool advanceDialogue() {
    if (_dialogueIndex < _dialogue.length - 1) {
      _dialogueIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  void startQuiz(List<QuizQuestion> questions) {
    _dialogueIndex = _dialogue.length;
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _quizFinished = false;
    _showFailure = false;
    _currentQuestions = questions;
    notifyListeners();
  }

  /// Single-choice answer (backward compatible)
  bool answerQuestion(int selectedIndex, QuizQuestion question) {
    return _processAnswer([selectedIndex], null, question);
  }

  /// Multi-choice answer with multiple selected indices
  bool answerMultiChoice(List<int> selectedIndices, QuizQuestion question) {
    return _processAnswer(selectedIndices, null, question);
  }

  /// Tile ordering answer: userOrder is the list of tile codes in the user's order
  bool answerTileOrdering(List<String> userOrder, QuizQuestion question) {
    return _processAnswer([], userOrder, question);
  }

  bool _processAnswer(List<int> selectedIndices, List<String>? userOrder, QuizQuestion question) {
    if (!_isPremium) {
      _applyDailyHeartRefill();
    }
    _resetDailyTasksIfNeeded();

    bool isCorrect;
    if (question.type == QuizType.tileOrdering && userOrder != null) {
      // Compare user's order with correct order (tiles field)
      final correctOrder = question.tiles ?? [];
      isCorrect = _listEquals(userOrder, correctOrder);
    } else if (question.type == QuizType.multiChoice) {
      // Multi-select: compare selected indices with correct index
      // For single-correct multi-choice, check if only the correct index is selected
      isCorrect = selectedIndices.length == 1 &&
          selectedIndices.first == question.correctIndex;
    } else {
      // Single choice (tileSelection or legacy)
      isCorrect = selectedIndices.isNotEmpty &&
          selectedIndices.first == question.correctIndex;
    }

    if (isCorrect) {
      _correctAnswers++;
      _consecutiveCorrect++;
    } else {
      _consecutiveCorrect = 0;

      // Record wrong answer (skip in review mode)
      if (!_isReviewMode) {
        final lessonId = _currentLessonId ?? '';
        final qIndex = _currentQuestions.indexOf(question);
        _wrongAnswers.add(WrongAnswer(
          lessonId: lessonId,
          questionIndex: qIndex >= 0 ? qIndex : _currentQuestionIndex,
          selectedIndices: selectedIndices,
          userOrderJson: userOrder != null ? jsonEncode(userOrder) : null,
        ));
      }

      if (!_isPremium && !_isReviewMode) {
        _hearts--;
        _lastHeartLossAt = DateTime.now();
        if (_hearts <= 0) {
          _hearts = 0;
          _showFailure = true;
          _persist();
          notifyListeners();
          return isCorrect;
        }
      }
    }

    if (_currentQuestionIndex < _currentQuestions.length - 1 &&
        !_showFailure) {
      _currentQuestionIndex++;
    } else if (!_showFailure) {
      _quizFinished = true;
      if (!_isReviewMode) {
        _completeLesson();
      }
    }
    _persist();
    notifyListeners();
    return isCorrect;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _completeLesson() {
    if (_currentLessonId == null) return;

    final alreadyCompleted =
        _lessonCompleted[_currentLessonId] ?? false;
    if (!alreadyCompleted) {
      _lessonCompleted[_currentLessonId!] = true;
      _xp += 20;
      _dailyXpEarned += 20;
      _lessonCompletedToday++;
      _updateStreakOnLessonComplete();

      // Track lesson completion timestamp (for early_bird / night_owl / quick_learner)
      _lessonCompletionTimestamps.add(DateTime.now().millisecondsSinceEpoch);
      // Keep only last 100 entries to avoid unbounded growth
      if (_lessonCompletionTimestamps.length > 100) {
        _lessonCompletionTimestamps =
            _lessonCompletionTimestamps.sublist(_lessonCompletionTimestamps.length - 100);
      }

      // Compute inactive days for comeback achievement
      if (_lastLessonDate != null) {
        final last = _dateOnlyDate(DateTime.parse(_lastLessonDate!));
        final today = _dateOnlyDate(DateTime.now());
        _lastInactiveDays = today.difference(last).inDays;
      }
    }

    // Compute last quiz correct ratio for perfect_quiz achievement
    if (_currentQuestions.isNotEmpty) {
      _lastQuizCorrectRatio = _correctAnswers / _currentQuestions.length;
    }

    _syncStageProgress();
    _updateStageUnlocks();
    _checkAndUpdateDailyTasks();
    checkAchievements();
    _persist();
  }

  void _updateStreakOnLessonComplete() {
    final today = _dateKey(DateTime.now());

    if (_lastLessonDate == today) {
      return;
    }

    if (_lastLessonDate == null) {
      _streak = 1;
    } else {
      final last = DateTime.parse(_lastLessonDate!);
      final gap =
          _dateOnlyDate(DateTime.now()).difference(_dateOnlyDate(last)).inDays;
      if (gap == 1) {
        _streak += 1;
      } else if (gap > 1) {
        _streak = 1;
      } else {
        _streak = _streak == 0 ? 1 : _streak;
      }
    }

    _lastLessonDate = today;
  }

  /// Record a practice session result.
  /// [mode] is one of: 'tile_recognition', 'tile_matching', 'sequence_sorting', 'rules_quiz', 'speed_challenge'.
  /// [isWin] for speed_challenge win counting (toward speed_demon achievement).
  void recordPracticeResult(String mode, {bool isWin = false}) {
    _practiceModesCompleted.add(mode);
    if (mode == 'speed_challenge' && isWin) {
      _speedChallengeWins++;
    }
    checkAchievements();
    _persist();
  }

  DateTime _dateOnlyDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _syncStageProgress() {
    for (final stage in _stages) {
      final stageLessons =
          allLessonsData.where((l) => l.stageId == stage.id);
      int completed = 0;
      for (final sl in stageLessons) {
        if (_lessonCompleted[sl.id] == true) completed++;
      }
      stage.completedLessons = completed;
    }
  }

  void _updateStageUnlocks() {
    for (int i = 1; i < _stages.length; i++) {
      final prevStage = _stages[i - 1];
      final currentStage = _stages[i];
      if (!currentStage.isUnlocked && prevStage.progress >= 0.7) {
        currentStage.isUnlocked = true;
      }
    }
  }

  bool isLessonUnlocked(String lessonId) {
    final lesson = allLessonsData.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => allLessonsData.first,
    );
    final stage = _stages.firstWhere(
      (s) => s.id == lesson.stageId,
      orElse: () => _stages.first,
    );
    if (!stage.isUnlocked) return false;

    if (_lessonCompleted[lessonId] == true) return true;

    final stageLessons =
        allLessonsData.where((l) => l.stageId == lesson.stageId).toList();
    final idx = stageLessons.indexWhere((l) => l.id == lessonId);
    if (idx == 0) return true;
    final prevLessonId = stageLessons[idx - 1].id;
    return _lessonCompleted[prevLessonId] == true;
  }

  String getUnlockConditionText(String lessonId) {
    final lesson = allLessonsData.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => allLessonsData.first,
    );
    final stage = _stages.firstWhere(
      (s) => s.id == lesson.stageId,
      orElse: () => _stages.first,
    );
    if (!stage.isUnlocked) {
      final stageIdx = _stages.indexWhere((s) => s.id == stage.id);
      if (stageIdx > 0) {
        return 'Complete ${_stages[stageIdx - 1].title} 70% to unlock';
      }
      return 'Locked';
    }
    final stageLessons =
        allLessonsData.where((l) => l.stageId == lesson.stageId).toList();
    final idx = stageLessons.indexWhere((l) => l.id == lessonId);
    if (idx > 0) {
      return 'Complete "${stageLessons[idx - 1].title}" first';
    }
    return 'Locked';
  }

  void retryQuiz() {
    if (_isPremium) {
      _hearts = maxHearts;
      _lastHeartLossAt = null;
    } else {
      _applyDailyHeartRefill();
      if (_hearts <= 0) {
        notifyListeners();
        return;
      }
    }
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _quizFinished = false;
    _showFailure = false;
    _persist();
    notifyListeners();
  }

  void clearLesson() {
    _currentLessonId = null;
    _dialogue = [];
    _dialogueIndex = 0;
    _quizFinished = false;
    _showFailure = false;
    _isReviewMode = false;
    _reviewQuestions = [];
    _reviewResults.clear();
    _reviewCorrectCount = 0;
    notifyListeners();
  }

  void addXP(int amount) {
    _xp += amount;
    _dailyXpEarned += amount;
    _checkAndUpdateDailyTasks();
    _persist();
    notifyListeners();
  }

  void loseHeart() {
    if (_isPremium) return;
    if (_hearts > 0) {
      _hearts--;
      _lastHeartLossAt = DateTime.now();
      if (_hearts == 0) {
        _showFailure = true;
      }
      _persist();
      notifyListeners();
    }
  }

  void navigateToStage(String stageId) {
    _targetStageId = stageId;
    notifyListeners();
  }

  void clearTargetStage() {
    _targetStageId = null;
  }

  void setPremium(bool value) {
    if (_isPremium == value) return;
    _isPremium = value;
    if (_isPremium) {
      _hearts = maxHearts;
      _lastHeartLossAt = null;
    }
    _persist();
    notifyListeners();
  }

  /// Master mode: unlock all stages for testing
  void activateMasterMode() {
    _isPremium = true;
    _hearts = maxHearts;
    _lastHeartLossAt = null;
    for (final stage in _stages) {
      stage.isUnlocked = true;
    }
    _persist();
    notifyListeners();
  }

  /// Reset master mode: lock stages back to normal progression
  void deactivateMasterMode() {
    _isPremium = false;
    for (int i = 0; i < _stages.length; i++) {
      if (i == 0) {
        _stages[i].isUnlocked = true;
      } else {
        _stages[i].isUnlocked = _stages[i - 1].progress >= 0.7;
      }
    }
    _persist();
    notifyListeners();
  }

  String? getNextLessonId() {
    if (_currentLessonId == null) return null;

    final parts = _currentLessonId!.split('-');
    if (parts.length != 2) return null;
    final stageNum = int.tryParse(parts[0]);
    if (stageNum == null || stageNum < 1 || stageNum > _stages.length) {
      return null;
    }

    final currentStage = _stages[stageNum - 1];
    final stageLessons =
        allLessonsData.where((l) => l.stageId == currentStage.id).toList();
    stageLessons.sort((a, b) => a.id.compareTo(b.id));

    final idx = stageLessons.indexWhere((l) => l.id == _currentLessonId);
    if (idx >= 0 && idx < stageLessons.length - 1) {
      return stageLessons[idx + 1].id;
    }

    _updateStageUnlocks();
    if (stageNum < _stages.length) {
      final nextStage = _stages[stageNum];
      if (nextStage.isUnlocked) {
        final nextStageLessons = allLessonsData
            .where((l) => l.stageId == nextStage.id)
            .toList();
        nextStageLessons.sort((a, b) => a.id.compareTo(b.id));
        if (nextStageLessons.isNotEmpty) return nextStageLessons.first.id;
      }
    }

    return null;
  }

  // ── Nickname / Avatar ──

  void setNickname(String name) {
    _nickname = name;
    _persist();
    notifyListeners();
  }

  void setAvatarEmoji(String emoji) {
    _avatarEmoji = emoji;
    _persist();
    notifyListeners();
  }

  // ── Wrong Answer Review ──

  /// Start reviewing all wrong answers
  void startWrongAnswerReview() {
    if (_wrongAnswers.isEmpty) return;

    // Collect unique questions from wrong answers
    _reviewQuestions = [];
    for (final wa in _wrongAnswers) {
      final lesson = allLessonsData.firstWhere(
        (l) => l.id == wa.lessonId,
        orElse: () => allLessonsData.first,
      );
      if (wa.questionIndex >= 0 && wa.questionIndex < lesson.localizedQuestions.length) {
        final q = lesson.localizedQuestions[wa.questionIndex];
        if (!_reviewQuestions.contains(q)) {
          _reviewQuestions.add(q);
        }
      }
    }

    if (_reviewQuestions.isEmpty) return;

    _isReviewMode = true;
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _reviewCorrectCount = 0;
    _reviewResults.clear();
    _quizFinished = false;
    _showFailure = false;
    _currentQuestions = _reviewQuestions;
    _hearts = maxHearts; // no heart penalty in review
    notifyListeners();
  }

  /// Answer in review mode
  bool answerReviewQuestion(List<int> selectedIndices, List<String>? userOrder, QuizQuestion question) {
    bool isCorrect;
    if (question.type == QuizType.tileOrdering && userOrder != null) {
      final correctOrder = question.tiles ?? [];
      isCorrect = correctOrder.length == userOrder.length &&
          List.generate(correctOrder.length, (i) => correctOrder[i] == userOrder[i])
              .every((e) => e);
    } else if (question.type == QuizType.multiChoice) {
      isCorrect = selectedIndices.length == 1 &&
          selectedIndices.first == question.correctIndex;
    } else {
      isCorrect = selectedIndices.isNotEmpty &&
          selectedIndices.first == question.correctIndex;
    }

    _reviewResults[_currentQuestionIndex] = isCorrect;
    if (isCorrect) {
      _reviewCorrectCount++;
      _correctAnswers++;
    }

    if (_currentQuestionIndex < _reviewQuestions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _quizFinished = true;
    }
    _persist();
    notifyListeners();
    return isCorrect;
  }

  /// Clear wrong answers
  void clearWrongAnswers() {
    _wrongAnswers.clear();
    _persist();
    notifyListeners();
  }

  /// Exit review mode
  void exitReview() {
    _isReviewMode = false;
    _reviewQuestions = [];
    _reviewResults.clear();
    _reviewCorrectCount = 0;
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _quizFinished = false;
    _currentQuestions = [];
    notifyListeners();
  }

  // ── Cloud Sync ──

  /// Schedule a debounced cloud upload. Calls within 500ms are coalesced.
  void _scheduleCloudSync() {
    if (!_cloudSyncActive) return;
    _cloudSyncTimer?.cancel();
    _cloudSyncTimer = Timer(const Duration(milliseconds: 500), () {
      _syncToCloud();
    });
  }

  Future<void> _syncToCloud() async {
    if (!_cloudSyncActive) return;

    final stageMap = <String, Map<String, dynamic>>{};
    for (final stage in _stages) {
      stageMap[stage.id] = {
        'completedLessons': stage.completedLessons,
        'lessonCount': stage.lessonCount,
        'isUnlocked': stage.isUnlocked,
      };
    }

    await FirebaseService.saveProgress({
      'xp': _xp,
      'streak': _streak,
      'currentStageId': _targetStageId ?? (_stages.isNotEmpty ? _stages[0].id : 'stage1'),
      'completedStages': stageMap,
      'completedLessons': completedLessons,
      'achievements': _unlockedAchievements.toList(),
      'dailyXpEarned': _dailyXpEarned,
      'nickname': _nickname,
      'avatarEmoji': _avatarEmoji,
      'userLevel': userLevel,
      'playerId': _playerId,
      'lessonCompletionTimestamps': _lessonCompletionTimestamps,
      'practiceModesCompleted': _practiceModesCompleted.toList(),
      'speedChallengeWins': _speedChallengeWins,
      'lastInactiveDays': _lastInactiveDays,
    });
  }

  Future<void> _loadFromCloud() async {
    try {
      final data = await FirebaseService.loadProgress();
      if (data == null) return;

      // Merge: take max for XP and streak
      final cloudXp = (data['xp'] as num?)?.toInt() ?? 0;
      final cloudStreak = (data['streak'] as num?)?.toInt() ?? 0;
      final cloudDailyXp = (data['dailyXpEarned'] as num?)?.toInt() ?? 0;

      if (cloudXp > _xp) _xp = cloudXp;
      if (cloudStreak > _streak) _streak = cloudStreak;
      if (cloudDailyXp > _dailyXpEarned) _dailyXpEarned = cloudDailyXp;

      // Merge achievements
      final cloudAchievements = (data['achievements'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toSet();
      if (cloudAchievements != null) {
        _unlockedAchievements.addAll(cloudAchievements);
      }

      // Merge completed lessons count — trust cloud if higher
      final cloudCompletedLessons =
          (data['completedLessons'] as num?)?.toInt() ?? 0;
      if (cloudCompletedLessons > completedLessons) {
        // Sync lesson completion map
        final cloudStageMap =
            data['completedStages'] as Map<String, dynamic>?;
        if (cloudStageMap != null) {
          for (final stage in _stages) {
            final entry = cloudStageMap[stage.id];
            if (entry is Map<String, dynamic>) {
              final cloudComp =
                  (entry['completedLessons'] as num?)?.toInt() ?? 0;
              if (cloudComp > stage.completedLessons) {
                stage.completedLessons = cloudComp;
              }
              stage.isUnlocked =
                  entry['isUnlocked'] == true || stage.isUnlocked;
            }
          }
        }
        _syncStageProgress();
      }

      // Merge new tracking fields (union / max strategy)
      final cloudTimestamps = (data['lessonCompletionTimestamps'] as List<dynamic>?)
          ?.map((e) => (e is int) ? e : int.tryParse(e.toString()) ?? 0)
          .where((t) => t > 0)
          .toList() ?? [];
      _lessonCompletionTimestamps = List.from({..._lessonCompletionTimestamps, ...cloudTimestamps});
      if (_lessonCompletionTimestamps.length > 100) {
        _lessonCompletionTimestamps = _lessonCompletionTimestamps.sublist(
            _lessonCompletionTimestamps.length - 100);
      }
      final cloudModes = (data['practiceModesCompleted'] as List<dynamic>?)
          ?.map((e) => e.toString()).toSet() ?? <String>{};
      _practiceModesCompleted = _practiceModesCompleted.union(cloudModes);
      final cloudSpeedWins = (data['speedChallengeWins'] as num?)?.toInt() ?? 0;
      if (cloudSpeedWins > _speedChallengeWins) _speedChallengeWins = cloudSpeedWins;
      final cloudInactiveDays = (data['lastInactiveDays'] as num?)?.toInt() ?? 0;
      if (cloudInactiveDays > _lastInactiveDays) _lastInactiveDays = cloudInactiveDays;

      // Sync playerId from cloud (only accept well-formed LD#### IDs; regenerate if legacy)
      final cloudPlayerId = data['playerId'] as String?;
      final isLocalValid = _playerId != null && RegExp(r'^LD\d{4}$').hasMatch(_playerId!);
      if (isLocalValid) {
        // Local already correct; if cloud is legacy/different, push local back to cloud
        if (cloudPlayerId != _playerId) {
          // will be synced by _syncToCloud() below
        }
      } else if (cloudPlayerId != null &&
          cloudPlayerId.isNotEmpty &&
          RegExp(r'^LD\d{4}$').hasMatch(cloudPlayerId)) {
        // Cloud is well-formed, adopt it
        _playerId = cloudPlayerId;
        await ProgressStorage.savePlayerId(_playerId!);
      } else {
        // Both missing or legacy: generate a fresh well-formed ID
        _playerId = FirebaseService.generatePlayerId();
        await ProgressStorage.savePlayerId(_playerId!);
      }

      _persist();
      _syncToCloud(); // write merged data back
      notifyListeners();
    } catch (_) {
      // Silently fail — local data remains source of truth.
    }
  }

  /// Call after user signs in to pull cloud progress.
  void loadCloudProgress() {
    _cloudSyncActive = true;
    _loadFromCloud();
  }

  /// Disable cloud sync (called on logout).
  void disableCloudSync() {
    _cloudSyncActive = false;
    _cloudSyncTimer?.cancel();
  }

  /// Reset all local progress (used by Delete Account flow).
  Future<void> resetProgress() async {
    _xp = 0;
    _streak = 0;
    _hearts = 3;
    _isPremium = false;
    _lastHeartLossAt = null;
    _lastLessonDate = null;
    _hasSeenOnboarding = false;
    _lessonCompleted.clear();
    _lastLessonId = null;
    _nickname = 'Player';
    _avatarEmoji = '🐼';
    _unlockedAchievements.clear();
    _dailyTasks.clear();
    _lastActiveDate = '';
    _consecutiveCorrect = 0;
    _dailyXpEarned = 0;
    _wrongAnswers.clear();
    _isReviewMode = false;
    _reviewQuestions = [];
    _reviewResults.clear();
    _reviewCorrectCount = 0;
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _quizFinished = false;
    _showFailure = false;
    _dialogue = [];
    _dialogueIndex = 0;
    _currentLessonId = null;
    _currentQuestions = [];
    _targetStageId = null;
    _syncStageProgress();
    _updateStageUnlocks();
    await _persist();
    notifyListeners();
  }

  // ── Persist override ──

  Future<void> _persist() async {
    if (!_isLoaded) return;

    final lessonCompletedSnapshot = Map<String, bool>.from(_lessonCompleted);
    final lastHeartLossAtIso = _lastHeartLossAt?.toIso8601String();
    final wrongAnswersJsonList =
        _wrongAnswers.map((wa) => jsonEncode(wa.toJson())).toList();

    await _storage.save(
      xp: _xp,
      streak: _streak,
      hearts: _hearts,
      isPremium: _isPremium,
      lastHeartLossAt: lastHeartLossAtIso,
      lastLessonDate: _lastLessonDate,
      hasSeenOnboarding: _hasSeenOnboarding,
      lessonCompleted: lessonCompletedSnapshot,
      lastLessonId: _lastLessonId,
      nickname: _nickname,
      avatarEmoji: _avatarEmoji,
      unlockedAchievements: _unlockedAchievements,
      dailyTasks: _dailyTasks,
      lastActiveDate: _lastActiveDate,
      consecutiveCorrect: _consecutiveCorrect,
      dailyXpEarned: _dailyXpEarned,
      wrongAnswersJsonList: wrongAnswersJsonList,
      lessonCompletionTimestamps: _lessonCompletionTimestamps,
      practiceModesCompleted: _practiceModesCompleted,
      speedChallengeWins: _speedChallengeWins,
      lastInactiveDays: _lastInactiveDays,
    );

    if (_cloudEnabled && _cloudUid != null) {
      await _cloudSyncService.save(
        uid: _cloudUid!,
        xp: _xp,
        streak: _streak,
        hearts: _hearts,
        isPremium: _isPremium,
        lastHeartLossAt: lastHeartLossAtIso,
        lastLessonDate: _lastLessonDate,
        hasSeenOnboarding: _hasSeenOnboarding,
        lessonCompleted: lessonCompletedSnapshot,
        nickname: _nickname,
        avatarEmoji: _avatarEmoji,
      );
    }

    // Trigger debounced sync to Firebase (logged-in users)
    _scheduleCloudSync();
  }

  // ── Player ID & Region ──
  Future<void> initPlayerId() async {
    if (_playerId != null) return;
    _playerId = FirebaseService.generatePlayerId();
    await ProgressStorage.savePlayerId(_playerId!);
    notifyListeners();
  }

  void setRegion(String r) {
    _region = r;
    notifyListeners();
  }

  Future<void> loadPlayerId() async {
    _playerId = await ProgressStorage.getPlayerId();
    // Migrate legacy player IDs: regenerate if not matching LD + 4 digits
    if (_playerId != null && !RegExp(r'^LD\d{4}$').hasMatch(_playerId!)) {
      _playerId = FirebaseService.generatePlayerId();
      await ProgressStorage.savePlayerId(_playerId!);
    }
  }

}
