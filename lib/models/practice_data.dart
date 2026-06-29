import 'dart:convert';

/// All tile codes used in practice
const List<String> allTileCodes = [
  'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9',
  'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9',
  's1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9',
  'east', 'south', 'west', 'north',
  'red', 'green', 'white',
  'f_plum', 'f_orchid', 'f_chrys', 'f_bamboo',
  'f_spring', 'f_summer', 'f_autumn', 'f_winter',
];

/// Tile categories for matching practice
enum TileCategory {
  characters, // m1-m9
  circles, // p1-p9
  bamboo, // s1-s9
  winds, // east, south, west, north
  dragons, // red, green, white
  flowers, // f_*
}

/// Get category for a tile code
TileCategory getTileCategory(String code) {
  if (code.startsWith('m')) return TileCategory.characters;
  if (code.startsWith('p')) return TileCategory.circles;
  if (code.startsWith('s')) return TileCategory.bamboo;
  if (code.startsWith('f_')) return TileCategory.flowers;
  if (['east', 'south', 'west', 'north'].contains(code)) {
    return TileCategory.winds;
  }
  return TileCategory.dragons;
}

/// Get display name for a tile category
String getCategoryName(TileCategory cat) {
  switch (cat) {
    case TileCategory.characters:
      return 'Characters (萬)';
    case TileCategory.circles:
      return 'Circles (筒)';
    case TileCategory.bamboo:
      return 'Bamboo (索)';
    case TileCategory.winds:
      return 'Winds (風)';
    case TileCategory.dragons:
      return 'Dragons (三元)';
    case TileCategory.flowers:
      return 'Flowers (花)';
  }
}

/// Tile names for recognition practice
const Map<String, String> tileNames = {
  'm1': '1 Characters (一萬)',
  'm2': '2 Characters (二萬)',
  'm3': '3 Characters (三萬)',
  'm4': '4 Characters (四萬)',
  'm5': '5 Characters (五萬)',
  'm6': '6 Characters (六萬)',
  'm7': '7 Characters (七萬)',
  'm8': '8 Characters (八萬)',
  'm9': '9 Characters (九萬)',
  'p1': '1 Circles (一筒)',
  'p2': '2 Circles (二筒)',
  'p3': '3 Circles (三筒)',
  'p4': '4 Circles (四筒)',
  'p5': '5 Circles (五筒)',
  'p6': '6 Circles (六筒)',
  'p7': '7 Circles (七筒)',
  'p8': '8 Circles (八筒)',
  'p9': '9 Circles (九筒)',
  's1': '1 Bamboo (一索)',
  's2': '2 Bamboo (二索)',
  's3': '3 Bamboo (三索)',
  's4': '4 Bamboo (四索)',
  's5': '5 Bamboo (五索)',
  's6': '6 Bamboo (六索)',
  's7': '7 Bamboo (七索)',
  's8': '8 Bamboo (八索)',
  's9': '9 Bamboo (九索)',
  'east': 'East Wind (東)',
  'south': 'South Wind (南)',
  'west': 'West Wind (西)',
  'north': 'North Wind (北)',
  'red': 'Red Dragon (中)',
  'green': 'Green Dragon (發)',
  'white': 'White Dragon (白)',
  'f_plum': 'Plum (梅)',
  'f_orchid': 'Orchid (蘭)',
  'f_chrys': 'Chrysanthemum (菊)',
  'f_bamboo': 'Bamboo (竹)',
  'f_spring': 'Spring (春)',
  'f_summer': 'Summer (夏)',
  'f_autumn': 'Autumn (秋)',
  'f_winter': 'Winter (冬)',
};

/// Rules quiz questions
class RulesQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const RulesQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

const List<RulesQuestion> rulesQuestions = [
  RulesQuestion(
    question: 'How many tiles are there in a standard Mahjong set?',
    options: ['136', '144', '148', '152'],
    correctIndex: 1,
    explanation: 'A standard Mahjong set has 144 tiles (136 + 8 bonus tiles).',
  ),
  RulesQuestion(
    question: 'How many tiles does each player start with?',
    options: ['13', '14', '16', '17'],
    correctIndex: 0,
    explanation: 'Each player starts with 13 tiles. The dealer starts with 14.',
  ),
  RulesQuestion(
    question: 'What is a "Pong" (碰)?',
    options: [
      'A set of 3 identical tiles',
      'A sequence of 3 consecutive tiles',
      'A pair of identical tiles',
      'A set of 4 identical tiles',
    ],
    correctIndex: 0,
    explanation: 'A Pong is a set of 3 identical tiles.',
  ),
  RulesQuestion(
    question: 'What is a "Chi" (吃)?',
    options: [
      'A set of 3 identical tiles',
      'A sequence of 3 consecutive tiles of the same suit',
      'A pair of identical tiles',
      'Declaring a win',
    ],
    correctIndex: 1,
    explanation: 'A Chi is a sequence of 3 consecutive tiles of the same suit.',
  ),
  RulesQuestion(
    question: 'What is a "Kong" (槓)?',
    options: [
      'A set of 3 identical tiles',
      'A sequence of 4 consecutive tiles',
      'A set of 4 identical tiles',
      'A pair of identical tiles',
    ],
    correctIndex: 2,
    explanation: 'A Kong is a set of 4 identical tiles.',
  ),
  RulesQuestion(
    question: 'Which tiles cannot form a Chi (sequence)?',
    options: [
      'Characters (萬)',
      'Circles (筒)',
      'Winds and Dragons (字牌)',
      'Bamboo (索)',
    ],
    correctIndex: 2,
    explanation: 'Winds and Dragons are honor tiles and cannot form sequences.',
  ),
  RulesQuestion(
    question: 'What does "Hu" (胡) mean?',
    options: [
      'Drawing a tile',
      'Discarding a tile',
      'Winning the game',
      'Passing your turn',
    ],
    correctIndex: 2,
    explanation: '"Hu" means declaring a win when your hand is complete.',
  ),
  RulesQuestion(
    question: 'A winning hand typically needs how many sets + 1 pair?',
    options: ['3 sets + 1 pair', '4 sets + 1 pair', '5 sets + 1 pair', '2 sets + 1 pair'],
    correctIndex: 1,
    explanation: 'A standard winning hand has 4 sets (melds) + 1 pair = 14 tiles.',
  ),
  RulesQuestion(
    question: 'What is "Self-draw" (自摸)?',
    options: [
      'Drawing the winning tile yourself',
      'Discarding a tile',
      'Taking a tile from another player',
      'Declaring a Kong',
    ],
    correctIndex: 0,
    explanation: 'Self-draw means you draw the winning tile from the wall yourself.',
  ),
  RulesQuestion(
    question: 'How many suits are there in Mahjong?',
    options: ['2', '3', '4', '5'],
    correctIndex: 1,
    explanation: 'There are 3 suits: Characters (萬), Circles (筒), and Bamboo (索).',
  ),
  RulesQuestion(
    question: 'What are "Honor tiles" (字牌)?',
    options: [
      'Only Winds',
      'Only Dragons',
      'Winds and Dragons',
      'Flowers and Seasons',
    ],
    correctIndex: 2,
    explanation: 'Honor tiles include 4 Winds and 3 Dragons.',
  ),
  RulesQuestion(
    question: 'In Hong Kong Mahjong, what is the minimum number of "fan" (番) to win?',
    options: ['0', '1', '3', '5'],
    correctIndex: 2,
    explanation: 'In Hong Kong Mahjong, you need at least 3 fan to declare a win.',
  ),
  RulesQuestion(
    question: 'What is "All Pongs" (對對胡)?',
    options: [
      'A hand with all sequences',
      'A hand with all triplets/quads + 1 pair',
      'A hand with all honor tiles',
      'A hand with no flowers',
    ],
    correctIndex: 1,
    explanation: 'All Pongs means your hand consists entirely of triplets/quads plus one pair.',
  ),
  RulesQuestion(
    question: 'What is "Mixed One Suit" (混一色)?',
    options: [
      'All tiles from one suit only',
      'One suit + honor tiles only',
      'All honor tiles',
      'Two different suits only',
    ],
    correctIndex: 1,
    explanation: 'Mixed One Suit means tiles from one suit combined with honor tiles.',
  ),
  RulesQuestion(
    question: 'What is "Pure One Suit" (清一色)?',
    options: [
      'All tiles from one suit only',
      'One suit + honor tiles',
      'All honor tiles',
      'All flower tiles',
    ],
    correctIndex: 0,
    explanation: 'Pure One Suit means all tiles are from a single suit with no honor tiles.',
  ),
  RulesQuestion(
    question: 'Who gets priority when multiple players want the same discarded tile?',
    options: [
      'The player closest to the discarder',
      'Hu > Pong/Kong > Chi',
      'First come first served',
      'The dealer always has priority',
    ],
    correctIndex: 1,
    explanation: 'Win (Hu) has highest priority, then Pong/Kong, then Chi.',
  ),
  RulesQuestion(
    question: 'How many flower tiles are in a standard set?',
    options: ['4', '6', '8', '10'],
    correctIndex: 2,
    explanation: 'There are 8 flower/season tiles: 4 flowers + 4 seasons.',
  ),
  RulesQuestion(
    question: 'What happens when you draw a flower tile?',
    options: [
      'Discard it immediately',
      'Place it aside and draw a replacement tile',
      'Keep it in your hand',
      'Give it to another player',
    ],
    correctIndex: 1,
    explanation: 'Flower tiles are placed aside for bonus points and you draw a replacement.',
  ),
  RulesQuestion(
    question: 'What is "Chicken Hand" (雞胡) in HK Mahjong?',
    options: [
      'A hand worth exactly 3 fan',
      'A hand with no extra fan (minimum win)',
      'A hand with all chickens',
      'A hand that cannot win',
    ],
    correctIndex: 1,
    explanation: 'Chicken Hand is a minimum-value winning hand with no bonus fan.',
  ),
  RulesQuestion(
    question: 'In which direction does play proceed?',
    options: [
      'Clockwise',
      'Counter-clockwise',
      'Alternating',
      'Random',
    ],
    correctIndex: 1,
    explanation: 'Play proceeds counter-clockwise in Mahjong.',
  ),
];

/// Practice session result
class PracticeResult {
  final String drillType; // 'recognition', 'matching', 'sorting', 'rules', 'speed'
  final int totalQuestions;
  final int correctAnswers;
  final List<String> wrongTiles; // tile codes that were answered incorrectly
  final List<String> wrongCategories; // categories that were weak
  final DateTime timestamp;
  final int? timeTaken; // seconds (for speed challenge)

  PracticeResult({
    required this.drillType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongTiles,
    required this.wrongCategories,
    DateTime? timestamp,
    this.timeTaken,
  }) : timestamp = timestamp ?? DateTime.now();

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  Map<String, dynamic> toJson() => {
        'drillType': drillType,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'wrongTiles': wrongTiles,
        'wrongCategories': wrongCategories,
        'timestamp': timestamp.toIso8601String(),
        'timeTaken': timeTaken,
      };

  factory PracticeResult.fromJson(Map<String, dynamic> json) => PracticeResult(
        drillType: json['drillType'] as String,
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        wrongTiles: (json['wrongTiles'] as List).cast<String>(),
        wrongCategories: (json['wrongCategories'] as List).cast<String>(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        timeTaken: json['timeTaken'] as int?,
      );
}

/// Weakness analysis
class WeaknessReport {
  final Map<String, int> tileErrorCount; // tile code -> error count
  final Map<String, int> categoryErrorCount; // category -> error count
  final List<String> weakestTiles; // top 5 weakest tiles
  final List<String> weakestCategories; // weakest categories

  WeaknessReport({
    required this.tileErrorCount,
    required this.categoryErrorCount,
    required this.weakestTiles,
    required this.weakestCategories,
  });
}

/// Analyze practice results to find weaknesses
WeaknessReport analyzeWeaknesses(List<PracticeResult> results) {
  final tileErrors = <String, int>{};
  final catErrors = <String, int>{};

  for (final r in results) {
    for (final tile in r.wrongTiles) {
      tileErrors[tile] = (tileErrors[tile] ?? 0) + 1;
    }
    for (final cat in r.wrongCategories) {
      catErrors[cat] = (catErrors[cat] ?? 0) + 1;
    }
  }

  // Sort by error count descending
  final sortedTiles = tileErrors.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final sortedCats = catErrors.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return WeaknessReport(
    tileErrorCount: tileErrors,
    categoryErrorCount: catErrors,
    weakestTiles: sortedTiles.take(5).map((e) => e.key).toList(),
    weakestCategories: sortedCats.take(3).map((e) => e.key).toList(),
  );
}
