import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../services/firebase_service.dart';
import 'learn_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _avatarOptions = [
    '🐼', '🀇', '🐉', '🐯', '🦊', '🐱', '🐶', '🐰',
  ];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD94040))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Avatar & Nickname
            _buildProfileHeader(context, game),
            const SizedBox(height: 24),

            // Stats cards
            _buildStatCards(game),
            const SizedBox(height: 24),

            // Wrong Answer Review
            _buildWrongAnswerReview(context, game),
            const SizedBox(height: 24),

            // Achievements
            _buildAchievements(game),
            const SizedBox(height: 24),

            // Stage progress
            _buildStageProgress(game),
            const SizedBox(height: 24),

            // Premium toggle
            _buildPremiumToggle(game),
            const SizedBox(height: 16),

            // Logout button
            _buildLogoutButton(context),
            const SizedBox(height: 16),
            // About
            _buildAbout(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══ Profile Header ═══
  Widget _buildProfileHeader(BuildContext context, GameState game) {
    return Row(
      children: [
        // Avatar selector
        GestureDetector(
          onTap: () => _showAvatarPicker(context, game),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD94040).withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
              border:
                  Border.all(color: const Color(0xFFD94040).withAlpha(50), width: 2),
            ),
            child: Center(
              child: Text(game.avatarEmoji,
                  style: GoogleFonts.nunito(fontSize: 36)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Name & level
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showNicknameDialog(context, game),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(game.nickname,
                        style: GoogleFonts.nunito(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_rounded,
                        size: 16, color: const Color(0xFFBDBDBD)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD94040).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(game.userLevel,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD94040))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNicknameDialog(BuildContext context, GameState game) {
    final controller = TextEditingController(text: game.nickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nickname',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          decoration: const InputDecoration(hintText: 'Enter nickname'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                game.setNickname(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, GameState game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose Avatar',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 240,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _avatarOptions.map((emoji) {
              final selected = game.avatarEmoji == emoji;
              return GestureDetector(
                onTap: () {
                  game.setAvatarEmoji(emoji);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFFF0F0)
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: const Color(0xFFD94040), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: GoogleFonts.nunito(fontSize: 26)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ═══ Wrong Answer Review ═══
  Widget _buildWrongAnswerReview(BuildContext context, GameState game) {
    final count = game.wrongAnswerCount;
    return GestureDetector(
      onTap: count > 0
          ? () {
              game.startWrongAnswerReview();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LearnScreen(),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: count > 0
              ? const Color(0xFFFFF9E6)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: count > 0
                ? const Color(0xFFE8B93E).withAlpha(80)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: count > 0
                    ? const Color(0xFFE8B93E).withAlpha(25)
                    : const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.replay_rounded,
                  color: count > 0
                      ? const Color(0xFFE8B93E)
                      : const Color(0xFFBDBDBD),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wrong Answer Review',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: count > 0
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count > 0
                        ? '$count wrong answer${count > 1 ? 's' : ''} to review'
                        : 'No wrong answers yet',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: count > 0
                          ? const Color(0xFF757575)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
            if (count > 0)
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Color(0xFFE8B93E)),
          ],
        ),
      ),
    );
  }

  // ═══ Stat Cards ═══
  Widget _buildStatCards(GameState game) {
    return Row(
      children: [
        _statCard('🔥 Streak', '${game.streak} days', const Color(0xFFE8B93E)),
        const SizedBox(width: 10),
        _statCard('⭐ XP', '${game.xp}', const Color(0xFFD94040)),
        const SizedBox(width: 10),
        _statCard(
            '📚 Lessons', '${game.completedLessons}', const Color(0xFF2E7D32)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withAlpha(25), color.withAlpha(8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(38)),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFF757575))),
          ],
        ),
      ),
    );
  }

  // ═══ Achievements ═══
  Widget _buildAchievements(GameState game) {
    final defs = achievementDefs.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFE8B93E), size: 20),
            const SizedBox(width: 6),
            Text('Achievements',
                style: GoogleFonts.nunito(
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            // Count
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B93E).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${game.unlockedAchievements.length}/${defs.length}',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE8B93E)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemCount: defs.length,
          itemBuilder: (context, index) {
            final def = defs[index];
            final unlocked = game.unlockedAchievements.contains(def.id);
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: unlocked ? Colors.white : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFFE8B93E).withAlpha(76)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    def.emoji,
                    style: GoogleFonts.nunito(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    def.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: unlocked
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                  if (!unlocked)
                    const Icon(Icons.lock_rounded,
                        size: 12, color: Color(0xFFBDBDBD)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══ Stage progress ═══
  Widget _buildStageProgress(GameState game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stage Progress',
            style: GoogleFonts.nunito(
                fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...game.stages.map((stage) {
          final frac = stage.lessonCount > 0
              ? stage.completedLessons / stage.lessonCount
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(stage.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: frac,
                      backgroundColor: const Color(0xFFF5F5F5),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(stage.color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${stage.completedLessons}/${stage.lessonCount}',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF9E9E9E)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ═══ Premium Toggle ═══
  Widget _buildPremiumToggle(GameState game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: game.isPremium
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: game.isPremium
                ? const Color(0xFFE8B93E)
                : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(
              game.isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.workspace_premium_outlined,
              color: const Color(0xFFE8B93E),
              size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Premium Mode',
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                    game.isPremium
                        ? 'Unlimited hearts enabled'
                        : 'Unlock unlimited hearts & ad-free',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF757575))),
              ],
            ),
          ),
          Switch(
            value: game.isPremium,
            activeColor: const Color(0xFFE8B93E),
            onChanged: (v) => game.setPremium(v),
          ),
        ],
      ),
    );
  }

  // ═══ Logout ═══
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await FirebaseService.signOut();
          if (context.mounted) {
            context.read<GameState>().disableCloudSync();
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text('Sign Out',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF757575),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ═══ About ═══
  Widget _buildAbout() {
    return Text(
      'Ludi v2.0.0 · Your guide to mastering board games',
      textAlign: TextAlign.center,
      style: GoogleFonts.nunito(
          fontSize: 11, color: const Color(0xFFBDBDBD)),
    );
  }
}
