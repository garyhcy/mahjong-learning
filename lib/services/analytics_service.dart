import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Thin, failure-tolerant wrapper around Firebase Analytics.
///
/// The app must keep working when Firebase is not configured (local/dev),
/// so every method is a no-op until [init] succeeds. Never log email, name
/// or any other directly identifying value here.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _enabled = false;

  bool get enabled => _enabled;

  Future<void> init() async {
    if (Firebase.apps.isEmpty) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      _enabled = true;
    } catch (error) {
      debugPrint('Analytics disabled: $error');
      _analytics = null;
      _enabled = false;
    }
  }

  void log(String name, [Map<String, Object>? parameters]) {
    final analytics = _analytics;
    if (!_enabled || analytics == null) return;
    analytics.logEvent(name: name, parameters: parameters).catchError((
      Object error,
    ) {
      debugPrint('Analytics event $name failed: $error');
    });
  }

  void screen(String name) {
    final analytics = _analytics;
    if (!_enabled || analytics == null) return;
    analytics.logScreenView(screenName: name).catchError((Object error) {
      debugPrint('Analytics screen $name failed: $error');
    });
  }

  Future<void> setUserProperties({
    String? language,
    bool? isPro,
    String? stage,
    int? streak,
  }) async {
    final analytics = _analytics;
    if (!_enabled || analytics == null) return;
    try {
      if (language != null) {
        await analytics.setUserProperty(
          name: 'display_language',
          value: language,
        );
      }
      if (isPro != null) {
        await analytics.setUserProperty(
          name: 'is_pro',
          value: isPro ? 'true' : 'false',
        );
      }
      if (stage != null) {
        await analytics.setUserProperty(name: 'current_stage', value: stage);
      }
      if (streak != null) {
        await analytics.setUserProperty(name: 'streak', value: '$streak');
      }
    } catch (error) {
      debugPrint('Analytics user properties failed: $error');
    }
  }
}
