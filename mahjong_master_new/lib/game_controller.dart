import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models/curriculum_data.dart';
import 'services/progress_storage.dart';

class GameController extends ChangeNotifier {
  GameController(this._storage);

  final ProgressStorage _storage;

  int _xp = 0;
  int _hearts = 5;
  int _streak = 0;
  String? _currentLessonId;
  int _dialogueIndex = 0;
  int _questionIndex = 0;
  final Map<String, bool> _lessonCompleted = {};
  String? _lastHeartRefillDate;
  bool _onboardingSeen = false;
  String? _dailyDoneDate;
  int _dailyDoneCount = 0;
  final List<String> _analyticsEvents = [];
  String? _seenReleaseNoteVersion;
  bool _demoModeEnabled = false;
  bool _ready = false;

  bool get ready => _ready;
  int get xp => _xp;
  int get hearts => _hearts;
  int get streak => _streak;
  String? get currentLessonId => _currentLessonId;
  int get dialogueIndex => _dialogueIndex;
  int get questionIndex => _questionIndex;
  Map<String, bool> get lessonCompleted => Map<String, bool>.from(_lessonCompleted);
  bool get onboardingSeen => _onboardingSeen;

  int get dailyGoal => 3;
  int get dailyDoneCount => _dailyDoneCount;
  bool get hasActiveLesson => _currentLessonId != null;
  bool get outOfHearts => _hearts <= 0;
  List<String> get analyticsEvents => List<String>.from(_analyticsEvents);
  String? get seenReleaseNoteVersion => _seenReleaseNoteVersion;
  bool get demoModeEnabled => _demoModeEnabled;

  String get todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  double get dailyProgress => (_dailyDoneCount / dailyGoal).clamp(0.0, 1.0);

  CursorLesson? get currentLesson {
    final id = _currentLessonId;
    if (id == null) return null;
    for (final lesson in cursorLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  Future<void> load() async {
    final saved = await _storage.load();
    if (saved != null) {
      _xp = saved.xp;
      _hearts = saved.hearts;
      _streak = saved.streak;
      _currentLessonId = saved.currentLessonId;
      _dialogueIndex = saved.dialogueIndex;
      _questionIndex = saved.questionIndex;
      _lessonCompleted
        ..clear()
        ..addAll(saved.lessonCompleted);
      _lastHeartRefillDate = saved.lastHeartRefillDate;
      _onboardingSeen = saved.onboardingSeen;
      _dailyDoneDate = saved.dailyDoneDate;
      _dailyDoneCount = saved.dailyDoneCount;
      _analyticsEvents
        ..clear()
        ..addAll(saved.analyticsEvents);
      _seenReleaseNoteVersion = saved.seenReleaseNoteVersion;
      _demoModeEnabled = saved.demoModeEnabled;
    }
    _applyDailyHeartRefill();
    _ensureDailyCounter();
    _ready = true;
    notifyListeners();
  }

  bool isLessonUnlocked(CursorLesson lesson) {
    if (_demoModeEnabled) return true;
    if (lesson.id == '1-1') return true;
    final idx = cursorLessons.indexWhere((l) => l.id == lesson.id);
    if (idx <= 0) return true;
    final prev = cursorLessons[idx - 1];
    return _lessonCompleted[prev.id] == true;
  }

  void startLesson(String lessonId) {
    _currentLessonId = lessonId;
    _dialogueIndex = 0;
    _questionIndex = 0;
    _logEvent('lesson_start:$lessonId');
    _persist();
    notifyListeners();
  }

  void advanceDialogue() {
    final lesson = currentLesson;
    if (lesson == null) return;
    if (_dialogueIndex < lesson.dialogue.length - 1) {
      _dialogueIndex += 1;
      _persist();
      notifyListeners();
    }
  }

  bool get isDialogueDone {
    final lesson = currentLesson;
    if (lesson == null) return true;
    return _dialogueIndex >= lesson.dialogue.length - 1;
  }

  bool get isQuizDone {
    final lesson = currentLesson;
    if (lesson == null) return true;
    return _questionIndex >= lesson.questions.length;
  }

  CursorQuizQuestion? get currentQuestion {
    final lesson = currentLesson;
    if (lesson == null) return null;
    if (_questionIndex < 0 || _questionIndex >= lesson.questions.length) return null;
    return lesson.questions[_questionIndex];
  }

  int get questionCount {
    final lesson = currentLesson;
    if (lesson == null) return 0;
    return lesson.questions.length;
  }

  double lessonProgress(String lessonId) {
    CursorLesson? lesson;
    for (final l in cursorLessons) {
      if (l.id == lessonId) {
        lesson = l;
        break;
      }
    }
    if (lesson == null || lesson.questions.isEmpty) return 0;
    if (_lessonCompleted[lessonId] == true) return 1;
    if (_currentLessonId != lessonId) return 0;
    return (_questionIndex / lesson.questions.length).clamp(0.0, 1.0);
  }

  double stageProgress(String stageId) {
    final lessons = cursorLessons.where((l) => l.stageId == stageId).toList();
    if (lessons.isEmpty) return 0;
    final done = lessons.where((l) => _lessonCompleted[l.id] == true).length;
    return done / lessons.length;
  }

  bool answer(int selectedIndex) {
    final q = currentQuestion;
    if (q == null) return false;
    if (outOfHearts) return false;
    final ok = selectedIndex == q.correctIndex;
    if (ok) {
      _xp += 10;
      _questionIndex += 1;
      _logEvent('answer_correct:${q.question}');
      if (isQuizDone) {
        _completeCurrentLesson();
      }
    } else {
      if (_hearts > 0) _hearts -= 1;
      _logEvent('answer_wrong:${q.question}');
    }
    _persist();
    notifyListeners();
    return ok;
  }

  void _completeCurrentLesson() {
    final id = _currentLessonId;
    if (id == null) return;
    final isFirstCompletion = _lessonCompleted[id] != true;
    _lessonCompleted[id] = true;
    _streak += 1;
    if (isFirstCompletion) {
      _ensureDailyCounter();
      _dailyDoneCount += 1;
      _logEvent('lesson_complete:$id');
    }
  }

  void leaveLesson() {
    final id = _currentLessonId;
    _currentLessonId = null;
    _dialogueIndex = 0;
    _questionIndex = 0;
    if (id != null) _logEvent('lesson_leave:$id');
    _persist();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _xp = 0;
    _hearts = 5;
    _streak = 0;
    _currentLessonId = null;
    _dialogueIndex = 0;
    _questionIndex = 0;
    _lessonCompleted.clear();
    _lastHeartRefillDate = null;
    _onboardingSeen = false;
    _dailyDoneDate = null;
    _dailyDoneCount = 0;
    _analyticsEvents.clear();
    _seenReleaseNoteVersion = null;
    _demoModeEnabled = false;
    await _storage.clearAll();
    _applyDailyHeartRefill();
    _ensureDailyCounter();
    notifyListeners();
  }

  void setDemoMode(bool enabled) {
    _demoModeEnabled = enabled;
    if (enabled) {
      for (final lesson in cursorLessons) {
        _lessonCompleted[lesson.id] = true;
      }
      _logEvent('demo_mode_enabled');
    } else {
      _logEvent('demo_mode_disabled');
    }
    _persist();
    notifyListeners();
  }

  void markReleaseNoteSeen(String version) {
    _seenReleaseNoteVersion = version;
    _logEvent('release_note_seen:$version');
    _persist();
    notifyListeners();
  }

  void markOnboardingSeen() {
    if (_onboardingSeen) return;
    _onboardingSeen = true;
    _logEvent('onboarding_seen');
    _persist();
    notifyListeners();
  }

  String exportProgressJson() {
    final data = <String, dynamic>{
      'xp': _xp,
      'hearts': _hearts,
      'streak': _streak,
      'currentLessonId': _currentLessonId,
      'dialogueIndex': _dialogueIndex,
      'questionIndex': _questionIndex,
      'lessonCompleted': _lessonCompleted,
      'lastHeartRefillDate': _lastHeartRefillDate,
      'onboardingSeen': _onboardingSeen,
      'dailyDoneDate': _dailyDoneDate,
      'dailyDoneCount': _dailyDoneCount,
      'analyticsEvents': _analyticsEvents,
      'seenReleaseNoteVersion': _seenReleaseNoteVersion,
      'demoModeEnabled': _demoModeEnabled,
    };
    return jsonEncode(data);
  }

  bool importProgressJson(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _xp = (map['xp'] as num?)?.toInt() ?? 0;
      _hearts = (map['hearts'] as num?)?.toInt() ?? 5;
      _streak = (map['streak'] as num?)?.toInt() ?? 0;
      _currentLessonId = map['currentLessonId'] as String?;
      _dialogueIndex = (map['dialogueIndex'] as num?)?.toInt() ?? 0;
      _questionIndex = (map['questionIndex'] as num?)?.toInt() ?? 0;
      _lastHeartRefillDate = map['lastHeartRefillDate'] as String?;
      _onboardingSeen = map['onboardingSeen'] == true;
      _dailyDoneDate = map['dailyDoneDate'] as String?;
      _dailyDoneCount = (map['dailyDoneCount'] as num?)?.toInt() ?? 0;
      _seenReleaseNoteVersion = map['seenReleaseNoteVersion'] as String?;
      _demoModeEnabled = map['demoModeEnabled'] == true;

      final completedRaw = map['lessonCompleted'];
      _lessonCompleted.clear();
      if (completedRaw is Map) {
        completedRaw.forEach((key, value) {
          _lessonCompleted['$key'] = value == true;
        });
      }
      _analyticsEvents.clear();
      final analyticsRaw = map['analyticsEvents'];
      if (analyticsRaw is List) {
        for (final item in analyticsRaw) {
          _analyticsEvents.add('$item');
        }
      }

      _applyDailyHeartRefill();
      _ensureDailyCounter();
      _persist();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persist() {
    return _storage.save(
      xp: _xp,
      hearts: _hearts,
      streak: _streak,
      currentLessonId: _currentLessonId,
      dialogueIndex: _dialogueIndex,
      questionIndex: _questionIndex,
      lessonCompleted: _lessonCompleted,
      lastHeartRefillDate: _lastHeartRefillDate,
      onboardingSeen: _onboardingSeen,
      dailyDoneDate: _dailyDoneDate,
      dailyDoneCount: _dailyDoneCount,
      analyticsEvents: _analyticsEvents,
      seenReleaseNoteVersion: _seenReleaseNoteVersion,
      demoModeEnabled: _demoModeEnabled,
    );
  }

  void _applyDailyHeartRefill() {
    final today = todayKey;
    if (_lastHeartRefillDate != today) {
      _hearts = 5;
      _lastHeartRefillDate = today;
    }
  }

  void _ensureDailyCounter() {
    final today = todayKey;
    if (_dailyDoneDate != today) {
      _dailyDoneDate = today;
      _dailyDoneCount = 0;
    }
  }

  void _logEvent(String event) {
    final ts = DateTime.now().toIso8601String();
    _analyticsEvents.add('$ts | $event');
    if (_analyticsEvents.length > 200) {
      _analyticsEvents.removeRange(0, _analyticsEvents.length - 200);
    }
  }
}
