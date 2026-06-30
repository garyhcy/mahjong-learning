import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_data.dart';

class PracticeState extends ChangeNotifier {
  static const int freeAttemptsPerDay = 3;
  static const String _resultsKey = 'practice_results';
  static const String _attemptsKey = 'practice_attempts_today';
  static const String _attemptDateKey = 'practice_attempt_date';
  static const String _speedBestKey = 'practice_speed_best';
  static const String _totalPracticesKey = 'practice_total_count';

  List<PracticeResult> _results = [];
  int _attemptsToday = 0;
  String _attemptDate = '';
  int _speedBest = 0;
  int _totalPractices = 0;
  bool _isPremium = false;
  bool _isLoaded = false;

  // Getters
  List<PracticeResult> get results => List.unmodifiable(_results);
  int get attemptsToday => _attemptsToday;
  int get attemptsRemaining =>
      _isPremium ? 999 : (freeAttemptsPerDay - _attemptsToday).clamp(0, freeAttemptsPerDay);
  bool get canPractice => _isPremium || _attemptsToday < freeAttemptsPerDay;
  int get speedBest => _speedBest;
  int get totalPractices => _totalPractices;
  bool get isLoaded => _isLoaded;
  bool get isPremiumFlag => _isPremium;

  WeaknessReport get weaknessReport => analyzeWeaknesses(_results);

  /// Get recent results for a specific drill type
  List<PracticeResult> getRecentResults(String drillType, {int limit = 10}) {
    return _results
        .where((r) => r.drillType == drillType)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Get overall accuracy for a drill type
  double getAccuracy(String drillType) {
    final drillResults = _results.where((r) => r.drillType == drillType).toList();
    if (drillResults.isEmpty) return 0;
    int total = 0;
    int correct = 0;
    for (final r in drillResults) {
      total += r.totalQuestions;
      correct += r.correctAnswers;
    }
    return total > 0 ? correct / total : 0;
  }

  /// Get average accuracy across all drills
  double get overallAccuracy {
    if (_results.isEmpty) return 0;
    int total = 0;
    int correct = 0;
    for (final r in _results) {
      total += r.totalQuestions;
      correct += r.correctAnswers;
    }
    return total > 0 ? correct / total : 0;
  }

  /// Get recommended practice based on weaknesses
  String? get recommendedDrill {
    if (_results.isEmpty) return null;
    final report = weaknessReport;
    if (report.weakestCategories.isEmpty && report.weakestTiles.isEmpty) {
      return null;
    }
    // If weak in tile recognition, recommend recognition
    if (report.weakestTiles.isNotEmpty) return 'recognition';
    // If weak in categories, recommend matching
    if (report.weakestCategories.isNotEmpty) return 'matching';
    return null;
  }

  // Load from storage
  Future<void> load({bool isPremium = false}) async {
    _isPremium = isPremium;
    final prefs = await SharedPreferences.getInstance();

    // Load results
    final resultsRaw = prefs.getStringList(_resultsKey);
    if (resultsRaw != null) {
      _results = resultsRaw.map((raw) {
        try {
          return PracticeResult.fromJson(jsonDecode(raw));
        } catch (_) {
          return null;
        }
      }).whereType<PracticeResult>().toList();
    }

    // Load daily attempts
    _attemptDate = prefs.getString(_attemptDateKey) ?? '';
    _attemptsToday = prefs.getInt(_attemptsKey) ?? 0;
    _speedBest = prefs.getInt(_speedBestKey) ?? 0;
    _totalPractices = prefs.getInt(_totalPracticesKey) ?? 0;

    // Reset if new day
    _checkDayReset();

    _isLoaded = true;
    notifyListeners();
  }

  void updatePremium(bool isPremium) {
    _isPremium = isPremium;
    notifyListeners();
  }

  void _checkDayReset() {
    final today = DateTime.now().toIso8601String().split('T').first;
    if (_attemptDate != today) {
      _attemptsToday = 0;
      _attemptDate = today;
    }
  }

  /// Record a practice attempt
  Future<void> recordResult(PracticeResult result) async {
    _checkDayReset();

    _results.add(result);
    _attemptsToday++;
    _totalPractices++;

    // Update speed best
    if (result.drillType == 'speed' && result.correctAnswers > _speedBest) {
      _speedBest = result.correctAnswers;
    }

    // Keep only last 100 results
    if (_results.length > 100) {
      _results = _results.sublist(_results.length - 100);
    }

    await _persist();
    notifyListeners();
  }

  /// Use an attempt (call before starting a drill)
  bool useAttempt() {
    _checkDayReset();
    if (!canPractice) return false;
    // Attempt is counted when result is recorded
    return true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = _results.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_resultsKey, resultsJson);
    await prefs.setString(_attemptDateKey, _attemptDate);
    await prefs.setInt(_attemptsKey, _attemptsToday);
    await prefs.setInt(_speedBestKey, _speedBest);
    await prefs.setInt(_totalPracticesKey, _totalPractices);
  }
}
