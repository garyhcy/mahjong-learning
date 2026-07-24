import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community/leaderboard_entry.dart';
import '../utils/sort_utils.dart';
import 'firebase_service.dart';

/// Builds the merged leaderboard entries used by both the inline region
/// leaderboard (community_screen.dart) and the full leaderboard page
/// (all_leaderboard_page.dart).
///
/// Combines real Firestore players + locally-generated fake players + the
/// current user (if not already present in [realDocs]), then sorts by XP
/// descending and assigns ranks starting at 1.
///
/// [myPlayerId] is the current user's player id. Pass an empty string only
/// when the caller genuinely has no player id; otherwise always pass the real
/// id so the merged entry can be correlated.
List<LeaderboardEntry> buildLeaderboardEntries({
  required List<QueryDocumentSnapshot> realDocs,
  required List<Map<String, dynamic>> fakes,
  required String uid,
  required String nickname,
  required String avatarEmoji,
  required int userXp,
  required String myPlayerId,
}) {
  final merged = <LeaderboardEntry>[];
  bool meIncluded = false;

  for (final doc in realDocs) {
    final d = doc.data() as Map<String, dynamic>;
    final isMe = doc.id == uid;
    if (isMe) meIncluded = true;
    merged.add(LeaderboardEntry(
      rank: 0,
      name: (d['nickname'] as String?) ?? 'Player',
      avatar: (d['avatarEmoji'] as String?) ?? '🐼',
      xp: (d['xp'] as num?)?.toInt() ?? 0,
      streak: (d['streak'] as num?)?.toInt() ?? 0,
      isCurrentUser: isMe,
      playerId: (d['playerId'] as String?) ?? '',
      skillRating: ((d['xp'] as num?)?.toInt() ?? 0) ~/ 40,
    ));
  }

  for (final f in fakes) {
    merged.add(LeaderboardEntry(
      rank: 0,
      name: (f['nickname'] as String?) ?? 'Player',
      avatar: (f['avatarEmoji'] as String?) ?? '🐼',
      xp: (f['xp'] as num?)?.toInt() ?? 0,
      streak: (f['streak'] as num?)?.toInt() ?? 0,
      isCurrentUser: false,
      playerId: (f['playerId'] as String?) ?? '',
      skillRating: ((f['xp'] as num?)?.toInt() ?? 0) ~/ 40,
    ));
  }

  if (!meIncluded) {
    merged.add(LeaderboardEntry(
      rank: 0,
      name: nickname,
      avatar: avatarEmoji,
      xp: userXp,
      isCurrentUser: true,
      playerId: myPlayerId,
      skillRating: userXp ~/ 40,
    ));
  }

  sortLeaderboard(merged);

  final entries = <LeaderboardEntry>[];
  for (int i = 0; i < merged.length; i++) {
    final e = merged[i];
    entries.add(LeaderboardEntry(
      rank: i + 1,
      name: e.name,
      avatar: e.avatar,
      xp: e.xp,
      streak: e.streak,
      isCurrentUser: e.isCurrentUser,
      playerId: e.playerId,
      skillRating: e.skillRating,
    ));
  }
  return entries;
}

/// Generates fake players for a region and builds the merged leaderboard in
/// one call. Returns an empty list only if there are no entries at all
/// (real + fake + self); callers should treat an empty list as "no data".
///
/// Convenience wrapper used by both leaderboard surfaces.
List<LeaderboardEntry> generateAndMergeLeaderboard({
  required String region,
  required List<QueryDocumentSnapshot> realDocs,
  required String uid,
  required String nickname,
  required String avatarEmoji,
  required int userXp,
  required String myPlayerId,
}) {
  final realNicknames = realDocs
      .map((d) =>
          ((d.data() as Map<String, dynamic>)['nickname'] as String?) ?? '')
      .toList();
  final fakes = FirebaseService.generateLocalFakePlayers(region,
      count: 6, realNicknames: realNicknames);
  return buildLeaderboardEntries(
    realDocs: realDocs,
    fakes: fakes,
    uid: uid,
    nickname: nickname,
    avatarEmoji: avatarEmoji,
    userXp: userXp,
    myPlayerId: myPlayerId,
  );
}
