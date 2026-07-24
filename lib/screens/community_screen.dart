import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../screens/find_match_screen.dart';
import '../services/app_i18n.dart';
import '../services/firebase_service.dart';
import '../services/leaderboard_merge.dart';
import '../widgets/mascot_widget.dart';
import '../models/community/league_tier.dart';
import '../models/community/leaderboard_entry.dart';
import '../models/community/achievement_display.dart';
import 'community/avatar_selection_page.dart';
import 'community/league_detail_page.dart';
import 'community/all_achievements_page.dart';
import 'community/all_leaderboard_page.dart';

// ═══════════════════════════════════════════════════════════════
// ─── Main Widget ───
// ═══════════════════════════════════════════════════════════════
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final userXp = game.xp;
    final userStreak = game.streak;
    final completedCount = game.completedLessons;
    final nickname = game.nickname;
    final league = getLeague(userXp);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildProfileHeader(context, nickname, league, game),
              const SizedBox(height: 16),
              _buildLeagueCard(context, league, userXp),
              const SizedBox(height: 16),
              _buildStatsRow(userXp, userStreak, completedCount),
              const SizedBox(height: 24),
              _buildAchievementsSection(context),
              const SizedBox(height: 24),
              _buildLeaderboardSection(context, userXp, nickname, game),
              const SizedBox(height: 24),
              _buildFriendsSection(context, game),
              const SizedBox(height: 32),
              // T3: Find a Match hidden - backend not ready
              // _buildMatchCard(context),
              // const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Profile Header ───
  Widget _buildProfileHeader(
      BuildContext context, String nickname, LeagueTier league, GameState game) {
    return Row(
      children: [
        // Mascot Avatar (tappable → avatar selection)
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AvatarSelectionPage(),
            ));
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
            ),
            child: const ClipOval(
              child: MascotWidget(
                expression: MascotExpression.happy,
                size: 48,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Name & League
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showNicknameDialog(context, game),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        nickname,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2D2D2D),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 14, color: Color(0xFF4CAF50)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${league.emoji} ${AppI18n.t(league.name)}  ·  ${game.playerId ?? 'LD----'}  ·  ${AppI18n.t('community.skill')} ${game.skillRating}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: league.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Nickname Edit Dialog ───
  void _showNicknameDialog(BuildContext context, GameState game) {
    final controller = TextEditingController(text: game.nickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppI18n.t('settings.editNickname'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          decoration: InputDecoration(
            hintText: AppI18n.t('settings.enterNickname'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppI18n.t('common.cancel'),
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                game.setNickname(name);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppI18n.t('common.save'),
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── League Card (dynamic, tappable) ───
  Widget _buildLeagueCard(BuildContext context, LeagueTier league, int xp) {
    final progress = (xp - league.minXp) / (league.maxXp - league.minXp);
    // Calculate rank among fake leaderboard
    int rank = fakeLeaderboard.length + 1;
    for (int i = 0; i < fakeLeaderboard.length; i++) {
      if (xp >= fakeLeaderboard[i].xp) {
        rank = i + 1;
        break;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const LeagueDetailPage(),
        ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: league.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(league.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppI18n.t(league.name),
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        AppI18n.t('community.rank') + ' ' + '$rank',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: league.color.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(league.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFBDBDBD), size: 20),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar to next league
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(league.color),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$xp XP',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF9E9E9E))),
                Text('${league.maxXp} XP',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF9E9E9E))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Stats Row ───
  Widget _buildStatsRow(int xp, int streak, int completedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('⚡', AppI18n.t('community.totalXp'), '$xp'),
          _statDivider(),
          _statItem('🔥', AppI18n.t('community.streak'), '$streak'),
          _statDivider(),
          _statItem('✅', AppI18n.t('community.completed'), '$completedCount'),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 11, color: const Color(0xFF9E9E9E))),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D))),
      ],
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 40, color: const Color(0xFFEEEEEE));
  }

  // ─── Achievements Section ───
  Widget _buildAchievementsSection(BuildContext context) {
    final game = context.watch<GameState>();
    final showcase = allAchievements.where((a) => game.unlockedAchievements.contains(a.id)).take(3).toList();
    final unlockedCount = allAchievements.where((a) => game.unlockedAchievements.contains(a.id)).length;
    final total = allAchievements.length;

    return Column(
      children: [
        Row(
          children: [
            Text(AppI18n.t('community.achievements'),
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$unlockedCount/$total',
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4CAF50))),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AllAchievementsPage(),
                ));
              },
              child: Row(
                children: [
                  Text(AppI18n.t('community.viewAll'),
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50))),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: showcase.map((a) => _achievementBadge(a, game.unlockedAchievements.contains(a.id))).toList(),
          ),
        ),
      ],
    );
  }

  Widget _achievementBadge(AchievementDisplay achievement, bool isUnlocked) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isUnlocked
                ? const Color(0xFFFFF8E1)
                : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFFE0E0E0),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(achievement.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 8),
        Text(AppI18n.t(achievement.title),
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D)),
            textAlign: TextAlign.center),
        Text(AppI18n.t(achievement.subtitle),
            style: GoogleFonts.nunito(
                fontSize: 10, color: const Color(0xFF9E9E9E)),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ─── Leaderboard Section (with Add Friend button) ───
  Widget _buildLeaderboardSection(
      BuildContext context, int userXp, String nickname, GameState game) {
    final uid = game.currentUid;
    final region = game.region;
    final myPlayerId = game.playerId ?? '';

    return Column(
      children: [
        Row(
          children: [
            Text(AppI18n.t('community.regionLeaderboard'),
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AllLeaderboardPage(
                    userXp: userXp,
                    nickname: nickname,
                    avatarEmoji: game.avatarEmoji,
                    uid: uid,
                    region: region,
                    myPlayerId: myPlayerId,
                  ),
                ));
              },
              child: Row(
                children: [
                  Text(AppI18n.t('community.viewAll'),
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50))),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
          child: uid == null
              ? _leaderboardLoadingPlaceholder()
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.getRegionLeaderboard(region),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _leaderboardLoadingPlaceholder();
                    }
                    if (snapshot.hasError) {
                      return _leaderboardErrorPlaceholder(snapshot.error.toString());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    // 過濾掉舊的 Firestore fake_ 文檔（本地合併後不再寫入，殘留者忽略）
                    final realDocs =
                        docs.where((d) => !d.id.startsWith('fake_')).toList();
                    // 合併真實玩家 + 假玩家 + 自己（共用 helper）
                    final merged = generateAndMergeLeaderboard(
                      region: region,
                      realDocs: realDocs,
                      uid: uid!,
                      nickname: nickname,
                      avatarEmoji: game.avatarEmoji,
                      userXp: userXp,
                      myPlayerId: myPlayerId,
                    );
                    if (merged.isEmpty) {
                      return _leaderboardEmptyPlaceholder();
                    }
                    final entries = merged;
                    final topEntries = entries.take(3).toList();
                    int myRank = 0;
                    for (int i = 0; i < entries.length; i++) {
                      if (entries[i].isCurrentUser) {
                        myRank = i + 1;
                        break;
                      }
                    }
                    return Column(
                      children: [
                        ...topEntries.map((e) => _leaderboardRow(e)),
                        if (myRank > 3) _leaderboardRow(entries[myRank - 1]),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _leaderboardLoadingPlaceholder() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(
            color: const Color(0xFF4CAF50).withAlpha(120),
            strokeWidth: 2,
          ),
        ),
      );

  Widget _leaderboardErrorPlaceholder(String err) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Text('Load failed: $err',
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.redAccent),
            textAlign: TextAlign.center),
      );

  Widget _leaderboardEmptyPlaceholder() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(AppI18n.t('community.noRegionPlayers'),
            style: GoogleFonts.nunito(
                fontSize: 13, color: const Color(0xFF9E9E9E)),
            textAlign: TextAlign.center),
      );

  // ─── Friends Section (real data) ───
  Widget _buildFriendsSection(BuildContext context, GameState game) {
    final uid = game.currentUid;
    if (uid == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppI18n.t('community.friends'),
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const SizedBox(width: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getFriendRequests(uid),
              builder: (context, snap) {
                final count = snap.data?.docs.length ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count',
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                );
              },
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddFriendDialog(context, uid),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50).withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add_rounded,
                        size: 14, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 4),
                    Text(AppI18n.t('community.addAll'),
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4CAF50))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Pending requests
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getFriendRequests(uid),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text(AppI18n.t('community.friendRequests'),
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF757575))),
                  ),
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final fromUid = data['from'] as String? ?? '';
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: FirebaseService.getUserProfile(fromUid),
                      builder: (context, psnap) {
                        final p = psnap.data;
                        return _friendRequestRow(
                          context,
                          requestId: doc.id,
                          name: (p?['nickname'] as String?) ?? 'Player',
                          avatar: (p?['avatarEmoji'] as String?) ?? '🐼',
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
        // Friends list
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getFriends(uid),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(AppI18n.t('community.noFriends'),
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: const Color(0xFF9E9E9E)),
                    textAlign: TextAlign.center),
              );
            }
            return Container(
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
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final friendUid = data['friendUid'] as String? ?? doc.id;
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: FirebaseService.getUserProfile(friendUid),
                    builder: (context, psnap) {
                      final p = psnap.data;
                      return _friendRow(
                        name: (p?['nickname'] as String?) ?? 'Player',
                        avatar: (p?['avatarEmoji'] as String?) ?? '🐼',
                        xp: (p?['xp'] as num?)?.toInt() ?? 0,
                        playerId: (p?['playerId'] as String?) ?? '',
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _friendRequestRow(
    BuildContext context, {
    required String requestId,
    required String name,
    required String avatar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(avatar, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D))),
          ),
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseService.acceptFriendRequest(requestId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppI18n.t('community.accept')),
                    backgroundColor: const Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.redAccent,
                  ));
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(AppI18n.t('community.accept'),
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseService.rejectFriendRequest(requestId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.redAccent,
                  ));
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(AppI18n.t('community.reject'),
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF757575))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendRow({
    required String name,
    required String avatar,
    required int xp,
    required String playerId,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(avatar, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D))),
                if (playerId.isNotEmpty)
                  Text(playerId,
                      style: GoogleFonts.nunito(
                          fontSize: 10, color: const Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Text('$xp XP',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF757575))),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context, String? uid) {
    final controller = TextEditingController();
    // Live lookup state
    ValueNotifier<Map<String, dynamic>?> foundPlayer = ValueNotifier(null);
    ValueNotifier<bool> searching = ValueNotifier(false);
    ValueNotifier<String?> errorMsg = ValueNotifier(null);
    Timer? debounce;

    void lookup(String code) {
      final trimmed = code.trim();
      if (trimmed.isEmpty) {
        foundPlayer.value = null;
        errorMsg.value = null;
        return;
      }
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 400), () async {
        searching.value = true;
        errorMsg.value = null;
        try {
          final player = await FirebaseService.getUserByPlayerId(trimmed);
          foundPlayer.value = player;
          if (player == null) {
            errorMsg.value = AppI18n.t('community.playerNotFound');
          }
        } catch (e) {
          errorMsg.value = 'Error: $e';
        } finally {
          searching.value = false;
        }
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppI18n.t('community.addFriend'),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppI18n.t('community.addFriendDesc'),
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: const Color(0xFF757575))),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: AppI18n.t('community.playerNumberHint'),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF9E9E9E)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                ),
                onChanged: lookup,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: searching,
                builder: (_, loading, __) => loading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF4CAF50)),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              ValueListenableBuilder<Map<String, dynamic>?>(
                valueListenable: foundPlayer,
                builder: (_, player, __) {
                  if (player != null) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Center(
                                child: Text(
                                    (player['avatarEmoji'] as String?) ?? '🐼',
                                    style: const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((player['nickname'] as String?) ?? 'Player',
                                    style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2D2D2D))),
                                Text(
                                    '${(player['playerId'] as String?) ?? ''}',
                                    style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: const Color(0xFF9E9E9E))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ValueListenableBuilder<String?>(
                    valueListenable: errorMsg,
                    builder: (_, err, __) => err != null
                        ? Text(err,
                            style: GoogleFonts.nunito(
                                fontSize: 13, color: const Color(0xFFE53935)))
                        : const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                debounce?.cancel();
                Navigator.pop(ctx);
              },
              child: Text(AppI18n.t('common.cancel'),
                  style: GoogleFonts.nunito(color: const Color(0xFF757575))),
            ),
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: foundPlayer,
              builder: (_, player, __) => ElevatedButton.icon(
                onPressed: (player == null || uid == null)
                    ? null
                    : () async {
                        final targetUid = player['uid'] as String?;
                        if (targetUid == null) return;
                        try {
                          await FirebaseService.sendFriendRequest(
                              uid, player['playerId'] as String);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    AppI18n.t('community.friendRequestSent'),
                                    style: GoogleFonts.nunito()),
                                backgroundColor: const Color(0xFF4CAF50),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } catch (e) {
                          String msg = 'Error: $e';
                          if (e.toString().contains('cannot_add_self')) {
                            msg = 'You cannot add yourself.';
                          } else if (e
                              .toString()
                              .contains('request_already_sent')) {
                            msg = 'A request is already pending.';
                          }
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(msg),
                              backgroundColor: Colors.redAccent,
                            ));
                          }
                        }
                      },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(AppI18n.t('community.send'),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaderboardRow(LeaderboardEntry entry) {
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
            width: 24,
            child: Text('${entry.rank}',
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isUser
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF757575))),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFC8E6C9) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(entry.avatar, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.name,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
                            color: const Color(0xFF2D2D2D))),
                    if (entry.playerId.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(entry.playerId,
                            style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9E9E9E))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('${entry.skillRating}',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7A6E))),
                    const SizedBox(width: 4),
                    Text(AppI18n.t('community.skill'),
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            color: const Color(0xFF9AA89C))),
                  ],
                ),
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

  // ─── Find a Match Card ───
  Widget _buildMatchCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Text('🀄', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppI18n.t('community.findMatch'),
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D2D2D))),
                    Text(AppI18n.t('community.playOffline'),
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: const Color(0xFF757575))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Beta',
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _matchFeatureRow(
                    Icons.psychology_rounded, AppI18n.t('community.matchedBySkill')),
                const SizedBox(height: 10),
                _matchFeatureRow(
                    Icons.language_rounded, AppI18n.t('community.languagePairing')),
                const SizedBox(height: 10),
                _matchFeatureRow(Icons.storefront_rounded,
                    AppI18n.t('community.verifiedVenues')),
                const SizedBox(height: 10),
                _matchFeatureRow(Icons.support_agent_rounded,
                    AppI18n.t('community.onSiteStaff')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FindMatchScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Find a Match',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF424242))),
        ),
      ],
    );
  }
}

