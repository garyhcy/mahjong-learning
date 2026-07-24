import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/game_state.dart';
import '../../models/community/league_tier.dart';
import '../../services/app_i18n.dart';


// ═══════════════════════════════════════════════════════════════
// ─── League Detail Page ───
// ═══════════════════════════════════════════════════════════════
class LeagueDetailPage extends StatelessWidget {
  const LeagueDetailPage();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final xp = game.xp;
    final currentLeague = getLeague(xp);

    int currentIdx = 0;
    for (int i = leagueTiers.length - 1; i >= 0; i--) {
      if (xp >= leagueTiers[i].minXp) {
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
            ...leagueTiers.asMap().entries.map((entry) {
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
