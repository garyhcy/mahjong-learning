// ─── Leaderboard entry model (used by both real and fake leaderboards) ───
class LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int xp;
  final int streak;
  final bool isCurrentUser;
  final String playerId;
  final int skillRating;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.xp,
    this.streak = 0,
    this.isCurrentUser = false,
    this.playerId = '',
    this.skillRating = 0,
  });
}

const List<LeaderboardEntry> fakeLeaderboard = [
  LeaderboardEntry(rank: 1, name: 'Jason', avatar: '🐉', xp: 3120, streak: 14, playerId: '#LD01', skillRating: 88),
  LeaderboardEntry(rank: 2, name: 'Emily', avatar: '🐱', xp: 2340, streak: 9, playerId: '#LD02', skillRating: 72),
  LeaderboardEntry(rank: 3, name: 'David', avatar: '🎯', xp: 1980, streak: 7, playerId: '#LD03', skillRating: 65),
  LeaderboardEntry(rank: 4, name: 'Michelle', avatar: '🌸', xp: 1650, streak: 5, playerId: '#LD04', skillRating: 55),
  LeaderboardEntry(rank: 5, name: 'Sarah', avatar: '🦊', xp: 1420, streak: 3, playerId: '#LD05', skillRating: 48),
  LeaderboardEntry(rank: 6, name: 'Kevin', avatar: '🎮', xp: 1280, streak: 4, playerId: '#LD06', skillRating: 40),
  LeaderboardEntry(rank: 7, name: 'Amy', avatar: '🌺', xp: 1100, streak: 2, playerId: '#LD07', skillRating: 25),
  LeaderboardEntry(rank: 8, name: 'Tom', avatar: '🦝', xp: 950, streak: 1, playerId: '#LD08', skillRating: 20),
  LeaderboardEntry(rank: 9, name: 'Lisa', avatar: '🦜', xp: 800, streak: 3, playerId: '#LD09', skillRating: 15),
  LeaderboardEntry(rank: 10, name: 'Ben', avatar: '🦝', xp: 650, streak: 0, playerId: '#LD10', skillRating: 10),
];

