import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/match_state.dart';
import '../screens/find_match_screen.dart';
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
  _LeagueTier(name: 'Bronze League', emoji: '🥉', minXp: 0, maxXp: 500, color: Color(0xFFCD7F32)),
  _LeagueTier(name: 'Silver League', emoji: '🥈', minXp: 500, maxXp: 1200, color: Color(0xFFC0C0C0)),
  _LeagueTier(name: 'Gold League', emoji: '🥇', minXp: 1200, maxXp: 2500, color: Color(0xFFFFD700)),
  _LeagueTier(name: 'Emerald League', emoji: '💎', minXp: 2500, maxXp: 4000, color: Color(0xFF4CAF50)),
  _LeagueTier(name: 'Diamond League', emoji: '👑', minXp: 4000, maxXp: 6000, color: Color(0xFF7C4DFF)),
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
  _LeaderboardEntry(rank: 1, name: 'Jason', avatar: '🐉', xp: 3120, streak: 14, playerId: '#LD001', skillRating: 88),
  _LeaderboardEntry(rank: 2, name: 'Emily', avatar: '🐱', xp: 2340, streak: 9, playerId: '#LD002', skillRating: 72),
  _LeaderboardEntry(rank: 3, name: 'David', avatar: '🎯', xp: 1980, streak: 7, playerId: '#LD003', skillRating: 65),
  _LeaderboardEntry(rank: 4, name: 'Michelle', avatar: '🌸', xp: 1650, streak: 5, playerId: '#LD004', skillRating: 55),
  _LeaderboardEntry(rank: 5, name: 'Sarah', avatar: '🦊', xp: 1420, streak: 3, playerId: '#LD005', skillRating: 48),
  _LeaderboardEntry(rank: 6, name: 'Kevin', avatar: '🎮', xp: 1280, streak: 4, playerId: '#LD006', skillRating: 40),
  _LeaderboardEntry(rank: 7, name: 'Amy', avatar: '🌺', xp: 1100, streak: 2, playerId: '#LD007', skillRating: 25),
  _LeaderboardEntry(rank: 8, name: 'Tom', avatar: '🦝', xp: 950, streak: 1, playerId: '#LD008', skillRating: 20),
  _LeaderboardEntry(rank: 9, name: 'Lisa', avatar: '🦜', xp: 800, streak: 3, playerId: '#LD009', skillRating: 15),
  _LeaderboardEntry(rank: 10, name: 'Ben', avatar: '🦝', xp: 650, streak: 0, playerId: '#LD010', skillRating: 10),
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
  _AchievementDisplay(id: 'first_lesson', emoji: '🎓', title: 'Beginner', subtitle: 'Complete 1 lesson'),
  _AchievementDisplay(id: 'early_bird', emoji: '🐦', title: 'Early Bird', subtitle: 'Study before 8am'),
  _AchievementDisplay(id: 'streak_3', emoji: '🔥', title: '3-Day Streak', subtitle: 'Study 3 days in a row'),
  _AchievementDisplay(id: 'streak_7', emoji: '💪', title: '7-Day Streak', subtitle: 'Study 7 days in a row'),
  _AchievementDisplay(id: 'perfect_quiz', emoji: '💯', title: 'Perfect Score', subtitle: '100% on a quiz'),
  _AchievementDisplay(id: 'five_lessons', emoji: '📚', title: 'Bookworm', subtitle: 'Complete 5 lessons'),
  _AchievementDisplay(id: 'first_stage', emoji: '🏅', title: 'Stage Clear', subtitle: 'Complete Stage 1'),
  _AchievementDisplay(id: 'quick_learner', emoji: '⚡', title: 'Quick Learner', subtitle: 'Finish lesson in 2 min'),
  _AchievementDisplay(id: 'comeback', emoji: '🔄', title: 'Comeback', subtitle: 'Return after 3 days'),
  _AchievementDisplay(id: 'night_owl', emoji: '🦉', title: 'Night Owl', subtitle: 'Study after 11pm'),
  // Locked (14)
  _AchievementDisplay(id: 'streak_14', emoji: '🌟', title: '14-Day Streak', subtitle: 'Study 14 days', unlocked: false),
  _AchievementDisplay(id: 'streak_30', emoji: '🏆', title: '30-Day Streak', subtitle: 'Study 30 days', unlocked: false),
  _AchievementDisplay(id: 'ten_lessons', emoji: '📖', title: 'Scholar', subtitle: 'Complete 10 lessons', unlocked: false),
  _AchievementDisplay(id: 'twenty_lessons', emoji: '🎯', title: 'Dedicated', subtitle: 'Complete 20 lessons', unlocked: false),
  _AchievementDisplay(id: 'all_stages', emoji: '👑', title: 'Master', subtitle: 'Complete all stages', unlocked: false),
  _AchievementDisplay(id: 'social_3', emoji: '🤝', title: 'Social', subtitle: 'Add 3 friends', unlocked: false),
  _AchievementDisplay(id: 'social_10', emoji: '🎉', title: 'Popular', subtitle: 'Add 10 friends', unlocked: false),
  _AchievementDisplay(id: 'first_match', emoji: '🀄', title: 'First Match', subtitle: 'Play 1 offline match', unlocked: false),
  _AchievementDisplay(id: 'match_5', emoji: '🎲', title: 'Regular', subtitle: 'Play 5 offline matches', unlocked: false),
  _AchievementDisplay(id: 'match_win', emoji: '🏅', title: 'Winner', subtitle: 'Win an offline match', unlocked: false),
  _AchievementDisplay(id: 'speed_demon', emoji: '💨', title: 'Speed Demon', subtitle: 'Finish quiz in 30s', unlocked: false),
  _AchievementDisplay(id: 'explorer', emoji: '🗺️', title: 'Explorer', subtitle: 'Try all lesson types', unlocked: false),
  _AchievementDisplay(id: 'gold_league', emoji: '🥇', title: 'Gold Member', subtitle: 'Reach Gold League', unlocked: false),
  _AchievementDisplay(id: 'diamond_league', emoji: '💎', title: 'Diamond', subtitle: 'Reach Diamond League', unlocked: false),
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
              _buildLeaderboardSection(context, userXp, nickname),
              const SizedBox(height: 24),
              _buildMatchCard(context),
              const SizedBox(height: 32),
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
                '${league.emoji} ${league.name}',
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
        title: Text('Edit Nickname',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          decoration: InputDecoration(
            hintText: 'Enter nickname',
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
            child: Text('Cancel',
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
            child: Text('Save',
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
                        league.name,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        'Rank #$rank',
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
          _statItem('⚡', 'Total XP', '$xp'),
          _statDivider(),
          _statItem('🔥', 'Streak', '$streak Days'),
          _statDivider(),
          _statItem('✅', 'Completed', '$completedCount'),
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
            Text('Achievements',
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
                  Text('View All',
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
        Text(achievement.title,
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D)),
            textAlign: TextAlign.center),
        Text(achievement.subtitle,
            style: GoogleFonts.nunito(
                fontSize: 10, color: const Color(0xFF9E9E9E)),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ─── Leaderboard Section (with Add Friend button) ───
  Widget _buildLeaderboardSection(
      BuildContext context, int userXp, String nickname) {
    final topEntries = _fakeLeaderboard.take(3).toList();
    int userRank = _fakeLeaderboard.length + 1;
    for (int i = 0; i < _fakeLeaderboard.length; i++) {
      if (userXp >= _fakeLeaderboard[i].xp) {
        userRank = i + 1;
        break;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Text('Friend Leaderboard',
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const Spacer(),
            // Add Friend button
            GestureDetector(
              onTap: () => _showAddFriendDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF4CAF50).withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add_rounded,
                        size: 14, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 4),
                    Text('Add',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4CAF50))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _AllLeaderboardPage(
                    userXp: userXp,
                    nickname: nickname,
                  ),
                ));
              },
              child: Row(
                children: [
                  Text('View All',
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
          child: Column(
            children: [
              ...topEntries.map((e) => _leaderboardRow(e)),
              _leaderboardRow(_LeaderboardEntry(
                rank: userRank > 5 ? _fakeLeaderboard.length + 1 : userRank,
                name: nickname,
                avatar: '🐼',
                xp: userXp,
                isCurrentUser: true,
              )),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    final playerId = controller.text.trim();
    final foundPlayer = _fakeLeaderboard.firstWhere(
      (entry) => entry.playerId == playerId,
      orElse: () => _LeaderboardEntry(
        rank: -1,
        name: 'Unknown',
        avatar: '🤔',
        xp: 0,
        streak: 0,
        isCurrentUser: false,
        playerId: '',
        skillRating: 0,
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Friend',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your friend\'s username or invite code to connect.',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: const Color(0xFF757575))),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Username or invite code',
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
            ),
            if (foundPlayer.rank != -1)
              Text('Found: ${foundPlayer.name}',
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: const Color(0xFF4CAF50))),
            if (foundPlayer.rank == -1)
              Text('Player not found.',
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: const Color(0xFFE53935))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Friend request sent!',
                      style: GoogleFonts.nunito()),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: Text('Send',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
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
                        child: Text('#${entry.playerId}',
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
                    Text('Skill',
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
                    Text('Find a Match',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D2D2D))),
                    Text('Play offline with matched players',
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
                    Icons.psychology_rounded, 'Matched by your skill level'),
                const SizedBox(height: 10),
                _matchFeatureRow(
                    Icons.language_rounded, 'Language-based pairing'),
                const SizedBox(height: 10),
                _matchFeatureRow(Icons.storefront_rounded,
                    'Verified venues with transparent pricing'),
                const SizedBox(height: 10),
                _matchFeatureRow(Icons.support_agent_rounded,
                    'On-site staff for rules assistance'),
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
        title: Text('Choose Avatar',
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
            Text('Mascot Expressions',
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
                Text('Pro Frames',
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
                      content: Text('Avatar updated!',
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
                child: Text('Save Avatar',
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
              content: Text('Upgrade to Pro to unlock this frame!',
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
        title: Text('League Progress',
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
                  Text(currentLeague.name,
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Keep learning to advance!',
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
                          Text(league.name,
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
        title: Text('All Achievements',
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
                        Text('Achievement Progress',
                            style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('$unlockedCount / $total unlocked',
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
            // Unlocked
            Text('Unlocked ($unlockedCount)',
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
            // Locked
            Text('Locked (${total - unlockedCount})',
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
          Text(a.title,
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: a.unlocked
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFBDBDBD)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(a.subtitle,
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

  const _AllLeaderboardPage({
    required this.userXp,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    int userRank = _fakeLeaderboard.length + 1;
    for (int i = 0; i < _fakeLeaderboard.length; i++) {
      if (userXp >= _fakeLeaderboard[i].xp) {
        userRank = i + 1;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Friend Leaderboard',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded,
                color: Color(0xFF4CAF50)),
            onPressed: () {
              // Reuse add friend dialog
              _showAddFriendSnack(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPodium(),
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
                children: [
                  ..._fakeLeaderboard.map((e) => _fullRow(e)),
                  _fullRow(_LeaderboardEntry(
                    rank: userRank > 10 ? 11 : userRank,
                    name: nickname,
                    avatar: '🐼',
                    xp: userXp,
                    streak: 0,
                    isCurrentUser: true,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share your invite code: LUDI-${nickname.toUpperCase().substring(0, 3)}',
            style: GoogleFonts.nunito()),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Copy',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _fakeLeaderboard.take(3).toList();
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
                  Text('🔥 ${entry.streak} day streak',
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
            _sectionTitle('Account'),
            _settingsCard([
              _settingsRow(Icons.person_rounded, 'Edit Profile', onTap: () {
                Navigator.pop(context);
              }),
              _settingsDivider(),
              _settingsRow(Icons.lock_rounded, 'Change Password', onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.email_rounded, 'Email', subtitle: 'user@example.com'),
            ]),
            const SizedBox(height: 20),

            // Preferences section
            _sectionTitle('Preferences'),
            _settingsCard([
              _settingsToggle(Icons.notifications_rounded, 'Notifications',
                  _notificationsEnabled, (v) {
                setState(() => _notificationsEnabled = v);
              }),
              _settingsDivider(),
              _settingsToggle(Icons.volume_up_rounded, 'Sound Effects',
                  _soundEnabled, (v) {
                setState(() => _soundEnabled = v);
              }),
              _settingsDivider(),
              _settingsToggle(Icons.vibration_rounded, 'Haptic Feedback',
                  _hapticEnabled, (v) {
                setState(() => _hapticEnabled = v);
              }),
              _settingsDivider(),
              _settingsRow(Icons.language_rounded, 'Language',
                  subtitle: _language, onTap: () {
                _showLanguageDialog();
              }),
            ]),
            const SizedBox(height: 20),

            // Learning section
            _sectionTitle('Learning'),
            _settingsCard([
              _settingsRow(Icons.schedule_rounded, 'Daily Reminder',
                  subtitle: '9:00 AM', onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.speed_rounded, 'Difficulty',
                  subtitle: 'Adaptive', onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.restart_alt_rounded, 'Reset Progress',
                  isDestructive: true, onTap: () {
                _showResetDialog();
              }),
            ]),
            const SizedBox(height: 20),

            // About section
            _sectionTitle('About'),
            _settingsCard([
              _settingsRow(Icons.info_rounded, 'Version',
                  subtitle: '1.0.0 (Beta)'),
              _settingsDivider(),
              _settingsRow(Icons.description_rounded, 'Terms of Service',
                  onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.privacy_tip_rounded, 'Privacy Policy',
                  onTap: () {}),
              _settingsDivider(),
              _settingsRow(Icons.help_rounded, 'Help & Support', onTap: () {}),
            ]),
            const SizedBox(height: 20),

            // Subscription
            _sectionTitle('Subscription'),
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
                  Text('Upgrade to Pro',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                      'Unlimited lives, matches, and exclusive avatar frames',
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
                    child: Text('View Plans',
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
                child: Text('Log Out',
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
        title: Text('Language',
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
        title: Text('Reset Progress',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to reset all your learning progress? This action cannot be undone.',
            style: GoogleFonts.nunito(color: const Color(0xFF757575))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Reset',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
