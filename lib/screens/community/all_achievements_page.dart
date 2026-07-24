import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../../models/community/achievement_display.dart';
import '../../services/app_i18n.dart';
import '../../widgets/mascot_widget.dart';


// ═══════════════════════════════════════════════════════════════
// ─── All Achievements Page ───
// ═══════════════════════════════════════════════════════════════
class AllAchievementsPage extends StatelessWidget {
  const AllAchievementsPage();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final unlockedCount = allAchievements.where((a) => game.unlockedAchievements.contains(a.id)).length;
    final total = allAchievements.length;

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
              children: allAchievements
                  .where((a) => game.unlockedAchievements.contains(a.id))
                  .map((a) => _achievementGridItem(a, true))
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
              children: allAchievements
                  .where((a) => !game.unlockedAchievements.contains(a.id))
                  .map((a) => _achievementGridItem(a, false))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementGridItem(AchievementDisplay a, bool isUnlocked) {
    return SizedBox(
      width: 75,
      child: Column(
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
              child: Text(a.emoji,
                  style: TextStyle(
                      fontSize: 24,
                      color: isUnlocked ? null : const Color(0xFFBDBDBD))),
            ),
          ),
          const SizedBox(height: 6),
          Text(AppI18n.t(a.title),
              style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isUnlocked
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
