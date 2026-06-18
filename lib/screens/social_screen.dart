import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../services/firebase_service.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Community',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4CAF50))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Daily Tasks ──
            _buildDailyTasks(game),
            const SizedBox(height: 24),

            // ── Share Progress ──
            _buildShareProgress(context, game),
            const SizedBox(height: 24),

            // ── Leaderboard ──
            _buildLeaderboard(game),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══ Daily Tasks ═══
  Widget _buildDailyTasks(GameState game) {
    final tasks = [
      {
        'id': 'complete_lesson',
        'icon': Icons.menu_book_rounded,
        'name': 'Complete 1 Lesson',
        'target': 1,
        'reward': 5,
        'progress': game.lessonCompletedToday > 0 ? 1 : 0,
        'claimed': game.dailyTasks['complete_lesson_claimed'] == 1,
        'done': game.lessonCompletedToday >= 1,
      },
      {
        'id': 'streak_3',
        'icon': Icons.checklist_rounded,
        'name': '3 Correct in a Row',
        'target': 3,
        'reward': 10,
        'progress': game.consecutiveCorrect,
        'claimed': game.dailyTasks['streak_3_claimed'] == 1,
        'done': game.consecutiveCorrect >= 3,
      },
      {
        'id': 'earn_50xp',
        'icon': Icons.stars_rounded,
        'name': 'Earn 50 XP',
        'target': 50,
        'reward': 15,
        'progress': game.dailyXpEarned,
        'claimed': game.dailyTasks['earn_50xp_claimed'] == 1,
        'done': game.dailyXpEarned >= 50,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFE8B93E), size: 22),
              const SizedBox(width: 8),
              Text('Daily Tasks',
                  style: GoogleFonts.nunito(
                      fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Complete tasks to earn bonus XP',
              style: GoogleFonts.nunito(
                  fontSize: 12, color: const Color(0xFF757575))),
          const SizedBox(height: 14),
          ...tasks.map((task) {
            final progress = task['progress'] as int;
            final target = task['target'] as int;
            final done = task['done'] as bool;
            final claimed = task['claimed'] as bool;
            final reward = task['reward'] as int;
            final frac = (progress / target).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(task['icon'] as IconData,
                      size: 20,
                      color: done
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF9E9E9E)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['name'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: frac,
                            minHeight: 4,
                            backgroundColor: const Color(0xFFF5F5F5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                done
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF4CAF50)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (claimed)
                    Icon(Icons.check_circle_rounded,
                        color: const Color(0xFF2E7D32), size: 20)
                  else if (done)
                    GestureDetector(
                      onTap: () => game.claimDailyTaskReward(
                          task['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8B93E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('+${reward}XP',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    )
                  else
                    Text('$progress/$target',
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: const Color(0xFF9E9E9E))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══ Share Progress ═══
  Widget _buildShareProgress(BuildContext context, GameState game) {
    // Find current stage
    String currentStage = '1';
    for (final stage in game.stages.reversed) {
      if (stage.completedLessons > 0) {
        currentStage = stage.title;
        break;
      }
    }

    final message =
        "I'm learning board games on Ludi! "
        "Stage: $currentStage, XP: ${game.xp}, Streak: ${game.streak} days!";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.share_rounded,
              color: Color(0xFF4CAF50), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Share Your Progress',
                style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard!',
                      style: GoogleFonts.nunito()),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ Leaderboard ═══
  Widget _buildLeaderboard(GameState game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.leaderboard_rounded,
                color: Color(0xFFE8B93E), size: 22),
            const SizedBox(width: 8),
            Text('Leaderboard',
                style: GoogleFonts.nunito(
                    fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.getLeaderboard(),
          builder: (context, snapshot) {
            // Loading skeleton
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeletonLeaderboard();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Leaderboard unavailable. Please check your connection.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: const Color(0xFF9E9E9E)),
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No players yet. Be the first!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: const Color(0xFF9E9E9E)),
                  ),
                ),
              );
            }

            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            final rankColors = [
              const Color(0xFFE8B93E), // gold
              const Color(0xFF9E9E9E), // silver
              const Color(0xFFCD7F32), // bronze
            ];

            return Column(
              children: docs.asMap().entries.map((entry) {
                final i = entry.key;
                final doc = entry.value;
                final data = doc.data() as Map<String, dynamic>;
                final xp = (data['xp'] as num?)?.toInt() ?? 0;
                final email = (data['email'] as String?) ?? '';
                final nickname = (data['nickname'] as String?) ?? '';
                final avatarEmoji = (data['avatarEmoji'] as String?) ?? '🐼';
                final uid = doc.id;
                final isCurrentUser = uid == currentUid;

                // Display name: nickname > email prefix > "Player"
                String displayName = 'Player';
                if (nickname.isNotEmpty) {
                  displayName = nickname;
                } else if (email.isNotEmpty) {
                  displayName = email.split('@').first;
                }
                final prefix =
                    avatarEmoji.isNotEmpty ? '$avatarEmoji ' : '';
                final fullName = '$prefix$displayName${isCurrentUser ? ' (You)' : ''}';

                final rankColor =
                    i < 3 ? rankColors[i] : const Color(0xFF757575);
                final rankBadge = i < 3
                    ? ['🥇', '🥈', '🥉'][i]
                    : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? const Color(0xFFFFF0F0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isCurrentUser
                            ? const Color(0xFF4CAF50).withAlpha(76)
                            : i < 3
                                ? rankColor.withAlpha(76)
                                : const Color(0xFFEEEEEE),
                        width: i < 3 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            rankBadge.isNotEmpty ? rankBadge : '${i + 1}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: rankBadge.isNotEmpty ? 20 : 14,
                              fontWeight: FontWeight.w800,
                              color: rankColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fullName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: isCurrentUser
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isCurrentUser
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                        Text(
                          '$xp XP',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isCurrentUser
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        // Coming soon teaser
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Multiplayer matches are under development. Stay tuned!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLeaderboard() {
    return Column(
      children: List.generate(5, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 24,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}
