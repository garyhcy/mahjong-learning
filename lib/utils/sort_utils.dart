import '../models/community/leaderboard_entry.dart';

/// Sorts leaderboard entries by XP descending (highest XP first).
///
/// Single source of truth for leaderboard ordering. Used after merging
/// real and fake players so rank assignment is consistent.
void sortLeaderboard(List<LeaderboardEntry> entries) {
  entries.sort((a, b) => b.xp.compareTo(a.xp));
}
