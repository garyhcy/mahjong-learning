import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_data.dart';

/// Manages Find a Match (約戰) preferences and weekly quota.
///
/// Demo scope: language + day/time preferences and quota logic are REAL and
/// persisted. Opponent pool, venues, and chat are simulated locally.
///
/// Quota rules (free players):
/// - 1 scheduled game per week.
/// - The weekly opportunity is consumed by EITHER 1 confirmed reservation
///   OR 3 failed scheduling attempts.
/// - Pro players are unlimited.
class MatchState extends ChangeNotifier {
  static const String _langKey = 'match_language';
  static const String _langChosenKey = 'match_language_chosen';
  static const String _daysKey = 'match_days';
  static const String _timesKey = 'match_times';
  static const String _noTimePrefKey = 'match_no_time_pref';
  static const String _weekKey = 'match_week_id';
  static const String _confirmedKey = 'match_confirmed_this_week';
  static const String _failedKey = 'match_failed_attempts';

  static const int maxFailedAttempts = 3;

  AppLanguage _language = AppLanguage.cantonese;
  bool _languageChosen = false;
  final Set<DayPref> _days = {};
  final Set<TimeBand> _times = {};
  bool _noTimePref = true;

  String _weekId = '';
  bool _confirmedThisWeek = false;
  int _failedAttempts = 0;

  bool _isPremium = false;
  bool _isLoaded = false;

  // ── Getters ──
  AppLanguage get language => _language;
  bool get languageChosen => _languageChosen;
  Set<DayPref> get days => _days;
  Set<TimeBand> get times => _times;
  bool get noTimePref => _noTimePref;
  bool get isLoaded => _isLoaded;
  bool get isPremium => _isPremium;

  bool get confirmedThisWeek => _confirmedThisWeek;
  int get failedAttempts => _failedAttempts;

  /// Whether the free player still has their weekly match opportunity.
  bool get hasWeeklyOpportunity {
    if (_isPremium) return true;
    if (_confirmedThisWeek) return false;
    if (_failedAttempts >= maxFailedAttempts) return false;
    return true;
  }

  int get failedRemaining =>
      (maxFailedAttempts - _failedAttempts).clamp(0, maxFailedAttempts);

  /// ISO week identifier, e.g. "2026-W27".
  static String _currentWeekId([DateTime? now]) {
    final d = now ?? DateTime.now();
    final dayOfYear = int.parse(
        ((d.difference(DateTime(d.year, 1, 1)).inDays) + 1).toString());
    final week = ((dayOfYear - d.weekday + 10) ~/ 7);
    return '${d.year}-W$week';
  }

  Future<void> load({bool isPremium = false}) async {
    _isPremium = isPremium;
    final prefs = await SharedPreferences.getInstance();

    _language = AppLanguageInfo.fromKey(prefs.getString(_langKey));
    _languageChosen = prefs.getBool(_langChosenKey) ?? false;

    _days
      ..clear()
      ..addAll((prefs.getStringList(_daysKey) ?? [])
          .map((s) => DayPref.values.firstWhere((d) => d.name == s,
              orElse: () => DayPref.sat)));
    _times
      ..clear()
      ..addAll((prefs.getStringList(_timesKey) ?? [])
          .map((s) => TimeBand.values.firstWhere((t) => t.name == s,
              orElse: () => TimeBand.evening)));
    _noTimePref = prefs.getBool(_noTimePrefKey) ?? true;

    // Reset weekly quota if the ISO week changed.
    final storedWeek = prefs.getString(_weekKey) ?? '';
    _weekId = _currentWeekId();
    if (storedWeek != _weekId) {
      _confirmedThisWeek = false;
      _failedAttempts = 0;
      await prefs.setString(_weekKey, _weekId);
      await prefs.setBool(_confirmedKey, false);
      await prefs.setInt(_failedKey, 0);
    } else {
      _confirmedThisWeek = prefs.getBool(_confirmedKey) ?? false;
      _failedAttempts = prefs.getInt(_failedKey) ?? 0;
    }

    _isLoaded = true;
    notifyListeners();
  }

  void updatePremium(bool isPremium) {
    if (_isPremium == isPremium) return;
    _isPremium = isPremium;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang, {bool markChosen = true}) async {
    _language = lang;
    if (markChosen) _languageChosen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang.key);
    if (markChosen) await prefs.setBool(_langChosenKey, true);
    notifyListeners();
  }

  Future<void> toggleDay(DayPref day) async {
    if (_days.contains(day)) {
      _days.remove(day);
    } else {
      _days.add(day);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_daysKey, _days.map((d) => d.name).toList());
    notifyListeners();
  }

  Future<void> setNoTimePref(bool value) async {
    _noTimePref = value;
    if (value) _times.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_noTimePrefKey, value);
    await prefs.setStringList(_timesKey, _times.map((t) => t.name).toList());
    notifyListeners();
  }

  Future<void> toggleTime(TimeBand band) async {
    if (_times.contains(band)) {
      _times.remove(band);
    } else {
      _times.add(band);
      _noTimePref = false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_timesKey, _times.map((t) => t.name).toList());
    await prefs.setBool(_noTimePrefKey, _noTimePref);
    notifyListeners();
  }

  /// Record a confirmed reservation — consumes the weekly opportunity.
  Future<void> recordConfirmedReservation() async {
    _confirmedThisWeek = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_confirmedKey, true);
    notifyListeners();
  }

  /// Record a failed scheduling attempt. 3 failures consume the week.
  Future<void> recordFailedAttempt() async {
    _failedAttempts = (_failedAttempts + 1).clamp(0, maxFailedAttempts);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_failedKey, _failedAttempts);
    notifyListeners();
  }

  /// Demo helper: reset this week's quota (for repeated investor walk-throughs).
  Future<void> resetWeeklyQuotaForDemo() async {
    _confirmedThisWeek = false;
    _failedAttempts = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_confirmedKey, false);
    await prefs.setInt(_failedKey, 0);
    notifyListeners();
  }
}
