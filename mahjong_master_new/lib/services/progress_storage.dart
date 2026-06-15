import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_model.dart';

class ProgressStorage {
  static const _xpKey = 'xp';
  static const _heartsKey = 'hearts';
  static const _streakKey = 'streak';
  static const _currentLessonIdKey = 'currentLessonId';
  static const _dialogueIndexKey = 'dialogueIndex';
  static const _questionIndexKey = 'questionIndex';
  static const _completedKey = 'lessonCompleted';
  static const _lastHeartRefillDateKey = 'lastHeartRefillDate';
  static const _onboardingSeenKey = 'onboardingSeen';
  static const _dailyDoneDateKey = 'dailyDoneDate';
  static const _dailyDoneCountKey = 'dailyDoneCount';
  static const _analyticsEventsKey = 'analyticsEvents';
  static const _seenReleaseNoteVersionKey = 'seenReleaseNoteVersion';
  static const _demoModeEnabledKey = 'demoModeEnabled';

  Future<SavedProgress?> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_xpKey)) {
      return null;
    }

    final rawMap = prefs.getString(_completedKey);
    final decoded = rawMap == null ? <String, dynamic>{} : jsonDecode(rawMap) as Map<String, dynamic>;

    return SavedProgress(
      xp: prefs.getInt(_xpKey) ?? 0,
      hearts: prefs.getInt(_heartsKey) ?? 5,
      streak: prefs.getInt(_streakKey) ?? 0,
      currentLessonId: prefs.getString(_currentLessonIdKey),
      dialogueIndex: prefs.getInt(_dialogueIndexKey) ?? 0,
      questionIndex: prefs.getInt(_questionIndexKey) ?? 0,
      lessonCompleted: decoded.map((key, value) => MapEntry(key, value == true)),
      lastHeartRefillDate: prefs.getString(_lastHeartRefillDateKey),
      onboardingSeen: prefs.getBool(_onboardingSeenKey) ?? false,
      dailyDoneDate: prefs.getString(_dailyDoneDateKey),
      dailyDoneCount: prefs.getInt(_dailyDoneCountKey) ?? 0,
      analyticsEvents: prefs.getStringList(_analyticsEventsKey) ?? const [],
      seenReleaseNoteVersion: prefs.getString(_seenReleaseNoteVersionKey),
      demoModeEnabled: prefs.getBool(_demoModeEnabledKey) ?? false,
    );
  }

  Future<void> save({
    required int xp,
    required int hearts,
    required int streak,
    required String? currentLessonId,
    required int dialogueIndex,
    required int questionIndex,
    required Map<String, bool> lessonCompleted,
    required String? lastHeartRefillDate,
    required bool onboardingSeen,
    required String? dailyDoneDate,
    required int dailyDoneCount,
    required List<String> analyticsEvents,
    required String? seenReleaseNoteVersion,
    required bool demoModeEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, xp);
    await prefs.setInt(_heartsKey, hearts);
    await prefs.setInt(_streakKey, streak);

    if (currentLessonId == null) {
      await prefs.remove(_currentLessonIdKey);
    } else {
      await prefs.setString(_currentLessonIdKey, currentLessonId);
    }

    await prefs.setInt(_dialogueIndexKey, dialogueIndex);
    await prefs.setInt(_questionIndexKey, questionIndex);
    await prefs.setString(_completedKey, jsonEncode(lessonCompleted));
    await prefs.setBool(_onboardingSeenKey, onboardingSeen);
    await prefs.setInt(_dailyDoneCountKey, dailyDoneCount);
    await prefs.setStringList(_analyticsEventsKey, analyticsEvents);
    if (seenReleaseNoteVersion == null) {
      await prefs.remove(_seenReleaseNoteVersionKey);
    } else {
      await prefs.setString(_seenReleaseNoteVersionKey, seenReleaseNoteVersion);
    }
    await prefs.setBool(_demoModeEnabledKey, demoModeEnabled);

    if (lastHeartRefillDate == null) {
      await prefs.remove(_lastHeartRefillDateKey);
    } else {
      await prefs.setString(_lastHeartRefillDateKey, lastHeartRefillDate);
    }

    if (dailyDoneDate == null) {
      await prefs.remove(_dailyDoneDateKey);
    } else {
      await prefs.setString(_dailyDoneDateKey, dailyDoneDate);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_xpKey);
    await prefs.remove(_heartsKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_currentLessonIdKey);
    await prefs.remove(_dialogueIndexKey);
    await prefs.remove(_questionIndexKey);
    await prefs.remove(_completedKey);
    await prefs.remove(_lastHeartRefillDateKey);
    await prefs.remove(_onboardingSeenKey);
    await prefs.remove(_dailyDoneDateKey);
    await prefs.remove(_dailyDoneCountKey);
    await prefs.remove(_analyticsEventsKey);
    await prefs.remove(_seenReleaseNoteVersionKey);
    await prefs.remove(_demoModeEnabledKey);
  }
}
