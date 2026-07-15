import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'otp_service.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Create the Firebase user + generate a 6-digit OTP.
  /// The caller must then verify the OTP via [OtpService.verify] before
  /// considering registration complete. Returns the generated OTP code
  /// (also accessible via [OtpService.lastGeneratedOtp]).
  static Future<String> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    // Generate + store 6-digit OTP (replaces legacy email-verification link).
    final code = await OtpService.generateAndStore(email);
    return code;
  }

  /// Resend OTP for the current pending registration.
  static Future<String> resendOtp(String email) async {
    return OtpService.resend(email);
  }

  /// Verify the 6-digit OTP entered by the user.
  static Future<OtpResult> verifyOtp(String email, String code) async {
    return OtpService.verify(email, code);
  }

  /// Reload current user to refresh emailVerified status.
  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Check if current user's email is verified.
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return await _auth.signInWithCredential(oauthCredential);
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Save/Load Progress
  static Future<void> saveProgress(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> loadProgress() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Leaderboard
  static Stream<QuerySnapshot> getLeaderboard() {
    return _firestore
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(20)
        .snapshots();
  }
}
