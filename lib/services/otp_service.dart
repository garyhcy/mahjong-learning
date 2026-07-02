import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// OTP verification service.
///
/// Two modes:
/// - Firebase mode: stores OTP in Firestore `email_otps` collection with TTL.
///   Email sending is deferred (currently surfaced via [lastGeneratedOtp] for
///   testing). Production should wire a Cloud Function / extension to send.
/// - Demo mode (Firebase unavailable): stores OTP in SharedPreferences and
///   exposes it via [lastGeneratedOtp] so the UI can show it for testing.
class OtpService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The most recently generated OTP (used by UI to display in demo/test mode).
  static String? lastGeneratedOtp;

  static String _generate() {
    final rnd = Random.secure();
    final code = List<int>.generate(
      6,
      (_) => rnd.nextInt(10),
    ).join();
    lastGeneratedOtp = code;
    return code;
  }

  /// Generate + store an OTP for [email]. Returns the OTP code.
  static Future<String> generateAndStore(String email) async {
    final code = _generate();
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 10));

    // Always persist locally so demo mode + Firebase-fallback can verify.
    final sp = await SharedPreferences.getInstance();
    await sp.setString('otp_email', email);
    await sp.setString('otp_code', code);
    await sp.setInt('otp_generated_at', now.millisecondsSinceEpoch);
    await sp.setInt('otp_expires_at', expiresAt.millisecondsSinceEpoch);
    await sp.setInt('otp_attempts', 0);

    // Also store in Firestore if Firebase is available (for real clients).
    try {
      await _firestore.collection('email_otps').doc(email).set({
        'email': email,
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'attempts': 0,
        'verified': false,
      });
    } catch (_) {
      // Firebase unavailable — local-only is fine for demo.
    }

    return code;
  }

  /// Verify the OTP entered by the user. Returns:
  /// - `OtpResult.success` on match
  /// - `OtpResult.expired` if past TTL
  /// - `OtpResult.invalid` if wrong code
  /// - `OtpResult.tooManyAttempts` after 5 wrong tries
  static Future<OtpResult> verify(String email, String code) async {
    final sp = await SharedPreferences.getInstance();
    final storedEmail = sp.getString('otp_email');
    final storedCode = sp.getString('otp_code');
    final expiresAt = sp.getInt('otp_expires_at');
    final attempts = sp.getInt('otp_attempts') ?? 0;

    if (storedEmail != email) {
      return OtpResult.invalid;
    }

    if (expiresAt != null &&
        DateTime.now().millisecondsSinceEpoch > expiresAt) {
      return OtpResult.expired;
    }

    if (attempts >= 5) {
      return OtpResult.tooManyAttempts;
    }

    if (storedCode != code) {
      await sp.setInt('otp_attempts', attempts + 1);
      // Also reflect attempts to Firestore if available.
      try {
        await _firestore.collection('email_otps').doc(email).update({
          'attempts': attempts + 1,
        });
      } catch (_) {}
      return OtpResult.invalid;
    }

    // Success — mark verified.
    await sp.setBool('otp_verified_$email', true);
    try {
      await _firestore.collection('email_otps').doc(email).update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    // Also trigger Firebase email verification if a user exists, so that
    // Firebase's own emailVerified flag also becomes true after the user
    // clicks the link. This is a best-effort no-op in demo mode.
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (_) {}

    return OtpResult.success;
  }

  /// Resend a fresh OTP for [email].
  static Future<String> resend(String email) async {
    return generateAndStore(email);
  }

  /// Clear stored OTP state (after successful registration or cancellation).
  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('otp_email');
    await sp.remove('otp_code');
    await sp.remove('otp_generated_at');
    await sp.remove('otp_expires_at');
    await sp.remove('otp_attempts');
    lastGeneratedOtp = null;
  }
}

enum OtpResult {
  success,
  invalid,
  expired,
  tooManyAttempts,
}
