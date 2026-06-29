import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/mascot_widget.dart';

// ─── Fake leaderboard data ───
class _LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int xp;
  final int streak;
  final bool isCurrentUser;

  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.xp,
    this.streak = 0,
    this.isCurrentUser = false,
  });
}

const List<_LeaderboardEntry> _fakeLeaderboard = [
  _LeaderboardEntry(rank: 1, name: 'Jason', avatar: '🐉', xp: 3120, streak: 14),
  _LeaderboardEntry(rank: 2, name: 'Emily', avatar: '🐱', xp: 2340, streak: 9),
  _LeaderboardEntry(rank: 3, name: 'David', avatar: '🎯', xp: 1980, streak: 7),
  _LeaderboardEntry(rank: 4, name: 'Michelle', avatar: '🌸', xp: 1650, streak: 5),
  _LeaderboardEntry(rank: 5, name: 'Sarah', avatar: '🦊', xp: 1420, streak: 3),
  _LeaderboardEntry(rank: 6, name: 'Kevin', avatar: '🎮', xp: 1280, streak: 4),
  _LeaderboardEntry(rank: 7, name: 'Amy', avatar: '🌺', xp: 1100, streak: 2),
  _LeaderboardEntry(rank: 8, name: 'Tom', avatar: '🦁', xp: 980, streak: 6),
  _LeaderboardEntry(rank: 9, name: 'Lisa', avatar: '🐼', xp: 870, streak: 1),
  _LeaderboardEntry(rank: 10, name: 'Chris', avatar: '🎲', xp: 750, streak: 3),
];

// ─── Achievement display model ───
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
  _AchievementDisplay(id: 'first_lesson', emoji: '🎓', title: 'Beginner', subtitle: 'Complete 1 lesson'),
  _AchievementDisplay(id: 'early_bird', emoji: '🐦', title: 'Early Bird', subtitle: 'Morning study'),
  _AchievementDisplay(id: 'streak_7', emoji: '🔥', title: '7-Day Streak', subtitle: 'Study 7 days'),
  _AchievementDisplay(id: 'streak_30', emoji: '💪', title: '30-Day Streak', subtitle: 'Study 30 days', unlocked: false),
  _AchievementDisplay(id: 'perfect_quiz', emoji: '💯', title: 'Perfect Score', subtitle: '100% on a quiz'),
  _AchievementDisplay(id: 'five_lessons', emoji: '📚', title: 'Bookworm', subtitle: 'Complete 5 lessons'),
  _AchievementDisplay(id: 'ten_lessons', emoji: '🏆', title: 'Champion', subtitle: 'Complete 10 lessons', unlocked: false),
  _AchievementDisplay(id: 'social', emoji: '🤝', title: 'Social', subtitle: 'Add 3 friends', unlocked: false),
  _AchievementDisplay(id: 'night_owl', emoji: '🦉', title: 'Night Owl', subtitle: 'Study after 10pm', unlocked: false),
  _AchievementDisplay(id: 'speed_demon', emoji: '⚡', title: 'Speed Demon', subtitle: 'Finish quiz in 60s', unlocked: false),
  _AchievementDisplay(id: 'explorer', emoji: '🗺️', title: 'Explorer', subtitle: 'Try all stages', unlocked: false),
  _AchievementDisplay(id: 'master', emoji: '👑', title: 'Master', subtitle: 'Reach Expert level', unlocked: false),
];

// ─── Main Widget ───
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final userXp = game.xp;
    final userStreak = game.streak;
    final completedCount = game.completedLessons;
    final nickname = game.nickname;
    final userLevel = game.userLevel;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildProfileHeader(context, nickname, userLevel, game),
              const SizedBox(height: 16),
              _buildLeagueCard(context),
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

  // ─── Profile Header (Mascot avatar + editable nickname) ───
  Widget _buildProfileHeader(
      BuildContext context, String nickname, String level, GameState game) {
    return Row(
      children: [
        // Mascot Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
          child: const ClipOval(
            child: MascotWidget(
              expression: MascotExpression.happy,
              size: 48,
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Name & Level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showNicknameDialog(context, game),
                child: Row(
                  children: [
                    Text(
                      nickname,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2D2D),
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
                level,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: const Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
        // Settings icon
        GestureDetector(
          onTap: () {
            // Navigate to settings/profile
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const _SettingsPlaceholderPage(),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  // ─── League Card (tappable) ───
  Widget _buildLeagueCard(BuildContext context) {
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('💎', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emerald League',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    'Rank #2',
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
                color: const Color(0xFF4CAF50).withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('💎', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFBDBDBD), size: 20),
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
          _statItem('⚡', 'Total XP', '$xp XP'),
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
            style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF9E9E9E))),
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
    final showcase = _allAchievements.take(3).toList();
    return Column(
      children: [
        Row(
          children: [
            Text('Achievements',
                style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
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
            child: Text(achievement.emoji,
                style: TextStyle(
                    fontSize: 24,
                    color:
                        achievement.unlocked ? null : const Color(0xFFBDBDBD))),
          ),
        ),
        const SizedBox(height: 8),
        Text(achievement.title,
            style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: achievement.unlocked
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFBDBDBD)),
            textAlign: TextAlign.center),
        Text(achievement.subtitle,
            style: GoogleFonts.nunito(
                fontSize: 10, color: const Color(0xFF9E9E9E)),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ─── Leaderboard Section ───
  Widget _buildLeaderboardSection(
      BuildContext context, int userXp, String nickname) {
    final topEntries = _fakeLeaderboard.take(3).toList();

    int userRank = _fakeLeaderboard.length + 1;
    for (int i = 0; i < _fakeLeaderboard.length; i++) {
      if (userXp >= _fakeLeaderboard[i].xp) {
        userRank = _fakeLeaderboard[i].rank;
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
              // Current user row
              _leaderboardRow(_LeaderboardEntry(
                rank: userRank > 5 ? 6 : userRank,
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
            child: Text(entry.name,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
                    color: const Color(0xFF2D2D2D))),
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
                child: Text('Coming Soon',
                    style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE65100))),
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
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Notify Me When Available',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF757575))),
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
// ─── League Detail Page ───
// ═══════════════════════════════════════════════════════════════
class _LeagueDetailPage extends StatelessWidget {
  const _LeagueDetailPage();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final xp = game.xp;

    // League tiers
    final leagues = [
      {'name': 'Bronze', 'emoji': '🥉', 'min': 0, 'max': 500},
      {'name': 'Silver', 'emoji': '🥈', 'min': 500, 'max': 1000},
      {'name': 'Gold', 'emoji': '🥇', 'min': 1000, 'max': 2000},
      {'name': 'Emerald', 'emoji': '💎', 'min': 2000, 'max': 3500},
      {'name': 'Diamond', 'emoji': '👑', 'min': 3500, 'max': 5000},
    ];

    // Determine current league
    int currentIdx = 0;
    for (int i = leagues.length - 1; i >= 0; i--) {
      if (xp >= (leagues[i]['min'] as int)) {
        currentIdx = i;
        break;
      }
    }

    final currentLeague = leagues[currentIdx];
    final maxXp = currentLeague['max'] as int;
    final minXp = currentLeague['min'] as int;
    final progress = (xp - minXp) / (maxXp - minXp);

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
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(currentLeague['emoji'] as String,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(currentLeague['name'] as String,
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Rank #2 this week',
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: Colors.white.withAlpha(200))),
                  const SizedBox(height: 20),
                  // Progress bar
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
                  Text('$xp / $maxXp XP',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.white.withAlpha(200))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // All leagues
            ...leagues.asMap().entries.map((entry) {
              final idx = entry.key;
              final league = entry.value;
              final isCurrent = idx == currentIdx;
              final isUnlocked = idx <= currentIdx;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFFE8F5E9)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isCurrent
                      ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
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
                    Text(league['emoji'] as String,
                        style: TextStyle(
                            fontSize: 28,
                            color: isUnlocked ? null : Colors.grey)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(league['name'] as String,
                              style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isUnlocked
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFBDBDBD))),
                          Text('${league['min']} - ${league['max']} XP',
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
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Current',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      )
                    else if (isUnlocked)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF4CAF50), size: 22)
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
    final unlockedCount =
        _allAchievements.where((a) => a.unlocked).length;
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
            Text('Unlocked',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _allAchievements
                  .where((a) => a.unlocked)
                  .map((a) => _achievementGridItem(a))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Locked
            Text('Locked',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9E9E9E))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
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
      width: 80,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
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
                      fontSize: 26,
                      color: a.unlocked ? null : const Color(0xFFBDBDBD))),
            ),
          ),
          const SizedBox(height: 6),
          Text(a.title,
              style: GoogleFonts.nunito(
                  fontSize: 11,
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
        userRank = _fakeLeaderboard[i].rank;
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top 3 podium
            _buildPodium(),
            const SizedBox(height: 20),
            // Full list
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

  Widget _buildPodium() {
    final top3 = _fakeLeaderboard.take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        _podiumItem(top3[1], 70, const Color(0xFFC0C0C0)),
        const SizedBox(width: 8),
        // 1st place
        _podiumItem(top3[0], 90, const Color(0xFFFFD700)),
        const SizedBox(width: 8),
        // 3rd place
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
// ─── Settings Placeholder Page ───
// ═══════════════════════════════════════════════════════════════
class _SettingsPlaceholderPage extends StatelessWidget {
  const _SettingsPlaceholderPage();

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MascotWidget(
              expression: MascotExpression.thinking,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text('Settings coming soon!',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF757575))),
          ],
        ),
      ),
    );
  }
}
