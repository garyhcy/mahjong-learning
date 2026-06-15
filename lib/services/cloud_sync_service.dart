import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'progress_storage.dart';

class CloudSyncService {
  Future<bool> isAvailable() async {
    try {
      if (Firebase.apps.isEmpty) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> ensureAnonymousUser() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        return auth.currentUser!.uid;
      }
      final credential = await auth.signInAnonymously();
      return credential.user?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<SavedProgress?> load(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('app')
          .doc('progress')
          .get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;

      final lessons = <String, bool>{};
      final rawLessons = data['lessonCompleted'];
      if (rawLessons is Map<String, dynamic>) {
        rawLessons.forEach((key, value) {
          lessons[key] = value == true;
        });
      }

      return SavedProgress(
        xp: (data['xp'] as num?)?.toInt() ?? 0,
        streak: (data['streak'] as num?)?.toInt() ?? 0,
        hearts: (data['hearts'] as num?)?.toInt() ?? 3,
        isPremium: data['isPremium'] == true,
        lastHeartLossAt: data['lastHeartLossAt'] as String?,
        lastLessonDate: data['lastLessonDate'] as String?,
        hasSeenOnboarding: data['hasSeenOnboarding'] == true,
        lessonCompleted: lessons,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required String uid,
    required int xp,
    required int streak,
    required int hearts,
    required bool isPremium,
    required String? lastHeartLossAt,
    required String? lastLessonDate,
    required bool hasSeenOnboarding,
    required Map<String, bool> lessonCompleted,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('app')
          .doc('progress')
          .set({
        'xp': xp,
        'streak': streak,
        'hearts': hearts,
        'isPremium': isPremium,
        'lastHeartLossAt': lastHeartLossAt,
        'lastLessonDate': lastLessonDate,
        'hasSeenOnboarding': hasSeenOnboarding,
        'lessonCompleted': lessonCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Keep silent; local storage remains source of truth.
    }
  }
}
