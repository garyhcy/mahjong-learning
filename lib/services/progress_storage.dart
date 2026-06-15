import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedProgress {
  final int xp;
  final int streak;
  final int hearts;
  final bool isPremium;
  final String? lastHeartLossAt;
  final String? lastLessonDate;
  final bool hasSeenOnboarding;
  final Map<String, bool> lessonCompleted;
  final String? lastLessonId;
  final String nickname;
  final String avatarEmoji;
  final Set<String> unlockedAchievements;
  final Map<String, int> dailyTasks;
  final String lastActiveDate;
  final int consecutiveCorrect;
  final int dailyXpEarned;
  final List<String> wrongAnswersJsonList;

  const SavedProgress({
    this.xp = 0,
    this.streak = 0,
    this.hearts = 3,
    this.isPremium = false,
    this.lastHeartLossAt,
    this.lastLessonDate,
    this.hasSeenOnboarding = false,
    this.lessonCompleted = const {},
    this.lastLessonId,
    this.nickname = 'Player',
    this.avatarEmoji = '🐼',
    this.unlockedAchievements = const {},
    this.dailyTasks = const {},
    this.lastActiveDate = '',
    this.consecutiveCorrect = 0,
    this.dailyXpEarned = 0,
    this.wrongAnswersJsonList = const [],
  });
}

class ProgressStorage {
  static const _xpKey = 'progress_xp';
  static const _streakKey = 'progress_streak';
  static const _heartsKey = 'progress_hearts';
  static const _premiumKey = 'progress_is_premium';
  static const _lastHeartLossAtKey = 'progress_last_heart_loss_at';
  static const _lastLessonDateKey = 'progress_last_lesson_date';
  static const _onboardingKey = 'progress_onboarding_seen';
  static const _lessonsKey = 'progress_lessons_completed';
  static const _lastLessonIdKey = 'progress_last_lesson_id';
  static const _nicknameKey = 'progress_nickname';
  static const _avatarKey = 'progress_avatar';
  static const _achievementsKey = 'progress_achievements';
  static const _dailyTasksKey = 'progress_daily_tasks';
  static const _lastActiveDateKey = 'progress_last_active_date';
  static const _consecutiveCorrectKey = 'progress_consecutive_correct';
  static const _dailyXpEarnedKey = 'progress_daily_xp_earned';
  static const _wrongAnswersKey = 'progress_wrong_answers';

  Future<SavedProgress> load() async {
    final prefs = await SharedPreferences.getInstance();

    final lessonsRaw = prefs.getString(_lessonsKey);
    Map<String, bool> lessons = {};
    if (lessonsRaw != null) {
      final decoded = jsonDecode(lessonsRaw) as Map<String, dynamic>;
      lessons = decoded.map((key, value) => MapEntry(key, value == true));
    }

    final achievementsRaw = prefs.getStringList(_achievementsKey);
    final achievements = achievementsRaw?.toSet() ?? <String>{};

    final dailyTasksRaw = prefs.getString(_dailyTasksKey);
    Map<String, int> dailyTasks = {};
    if (dailyTasksRaw != null) {
      final decoded = jsonDecode(dailyTasksRaw) as Map<String, dynamic>;
      dailyTasks = decoded.map((key, value) => MapEntry(key, value as int));
    }

    final wrongAnswersRaw = prefs.getStringList(_wrongAnswersKey);
    final wrongAnswers = wrongAnswersRaw ?? [];

    return SavedProgress(
      xp: prefs.getInt(_xpKey) ?? 0,
      streak: prefs.getInt(_streakKey) ?? 0,
      hearts: prefs.getInt(_heartsKey) ?? 3,
      isPremium: prefs.getBool(_premiumKey) ?? false,
      lastHeartLossAt: prefs.getString(_lastHeartLossAtKey),
      lastLessonDate: prefs.getString(_lastLessonDateKey),
      hasSeenOnboarding: prefs.getBool(_onboardingKey) ?? false,
      lessonCompleted: lessons,
      lastLessonId: prefs.getString(_lastLessonIdKey),
      nickname: prefs.getString(_nicknameKey) ?? 'Player',
      avatarEmoji: prefs.getString(_avatarKey) ?? '🐼',
      unlockedAchievements: achievements,
      dailyTasks: dailyTasks,
      lastActiveDate: prefs.getString(_lastActiveDateKey) ?? '',
      consecutiveCorrect: prefs.getInt(_consecutiveCorrectKey) ?? 0,
      dailyXpEarned: prefs.getInt(_dailyXpEarnedKey) ?? 0,
      wrongAnswersJsonList: wrongAnswers,
    );
  }

  Future<void> save({
    required int xp,
    required int streak,
    required int hearts,
    required bool isPremium,
    required String? lastHeartLossAt,
    required String? lastLessonDate,
    required bool hasSeenOnboarding,
    required Map<String, bool> lessonCompleted,
    String? lastLessonId,
    required String nickname,
    required String avatarEmoji,
    required Set<String> unlockedAchievements,
    required Map<String, int> dailyTasks,
    required String lastActiveDate,
    required int consecutiveCorrect,
    required int dailyXpEarned,
    required List<String> wrongAnswersJsonList,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, xp);
    await prefs.setInt(_streakKey, streak);
    await prefs.setInt(_heartsKey, hearts);
    await prefs.setBool(_premiumKey, isPremium);
    await prefs.setBool(_onboardingKey, hasSeenOnboarding);
    await prefs.setString(_lessonsKey, jsonEncode(lessonCompleted));

    if (lastHeartLossAt == null) {
      await prefs.remove(_lastHeartLossAtKey);
    } else {
      await prefs.setString(_lastHeartLossAtKey, lastHeartLossAt);
    }

    if (lastLessonDate == null) {
      await prefs.remove(_lastLessonDateKey);
    } else {
      await prefs.setString(_lastLessonDateKey, lastLessonDate);
    }

    if (lastLessonId == null) {
      await prefs.remove(_lastLessonIdKey);
    } else {
      await prefs.setString(_lastLessonIdKey, lastLessonId);
    }

    await prefs.setString(_nicknameKey, nickname);
    await prefs.setString(_avatarKey, avatarEmoji);
    await prefs.setStringList(_achievementsKey, unlockedAchievements.toList());
    await prefs.setString(_dailyTasksKey, jsonEncode(dailyTasks));
    await prefs.setString(_lastActiveDateKey, lastActiveDate);
    await prefs.setInt(_consecutiveCorrectKey, consecutiveCorrect);
    await prefs.setInt(_dailyXpEarnedKey, dailyXpEarned);
    await prefs.setStringList(_wrongAnswersKey, wrongAnswersJsonList);
  }
}
