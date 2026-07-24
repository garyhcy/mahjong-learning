import 'dart:math';

/// Generates locally-computed fake players for a region's leaderboard.
///
/// These players never touch Firestore — they are deterministic (seeded by
/// region) so the same region always shows the same fake leaderboard, and the
/// same player never appears twice within a batch. Used to make sparse
/// leaderboards feel populated without writing dummy data to the backend.
class FakePlayers {
  FakePlayers._();

  static List<Map<String, dynamic>> generateLocalFakePlayers(
    String region, {
    int count = 6,
    List<String> realNicknames = const [],
  }) {
    final seed = region.hashCode;
    final random = Random(seed);

    const adjectives = [
      'Swift', 'Calm', 'Brave', 'Clever', 'Bright', 'Cosmic', 'Lucky',
      'Mighty', 'Noble', 'Royal', 'Silent', 'Vivid', 'Witty', 'Zen', 'Golden',
      'Azure', 'Crimson', 'Emerald', 'Silver', 'Stormy', 'Jolly', 'Frosty',
    ];
    const nouns = [
      'Panda', 'Tiger', 'Phoenix', 'Dragon', 'Falcon', 'Otter', 'Lion', 'Wolf',
      'Hawk', 'Crane', 'Fox', 'Bear', 'Heron', 'Koi', 'Lynx', 'Raven', 'Stag',
      'Owl', 'Swan', 'Viper', 'Sparrow', 'Otter',
    ];
    const emojis = [
      '🐉', '🐱', '🎯', '🌸', '🦊', '🎮', '🌺', '🦝', '🐼', '🦁',
      '🐯', '🦅', '🐸', '🦢', '🐠', '🦉', '🐍', '🦌', '🦚', '🐙',
    ];

    const bannedSubstrings = [
      'fuck', 'shit', 'damn', 'ass', 'dick', 'pussy', 'cunt', 'bitch',
      'nigger', 'nigga', 'retard', 'fag', 'rape', 'kill', 'nazi', 'slut',
      'whore', 'anal', 'cum', 'porn', 'sex',
    ];

    final realSet = realNicknames
        .map((n) => n.toLowerCase().trim())
        .where((n) => n.isNotEmpty)
        .toSet();
    final usedNames = <String>{};
    final usedXps = <int>{};
    final players = <Map<String, dynamic>>[];

    int attempts = 0;
    while (players.length < count && attempts < count * 60) {
      attempts++;
      final adj = adjectives[random.nextInt(adjectives.length)];
      final noun = nouns[random.nextInt(nouns.length)];
      final name = '$adj$noun';
      final lower = name.toLowerCase();

      if (bannedSubstrings.any((b) => lower.contains(b))) continue;
      if (realSet.contains(lower)) continue;
      if (usedNames.contains(name)) continue;

      int xp = 400 + random.nextInt(801); // 400..1200
      int xpAttempts = 0;
      while (usedXps.contains(xp) && xpAttempts < 60) {
        xp = 400 + random.nextInt(801);
        xpAttempts++;
      }
      usedXps.add(xp);
      usedNames.add(name);

      players.add({
        'playerId': 'LD${1000 + (seed.abs() % 8000) + players.length * 7}',
        'nickname': name,
        'avatarEmoji': emojis[random.nextInt(emojis.length)],
        'xp': xp,
        'streak': random.nextInt(30),
        'region': region,
        'isFake': true,
        'completedLessons': random.nextInt(20),
      });
    }

    players.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    return players;
  }
}
