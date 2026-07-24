import 'package:flutter/material.dart';

// ─── League Helper ───
class LeagueTier {
  final String name;
  final String emoji;
  final int minXp;
  final int maxXp;
  final Color color;

  const LeagueTier({
    required this.name,
    required this.emoji,
    required this.minXp,
    required this.maxXp,
    required this.color,
  });
}

const List<LeagueTier> leagueTiers = [
  LeagueTier(name: 'league.bronze', emoji: '🥉', minXp: 0, maxXp: 500, color: Color(0xFFCD7F32)),
  LeagueTier(name: 'league.silver', emoji: '🥈', minXp: 500, maxXp: 1200, color: Color(0xFFC0C0C0)),
  LeagueTier(name: 'league.gold', emoji: '🥇', minXp: 1200, maxXp: 2500, color: Color(0xFFFFD700)),
  LeagueTier(name: 'league.emerald', emoji: '💎', minXp: 2500, maxXp: 4000, color: Color(0xFF4CAF50)),
  LeagueTier(name: 'league.diamond', emoji: '👑', minXp: 4000, maxXp: 6000, color: Color(0xFF7C4DFF)),
];

int getLeagueIndex(int xp) {
  for (int i = leagueTiers.length - 1; i >= 0; i--) {
    if (xp >= leagueTiers[i].minXp) return i;
  }
  return 0;
}

LeagueTier getLeague(int xp) => leagueTiers[getLeagueIndex(xp)];

