import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../services/leaderboard_merge.dart';
import '../../models/community/leaderboard_entry.dart';
import '../../services/app_i18n.dart';


// ═══════════════════════════════════════════════════════════════
// ─── All Leaderboard Page ───
// ═══════════════════════════════════════════════════════════════
class AllLeaderboardPage extends StatelessWidget {
  final int userXp;
  final String nickname;
  final String avatarEmoji;
  final String? uid;
  final String region;
  final String myPlayerId;

  const AllLeaderboardPage({
    required this.userXp,
    required this.nickname,
    required this.avatarEmoji,
    required this.uid,
    required this.region,
    required this.myPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppI18n.t('community.regionLeaderboard'),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
      ),
      body: uid == null
          ? Center(
              child: Text(AppI18n.t('community.noRegionPlayers'),
                  style: GoogleFonts.nunito(color: const Color(0xFF9E9E9E))),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getRegionLeaderboard(region),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50), strokeWidth: 2));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Load failed: \${snapshot.error}',
                          style: GoogleFonts.nunito(
                              fontSize: 13, color: Colors.redAccent)));
                }
                final docs = snapshot.data?.docs ?? [];
                // 過濾掉舊的 Firestore fake_ 文檔（本地合併後不再寫入，殘留者忽略）
                final realDocs =
                    docs.where((d) => !d.id.startsWith('fake_')).toList();
                // 合併真實玩家 + 假玩家 + 自己（共用 helper）
                final entries = generateAndMergeLeaderboard(
                  region: region,
                  realDocs: realDocs,
                  uid: uid ?? '',
                  nickname: nickname,
                  avatarEmoji: avatarEmoji,
                  userXp: userXp,
                  myPlayerId: myPlayerId,
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (entries.length >= 3) _buildPodium(entries),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: entries.map((e) => _fullRow(e)).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> entries) {
    final top3 = entries.take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumItem(top3[1], 70, const Color(0xFFC0C0C0)),
        const SizedBox(width: 8),
        _podiumItem(top3[0], 90, const Color(0xFFFFD700)),
        const SizedBox(width: 8),
        _podiumItem(top3[2], 55, const Color(0xFFCD7F32)),
      ],
    );
  }

  Widget _podiumItem(LeaderboardEntry entry, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
              child: Text(entry.avatar, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(height: 4),
        Text(entry.name,
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700)),
        Text('${entry.xp} XP',
            style: GoogleFonts.nunito(
                fontSize: 10, color: const Color(0xFF757575))),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text('${entry.rank}',
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          ),
        ),
      ],
    );
  }

  Widget _fullRow(LeaderboardEntry entry) {
    final isUser = entry.isCurrentUser;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFE8F5E9) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isUser
            ? Border.all(color: const Color(0xFF4CAF50).withAlpha(60))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${entry.rank}',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isUser
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF757575))),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color:
                  isUser ? const Color(0xFFC8E6C9) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(entry.avatar, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
                        color: const Color(0xFF2D2D2D))),
                if (entry.streak > 0)
                  Text('🔥 ${entry.streak} ${AppI18n.t('community.dayStreak')}',
                      style: GoogleFonts.nunito(
                          fontSize: 10, color: const Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Text('${entry.xp} XP',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isUser
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF757575))),
        ],
      ),
    );
  }
}
