import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/mascot_widget.dart';

// ─── Fake data models ───
class _FriendActivity {
  final String name;
  final String avatar;
  final String action;
  final String timeAgo;
  final Color avatarColor;

  const _FriendActivity({
    required this.name,
    required this.avatar,
    required this.action,
    required this.timeAgo,
    required this.avatarColor,
  });
}

class _LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int xp;
  final int streak;
  final Color avatarColor;
  final bool isCurrentUser;

  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.xp,
    required this.streak,
    required this.avatarColor,
    this.isCurrentUser = false,
  });
}

// ─── Fake data ───
const List<_FriendActivity> _fakeFriendActivities = [
  _FriendActivity(
    name: 'Emily',
    avatar: '🐱',
    action: 'completed Stage 3: Scoring Basics',
    timeAgo: '5 min ago',
    avatarColor: Color(0xFFE8F5E9),
  ),
  _FriendActivity(
    name: 'Jason',
    avatar: '🐉',
    action: 'is on a 7-day streak!',
    timeAgo: '20 min ago',
    avatarColor: Color(0xFFFFF3E0),
  ),
  _FriendActivity(
    name: 'Michelle',
    avatar: '🌸',
    action: 'earned the "Perfectionist" badge',
    timeAgo: '1 hr ago',
    avatarColor: Color(0xFFFCE4EC),
  ),
  _FriendActivity(
    name: 'David',
    avatar: '🎯',
    action: 'unlocked Stage 5: Defensive Play',
    timeAgo: '2 hr ago',
    avatarColor: Color(0xFFE3F2FD),
  ),
  _FriendActivity(
    name: 'Sarah',
    avatar: '🦊',
    action: 'completed 3 lessons today',
    timeAgo: '3 hr ago',
    avatarColor: Color(0xFFF3E5F5),
  ),
];

const List<_LeaderboardEntry> _fakeLeaderboard = [
  _LeaderboardEntry(rank: 1, name: 'Jason', avatar: '🐉', xp: 3120, streak: 14, avatarColor: Color(0xFFFFF3E0)),
  _LeaderboardEntry(rank: 2, name: 'Emily', avatar: '🐱', xp: 2340, streak: 7, avatarColor: Color(0xFFE8F5E9)),
  _LeaderboardEntry(rank: 3, name: 'David', avatar: '🎯', xp: 1980, streak: 5, avatarColor: Color(0xFFE3F2FD)),
  _LeaderboardEntry(rank: 4, name: 'Michelle', avatar: '🌸', xp: 1650, streak: 3, avatarColor: Color(0xFFFCE4EC)),
  _LeaderboardEntry(rank: 5, name: 'Sarah', avatar: '🦊', xp: 1420, streak: 9, avatarColor: Color(0xFFF3E5F5)),
  _LeaderboardEntry(rank: 6, name: 'Kevin', avatar: '🎮', xp: 1280, streak: 2, avatarColor: Color(0xFFE0F7FA)),
  _LeaderboardEntry(rank: 7, name: 'Rachel', avatar: '🌺', xp: 1150, streak: 4, avatarColor: Color(0xFFFFF8E1)),
  _LeaderboardEntry(rank: 8, name: 'Tom', avatar: '🐼', xp: 1020, streak: 6, avatarColor: Color(0xFFEFEBE9)),
  _LeaderboardEntry(rank: 9, name: 'Lisa', avatar: '🦋', xp: 980, streak: 1, avatarColor: Color(0xFFE8EAF6)),
  _LeaderboardEntry(rank: 10, name: 'Alex', avatar: '🔥', xp: 910, streak: 3, avatarColor: Color(0xFFFBE9E7)),
];

// ─── Main Widget ───
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ───
            _buildTopBar(),
            // ─── Tab Bar ───
            _buildTabBar(),
            // ─── Tab Content ───
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsTab(),
                  _buildLeaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ───
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(
            'Community',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_rounded,
                    color: Color(0xFF4CAF50), size: 16),
                const SizedBox(width: 4),
                Text(
                  '6 Friends',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab Bar ───
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF2D2D2D),
        unselectedLabelColor: const Color(0xFF757575),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Friends'),
          Tab(text: 'Leaderboard'),
        ],
      ),
    );
  }

  // ─── Friends Tab ───
  Widget _buildFriendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Friend Activity Feed
          ..._fakeFriendActivities.map((a) => _buildActivityCard(a)),
          const SizedBox(height: 24),
          // Find a Match Card
          _buildMatchCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Activity Card ───
  Widget _buildActivityCard(_FriendActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activity.avatarColor,
            ),
            child: Center(
              child: Text(activity.avatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF2D2D2D),
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: activity.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' ${activity.action}'),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity.timeAgo,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Leaderboard Tab ───
  Widget _buildLeaderboardTab() {
    final game = context.watch<GameState>();
    final userXp = game.xp;
    final userStreak = game.streak;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Stats Card
          _buildYourStatsCard(userXp, userStreak),
          const SizedBox(height: 20),
          // Podium (Top 3)
          _buildPodium(),
          const SizedBox(height: 20),
          // Full Leaderboard
          _buildSectionHeader('Rankings', Icons.format_list_numbered_rounded),
          const SizedBox(height: 12),
          ..._fakeLeaderboard.skip(3).map((e) => _buildLeaderboardRow(e)),
          // Current user row
          _buildLeaderboardRow(_LeaderboardEntry(
            rank: 11,
            name: 'You',
            avatar: '🐼',
            xp: userXp,
            streak: userStreak,
            avatarColor: const Color(0xFFE8F5E9),
            isCurrentUser: true,
          )),
          const SizedBox(height: 24),
          // Find a Match Card
          _buildMatchCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Your Stats Card ───
  Widget _buildYourStatsCard(int xp, int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF56A85C), Color(0xFF3D8B44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const MascotWidget(
            expression: MascotExpression.excited,
            size: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Ranking',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '#11 this week',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statPill(Icons.bolt_rounded, '$xp XP'),
                    const SizedBox(width: 8),
                    _statPill(
                        Icons.local_fire_department_rounded, '$streak days'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Podium ───
  Widget _buildPodium() {
    final top3 = _fakeLeaderboard.take(3).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildPodiumItem(top3[1], 90, const Color(0xFFC0C0C0))),
        const SizedBox(width: 8),
        Expanded(child: _buildPodiumItem(top3[0], 110, const Color(0xFFFFD700))),
        const SizedBox(width: 8),
        Expanded(child: _buildPodiumItem(top3[2], 75, const Color(0xFFCD7F32))),
      ],
    );
  }

  Widget _buildPodiumItem(
      _LeaderboardEntry entry, double height, Color medalColor) {
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    return Column(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: entry.avatarColor,
            border: Border.all(color: medalColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: medalColor.withAlpha(60),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(entry.avatar, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.name,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${entry.xp} XP',
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 6),
        // Podium bar
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                medalColor,
                medalColor.withAlpha(180),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              medals[entry.rank]!,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Leaderboard Row ───
  Widget _buildLeaderboardRow(_LeaderboardEntry entry) {
    final bgColor =
        entry.isCurrentUser ? const Color(0xFFE8F5E9) : Colors.white;
    final borderColor = entry.isCurrentUser
        ? const Color(0xFF4CAF50).withAlpha(60)
        : const Color(0xFFF0F0F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: entry.isCurrentUser
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: entry.isCurrentUser
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.avatarColor,
            ),
            child: Center(
              child: Text(entry.avatar, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isCurrentUser ? 'You' : entry.name,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight:
                        entry.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                if (entry.streak > 0)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 11, color: Color(0xFFFF6D00)),
                      const SizedBox(width: 2),
                      Text(
                        '${entry.streak}-day streak',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: const Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // XP
          Text(
            '${entry.xp} XP',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: entry.isCurrentUser
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  // ─── Find a Match Card ───
  Widget _buildMatchCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                        fontSize: 17,
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
          // Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _matchFeatureRow(
                  Icons.psychology_rounded,
                  'Matched by your skill level',
                  'Play with opponents at a similar stage',
                ),
                const SizedBox(height: 10),
                _matchFeatureRow(
                  Icons.language_rounded,
                  'Language-based pairing',
                  'Find players who speak your language',
                ),
                const SizedBox(height: 10),
                _matchFeatureRow(
                  Icons.storefront_rounded,
                  'Verified venues',
                  'Transparent pricing with staff on-site',
                ),
                const SizedBox(height: 10),
                _matchFeatureRow(
                  Icons.support_agent_rounded,
                  'On-site assistance',
                  'Staff available for rules questions',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // CTA Button (disabled, coming soon)
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

  Widget _matchFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
