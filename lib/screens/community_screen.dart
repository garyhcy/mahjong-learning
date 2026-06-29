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
  final bool isCurrentUser;

  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.xp,
    this.isCurrentUser = false,
  });
}

const List<_LeaderboardEntry> _fakeLeaderboard = [
  _LeaderboardEntry(rank: 1, name: 'Jason', avatar: '🐉', xp: 3120),
  _LeaderboardEntry(rank: 2, name: 'Emily', avatar: '🐱', xp: 2340),
  _LeaderboardEntry(rank: 3, name: 'David', avatar: '🎯', xp: 1980),
  _LeaderboardEntry(rank: 4, name: 'Michelle', avatar: '🌸', xp: 1650),
  _LeaderboardEntry(rank: 5, name: 'Sarah', avatar: '🦊', xp: 1420),
];

// ─── Achievement display model ───
class _AchievementDisplay {
  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;

  const _AchievementDisplay({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.unlocked = true,
  });
}

const List<_AchievementDisplay> _achievementShowcase = [
  _AchievementDisplay(emoji: '🎓', title: 'Beginner', subtitle: 'Complete 1 unit'),
  _AchievementDisplay(emoji: '🐦', title: 'Early Bird', subtitle: 'Morning study'),
  _AchievementDisplay(emoji: '🔥', title: '7-Day Streak', subtitle: 'Study 7 days'),
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
    final avatarEmoji = game.avatarEmoji;
    final userLevel = game.userLevel;
    final unlockedCount = game.unlockedAchievements.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ─── Profile Header ───
              _buildProfileHeader(context, nickname, avatarEmoji, userLevel),
              const SizedBox(height: 16),
              // ─── League Card ───
              _buildLeagueCard(context),
              const SizedBox(height: 16),
              // ─── Stats Row ───
              _buildStatsRow(userXp, userStreak, completedCount),
              const SizedBox(height: 24),
              // ─── Achievements Section ───
              _buildAchievementsSection(context, unlockedCount),
              const SizedBox(height: 24),
              // ─── Leaderboard Section ───
              _buildLeaderboardSection(context, userXp, nickname, avatarEmoji),
              const SizedBox(height: 24),
              // ─── Find a Match Card ───
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
      BuildContext context, String nickname, String avatarEmoji, String level) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
          child: Center(
            child: Text(avatarEmoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 14),
        // Name & Level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Icon(Icons.edit_rounded,
                      size: 16, color: const Color(0xFFBDBDBD)),
                ],
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
        Container(
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
      ],
    );
  }

  // ─── League Card ───
  Widget _buildLeagueCard(BuildContext context) {
    return Container(
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
          // League icon
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
          // League info
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
          // League gem
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
        ],
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
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFEEEEEE),
    );
  }

  // ─── Achievements Section ───
  Widget _buildAchievementsSection(BuildContext context, int unlockedCount) {
    return Column(
      children: [
        // Section header
        Row(
          children: [
            Text(
              'Achievements',
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Achievement badges row
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
            children: _achievementShowcase.map((a) {
              return _achievementBadge(a);
            }).toList(),
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
            child: Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: 24,
                color: achievement.unlocked ? null : const Color(0xFFBDBDBD),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          achievement.title,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: achievement.unlocked
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFBDBDBD),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          achievement.subtitle,
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: const Color(0xFF9E9E9E),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Leaderboard Section ───
  Widget _buildLeaderboardSection(
      BuildContext context, int userXp, String nickname, String avatarEmoji) {
    // Build full list with current user
    final allEntries = [
      ..._fakeLeaderboard,
    ];

    // Determine user rank
    int userRank = allEntries.length + 1;
    for (int i = 0; i < allEntries.length; i++) {
      if (userXp >= allEntries[i].xp) {
        userRank = allEntries[i].rank;
        break;
      }
    }

    return Column(
      children: [
        // Section header
        Row(
          children: [
            Text(
              'Friend Leaderboard',
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Leaderboard card
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
              ...allEntries.take(5).map((e) => _leaderboardRow(e)),
              // Current user row (highlighted)
              _leaderboardRow(_LeaderboardEntry(
                rank: userRank > 5 ? 6 : userRank,
                name: nickname,
                avatar: avatarEmoji,
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
          // Rank number
          SizedBox(
            width: 24,
            child: Text(
              '${entry.rank}',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isUser
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFFC8E6C9)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(entry.avatar, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              entry.name,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          // XP
          Text(
            '${entry.xp} XP',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isUser
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF757575),
            ),
          ),
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
          // Header row
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
                  child: Text('🀄', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a Match',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      'Play offline with matched players',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
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
                child: Text(
                  'Coming Soon',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Features
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
                  Icons.psychology_rounded,
                  'Matched by your skill level',
                ),
                const SizedBox(height: 10),
                _matchFeatureRow(
                  Icons.language_rounded,
                  'Language-based pairing',
                ),
                const SizedBox(height: 10),
                _matchFeatureRow(
                  Icons.storefront_rounded,
                  'Verified venues with transparent pricing',
                ),
                const SizedBox(height: 10),
                _matchFeatureRow(
                  Icons.support_agent_rounded,
                  'On-site staff for rules assistance',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Notify Me When Available',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF757575),
                ),
              ),
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
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
          ),
        ),
      ],
    );
  }
}
