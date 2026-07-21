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
import '../widgets/mascot_widget.dart';

// ─── League Helper ───
class _LeagueTier {
  final String name;
  final String emoji;
  final int minXp;
  final int maxXp;
  final Color color;

  const _LeagueTier({
    required this.name,
    required this.emoji,
    required this.minXp,
    required this.maxXp,
    required this.color,
  });
}

const List<_LeagueTier> _leagueTiers = [
  _LeagueTier(name: 'league.bronze', emoji: '🥉', minXp: 0, maxXp: 500, color: Color(0xFFCD7F32)),
  _LeagueTier(name: 'league.silver', emoji: '🥈', minXp: 500, maxXp: 1200, color: Color(0xFFC0C0C0)),
  _LeagueTier(name: 'league.gold', emoji: '🥇', minXp: 1200, maxXp: 2500, color: Color(0xFFFFD700)),
  _LeagueTier(name: 'league.emerald', emoji: '💎', minXp: 2500, maxXp: 4000, color: Color(0xFF4CAF50)),
  _LeagueTier(name: 'league.diamond', emoji: '👑', minXp: 4000, maxXp: 6000, color: Color(0xFF7C4DFF)),
];

_LeagueTier _getLeague(int xp) {
  for (int i = _leagueTiers.length - 1; i >= 0; i--) {
    if (xp >= _leagueTiers[i].minXp) return _leagueTiers[i];
  }
  return _leagueTiers[0];
}

// ─── Fake leaderboard data ───
class _LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int xp;
  final int streak;
  final bool isCurrentUser;
  final String playerId;
  final int skillRating;

  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.xp,
    this.streak = 0,
    this.isCurrentUser = false,
    this.playerId = '',
    this.skillRating = 0,
  });
}

const List<_LeaderboardEntry> _fakeLeaderboard = [
  _LeaderboardEntry(rank: 1, name: 'Jason', avatar: '🐉', xp: 3120, streak: 14, playerId: '#LD01', skillRating: 88),
  _LeaderboardEntry(rank: 2, name: 'Emily', avatar: '🐱', xp: 2340, streak: 9, playerId: '#LD02', skillRating: 72),
  _LeaderboardEntry(rank: 3, name: 'David', avatar: '🎯', xp: 1980, streak: 7, playerId: '#LD03', skillRating: 65),
  _LeaderboardEntry(rank: 4, name: 'Michelle', avatar: '🌸', xp: 1650, streak: 5, playerId: '#LD04', skillRating: 55),
  _LeaderboardEntry(rank: 5, name: 'Sarah', avatar: '🦊', xp: 1420, streak: 3, playerId: '#LD05', skillRating: 48),
  _LeaderboardEntry(rank: 6, name: 'Kevin', avatar: '🎮', xp: 1280, streak: 4, playerId: '#LD06', skillRating: 40),
  _LeaderboardEntry(rank: 7, name: 'Amy', avatar: '🌺', xp: 1100, streak: 2, playerId: '#LD07', skillRating: 25),
  _LeaderboardEntry(rank: 8, name: 'Tom', avatar: '🦝', xp: 950, streak: 1, playerId: '#LD08', skillRating: 20),
  _LeaderboardEntry(rank: 9, name: 'Lisa', avatar: '🦜', xp: 800, streak: 3, playerId: '#LD09', skillRating: 15),
  _LeaderboardEntry(rank: 10, name: 'Ben', avatar: '🦝', xp: 650, streak: 0, playerId: '#LD10', skillRating: 10),
];

// ─── Achievement display model (expanded to 24) ───
class _AchievementDisplay {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;

  const _AchievementDisplay({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.unlocked = true,
  });
}

const List<_AchievementDisplay> _allAchievements = [
  // Unlocked (10)
  _AchievementDisplay(id: 'first_lesson', emoji: '🎓', title: 'achievement.first_lesson.title', subtitle: 'achievement.first_lesson.subtitle'),
  _AchievementDisplay(id: 'early_bird', emoji: '🐦', title: 'achievement.early_bird.title', subtitle: 'achievement.early_bird.subtitle'),
  _AchievementDisplay(id: 'streak_3', emoji: '🔥', title: 'achievement.streak_3.title', subtitle: 'achievement.streak_3.subtitle'),
  _AchievementDisplay(id: 'streak_7', emoji: '💪', title: 'achievement.streak_7.title', subtitle: 'achievement.streak_7.subtitle'),
  _AchievementDisplay(id: 'perfect_quiz', emoji: '💯', title: 'achievement.perfect_quiz.title', subtitle: 'achievement.perfect_quiz.subtitle'),
  _AchievementDisplay(id: 'five_lessons', emoji: '📚', title: 'achievement.five_lessons.title', subtitle: 'achievement.five_lessons.subtitle'),
  _AchievementDisplay(id: 'first_stage', emoji: '🏅', title: 'achievement.first_stage.title', subtitle: 'achievement.first_stage.subtitle'),
  _AchievementDisplay(id: 'quick_learner', emoji: '⚡', title: 'achievement.quick_learner.title', subtitle: 'achievement.quick_learner.subtitle'),
  _AchievementDisplay(id: 'comeback', emoji: '🔄', title: 'achievement.comeback.title', subtitle: 'achievement.comeback.subtitle'),
  _AchievementDisplay(id: 'night_owl', emoji: '🦉', title: 'achievement.night_owl.title', subtitle: 'achievement.night_owl.subtitle'),
  // Locked (14)
  _AchievementDisplay(id: 'streak_14', emoji: '🌟', title: 'achievement.streak_14.title', subtitle: 'achievement.streak_14.subtitle', unlocked: false),
  _AchievementDisplay(id: 'streak_30', emoji: '🏆', title: 'achievement.streak_30.title', subtitle: 'achievement.streak_30.subtitle', unlocked: false),
  _AchievementDisplay(id: 'ten_lessons', emoji: '📖', title: 'achievement.ten_lessons.title', subtitle: 'achievement.ten_lessons.subtitle', unlocked: false),
  _AchievementDisplay(id: 'twenty_lessons', emoji: '🎯', title: 'achievement.twenty_lessons.title', subtitle: 'achievement.twenty_lessons.subtitle', unlocked: false),
  _AchievementDisplay(id: 'all_stages', emoji: '👑', title: 'achievement.all_stages.title', subtitle: 'achievement.all_stages.subtitle', unlocked: false),
  _AchievementDisplay(id: 'social_3', emoji: '🤝', title: 'achievement.social_3.title', subtitle: 'achievement.social_3.subtitle', unlocked: false),
  _AchievementDisplay(id: 'social_10', emoji: '🎉', title: 'achievement.social_10.title', subtitle: 'achievement.social_10.subtitle', unlocked: false),
  _AchievementDisplay(id: 'first_match', emoji: '🀄', title: 'achievement.first_match.title', subtitle: 'achievement.first_match.subtitle', unlocked: false),
  _AchievementDisplay(id: 'match_5', emoji: '🎲', title: 'achievement.match_5.title', subtitle: 'achievement.match_5.subtitle', unlocked: false),
  _AchievementDisplay(id: 'match_win', emoji: '🏅', title: 'achievement.match_win.title', subtitle: 'achievement.match_win.subtitle', unlocked: false),
  _AchievementDisplay(id: 'speed_demon', emoji: '💨', title: 'achievement.speed_demon.title', subtitle: 'achievement.speed_demon.subtitle', unlocked: false),
  _AchievementDisplay(id: 'explorer', emoji: '🗺️', title: 'achievement.explorer.title', subtitle: 'achievement.explorer.subtitle', unlocked: false),
  _AchievementDisplay(id: 'gold_league', emoji: '🥇', title: 'achievement.gold_league.title', subtitle: 'achievement.gold_league.subtitle', unlocked: false),
  _AchievementDisplay(id: 'diamond_league', emoji: '💎', title: 'achievement.diamond_league.title', subtitle: 'achievement.diamond_league.subtitle', unlocked: false),
];

// ─── Mascot/Avatar options ───
class _AvatarOption {
  final String id;
  final MascotExpression expression;
  final String label;
  final Color frameColor;
  final bool isLocked;

  const _AvatarOption({
    required this.id,
    required this.expression,
    required this.label,
    required this.frameColor,
    this.isLocked = false,
  });
}

const List<_AvatarOption> _avatarOptions = [
  _AvatarOption(id: 'happy', expression: MascotExpression.happy, label: 'Happy', frameColor: Color(0xFF4CAF50)),
  _AvatarOption(id: 'excited', expression: MascotExpression.excited, label: 'Excited', frameColor: Color(0xFFFF9800)),
  _AvatarOption(id: 'wink', expression: MascotExpression.wink, label: 'Wink', frameColor: Color(0xFF9C27B0)),
  _AvatarOption(id: 'content', expression: MascotExpression.content, label: 'Chill', frameColor: Color(0xFF2196F3)),
  _AvatarOption(id: 'thinking', expression: MascotExpression.thinking, label: 'Thinking', frameColor: Color(0xFF607D8B)),
  _AvatarOption(id: 'pro_gold', expression: MascotExpression.happy, label: 'Gold Frame', frameColor: Color(0xFFFFD700), isLocked: true),
  _AvatarOption(id: 'pro_diamond', expression: MascotExpression.excited, label: 'Diamond Frame', frameColor: Color(0xFF7C4DFF), isLocked: true),
  _AvatarOption(id: 'pro_fire', expression: MascotExpression.wink, label: 'Fire Frame', frameColor: Color(0xFFFF5722), isLocked: true),
];

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
    final league = _getLeague(userXp);

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
      BuildContext context, String nickname, _LeagueTier league, GameState game) {
    return Row(
      children: [
        // Mascot Avatar (tappable → avatar selection)
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const _AvatarSelectionPage(),
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
        // Settings icon
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const _SettingsPage(),
            ));
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.settings_rounded,
                size: 18, color: Color(0xFF757575)),
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
  Widget _buildLeagueCard(BuildContext context, _LeagueTier league, int xp) {
    final progress = (xp - league.minXp) / (league.maxXp - league.minXp);
    // Calculate rank among fake leaderboard
    int rank = _fakeLeaderboard.length + 1;
    for (int i = 0; i < _fakeLeaderboard.length; i++) {
      if (xp >= _fakeLeaderboard[i].xp) {
        rank = i + 1;
        break;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const _LeagueDetailPage(),
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
                        AppI18n.t('community.rank') + '$rank',
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
    final showcase = _allAchievements.where((a) => a.unlocked).take(3).toList();
    final unlockedCount = _allAchievements.where((a) => a.unlocked).length;
    final total = _allAchievements.length;

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
                  builder: (_) => const _AllAchievementsPage(),
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
            children: showcase.map((a) => _achievementBadge(a)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _achievementBadge(_AchievementDisplay achievement) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: achievement.unlocked
                ? const Color(0xFFFFF8E1)
                : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            border: Border.all(
              color: achievement.unlocked
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
                  builder: (_) => _AllLeaderboardPage(
                    userXp: userXp,
                    nickname: nickname,
                    avatarEmoji: game.avatarEmoji,
                    uid: uid,
                    region: region,
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
                    if (docs.isEmpty) {
                      FirebaseService.seedFakePlayers(region, 6);
                      return _leaderboardEmptyPlaceholder();
                    }
                    final entries = <_LeaderboardEntry>[];
                    int myRank = docs.length + 1;
                    bool meIncluded = false;
                    for (int i = 0; i < docs.length; i++) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final docUid = docs[i].id;
                      final isMe = docUid == uid;
                      if (isMe) {
                        meIncluded = true;
                        myRank = i + 1;
                      }
                      entries.add(_LeaderboardEntry(
                        rank: i + 1,
                        name: (d['nickname'] as String?) ?? 'Player',
                        avatar: (d['avatarEmoji'] as String?) ?? '🐼',
                        xp: (d['xp'] as num?)?.toInt() ?? 0,
                        streak: (d['streak'] as num?)?.toInt() ?? 0,
                        isCurrentUser: isMe,
                        playerId: (d['playerId'] as String?) ?? '',
                        skillRating: ((d['xp'] as num?)?.toInt() ?? 0) ~/ 40,
                      ));
                    }
                    final topEntries = entries.take(3).toList();
                    return Column(
                      children: [
                        ...topEntries.map((e) => _leaderboardRow(e)),
                        if (!meIncluded)
                          _leaderboardRow(_LeaderboardEntry(
                            rank: docs.length + 1,
                            name: nickname,
                            avatar: game.avatarEmoji,
                            xp: userXp,
                            isCurrentUser: true,
                            playerId: myPlayerId,
                            skillRating: userXp ~/ 40,
                          )),
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
        child: Text(AppI18n.t('community.noFriends'),
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

  Widget _leaderboardRow(_LeaderboardEntry entry) {
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

// ═══════════════════════════════════════════════════════════════
// ─── Avatar Selection Page ───
// ═══════════════════════════════════════════════════════════════
class _AvatarSelectionPage extends StatefulWidget {
  const _AvatarSelectionPage();

  @override
  State<_AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<_AvatarSelectionPage> {
  String _selectedId = 'happy';

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
        title: Text(AppI18n.t('community.chooseAvatar'),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Preview
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _avatarOptions
                      .firstWhere((a) => a.id == _selectedId)
                      .frameColor,
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: MascotWidget(
                  expression: _avatarOptions
                      .firstWhere((a) => a.id == _selectedId)
                      .expression,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Free avatars
            Text(AppI18n.t('community.mascotExpressions'),
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: _avatarOptions
                  .where((a) => !a.isLocked)
                  .map((a) => _avatarGridItem(a))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Pro frames
            Row(
              children: [
                Text(AppI18n.t('community.proFrames'),
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2D2D))),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('PRO',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE65100))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: _avatarOptions
                  .where((a) => a.isLocked)
                  .map((a) => _avatarGridItem(a))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppI18n.t('community.avatarUpdated'),
                          style: GoogleFonts.nunito()),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(AppI18n.t('community.saveAvatar'),
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarGridItem(_AvatarOption option) {
    final isSelected = option.id == _selectedId;
    return GestureDetector(
      onTap: () {
        if (!option.isLocked) {
          setState(() => _selectedId = option.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppI18n.t('community.upgradeToUnlock'),
                  style: GoogleFonts.nunito()),
              backgroundColor: const Color(0xFFE65100),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? option.frameColor.withAlpha(20)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? option.frameColor : const Color(0xFFE0E0E0),
                width: isSelected ? 3 : 1.5,
              ),
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: MascotWidget(
                    expression: option.expression,
                    size: 50,
                  ),
                ),
                if (option.isLocked)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(option.label,
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: option.isLocked
                      ? const Color(0xFFBDBDBD)
                      : const Color(0xFF424242)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── League Detail Page ───
// ═══════════════════════════════════════════════════════════════
class _LeagueDetailPage extends StatelessWidget {
  const _LeagueDetailPage();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final xp = game.xp;
    final currentLeague = _getLeague(xp);

    int currentIdx = 0;
    for (int i = _leagueTiers.length - 1; i >= 0; i--) {
      if (xp >= _leagueTiers[i].minXp) {
        currentIdx = i;
        break;
      }
    }

    final progress = (xp - currentLeague.minXp) /
        (currentLeague.maxXp - currentLeague.minXp);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppI18n.t('community.leagueProgress'),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current league card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentLeague.color,
                    currentLeague.color.withAlpha(180)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(currentLeague.emoji,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(AppI18n.t(currentLeague.name),
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(AppI18n.t('community.keepLearning'),
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: Colors.white.withAlpha(200))),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white.withAlpha(50),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$xp / ${currentLeague.maxXp} XP',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.white.withAlpha(200))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // All leagues
            ..._leagueTiers.asMap().entries.map((entry) {
              final idx = entry.key;
              final league = entry.value;
              final isCurrent = idx == currentIdx;
              final isUnlocked = idx <= currentIdx;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCurrent ? league.color.withAlpha(20) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isCurrent
                      ? Border.all(color: league.color, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(league.emoji,
                        style: TextStyle(
                            fontSize: 28,
                            color: isUnlocked ? null : Colors.grey)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppI18n.t(league.name),
                              style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isUnlocked
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFBDBDBD))),
                          Text('${league.minXp} - ${league.maxXp} XP',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: const Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: league.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Current',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      )
                    else if (isUnlocked)
                      Icon(Icons.check_circle_rounded,
                          color: league.color, size: 22)
                    else
                      const Icon(Icons.lock_rounded,
                          color: Color(0xFFBDBDBD), size: 22),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── All Achievements Page ───
// ═══════════════════════════════════════════════════════════════
class _AllAchievementsPage extends StatelessWidget {
  const _AllAchievementsPage();

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _allAchievements.where((a) => a.unlocked).length;
    final total = _allAchievements.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppI18n.t('community.allAchievements'),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8B93E), Color(0xFFF9A825)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const MascotWidget(
                    expression: MascotExpression.excited,
                    size: 60,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppI18n.t('community.achievementProgress'),
                            style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(AppI18n.t('community.unlockedCount').replaceAll('{unlocked}', '$unlockedCount').replaceAll('{total}', '$total'),
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.white.withAlpha(200))),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: unlockedCount / total,
                            minHeight: 8,
                            backgroundColor: Colors.white.withAlpha(40),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(AppI18n.t('community.unlocked') + ' ($unlockedCount)',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: _allAchievements
                  .where((a) => a.unlocked)
                  .map((a) => _achievementGridItem(a))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(AppI18n.t('community.locked') + ' (${total - unlockedCount})',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9E9E9E))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: _allAchievements
                  .where((a) => !a.unlocked)
                  .map((a) => _achievementGridItem(a))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementGridItem(_AchievementDisplay a) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: a.unlocked
                  ? const Color(0xFFFFF8E1)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: a.unlocked
                    ? const Color(0xFFFFD54F)
                    : const Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(a.emoji,
                  style: TextStyle(
                      fontSize: 24,
                      color: a.unlocked ? null : const Color(0xFFBDBDBD))),
            ),
          ),
          const SizedBox(height: 6),
          Text(AppI18n.t(a.title),
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: a.unlocked
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFBDBDBD)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(AppI18n.t(a.subtitle),
              style: GoogleFonts.nunito(
                  fontSize: 9, color: const Color(0xFF9E9E9E)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── All Leaderboard Page ───
// ═══════════════════════════════════════════════════════════════
class _AllLeaderboardPage extends StatelessWidget {
  final int userXp;
  final String nickname;
  final String avatarEmoji;
  final String? uid;
  final String region;

  const _AllLeaderboardPage({
    required this.userXp,
    required this.nickname,
    required this.avatarEmoji,
    required this.uid,
    required this.region,
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
              child: Text(AppI18n.t('community.noFriends'),
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
                final entries = <_LeaderboardEntry>[];
                int myRank = docs.length + 1;
                bool meIncluded = false;
                for (int i = 0; i < docs.length; i++) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final docUid = docs[i].id;
                  final isMe = docUid == uid;
                  if (isMe) {
                    meIncluded = true;
                    myRank = i + 1;
                  }
                  entries.add(_LeaderboardEntry(
                    rank: i + 1,
                    name: (d['nickname'] as String?) ?? 'Player',
                    avatar: (d['avatarEmoji'] as String?) ?? '🐼',
                    xp: (d['xp'] as num?)?.toInt() ?? 0,
                    streak: (d['streak'] as num?)?.toInt() ?? 0,
                    isCurrentUser: isMe,
                    playerId: (d['playerId'] as String?) ?? '',
                    skillRating: ((d['xp'] as num?)?.toInt() ?? 0) ~/ 40,
                  ));
                }
                if (!meIncluded) {
                  entries.add(_LeaderboardEntry(
                    rank: docs.length + 1,
                    name: nickname,
                    avatar: avatarEmoji,
                    xp: userXp,
                    isCurrentUser: true,
                  ));
                }
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

  Widget _buildPodium(List<_LeaderboardEntry> entries) {
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

  Widget _podiumItem(_LeaderboardEntry entry, double height, Color color) {
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
            child: Text('#${entry.rank}',
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          ),
        ),
      ],
    );
  }

  Widget _fullRow(_LeaderboardEntry entry) {
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
            child: Text('#${entry.rank}',
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

// ═══════════════════════════════════════════════════════════════
// ─── Settings Page (Complete) ───
// ═══════════════════════════════════════════════════════════════
class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  String _language = 'English';

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
        title: Text('Settings',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _sectionTitle(AppI18n.t('settings.account')),
            _settingsCard([
              _settingsRow(Icons.person_rounded, AppI18n.t('community.editProfile'), onTap: () {
                Navigator.pop(context);
              }),
              _settingsDivider(),
              _settingsRow(Icons.lock_rounded, AppI18n.t('settings.changePassword'), onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.email_rounded, AppI18n.t('settings.email'), subtitle: 'user@example.com'),
            ]),
            const SizedBox(height: 20),

            // Preferences section
            _sectionTitle(AppI18n.t('settings.preferences')),
            _settingsCard([
              _settingsToggle(Icons.notifications_rounded, AppI18n.t('settings.notifications'),
                  _notificationsEnabled, (v) {
                setState(() => _notificationsEnabled = v);
              }),
              _settingsDivider(),
              _settingsToggle(Icons.volume_up_rounded, AppI18n.t('settings.soundEffects'),
                  _soundEnabled, (v) {
                setState(() => _soundEnabled = v);
              }),
              _settingsDivider(),
              _settingsToggle(Icons.vibration_rounded, AppI18n.t('settings.hapticFeedback'),
                  _hapticEnabled, (v) {
                setState(() => _hapticEnabled = v);
              }),
              _settingsDivider(),
              _settingsRow(Icons.language_rounded, AppI18n.t('settings.language'),
                  subtitle: _language, onTap: () {
                _showLanguageDialog();
              }),
            ]),
            const SizedBox(height: 20),

            // Learning section
            _sectionTitle(AppI18n.t('settings.learning')),
            _settingsCard([
              _settingsRow(Icons.schedule_rounded, AppI18n.t('settings.dailyReminder'),
                  subtitle: '9:00 AM', onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.speed_rounded, AppI18n.t('community.difficulty'),
                  subtitle: AppI18n.t('community.adaptive'), onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.restart_alt_rounded, AppI18n.t('settings.resetProgress'),
                  isDestructive: true, onTap: () {
                _showResetDialog();
              }),
            ]),
            const SizedBox(height: 20),

            // About section
            _sectionTitle(AppI18n.t('settings.about')),
            _settingsCard([
              _settingsRow(Icons.info_rounded, AppI18n.t('settings.version'),
                  subtitle: '1.0.0 (Beta)'),
              _settingsDivider(),
              _settingsRow(Icons.description_rounded, AppI18n.t('settings.termsOfService'),
                  onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.privacy_tip_rounded, AppI18n.t('settings.privacyPolicy'),
                  onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.help_rounded, AppI18n.t('settings.helpSupport'), onTap: () {}),
            ]),
            const SizedBox(height: 20),

            // Subscription
            _sectionTitle(AppI18n.t('settings.subscription')),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(AppI18n.t('settings.upgradeToPro'),
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                      AppI18n.t('community.upgradeDesc'),
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.white.withAlpha(200)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: Text(AppI18n.t('settings.viewPlans'),
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE53935),
                  side: const BorderSide(color: Color(0xFFE53935)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(AppI18n.t('settings.logOut'),
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF757575))),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsRow(IconData icon, String title,
      {String? subtitle, bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isDestructive
                    ? const Color(0xFFE53935)
                    : const Color(0xFF4CAF50)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFE53935)
                          : const Color(0xFF2D2D2D))),
            ),
            if (subtitle != null)
              Text(subtitle,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: const Color(0xFF9E9E9E))),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFBDBDBD)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _settingsToggle(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D))),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _settingsDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFF5F5F5)),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppI18n.t('settings.language'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', '繁體中文', '简体中文'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang, style: GoogleFonts.nunito()),
              value: lang,
              groupValue: _language,
              activeColor: const Color(0xFF4CAF50),
              onChanged: (v) {
                setState(() => _language = v!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppI18n.t('settings.resetProgress'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
            AppI18n.t('settings.resetConfirm'),
            style: GoogleFonts.nunito(color: const Color(0xFF757575))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppI18n.t('common.cancel'),
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppI18n.t('common.reset'),
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
