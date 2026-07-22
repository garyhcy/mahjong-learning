import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/mascot_widget.dart';
import '../services/app_i18n.dart';

// Achievement display metadata (id + icon + color). Unlock state is read live
// from GameState.unlockedAchievements so the UI reflects actual progress.
class _AchievementMeta {
  final String id;
  final IconData icon;
  final Color color;
  const _AchievementMeta(this.id, this.icon, this.color);
}

const List<_AchievementMeta> _allAchievements = [
  _AchievementMeta('first_lesson', Icons.school_rounded, Color(0xFF4CAF50)),
  _AchievementMeta('early_bird', Icons.wb_sunny_rounded, Color(0xFFFF9800)),
  _AchievementMeta('streak_3', Icons.local_fire_department_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('streak_7', Icons.whatshot_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('perfect_quiz', Icons.stars_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('five_lessons', Icons.menu_book_rounded, Color(0xFF4CAF50)),
  _AchievementMeta('first_stage', Icons.auto_awesome_rounded, Color(0xFF4CAF50)),
  _AchievementMeta('quick_learner', Icons.speed_rounded, Color(0xFF2196F3)),
  _AchievementMeta('comeback', Icons.refresh_rounded, Color(0xFF607D8B)),
  _AchievementMeta('night_owl', Icons.nights_stay_rounded, Color(0xFF5C6BC0)),
  _AchievementMeta('streak_14', Icons.star_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('streak_30', Icons.emoji_events_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('ten_lessons', Icons.library_books_rounded, Color(0xFF4CAF50)),
  _AchievementMeta('twenty_lessons', Icons.collections_bookmark_rounded, Color(0xFF4CAF50)),
  _AchievementMeta('all_stages', Icons.workspace_premium_rounded, Color(0xFF9C27B0)),
  _AchievementMeta('social_3', Icons.handshake_rounded, Color(0xFF4CAF50)),
  _AchievementMeta('social_10', Icons.celebration_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('first_match', Icons.casino_rounded, Color(0xFF9C27B0)),
  _AchievementMeta('match_5', Icons.sports_esports_rounded, Color(0xFF2196F3)),
  _AchievementMeta('match_win', Icons.emoji_events_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('speed_demon', Icons.bolt_rounded, Color(0xFFFF6B35)),
  _AchievementMeta('explorer', Icons.explore_rounded, Color(0xFF9C27B0)),
  _AchievementMeta('gold_league', Icons.emoji_events_rounded, Color(0xFFE8B93E)),
  _AchievementMeta('diamond_league', Icons.diamond_rounded, Color(0xFF7C4DFF)),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final unlockedSet = game.unlockedAchievements;
    final unlockedCount = unlockedSet.length;
    final total = _allAchievements.length;
    final progress = total > 0 ? unlockedCount / total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppI18n.t('community.achievements'),
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8B93E), Color(0xFFF9A825)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8B93E).withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const MascotWidget(
                      expression: MascotExpression.content,
                      size: 80,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppI18n.t('community.achievementProgress'),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppI18n.t('community.unlockedCount').replaceAll('{unlocked}', '$unlockedCount').replaceAll('{total}', '$total'),
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withAlpha(40),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Unlocked Section Header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppI18n.t('community.unlocked')} ($unlockedCount)',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Unlocked Achievement Grid (dynamic)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _allAchievements
                    .where((a) => unlockedSet.contains(a.id))
                    .map((a) => _AchievementBadge(
                          icon: a.icon,
                          color: a.color,
                          title: AppI18n.t('achievement.${a.id}.title'),
                          subtitle: AppI18n.t('achievement.${a.id}.subtitle'),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 28),

              // Locked Section Header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDBDBD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppI18n.t('community.locked')} (${total - unlockedCount})',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Locked Achievement Grid (dynamic)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _allAchievements
                    .where((a) => !unlockedSet.contains(a.id))
                    .map((a) => _AchievementBadge(
                          icon: a.icon,
                          color: a.color,
                          title: AppI18n.t('achievement.${a.id}.title'),
                          subtitle: AppI18n.t('achievement.${a.id}.subtitle'),
                          isLocked: true,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isLocked;

  const _AchievementBadge({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? const Color(0xFFEEEEEE) : const Color(0xFFF0F0F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFF5F5F5) : color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isLocked ? const Color(0xFFBDBDBD) : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLocked ? const Color(0xFFBDBDBD) : const Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: isLocked ? const Color(0xFFE0E0E0) : const Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}