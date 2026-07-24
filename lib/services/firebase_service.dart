import 'dart:math';
import 'fake_players.dart';
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

  static Future<String> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final code = await OtpService.generateAndStore(email);
    return code;
  }

  static Future<String> resendOtp(String email) async {
    return OtpService.resend(email);
  }

  static Future<OtpResult> verifyOtp(String email, String code) async {
    return OtpService.verify(email, code);
  }

  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
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

  // ── Player ID ──
  static String generatePlayerId() {
    const chars = '0123456789';
    final random = Random();
    final code = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return 'LD$code';
  }

  static Future<void> savePlayerId(String uid, String playerId) async {
    await _firestore.collection('users').doc(uid).set({
      'playerId': playerId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<String?> getPlayerId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['playerId'] as String?;
  }

  static Future<Map<String, dynamic>?> getUserByPlayerId(String playerId) async {
    final query = await _firestore.collection('users').where('playerId', isEqualTo: playerId).limit(1).get();
    if (query.docs.isEmpty) return null;
    return {'uid': query.docs.first.id, ...query.docs.first.data()!};
  }

  // ── Region ──
  /// 地區 leaderboard 所支援的固定地區列表。
  /// 假玩家採本地合併（generateLocalFakePlayers），不寫 Firestore，
  /// leaderboard 查詢時與真實用戶在客戶端合併顯示。
  static const List<String> kSupportedRegions = [
    // Asia
    'HK', 'TW', 'CN', 'SG', 'MY', 'MO', 'JP', 'KR', 'TH', 'VN', 'ID', 'PH', 'IN',
    // North America
    'US', 'CA', 'MX',
    // Europe
    'GB', 'IE', 'DE', 'FR', 'IT', 'ES', 'NL', 'BE', 'SE', 'NO', 'DK', 'FI',
    'CH', 'AT', 'PT', 'PL', 'CZ', 'GR',
    // Oceania
    'AU', 'NZ',
    // South America
    'BR', 'AR',
  ];

  /// 地區代碼 -> 顯示名稱（App UI 全英文）。未知代碼 fallback 原值。
  static const Map<String, String> _regionNames = {
    'HK': 'Hong Kong',
    'TW': 'Taiwan',
    'CN': 'Mainland China',
    'SG': 'Singapore',
    'MY': 'Malaysia',
    'MO': 'Macau',
    'JP': 'Japan',
    'KR': 'South Korea',
    'TH': 'Thailand',
    'VN': 'Vietnam',
    'ID': 'Indonesia',
    'PH': 'Philippines',
    'IN': 'India',
    'US': 'United States',
    'CA': 'Canada',
    'MX': 'Mexico',
    'GB': 'United Kingdom',
    'IE': 'Ireland',
    'DE': 'Germany',
    'FR': 'France',
    'IT': 'Italy',
    'ES': 'Spain',
    'NL': 'Netherlands',
    'BE': 'Belgium',
    'SE': 'Sweden',
    'NO': 'Norway',
    'DK': 'Denmark',
    'FI': 'Finland',
    'CH': 'Switzerland',
    'AT': 'Austria',
    'PT': 'Portugal',
    'PL': 'Poland',
    'CZ': 'Czech Republic',
    'GR': 'Greece',
    'AU': 'Australia',
    'NZ': 'New Zealand',
    'BR': 'Brazil',
    'AR': 'Argentina',
  };

  static String getRegionDisplayName(String code) {
    return _regionNames[code] ?? code;
  }

  static Future<void> saveRegion(String uid, String region) async {
    await _firestore.collection('users').doc(uid).set({
      'region': region,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Friend System ──
  static Future<void> sendFriendRequest(String fromUid, String toPlayerId) async {
    final target = await getUserByPlayerId(toPlayerId);
    if (target == null) throw Exception('player_not_found');
    final targetUid = target['uid'] as String;
    if (targetUid == fromUid) throw Exception('cannot_add_self');

    final existing = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: fromUid)
        .where('to', isEqualTo: targetUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) throw Exception('request_already_sent');

    final reverse = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: targetUid)
        .where('to', isEqualTo: fromUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (reverse.docs.isNotEmpty) throw Exception('request_already_sent');

    await _firestore.collection('friend_requests').add({
      'from': fromUid,
      'to': targetUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> acceptFriendRequest(String requestId) async {
    final req = await _firestore.collection('friend_requests').doc(requestId).get();
    if (!req.exists) throw Exception('request_not_found');
    final data = req.data()!;
    final fromUid = data['from'] as String;
    final toUid = data['to'] as String;

    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(fromUid).collection('friends').doc(toUid), {
      'friendUid': toUid,
      'addedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('users').doc(toUid).collection('friends').doc(fromUid), {
      'friendUid': fromUid,
      'addedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('friend_requests').doc(requestId), {'status': 'accepted'});
    await batch.commit();
  }

  static Future<void> rejectFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).update({'status': 'rejected'});
  }

  static Stream<QuerySnapshot> getFriendRequests(String uid) {
    return _firestore
        .collection('friend_requests')
        .where('to', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  static Stream<QuerySnapshot> getFriends(String uid) {
    return _firestore.collection('users').doc(uid).collection('friends').snapshots();
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Leaderboard ──
  static Stream<QuerySnapshot> getLeaderboard() {
    return _firestore.collection('users').orderBy('xp', descending: true).limit(20).snapshots();
  }

  static Stream<QuerySnapshot> getRegionLeaderboard(String region) {
    return _firestore
        .collection('users')
        .where('region', isEqualTo: region)
        .orderBy('xp', descending: true)
        .limit(30)
        .snapshots();
  }

  /// 純本地生成假玩家資料（不寫 Firestore）。
  ///
  /// 每個 region 以 deterministic seed 產生 [count] 名假玩家，
  /// 名字與 XP 每區不同；XP 範圍 400–1200；過濾不雅字詞與
  /// 與真實玩家重複的名字。回傳已按 XP 降序排序的清單。
  ///
  /// 同一 region 每次呼叫結果相同（deterministic），不會跳動。
    /// 假玩家採本地合併，不寫 Firestore，deterministic，不跳動。
  /// 實作已抽至 [FakePlayers]；此處保留 thin wrapper 維持向後相容。
  static List<Map<String, dynamic>> generateLocalFakePlayers(
    String region, {
    int count = 6,
    List<String> realNicknames = const [],
  }) {
    return FakePlayers.generateLocalFakePlayers(
      region,
      count: count,
      realNicknames: realNicknames,
    );
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
}