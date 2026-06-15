// 麻将教学数据模型
import 'package:flutter/material.dart';

// 学习阶段
class LearningStage {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int lessonCount;
  bool isUnlocked;
  int completedLessons;

  LearningStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lessonCount,
    this.isUnlocked = false,
    this.completedLessons = 0,
  });

  double get progress =>
      lessonCount > 0 ? completedLessons / lessonCount : 0;
}

// 教学对话消息
class DialogueMessage {
  final String speaker; // 'mj' (熊猫 MJ) or 'user'
  final String text;
  final Widget? widget;
  final List<String>? tileIds; // 用于展示牌面可视化

  DialogueMessage({required this.speaker, required this.text, this.widget, this.tileIds});
}

// ── 广东麻将番种定义 ──
class FanType {
  final String id;
  final String name;
  final String nameZh;
  final int score;
  final String scoreLabel;
  final List<String> tileIds;
  final String description;
  final String example;

  const FanType({
    required this.id,
    required this.name,
    required this.nameZh,
    required this.score,
    required this.scoreLabel,
    required this.tileIds,
    required this.description,
    required this.example,
  });
}

// 课程
class Lesson {
  final String id;
  final String stageId;
  final String title;
  final String subtitle;
  final List<DialogueMessage> dialogues;
  final List<QuizQuestion> questions;

  const Lesson({
    required this.id,
    required this.stageId,
    required this.title,
    required this.subtitle,
    required this.dialogues,
    required this.questions,
  });
}

// 测验题目
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final QuizType type;
  final List<String>? tiles;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.type = QuizType.multiChoice,
    this.tiles,
  });
}

enum QuizType { multiChoice, tileSelection, tileOrdering }

// 排行榜用户
class LeaderboardUser {
  final String name;
  final String avatar;
  final int xp;
  final int rank;

  LeaderboardUser({
    required this.name,
    required this.avatar,
    required this.xp,
    required this.rank,
  });
}

// 学习路径数据（5 阶段 36 课）
final List<LearningStage> defaultStages = [
  LearningStage(
    id: 'basics',
    title: 'The Basics',
    subtitle: 'Tiles, suits & table setup',
    icon: Icons.grid_view_rounded,
    color: const Color(0xFFD94040),
    lessonCount: 8,
    isUnlocked: true,
  ),
  LearningStage(
    id: 'how-to-play',
    title: 'How to Play',
    subtitle: 'Drawing, discarding & turns',
    icon: Icons.swap_horiz_rounded,
    color: const Color(0xFFE8B93E),
    lessonCount: 8,
  ),
  LearningStage(
    id: 'winning-hands',
    title: 'Winning Hands',
    subtitle: 'Melds, patterns & special hands',
    icon: Icons.celebration_rounded,
    color: const Color(0xFF8B4513),
    lessonCount: 6,
  ),
  LearningStage(
    id: 'scoring-faan',
    title: 'Scoring & Faan',
    subtitle: 'Points, patterns & payment',
    icon: Icons.stars_rounded,
    color: const Color(0xFF2E7D32),
    lessonCount: 8,
  ),
  LearningStage(
    id: 'strategy',
    title: 'Strategy',
    subtitle: 'Reading opponents & advanced play',
    icon: Icons.psychology_rounded,
    color: const Color(0xFF6A1B9A),
    lessonCount: 6,
  ),
  LearningStage(
    id: 'gdmj-fans',
    title: 'Guangdong Faan',
    subtitle: 'Complete fan scoring system',
    icon: Icons.stars_rounded,
    color: const Color(0xFFD94040),
    lessonCount: 6,
  ),
  LearningStage(
    id: 'practical',
    title: 'Practical Skills',
    subtitle: 'Table rules, seating & dealing',
    icon: Icons.sports_esports_rounded,
    color: const Color(0xFF1565C0),
    lessonCount: 3,
  ),
  LearningStage(
    id: 'stage6',
    title: 'Common Winning Hands',
    subtitle: 'Half Flush, Full Flush & stacking',
    icon: Icons.collections_bookmark,
    color: const Color(0xFF7B1FA2),
    lessonCount: 1,
  ),
  LearningStage(
    id: 'stage7',
    title: 'Defense & Reading',
    subtitle: 'Safe tiles, following suit & discards',
    icon: Icons.shield,
    color: const Color(0xFF1565C0),
    lessonCount: 1,
  ),
  LearningStage(
    id: 'stage8',
    title: 'Limit Hands & Etiquette',
    subtitle: 'Legendary hands & table manners',
    icon: Icons.auto_awesome,
    color: const Color(0xFFE65100),
    lessonCount: 1,
  ),
  LearningStage(
    id: 'stage9',
    title: 'Reading Opponents',
    subtitle: 'Discard analysis & opponent tells',
    icon: Icons.visibility,
    color: const Color(0xFF00897B),
    lessonCount: 1,
  ),
  LearningStage(
    id: 'stage10',
    title: 'Advanced Tactics',
    subtitle: 'Pace control, kong & deception',
    icon: Icons.psychology,
    color: const Color(0xFF5C6BC0),
    lessonCount: 1,
  ),
  LearningStage(
    id: 'stage11',
    title: 'Risk Management',
    subtitle: 'Danger assessment & end-game decisions',
    icon: Icons.balance,
    color: const Color(0xFFD84315),
    lessonCount: 1,
  ),
];

// ─────────────────────────────────────
//  Complete 36-Lesson Curriculum
// ─────────────────────────────────────
// 每个阶段 ID 与 defaultStages 对应：
//   basics / how-to-play / winning-hands / scoring-faan / strategy
// ─────────────────────────────────────

final List<Lesson> allLessonsData = [
  // ═══════════════════════════════════
  //  STAGE 1: The Basics (8 lessons)
  // ═══════════════════════════════════
  Lesson(id: '1-1', stageId: 'basics', title: 'What is Mahjong?',
      subtitle: 'History & basic concepts', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Welcome! I\'m MJ, your panda teacher. Mahjong is a 4-player tile game that started in China over 150 years ago. Today millions play worldwide!'),
    DialogueMessage(speaker: 'mj',
        text: 'A mahjong set has 144 tiles. Think of it like a card game, but with beautiful tiles instead of cards. Your goal: build a winning hand before anyone else!'),
    DialogueMessage(speaker: 'mj',
        text: 'We\'ll learn Hong Kong Mahjong rules. Ready to explore the tiles? Let\'s go! 🐼'),
  ], questions: [
    QuizQuestion(question: 'How many players are in a standard mahjong game?',
        options: ['2', '3', '4', '6'], correctIndex: 2,
        explanation: 'Mahjong is played by 4 players seated around a square table.'),
    QuizQuestion(question: 'How many tiles are in a full mahjong set?',
        options: ['108', '136', '144', '152'], correctIndex: 2,
        explanation: 'A standard set has 144 tiles: 108 suited, 28 honors, and 8 bonus tiles.'),
    QuizQuestion(question: 'What is the main objective of mahjong?',
        options: ['Collect the most tiles', 'Build a winning hand first', 'Score the most points per round',
          'Eliminate other players'], correctIndex: 1,
        explanation: 'Your goal is to complete a winning hand (4 melds + 1 pair) before anyone else.'),
  ]),

  Lesson(id: '1-2', stageId: 'basics', title: 'The Tiles — Suits',
      subtitle: 'Wan, Tiao & Tong (1—9)', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'There are three main suits in mahjong. First up: {{m1}}{{m2}}{{m3}}{{m4}}{{m5}}{{m6}}{{m7}}{{m8}}{{m9}} — these are Character tiles, also called Wan (万). They run from 1 to 9.'),
    DialogueMessage(speaker: 'mj',
        text: '{{s1}}{{s2}}{{s3}}{{s4}}{{s5}}{{s6}}{{s7}}{{s8}}{{s9}} — these are {{f_bamboo}} tiles, called Tiao (条). You can spot them by the bamboo sticks! Again, numbers 1 through 9.'),
    DialogueMessage(speaker: 'mj',
        text: '{{p1}}{{p2}}{{p3}}{{p4}}{{p5}}{{p6}}{{p7}}{{p8}}{{p9}} — these are Circle tiles, called Tong (筒). Each tile shows that many circles.'),
    DialogueMessage(speaker: 'mj',
        text: 'Every number in every suit has 4 identical copies. So 9 numbers × 3 suits × 4 copies = 108 suited tiles total!'),
  ], questions: [
    QuizQuestion(question: 'Which suit uses the Chinese character for "ten-thousand"?',
        options: ['Tong (Circles)', 'Tiao ({{f_bamboo}})', 'Wan (Characters)', 'Honors'],
        correctIndex: 2,
        explanation: 'Wan, also called Characters, uses Chinese number characters and the character 万.'),
    QuizQuestion(question: 'How many copies of each suited tile exist?',
        options: ['2', '3', '4', '6'],
        correctIndex: 2,
        explanation: 'Each suited tile, such as {{s5}} or 7 Circles, has 4 identical copies.'),
    QuizQuestion(question: 'How many suited tiles are there in total?',
        options: ['72', '108', '136', '144'],
        correctIndex: 1,
        explanation: 'There are 3 suits, 9 numbers in each suit, and 4 copies of each tile: 3 × 9 × 4 = 108.'),
    QuizQuestion(question: 'Which tile is a Circle tile?',
        options: ['p6', 'm6', 's6', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm3', 's2', 's3', 's4', 'p4',
          'p5', 'p6', 'east', 'south', 'red', 'white',
        ],
        explanation: 'Tile codes starting with p are Circle tiles, so p6 is 6 Circles.'),
    QuizQuestion(
        question: 'Arrange these Circle tiles from smallest to largest (1→6)',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'],
        explanation: 'Circle tiles are numbered 1 through 6. The correct order is 1→2→3→4→5→6.'),
  ]),

  Lesson(id: '1-3', stageId: 'basics', title: 'The Tiles — Honors',
      subtitle: 'Winds & Dragons', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Beyond suits, we have Honor tiles! First, the four Winds: {{east}} {{east}}, {{south}} {{south}}, {{west}} {{west}}, and {{north}} {{north}}. Four copies of each!'),
    DialogueMessage(speaker: 'mj',
        text: 'Then the three Dragons: {{red}} {{red}}, {{green}} {{green}}, and {{white}} {{white}}. Also four copies each.'),
    DialogueMessage(speaker: 'mj',
        text: 'So Honors total: 4 winds × 4 + 3 dragons × 4 = 28 honor tiles. They don\'t have numbers — they\'re special!'),
    DialogueMessage(speaker: 'mj',
        text: 'Honors can form Pongs, Kongs, or pairs, but never sequences. Keep that in mind!'),
  ], questions: [
    QuizQuestion(question: 'How many Wind tile types are there?',
        options: ['3', '4', '7', '9'],
        correctIndex: 1,
        explanation: 'The four Wind types are {{east}}, {{south}}, {{west}}, and {{north}}.'),
    QuizQuestion(question: 'Can Honor tiles form sequences?',
        options: [
          'Yes, {{east}}-{{south}}-{{west}} is a sequence',
          'Yes, Dragons can form sequences',
          'No, Honors only form Pongs, Kongs, or pairs',
          'Only if they are exposed',
        ],
        correctIndex: 2,
        explanation: 'Honor tiles have no numbers, so they cannot make runs like 1-2-3.'),
    QuizQuestion(question: 'How many honor tiles are in a set?',
        options: ['16', '24', '28', '32'],
        correctIndex: 2,
        explanation: 'There are 16 Winds and 12 Dragons, giving 28 Honor tiles in total.'),
    QuizQuestion(question: 'Which option is a Dragon tile?',
        options: ['red', 'east', 'm9', 's1'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'east', 'south', 'west', 'north', 'red', 'green', 'white',
          'm1', 'm9', 's1', 's9', 'p1', 'p9',
        ],
        explanation: 'Red, Green, and White are Dragon tiles. {{east}} is a Wind, not a Dragon.'),
  ]),

  Lesson(id: '1-4', stageId: 'basics', title: 'The Tiles — Bonus Flowers',
      subtitle: '{{f_plum}}, {{f_orchid}}, {{f_chrys}} & {{f_bamboo}}', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'There are 8 bonus Flower tiles: {{f_plum}} {{f_plum}}, {{f_orchid}} {{f_orchid}}, {{f_chrys}} {{f_chrys}}, and {{f_bamboo}} {{f_bamboo}} — each has 2 copies.'),
    DialogueMessage(speaker: 'mj',
        text: 'Flowers are special: when you draw one, you set it aside face-up and draw a replacement tile. They don\'t go in your hand!'),
    DialogueMessage(speaker: 'mj',
        text: 'Each flower gives you 1 Faan (point). If you collect all 4 flowers, that\'s a bonus! Some house rules even give instant rewards.'),
  ], questions: [
    QuizQuestion(question: 'What happens when you draw a Flower tile?',
        options: ['Keep it in your hand', 'Discard it immediately', 'Set it aside & draw a replacement',
          'Give it to the dealer'], correctIndex: 2,
        explanation: 'Flowers are set aside face-up and you draw a replacement tile from the wall.'),
    QuizQuestion(question: 'How many Flower tiles are there in a set?',
        options: ['4', '6', '8', '12'], correctIndex: 2,
        explanation: '4 types ({{f_plum}}, {{f_orchid}}, {{f_chrys}}, {{f_bamboo}}) × 2 copies = 8 bonus tiles.'),
    QuizQuestion(question: 'How many Faan is each flower worth?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'], correctIndex: 1,
        explanation: 'Each flower gives 1 Faan. Collect all 4 for extra rewards!'),
  ]),

  Lesson(id: '1-5', stageId: 'basics', title: 'Table Setup',
      subtitle: 'Four seats & wind positions', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Mahjong is played at a square table. Four players sit — one on each side. Each seat is assigned a Wind: {{east}} {{east}}, {{south}} {{south}}, {{west}} {{west}}, {{north}} {{north}}.'),
    DialogueMessage(speaker: 'mj',
        text: '{{east}} is the dealer position. The dealer has a slight advantage: they draw first and get 14 tiles instead of 13.'),
    DialogueMessage(speaker: 'mj',
        text: 'After each round (when someone not {{east}} wins), the winds rotate counterclockwise. The {{south}} player becomes the new {{east}}!'),
  ], questions: [
    QuizQuestion(question: 'Which wind is the dealer position?',
        options: ['{{north}}', '{{south}}', '{{west}}', '{{east}}'], correctIndex: 3,
        explanation: 'The {{east}} player is always the dealer (庄家) at the start of each round.'),
    QuizQuestion(question: 'How many tiles does the dealer start with?',
        options: ['12', '13', '14', '16'], correctIndex: 2,
        explanation: 'The dealer draws 14 tiles and discards first. Other players start with 13.'),
    QuizQuestion(question: 'After a non-{{east}} player wins, what happens to the winds?',
        options: ['Winds stay the same', 'Winds rotate clockwise', 'Winds rotate counterclockwise',
          'Random reassignment'], correctIndex: 2,
        explanation: 'The dealer position rotates counterclockwise: {{south}} becomes the new {{east}}.'),
  ]),

  Lesson(id: '1-6', stageId: 'basics', title: 'Building & Breaking the Wall',
      subtitle: '17×2 stacks & opening the wall', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'At the start, all 144 tiles are shuffled face-down — this is called "washing the tiles." Then each player builds a wall in front of them.'),
    DialogueMessage(speaker: 'mj',
        text: 'Each wall is 17 stacks wide and 2 tiles tall. 17×2×4 players = 136 tiles in the wall (the 8 flowers are set aside first in some rules).'),
    DialogueMessage(speaker: 'mj',
        text: 'To start, the dealer rolls dice. The total determines where to break the wall. Tiles are drawn clockwise from the break point!'),
    DialogueMessage(speaker: 'mj',
        text: 'The wall is the "bank" of tiles. Once it runs out and nobody has won, the round ends in a draw.'),
  ], questions: [
    QuizQuestion(question: 'How many stacks wide is each player\'s wall?',
        options: ['13', '15', '17', '18'], correctIndex: 2,
        explanation: 'Each wall is 17 stacks wide and 2 tiles tall.'),
    QuizQuestion(question: 'Who breaks the wall?',
        options: ['All players together', 'The dealer by rolling dice', 'The player with the highest score',
          'The youngest player'], correctIndex: 1,
        explanation: 'The dealer rolls dice to determine where to break the wall.'),
    QuizQuestion(question: 'What happens when the wall runs out with no winner?',
        options: ['The dealer wins', 'The round is a draw', 'Players reshuffle and continue',
          'The player with most tiles wins'], correctIndex: 1,
        explanation: 'When the wall is exhausted and nobody has declared a win, the round ends in a draw (荒牌).'),
  ]),

  Lesson(id: '1-7', stageId: 'basics', title: 'The Dealer & Turn Order',
      subtitle: 'Dice rolling & counter-clockwise play', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'The dealer ({{east}}) rolls two dice. The total — from 2 to 12 — tells you which wall to break and from where to start drawing.'),
    DialogueMessage(speaker: 'mj',
        text: 'Play goes counterclockwise: {{east}} → {{south}} → {{west}} → {{north}}. On your turn, you draw one tile, then discard one tile.'),
    DialogueMessage(speaker: 'mj',
        text: 'The dealer starts by discarding one tile (since they have 14). After that, each turn is: draw 1, discard 1. Simple!'),
    DialogueMessage(speaker: 'mj',
        text: 'The round continues until someone declares a winning hand or the wall is exhausted. Let\'s move on to playing!'),
  ], questions: [
    QuizQuestion(question: 'In which direction does play proceed?',
        options: ['Clockwise', 'Counterclockwise', 'Random', 'Depends on the dealer'],
        correctIndex: 1, explanation: 'Turns always go counterclockwise: {{east}} → {{south}} → {{west}} → {{north}}.'),
    QuizQuestion(question: 'How many dice are rolled to determine the wall break?',
        options: ['1', '2', '3', '4'], correctIndex: 1,
        explanation: 'Two dice are rolled, giving a total from 2 to 12.'),
    QuizQuestion(question: 'What does each player do on their turn?',
        options: ['Draw 2, discard 1', 'Draw 1, discard 1', 'Draw 1, keep all', 'Draw 1, discard 2'],
        correctIndex: 1, explanation: 'Standard turn: draw 1 tile from the wall, then discard 1 tile.'),
  ]),

  Lesson(id: '1-8', stageId: 'basics', title: 'Stage 1 Review Quiz',
      subtitle: 'Test your basics knowledge!', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Great job! You\'ve learned the foundation of mahjong. Let\'s do a quick review quiz to lock it in.'),
    DialogueMessage(speaker: 'mj',
        text: 'Don\'t worry if you miss a few — you can always retry. Ready? 🐼'),
  ], questions: [
    QuizQuestion(question: 'Which of these is NOT one of the three suits?',
        options: ['Wan (Characters)', 'Tiao ({{f_bamboo}})', 'Tong (Circles)', 'Dong ({{east}})'],
        correctIndex: 3, explanation: '{{east}} is a Wind (Honor) tile, not a suit.'),
    QuizQuestion(question: 'How many tiles does each non-dealer start with?',
        options: ['12', '13', '14', '15'], correctIndex: 1,
        explanation: 'Each non-dealer starts with 13 tiles. The dealer gets 14.'),
    QuizQuestion(question: 'What direction does play proceed?',
        options: ['Clockwise', 'Counterclockwise', 'Random each round',
          'The dealer chooses'], correctIndex: 1,
        explanation: 'All mahjong play proceeds counterclockwise.'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 2: How to Play (8 lessons)
  // ═══════════════════════════════════
  Lesson(id: '2-1', stageId: 'how-to-play', title: 'Drawing a Tile',
      subtitle: 'How & when to draw from the wall', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Every turn begins with drawing one tile. You take it from the live end of the wall — the spot where tiles are still stacked.'),
    DialogueMessage(speaker: 'mj',
        text: 'After drawing, look at your hand. Does this tile help you? Could it complete a meld? Think before you discard!'),
    DialogueMessage(speaker: 'mj',
        text: 'Remember: drawing is mandatory. You can\'t skip it, even if you have a great hand already. Draw first, then act!'),
  ], questions: [
    QuizQuestion(question: 'What is the first action on every turn?',
        options: ['Discard a tile', 'Declare a win', 'Draw a tile', 'Pass your turn'],
        correctIndex: 2, explanation: 'Every turn starts with drawing one tile from the wall.'),
    QuizQuestion(question: 'Can you skip drawing a tile?',
        options: ['Yes, if you have a good hand', 'Yes, only the dealer can', 'No, drawing is mandatory',
          'Only in the first round'], correctIndex: 2,
        explanation: 'Drawing one tile at the start of your turn is mandatory for every player.'),
    QuizQuestion(question: 'From where do you draw tiles?',
        options: ['The discard pool', 'The center of the table', 'The live end of the wall',
          'Anywhere on the wall'], correctIndex: 2,
        explanation: 'Tiles are drawn from the live end of the wall in order.'),
  ]),

  Lesson(id: '2-2', stageId: 'how-to-play', title: 'Discarding',
      subtitle: 'The discard pool & reading opponents', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'After drawing, you must discard exactly one tile. Place it face-up in the center — that\'s the discard pool (牌河).'),
    DialogueMessage(speaker: 'mj',
        text: 'Discards are public information! Everyone can see what you throw away. Smart players watch discards to guess what hands others are building.'),
    DialogueMessage(speaker: 'mj',
        text: 'Pro tip: if you discard a {{m1}} ({{m1}}), it\'s unlikely you\'re building a 1-2-{{m3}} sequence. Opponents notice these patterns!'),
    DialogueMessage(speaker: 'mj',
        text: 'The discard pool should be organized so everyone can see whose discard is whose. In HK style, 6 tiles per row.'),
  ], questions: [
    QuizQuestion(question: 'Where do discarded tiles go?',
        options: ['Back to the wall', 'Face-down on your side', 'Face-up in the center discards pool',
          'To the dealer'], correctIndex: 2,
        explanation: 'Discards go face-up in the center discard pool (牌河) for all to see.'),
    QuizQuestion(question: 'Are discards visible to all players?',
        options: ['Only to the discarder', 'Only to adjacent players', 'Yes, everyone can see them',
          'Only after the round ends'], correctIndex: 2,
        explanation: 'All discards are public. Smart players use this information strategically.'),
    QuizQuestion(question: 'How many tiles per row in HK-style discard organization?',
        options: ['4', '6', '8', '10'], correctIndex: 1,
        explanation: 'Hong Kong style typically organizes discards in rows of 6 tiles.'),
  ]),

  Lesson(id: '2-3', stageId: 'how-to-play', title: 'Pong (碰)',
      subtitle: 'Claiming three-of-a-kind', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Pong (碰) means "bump"! When any player discards a tile, and you already have 2 of that tile, you can call Pong to take it.'),
    DialogueMessage(speaker: 'mj',
        text: 'Say you have {{m1}}{{m1}} in hand. If someone discards another {{m1}}, you shout "Pong!" and take it. Now you have a Pong of {{m1}}{{m1}}{{m1}}!'),
    DialogueMessage(speaker: 'mj',
        text: 'After claiming a Pong, you must show the three tiles face-up on the table. This is an "exposed meld" — everyone can see it.'),
    DialogueMessage(speaker: 'mj',
        text: 'Important: claiming a Pong interrupts the normal turn order. After you Pong, you discard one tile and play continues from you.'),
  ], questions: [
    QuizQuestion(question: 'What does Pong (碰) complete?',
        options: ['A sequence', 'Three identical tiles', 'A pair only', 'Four different honors'],
        correctIndex: 1,
        explanation: 'Pong is used when you already have two identical tiles and claim a third matching tile.'),
    QuizQuestion(question: 'After claiming a Pong, the meld is...?',
        options: ['Kept hidden', 'Shown face-up', 'Given to the dealer', 'Returned to the wall'],
        correctIndex: 1,
        explanation: 'A claimed Pong must be exposed face-up, so all players can see it.'),
    QuizQuestion(question: 'What happens to the turn order after a Pong?',
        options: [
          'Play continues from you after you discard',
          'The discarder plays again',
          'The dealer restarts the hand',
          'Everyone draws one tile',
        ],
        correctIndex: 0,
        explanation: 'Claiming Pong interrupts the normal order. You expose the Pong, discard one tile, then play continues from your position.'),
    QuizQuestion(
        question: 'You have two {{red}}s. Which discard can you claim for Pong?',
        options: ['red', 'green', 'white', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'red', 'red', 'm2', 'm3', 'm4', 's5', 's6',
          's7', 'p2', 'p3', 'p4', 'east', 'east',
        ],
        explanation: 'Because you already hold two {{red}}s, a discarded red completes a Pong of {{red}}s.'),
  ]),

  Lesson(id: '2-4', stageId: 'how-to-play', title: 'Chi (吃)',
      subtitle: 'Claiming a sequence from the player before you', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Chi (吃) means "eat"! It lets you complete a sequence of three consecutive numbers in the same suit — but only from the player before you in turn order.'),
    DialogueMessage(speaker: 'mj',
        text: 'For example: you have {{m2}}{{m3}} (2-{{m3}}). If the player before you discards {{m1}} or {{m4}}, you can Chi to complete the sequence.'),
    DialogueMessage(speaker: 'mj',
        text: 'Unlike Pong, you cannot Chi from any player. Chi is more limited because it only works from the player immediately before you.'),
    DialogueMessage(speaker: 'mj',
        text: 'After Chi, show the three tiles face-up. Then discard one tile. Remember: Chi only works for suited tiles, never honors!'),
  ], questions: [
    QuizQuestion(question: 'From which player can you Chi?',
        options: ['Any player', 'Only the player before you', 'Only the dealer', 'Only the player across from you'],
        correctIndex: 1,
        explanation: 'Chi can only be claimed from the player immediately before you in turn order.'),
    QuizQuestion(question: 'Can you Chi with Honor tiles?',
        options: ['Yes, with Winds only', 'Yes, with Dragons only', 'No, Chi needs suited numbers', 'Only if concealed'],
        correctIndex: 2,
        explanation: 'Chi requires three consecutive numbers in the same suit. Honors have no number order.'),
    QuizQuestion(question: 'What do you need to Chi?',
        options: [
          'Two tiles that can form a sequence with the discard',
          'Two identical tiles',
          'Three identical tiles',
          'Any pair of honors',
        ],
        correctIndex: 0,
        explanation: 'For Chi, your two tiles plus the discard must form a suited sequence such as 3-4-5.'),
    QuizQuestion(
        question: 'You hold 3 and {{s4}}. Which tile completes a Chi sequence?',
        options: ['s2', 'east', 'p5', 'red'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          's3', 's4', 'm1', 'm2', 'm3', 'p6', 'p7',
          'p8', 'east', 'east', 'green', 'green', 'white',
        ],
        explanation: 'With s3 and s4, s2 completes the {{f_bamboo}} 2-3-4 sequence. Honors and other suits do not complete this Chi.'),
    QuizQuestion(
        question: 'Arrange these {{f_bamboo}} tiles to form sequence 2→3→4',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['s2', 's3', 's4'],
        explanation: 'A Chi sequence requires consecutive numbers in the same suit: {{s2}} → {{s3}} → {{s4}}.'),
  ]),

  Lesson(id: '2-5', stageId: 'how-to-play', title: 'Kong (杠)',
      subtitle: 'Exposed Kong vs Concealed Kong', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Kong (杠) means four-of-a-kind! There are two types: Exposed Kong (明杠) and Concealed Kong (暗杠).'),
    DialogueMessage(speaker: 'mj',
        text: 'Exposed Kong: you have 3 of a kind, someone discards the 4th — you claim it and show all 4 face-up. You draw a replacement tile from the dead wall!'),
    DialogueMessage(speaker: 'mj',
        text: 'Concealed Kong: you draw all 4 tiles yourself. Declare it, show them (outer tiles face-down, inner face-up), then draw a replacement. Much stronger!'),
    DialogueMessage(speaker: 'mj',
        text: 'Kong gives you an extra draw from the dead wall. If that replacement tile gives you a winning hand, it\'s called "Kong on Kong" — very exciting!'),
  ], questions: [
    QuizQuestion(question: 'What is a Kong (杠)?',
        options: ['Three identical tiles', 'Four identical tiles', 'A sequence of four',
          'Two pairs'], correctIndex: 1,
        explanation: 'Kong means four identical tiles of the same type.'),
    QuizQuestion(question: 'What is the difference between Exposed and Concealed Kong?',
        options: ['No difference', 'Exposed uses a claimed discard', 'Concealed is worth more Faan',
          'Both B and C'], correctIndex: 3,
        explanation: 'Exposed Kong uses a claimed discard (shown). Concealed Kong is self-drawn (worth more Faan).'),
    QuizQuestion(question: 'What happens after declaring a Kong?',
        options: ['Discard immediately', 'Draw a replacement tile', 'Skip your next turn',
          'End the round'], correctIndex: 1,
        explanation: 'After any Kong, you draw a replacement tile from the dead wall.'),
  ]),

  Lesson(id: '2-6', stageId: 'how-to-play', title: 'Priority Rules',
      subtitle: 'Pong beats Chi, Win beats all', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'What if two players want the same discard? There\'s a strict priority system!'),
    DialogueMessage(speaker: 'mj',
        text: 'Rule 1: Winning (胡) beats everything. If someone can win with this tile, they get priority — no matter what others want.'),
    DialogueMessage(speaker: 'mj',
        text: 'Rule 2: Pong beats Chi. If one player wants to Pong and another wants to Chi, Pong wins — even if the Chi player is closer in turn order.'),
    DialogueMessage(speaker: 'mj',
        text: 'Rule 3: Only one player can claim per discard. The priority is always: Win > Pong/Kong > Chi. Simple!'),
  ], questions: [
    QuizQuestion(question: 'What has the highest priority for a discarded tile?',
        options: ['Pong', 'Chi', 'Kong', 'Winning (胡)'], correctIndex: 3,
        explanation: 'Winning the hand always has top priority over any other claim.'),
    QuizQuestion(question: 'Between Pong and Chi, which wins?',
        options: ['Chi, because it uses more tiles', 'Pong', 'Whichever is declared first',
          'The dealer decides'], correctIndex: 1,
        explanation: 'Pong always beats Chi, regardless of turn order.'),
    QuizQuestion(question: 'Can two players both claim the same discard?',
        options: ['Yes, they share it', 'Yes, if they both Pong', 'No, only one player can claim',
          'Only in tournament play'], correctIndex: 2,
        explanation: 'Only one player can claim a discard. Priority: Win > Pong/Kong > Chi.'),
  ]),

  Lesson(id: '2-7', stageId: 'how-to-play', title: 'Concealed vs Exposed',
      subtitle: 'Hidden hand vs revealed melds', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Your hand has two parts: concealed tiles (held secretly in your hand) and exposed melds (shown on the table after Pong, Chi, or Kong).'),
    DialogueMessage(speaker: 'mj',
        text: 'Exposed melds tell opponents what you\'re building! If they see {{m1}}{{m1}}{{m1}} on your table, they know not to discard {{m1}}.'),
    DialogueMessage(speaker: 'mj',
        text: 'A fully concealed hand (no exposed melds at all) is called 门前清 and is worth extra Faan! It\'s harder but more rewarding.'),
    DialogueMessage(speaker: 'mj',
        text: 'Strategy tip: sometimes it\'s better to stay concealed, even if you could Pong. Keep opponents guessing!'),
  ], questions: [
    QuizQuestion(question: 'What is a concealed hand?',
        options: ['All melds are hidden', 'No tiles are exposed on the table', 'Only one meld is exposed',
          'All tiles are face-down'], correctIndex: 1,
        explanation: 'A fully concealed hand has no exposed melds — everything is in your hand.'),
    QuizQuestion(question: 'Why might you avoid claiming a Pong?',
        options: ['It costs points', 'It reveals information to opponents', 'It\'s against the rules',
          'You lose a turn'], correctIndex: 1,
        explanation: 'Exposing melds tells opponents what tiles you need, making them less likely to discard them.'),
    QuizQuestion(question: 'What is the benefit of a fully concealed win?',
        options: ['No benefit', 'Extra Faan (bonus points)', 'You get more tiles',
          'You can play again'], correctIndex: 1,
        explanation: 'A fully concealed hand (门前清) is awarded extra Faan for its difficulty.'),
  ]),

  Lesson(id: '2-8', stageId: 'how-to-play', title: 'Stage 2 Review Quiz',
      subtitle: 'Test your gameplay knowledge!', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'You\'ve learned the core mechanics of mahjong: drawing, discarding, Pong, Chi, Kong, and priority rules!'),
    DialogueMessage(speaker: 'mj',
        text: 'Let\'s do a quick review to make sure everything sticks. Don\'t stress — you can always revisit lessons!'),
  ], questions: [
    QuizQuestion(question: 'What is the correct priority order for claiming a discard?',
        options: ['Chi > Pong > Win', 'Pong > Chi > Win', 'Win > Pong > Chi', 'Win > Chi > Pong'],
        correctIndex: 2, explanation: 'The priority order is always: Win (胡) > Pong/Kong (碰/杠) > Chi (吃).'),
    QuizQuestion(question: 'From which player can you Chi?',
        options: ['Any player', 'Only the player on your left', 'Only the dealer', 'Only the player on your right'],
        correctIndex: 1, explanation: 'Chi can only be claimed from the player immediately to your left (上家).'),
    QuizQuestion(question: 'What happens after declaring a Kong?',
        options: ['Draw a replacement tile', 'End your turn', 'Discard two tiles',
          'Pass to the next player'], correctIndex: 0,
        explanation: 'After any Kong, draw a replacement tile from the dead wall, then discard one.'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 3: Winning Hands (6 lessons)
  // ═══════════════════════════════════
  Lesson(id: '3-1', stageId: 'winning-hands', title: 'How to Win',
      subtitle: '4 melds + 1 pair', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'The magic formula for a winning hand: 4 melds + 1 pair = 14 tiles. That\'s it! A meld can be a sequence or three-of-a-kind.'),
    DialogueMessage(speaker: 'mj',
        text: 'For example: a sequence {{m1}}{{m2}}{{m3}}, a Pong {{red}}{{red}}{{red}}, another Pong {{green}}{{green}}{{green}}, a sequence {{p1}}{{p2}}{{p3}}, and a pair SouthSouth. That\'s a complete hand!'),
    DialogueMessage(speaker: 'mj',
        text: 'When you have all 4 melds + 1 pair, and it\'s your turn, you declare "Hu!" (胡) — you\'ve won! Show your hand and collect your points.'),
    DialogueMessage(speaker: 'mj',
        text: 'Pro tip: a pair is also called "eyes" (将). Without a pair, even 4 perfect melds can\'t win.'),
  ], questions: [
    QuizQuestion(question: 'What is the winning hand formula?',
        options: ['3 melds + 2 pairs', '4 melds + 1 pair', '5 melds', '2 melds + 3 pairs'],
        correctIndex: 1, explanation: 'A winning hand = 4 melds (sequences or triplets) + 1 pair (eyes).'),
    QuizQuestion(question: 'What is a pair also called?',
        options: ['Meld', 'Eyes (将)', 'Run', 'Set'], correctIndex: 1,
        explanation: 'The pair in a winning hand is commonly called "eyes" (将/雀头).'),
    QuizQuestion(question: 'How many tiles in a complete winning hand?',
        options: ['13', '14', '15', '16'], correctIndex: 1,
        explanation: '4 melds (3×4=12) + 1 pair (2) = 14 tiles total.'),
    QuizQuestion(
        question: 'What tile completes this winning hand?',
        options: ['p3', 'p6', 'm1', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9',
          'p1', 'p2', 'red', 'red',
        ],
        explanation:
            'You have three Character sequences, a {{red}} pair, and 1–2 Circles. '
            '3 Circles ({{p3}}) completes the 1–2–3 Circles chow.'),
  ]),

  Lesson(id: '3-2', stageId: 'winning-hands', title: 'Meld Types',
      subtitle: 'Sequences, Triplets, Kongs & Pairs', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Let\'s review the four meld types! A Sequence (顺子) is three consecutive suited tiles: {{m1}}{{m2}}{{m3}}. Only suited tiles can form sequences.'),
    DialogueMessage(speaker: 'mj',
        text: 'A Triplet (刻子) is three identical tiles: {{red}}{{red}}{{red}}. Honors and suited tiles can both form triplets. Exposed or concealed!'),
    DialogueMessage(speaker: 'mj',
        text: 'A Kong (杠子) is four identical tiles: {{green}}{{green}}{{green}}{{green}}. It counts as a meld, but since it has 4 tiles you draw a replacement.'),
    DialogueMessage(speaker: 'mj',
        text: 'A Pair (对子) is two identical tiles: SouthSouth. You need exactly one pair as your "eyes" in the final hand.'),
  ], questions: [
    QuizQuestion(question: 'Which meld type requires suited tiles only?',
        options: ['Triplet', 'Kong', 'Sequence', 'Pair'], correctIndex: 2,
        explanation: 'Sequences (顺子) require suited tiles in consecutive order. Honors can\'t form sequences.'),
    QuizQuestion(question: 'How many tiles are in a Kong?',
        options: ['2', '3', '4', '5'], correctIndex: 2,
        explanation: 'A Kong (杠子) contains 4 identical tiles. Since it\'s 4 tiles (not 3), you draw a replacement.'),
    QuizQuestion(question: 'Can a pair be formed with any two tiles?',
        options: ['Yes, any two tiles', 'No, only identical tiles', 'Only suited tiles',
          'Only honor tiles'], correctIndex: 1,
        explanation: 'A pair must be two identical tiles — same suit and same number, or same honor tile.'),
    QuizQuestion(
        question: 'Which tile completes the Character sequence?',
        options: ['m3', 'm9', 'p5', 'green'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9',
          's1', 's2', 's3', 'p4', 'p4',
        ],
        explanation:
            'You hold 1–2 Characters ({{m1}}{{m2}}) plus three other complete melds and a Circles pair. '
            '3 Characters ({{m3}}) completes the 1–2–3 sequence.'),
    QuizQuestion(
        question: 'Arrange these Wan tiles in a 5→6→7 sequence',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m5', 'm6', 'm7'],
        explanation: 'A sequence (顺子) is three consecutive numbers in the same suit: 5→6→{{m7}}.'),
  ]),

  Lesson(id: '3-3', stageId: 'winning-hands', title: 'Self-Draw vs Claiming',
      subtitle: '自摸 vs 食胡', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'There are two ways to win! Self-Draw (自摸): you draw the winning tile yourself from the wall. This pays more because all 3 opponents pay you!'),
    DialogueMessage(speaker: 'mj',
        text: 'Claiming a discard (食胡): someone discards the tile you need. You call "Hu!" and take it. Only the discarder pays you, and it\'s usually worth less.'),
    DialogueMessage(speaker: 'mj',
        text: 'Self-Draw gives +1 bonus Faan! So a 3-Faan hand self-drawn becomes 4 Faan. That\'s why players love the thrill of drawing their winning tile.'),
  ], questions: [
    QuizQuestion(question: 'What is Self-Draw (自摸)?',
        options: ['Claiming a discard to win', 'Drawing your winning tile from the wall',
          'Winning without any melds', 'Winning as the dealer'], correctIndex: 1,
        explanation: 'Self-Draw means you draw your winning tile from the wall yourself.'),
    QuizQuestion(question: 'Who pays when you win by Self-Draw?',
        options: ['Only the dealer', 'Only the player who last discarded', 'All three opponents',
          'Nobody pays, it\'s free'], correctIndex: 2,
        explanation: 'On a Self-Draw win, all three opponents pay the winner.'),
    QuizQuestion(question: 'How much bonus Faan does Self-Draw give?',
        options: ['0', '+1 Faan', '+2 Faan', '+3 Faan'], correctIndex: 1,
        explanation: 'Self-Draw awards +1 bonus Faan to the winning hand.'),
  ]),

  Lesson(id: '3-4', stageId: 'winning-hands', title: 'Common Patterns',
      subtitle: 'All Pongs, Half Flush & Full Flush', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'All Pongs (对对胡) means every meld is a triplet or Kong — no sequences at all! Think: {{m1}}{{m1}}{{m1}} {{red}}{{red}}{{red}} {{green}}{{green}}{{green}} {{p1}}{{p1}}{{p1}} + pair. Very satisfying!'),
    DialogueMessage(speaker: 'mj',
        text: 'Half Flush (混一色): all your melds use only one suit PLUS honor tiles. Example: all Wan tiles + some dragons/winds. Worth 3 Faan!'),
    DialogueMessage(speaker: 'mj',
        text: 'Full Flush (清一色): your entire hand is one suit — no honors at all. Example: 14 tiles, all {{f_bamboo}}. This is worth 7 Faan!'),
    DialogueMessage(speaker: 'mj',
        text: 'These patterns stack with other patterns. A Full Flush + All Pongs? That\'s a monster hand!'),
  ], questions: [
    QuizQuestion(question: 'What is All Pongs (对对胡)?',
        options: ['All melds are sequences', 'All melds are triplets or Kongs', 'All tiles are pairs',
          'All tiles are honors'], correctIndex: 1,
        explanation: 'All Pongs means every meld in your hand is a triplet or Kong — no sequences.'),
    QuizQuestion(question: 'How many Faan is a Full Flush (清一色)?',
        options: ['3 Faan', '5 Faan', '7 Faan', '10 Faan'], correctIndex: 2,
        explanation: 'Full Flush (清一色) — all tiles in one suit — is worth 7 Faan.'),
    QuizQuestion(question: 'What does Half Flush (混一色) include?',
        options: ['Two suits only', 'One suit only', 'One suit + honors', 'Honors only'],
        correctIndex: 2, explanation: 'Half Flush uses one suit plus honor tiles (winds and dragons).'),
    QuizQuestion(
        question: 'This hand is All Pongs — what tile is it waiting for?',
        options: ['m8', 'm2', 'p2', 'red'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm2', 'm2', 'm2', 'm5', 'm5', 'm5', 'm8', 'm8',
          'p1', 'p1', 'p1', 'red', 'red',
        ],
        explanation:
            'Three Pongs (2, 5, and 1 of mixed suits) plus a {{red}} pair. '
            'The third 8 Characters ({{m8}}) completes the final Pong.'),
  ]),

  Lesson(id: '3-5', stageId: 'winning-hands', title: 'Special Hands',
      subtitle: 'Thirteen Orphans, Small/Large Three Dragons', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Some hands are legendary! Thirteen Orphans (十三幺): one of every terminal (1 and 9 of each suit) and honor tile, plus one duplicate. Ultra rare — limit hand!'),
    DialogueMessage(speaker: 'mj',
        text: 'Small Three Dragons (小三元): two dragon Pongs + one dragon pair. Example: {{red}}{{red}}{{red}} + {{green}}{{green}}{{green}} + {{white}}{{white}}. Worth 5+ Faan!'),
    DialogueMessage(speaker: 'mj',
        text: 'Large Three Dragons (大三元): all three dragon Pongs! {{red}}{{red}}{{red}} + {{green}}{{green}}{{green}} + {{white}}{{white}}{{white}} + any meld + pair. This is a limit hand — maximum payout!'),
  ], questions: [
    QuizQuestion(question: 'What tiles are needed for Thirteen Orphans (十三幺)?',
        options: ['All suited tiles 1-9', 'All terminal and honor tiles + one duplicate',
          'All dragon tiles', 'All wind tiles'], correctIndex: 1,
        explanation: 'Thirteen Orphans requires one of each 1/9 suited tile, each honor, plus one duplicate.'),
    QuizQuestion(question: 'How many dragon Pongs in a Large Three Dragons (大三元)?',
        options: ['1', '2', '3', '4'], correctIndex: 2,
        explanation: 'Large Three Dragons requires all three dragon Pongs — Red, Green, and White.'),
    QuizQuestion(question: 'Thirteen Orphans and Large Three Dragons are what type of hand?',
        options: ['1 Faan hands', '3 Faan hands', 'Limit hands (maximum payout)',
          'No-value hands'], correctIndex: 2,
        explanation: 'Both are limit hands (例牌), giving the maximum possible payout regardless of base Faan.'),
  ]),

  Lesson(id: '3-6', stageId: 'winning-hands', title: 'Stage 3 Review Quiz',
      subtitle: 'Test your winning hand knowledge!', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'You now know the winning formula, meld types, self-draw vs claiming, common patterns, and special hands!'),
    DialogueMessage(speaker: 'mj',
        text: 'This is the heart of mahjong. Let\'s review!'),
  ], questions: [
    QuizQuestion(question: 'What is the winning hand formula?',
        options: ['3 melds + 1 pair', '4 melds + 1 pair', '5 melds', '3 pairs + 2 melds'],
        correctIndex: 1, explanation: '4 melds (sequences or triplets) + 1 pair = winning hand.'),
    QuizQuestion(question: 'Who pays on a Self-Draw win?',
        options: ['Only the dealer', 'Only the discarder', 'All three opponents', 'The winner pays others'],
        correctIndex: 2, explanation: 'Self-Draw means all three opponents pay the winner.'),
    QuizQuestion(
        question: 'What is this {{f_bamboo}} hand waiting for?',
        options: ['s1', 's9', 'p4', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          's1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9',
          's2', 's3', 'p5', 'p5',
        ],
        explanation:
            'Three {{f_bamboo}} sequences plus a Circles pair, with 2–{{s3}} waiting. '
            '{{s1}} ({{s1}}) completes the second 1–2–{{s3}} chow.'),
    QuizQuestion(question: 'A Full Flush (清一色) is worth how many Faan?',
        options: ['3', '5', '7', '10'], correctIndex: 2,
        explanation: 'Full Flush (all tiles in one suit) is worth 7 Faan.'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 4: Scoring & Faan (8 lessons)
  // ═══════════════════════════════════
  Lesson(id: '4-1', stageId: 'scoring-faan', title: 'What is Faan?',
      subtitle: 'The scoring unit of mahjong', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Faan (番) is the scoring unit in mahjong. Each pattern in your hand gives a certain number of Faan. More Faan = bigger payout!'),
    DialogueMessage(speaker: 'mj',
        text: 'In HK Mahjong, you need a minimum of 3 Faan to win. A hand with only 1 or 2 Faan is called "chicken hand" (鸡胡) and can\'t win.'),
    DialogueMessage(speaker: 'mj',
        text: 'Faan come from patterns like Full Flush, All Pongs, or having your own Wind. Some patterns are worth 1 Faan, others are worth 7 or even a limit!'),
    DialogueMessage(speaker: 'mj',
        text: 'The payout doubles for each Faan above 3! 4 Faan pays 2× base, 5 Faan pays 4×, 6 Faan pays 8×... and limit hands pay the maximum.'),
  ], questions: [
    QuizQuestion(question: 'What is the minimum Faan required to win in HK Mahjong?',
        options: ['1 Faan', '2 Faan', '3 Faan', '5 Faan'], correctIndex: 2,
        explanation: 'Hong Kong Mahjong generally requires at least 3 Faan to declare a win.'),
    QuizQuestion(question: 'What is a hand with insufficient Faan called?',
        options: ['Dead hand', 'Chicken hand (鸡胡)', 'Empty hand', 'Weak hand'],
        correctIndex: 1, explanation: 'A hand below 3 Faan is called a "chicken hand" and cannot win.'),
    QuizQuestion(question: 'How does the payout scale with Faan?',
        options: ['Linearly (1× per Faan)', 'Doubles for each Faan above 3',
          'Fixed per Faan', 'Random'], correctIndex: 1,
        explanation: 'Each Faan above 3 doubles the payout: exponential growth!'),
  ]),

  Lesson(id: '4-2', stageId: 'scoring-faan', title: '1—2 Faan Patterns',
      subtitle: 'Basic scoring patterns', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Let\'s learn the smallest patterns! Ping Hu (平胡): all sequences, no triplets, with a suited pair. Worth 1 Faan.'),
    DialogueMessage(speaker: 'mj',
        text: 'No Flowers (无花): you collected no bonus tiles. Worth 1 Faan — a consolation prize if the flowers did not come your way.'),
    DialogueMessage(speaker: 'mj',
        text: 'Self-Draw (自摸): +1 Faan bonus. Own Wind: having a Pong of your seat wind gives +1 Faan. Round Wind gives the same for the round wind.'),
    DialogueMessage(speaker: 'mj',
        text: 'These small patterns add up. 1 + 1 + 1 = 3 Faan, which is just enough to win under common Hong Kong Mahjong rules.'),
  ], questions: [
    QuizQuestion(question: 'What is Ping Hu?',
        options: [
          'All triplets',
          'All sequences with a suited pair',
          'Only honor tiles',
          'Any hand with Dragons',
        ],
        correctIndex: 1,
        explanation: 'Ping Hu is built from sequences, with no triplets, and uses a suited pair as the eyes.'),
    QuizQuestion(question: 'How much Faan does Self-Draw add?',
        options: ['0 Faan', '+1 Faan', '+2 Faan', '+3 Faan'],
        correctIndex: 1,
        explanation: 'In Hong Kong Mahjong teaching rules, Self-Draw adds 1 Faan to the hand.'),
    QuizQuestion(question: 'A Pong of your own seat wind is worth how much?',
        options: ['0 Faan', '1 Faan', '3 Faan', 'Limit hand'],
        correctIndex: 1,
        explanation: 'Your own seat wind Pong is a small scoring pattern worth 1 Faan.'),
    QuizQuestion(
        question: 'Which tile would complete this Ping Hu-style sequence hand?',
        options: ['p6', 'red', 'east', 'm9'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm3', 's2', 's3', 's4', 's6',
          's7', 's8', 'p4', 'p5', 'm5', 'm5',
        ],
        explanation: 'The hand already has three sequences and a suited pair. p6 completes the 4-5-6 Circles sequence.'),
    QuizQuestion(
        question: 'Arrange these honor tiles in order: Wind ({{east}}) then Dragons (Red→Green→White)',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['east', 'red', 'green', 'white'],
        explanation: 'The standard display order is {{east}} Wind first, then Red, Green, {{white}}s.'),
  ]),

  Lesson(id: '4-3', stageId: 'scoring-faan', title: '3—5 Faan Patterns',
      subtitle: 'Mid-tier scoring hands', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Half Flush (混一色): one suit + honors. Worth 3 Faan. A very common mid-tier hand!'),
    DialogueMessage(speaker: 'mj',
        text: 'All Pongs (对对胡): every meld is a triplet. Worth 3 Faan. No sequences means opponents see those exposed triplets and get nervous!'),
    DialogueMessage(speaker: 'mj',
        text: 'Mixed One-Suit (混一色) + All Pongs (对对胡) together? That\'s 3 + 3 = 6 Faan — a very respectable hand!'),
    DialogueMessage(speaker: 'mj',
        text: 'All Concealed (门前清): no exposed melds, win by self-draw. Worth 5 Faan. Hard to achieve, but satisfying!'),
  ], questions: [
    QuizQuestion(question: 'How many Faan is Half Flush (混一色)?',
        options: ['1', '3', '5', '7'], correctIndex: 1,
        explanation: 'Half Flush (one suit + honors) is worth 3 Faan.'),
    QuizQuestion(question: 'All Pongs and Half Flush together give how many Faan?',
        options: ['4', '5', '6', '8'], correctIndex: 2,
        explanation: '3 Faan (All Pongs) + 3 Faan (Half Flush) = 6 Faan total.'),
    QuizQuestion(question: 'What is required for All Concealed (门前清)?',
        options: ['No exposed melds + self-draw win', 'All sequences', 'Only honor tiles',
          'Win by claiming discard'], correctIndex: 0,
        explanation: 'All Concealed means no exposed melds, winning by self-draw. Worth 5 Faan.'),
  ]),

  Lesson(id: '4-4', stageId: 'scoring-faan', title: '6—9 Faan Patterns',
      subtitle: 'High-value scoring hands', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Full Flush (清一色): all tiles in one suit. Worth 7 Faan. A beautiful hand — imagine all 14 tiles as {{f_bamboo}}!'),
    DialogueMessage(speaker: 'mj',
        text: 'Small Three Dragons (小三元): two Dragon Pongs plus one Dragon pair. It is valuable and often combines with other patterns.'),
    DialogueMessage(speaker: 'mj',
        text: 'Mixed Triple Sequence (三色同顺): the same sequence in all three suits, such as 1-2-3 Characters, 1-2-{{s3}}, and 1-2-3 Circles.'),
    DialogueMessage(speaker: 'mj',
        text: 'High-value hands are harder to build, but they can create much larger payouts when the structure is clear.'),
  ], questions: [
    QuizQuestion(question: 'How many Faan is Full Flush (清一色)?',
        options: ['3', '5', '7', 'Limit only'],
        correctIndex: 2,
        explanation: 'Full Flush — all tiles in one suit — is worth 7 Faan.'),
    QuizQuestion(question: 'What is Mixed Triple Sequence (三色同顺)?',
        options: [
          'The same sequence in all three suits',
          'Three Pongs in one suit',
          'Three Dragon pairs',
          'Any three sequences',
        ],
        correctIndex: 0,
        explanation: 'The exact same sequence (e.g., 1-2-3) in Wan, Tiao, and Tong — worth 6 Faan.'),
    QuizQuestion(question: 'Small Three Dragons requires what Dragon structure?',
        options: [
          'One Dragon Pong only',
          'Two Dragon Pongs and one Dragon pair',
          'Three Dragon pairs',
          'All three Dragon Pongs',
        ],
        correctIndex: 1,
        explanation: 'Small Three Dragons has two Dragon Pongs and the remaining Dragon as the pair.'),
    QuizQuestion(
        question: 'This hand is aiming for Full Flush. Which tile keeps the hand one-suit only?',
        options: ['s9', 'm9', 'red', 'p9'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          's1', 's1', 's1', 's2', 's3', 's4', 's5',
          's6', 's7', 's7', 's8', 's9', 's9',
        ],
        explanation: 'All current tiles are {{f_bamboo}}. Choosing s9 keeps the hand in one suit, while m9, p9, or red would break Full Flush.'),
  ]),

  Lesson(id: '4-5', stageId: 'scoring-faan', title: 'Limit Hands',
      subtitle: 'Maximum payout patterns', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Limit hands (例牌) pay the absolute maximum! Even if they technically score fewer fan, they cap out at the limit — usually 10 or 13 Faan equivalent.'),
    DialogueMessage(speaker: 'mj',
        text: 'Large Three Dragons (大三元): {{red}}{{red}}{{red}} + {{green}}{{green}}{{green}} + {{white}}{{white}}{{white}} + any meld + pair. All three dragon Pongs! The ultimate hand.'),
    DialogueMessage(speaker: 'mj',
        text: 'Large Four Winds (大四喜): {{east}} {{east}}, {{south}} {{south}}, {{west}} {{west}}, {{north}} {{north}} — all four wind Pongs! Plus any pair. Probably the rarest hand in mahjong.'),
    DialogueMessage(speaker: 'mj',
        text: 'Thirteen Orphans (十三幺), All Honors (字一色), All Kongs (十八罗汉) — all limit hands. When you see one, it\'s a moment to remember!'),
  ], questions: [
    QuizQuestion(question: 'What is the payout for a limit hand?',
        options: ['Same as other hands', 'Double normal payout', 'Maximum possible payout',
          'No payout'], correctIndex: 2,
        explanation: 'Limit hands always pay the maximum, regardless of their technical Faan count.'),
    QuizQuestion(question: 'Large Four Winds (大四喜) requires what?',
        options: ['All four wind Pongs', 'All four dragon Pongs', 'All four suits',
          'Four sequences'], correctIndex: 0,
        explanation: 'Large Four Winds needs Pongs of all four winds — {{east}}, {{south}}, {{west}}, {{north}}.'),
    QuizQuestion(question: 'All Honors (字一色) contains only what?',
        options: ['Only suited tiles', 'Only honor tiles (winds & dragons)', 'Only flowers',
          'Only 1 and 9 tiles'], correctIndex: 1,
        explanation: 'All Honors uses only wind and dragon tiles — no suited tiles at all.'),
  ]),

  Lesson(id: '4-6', stageId: 'scoring-faan', title: 'Payment Rules',
      subtitle: 'Who pays whom & dealer doubles', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Payment depends on how you win! Self-Draw (自摸): all 3 opponents pay you. Each pays the same amount.'),
    DialogueMessage(speaker: 'mj',
        text: 'Win by discard (食胡): only the player who discarded your winning tile pays. The other two pay nothing.'),
    DialogueMessage(speaker: 'mj',
        text: 'The dealer rule: when the dealer wins or loses, the amount doubles! Dealer pays double when losing, but receives double when winning.'),
    DialogueMessage(speaker: 'mj',
        text: 'Example: a 4-Faan hand. Base = 8 points. Self-draw: 8+8+8 = 24 total. Discard: one player pays 8. Dealer? Double everything!'),
  ], questions: [
    QuizQuestion(question: 'On a Self-Draw win, who pays?',
        options: ['Only the dealer', 'Only the discarder', 'All three opponents', 'Nobody'],
        correctIndex: 2, explanation: 'Self-Draw means all three opponents pay the winner.'),
    QuizQuestion(question: 'What happens when the dealer wins?',
        options: ['Same payout as normal', 'Payout is doubled', 'Payout is halved', 'Dealer gets no payout'],
        correctIndex: 1, explanation: 'The dealer receives double payment when winning and pays double when losing.'),
    QuizQuestion(question: 'On a discard win, who pays the winner?',
        options: ['All players', 'Only the discarder', 'The dealer and discarder',
          'The two players next to the winner'], correctIndex: 1,
        explanation: 'When you win by claiming a discard, only the player who discarded that tile pays.'),
  ]),

  Lesson(id: '4-7', stageId: 'scoring-faan', title: 'Faan Calculation Practice',
      subtitle: 'Real scoring scenarios', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Let\'s practice! Scenario: you have All Pongs (3 Faan), Half Flush (3 Faan), and Self-Draw (+1). Total: 7 Faan.'),
    DialogueMessage(speaker: 'mj',
        text: '7 Faan payout: base × 2^(7-3) = base × 16. If base is 2, each opponent pays 32 points.'),
    DialogueMessage(speaker: 'mj',
        text: 'Scenario 2: Full Flush (7 Faan) plus Self-Draw (+1) = 8 Faan. That is a very strong hand.'),
    DialogueMessage(speaker: 'mj',
        text: 'The key is stacking patterns. Even small patterns like Own Wind and Self-Draw can help you reach the 3-Faan minimum.'),
  ], questions: [
    QuizQuestion(question: 'How much is a 7 Faan hand worth (multiplier)?',
        options: ['×4', '×8', '×16', '×32'], correctIndex: 2,
        explanation: 'Each Faan above 3 doubles: 4→2, 5→4, 6→8, 7→16. So 7 Faan = base ×16.'),
    QuizQuestion(question: 'Which small patterns can help reach 3 Faan?',
        options: [
          'Own Wind + No Flowers + Self-Draw',
          'Only Full Flush',
          'Any single sequence',
          'One pair of Dragons only',
        ],
        correctIndex: 0,
        explanation: 'Each of those patterns is worth 1 Faan, so together they reach the 3-Faan minimum.'),
    QuizQuestion(question: 'What is the multiplier for 5 Faan?',
        options: ['×2', '×4', '×8', '×16'], correctIndex: 1,
        explanation: '5 Faan = 2^(5-3) = 2^2 = 4×. Each Faan above 3 doubles the base.'),
    QuizQuestion(
        question: 'Which tile completes a Half Flush hand with one suit plus honors?',
        options: ['m8', 's8', 'p8', 'green'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8',
          'm8', 'east', 'east', 'east', 'red', 'red',
        ],
        explanation: 'The hand uses Characters plus honors. m8 completes the 8 Character pair while keeping the Half Flush structure.'),
  ]),

  Lesson(id: '4-8', stageId: 'scoring-faan', title: 'Stage 4 Review Quiz',
      subtitle: 'Test your scoring knowledge!', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'You\'ve mastered the scoring system! Faan values, patterns from 1 to limit hands, payment rules, and calculation.'),
    DialogueMessage(speaker: 'mj',
        text: 'One last review before we move to strategy. Ready?'),
  ], questions: [
    QuizQuestion(question: 'What is the minimum Faan to win in HK Mahjong?',
        options: ['1', '2', '3', '5'], correctIndex: 2,
        explanation: 'A minimum of 3 Faan is required to declare a winning hand.'),
    QuizQuestion(question: 'Who pays double in mahjong?',
        options: ['The winner', 'The youngest player', 'The dealer', 'The player with most tiles'],
        correctIndex: 2, explanation: 'The dealer pays double when losing and receives double when winning.'),
    QuizQuestion(question: 'Large Three Dragons is what type of hand?',
        options: ['1 Faan', '3 Faan', '7 Faan', 'Limit hand (maximum payout)'],
        correctIndex: 3, explanation: 'Large Three Dragons is a limit hand paying the maximum possible amount.'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 5: Strategy (6 lessons)
  // ═══════════════════════════════════
  Lesson(id: '5-1', stageId: 'strategy', title: 'Reading Discards',
      subtitle: 'Infer opponents\' hands from the pool', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'The discard pool is a goldmine of information! If a player discards {{m2}}{{m3}} (2-{{m3}}), they probably don\'t need Wan tiles for a sequence.'),
    DialogueMessage(speaker: 'mj',
        text: 'Watch for "safe" patterns: if someone has discarded multiple {{f_bamboo}} tiles, they\'re likely building in other suits. You can safely discard {{f_bamboo}}!'),
    DialogueMessage(speaker: 'mj',
        text: 'Late-round discards are the most telling. If a player suddenly switches suit, they might be one tile away from winning. Stay alert!'),
    DialogueMessage(speaker: 'mj',
        text: 'Pro tip: if someone discards a tile that would complete an obvious sequence for you, be suspicious. They might be baiting you to reveal your hand!'),
  ], questions: [
    QuizQuestion(question: 'What can you learn from the discard pool?',
        options: ['Nothing useful', 'Which suits opponents are likely building',
          'The exact tiles in every hand', 'Only the dealer\'s strategy'], correctIndex: 1,
        explanation: 'Discards reveal which suits and tiles opponents don\'t need, helping you infer their hand.'),
    QuizQuestion(question: 'What does switching suits late in the round suggest?',
        options: ['The player is confused', 'They might be close to winning', 'They\'re giving up',
          'They want to lose'], correctIndex: 1,
        explanation: 'A sudden suit switch late in the round often means a player is one tile from winning.'),
    QuizQuestion(question: 'Why should you be suspicious of "too helpful" discards?',
        options: ['The player is being nice', 'It might be bait to reveal your hand',
          'It\'s against the rules', 'Discards are always random'], correctIndex: 1,
        explanation: 'A discard that perfectly completes your sequence might be bait — the player wants to see what you\'re building.'),
  ]),

  Lesson(id: '5-2', stageId: 'strategy', title: 'Defensive Play',
      subtitle: 'Breaking up hands & discarding safely', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Sometimes the best offense is defense! If you suspect an opponent is close to winning, switch to "safe discard" mode.'),
    DialogueMessage(speaker: 'mj',
        text: 'Safe tiles are those already discarded or clearly visible. If several copies of a tile are visible, it is less likely to complete someone\'s hand.'),
    DialogueMessage(speaker: 'mj',
        text: 'Breaking your own hand to defend is painful but smart. It is better to lose a possible win than to deal into someone else\'s winning hand.'),
    DialogueMessage(speaker: 'mj',
        text: 'When defending, be careful with middle suited tiles like 4, 5, and 6. They connect to many sequences and are often dangerous.'),
  ], questions: [
    QuizQuestion(question: 'What is a "safe tile"?',
        options: [
          'A tile already shown or discarded that is less likely to win for someone',
          'Any tile from your favorite suit',
          'A tile drawn from the dead wall',
          'A tile with a high number',
        ],
        correctIndex: 0,
        explanation: 'Safe tiles are based on visible information. If a tile has already appeared, it is often less risky than an unseen tile.'),
    QuizQuestion(question: 'Which tiles are the most dangerous to discard?',
        options: ['1 and 9 tiles', 'Honor tiles', 'Middle suited tiles like 4-5-6', 'Flower tiles'],
        correctIndex: 2,
        explanation: 'Middle numbers connect to many possible sequences, so they can complete more opponents\' waits.'),
    QuizQuestion(question: 'When should you play defensively?',
        options: [
          'When an opponent seems close to winning',
          'Only on the first turn',
          'Only when you have many Flowers',
          'Never',
        ],
        correctIndex: 0,
        explanation: 'If an opponent looks ready, avoiding a dangerous discard may be better than chasing your own slow hand.'),
    QuizQuestion(
        question: 'Late in the hand, which discard is usually safer?',
        options: ['east', 'm5', 'p6', 's4'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'east', 'east', 'm2', 'm3', 'm4', 's4', 's5',
          's6', 'p4', 'p5', 'p6', 'red', 'red',
        ],
        explanation: 'An already visible {{east}} is usually safer than middle suited tiles, because middle tiles complete many sequences.'),
  ]),

  Lesson(id: '5-3', stageId: 'strategy', title: 'Hand Building',
      subtitle: 'Choosing your path & planning Shanten', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Shanten (向听) means "how many tiles away from winning." 1-shanten means you need 1 useful tile. Your goal is to reduce Shanten every turn.'),
    DialogueMessage(speaker: 'mj',
        text: 'Early game: keep pairs because they can become Pongs or your final pair. Keep related tiles like 2-3 in the same suit.'),
    DialogueMessage(speaker: 'mj',
        text: 'Mid game: commit to a path. If you have many Character tiles, consider Half Flush or Full Flush. If you have many pairs, consider All Pongs.'),
    DialogueMessage(speaker: 'mj',
        text: 'Late game: if you are far from winning, switch to defense. A draw is often better than dealing into someone else\'s win.'),
  ], questions: [
    QuizQuestion(question: 'What does Shanten measure?',
        options: ['Your score', 'How many tiles away you are from winning', 'The number of Flowers', 'Dealer order'],
        correctIndex: 1,
        explanation: 'Shanten tells you how close your hand is to being ready or complete.'),
    QuizQuestion(question: 'What should beginners usually keep early in the hand?',
        options: [
          'Pairs and connected suited tiles',
          'Only isolated honors',
          'Only terminal tiles',
          'Nothing from one suit',
        ],
        correctIndex: 0,
        explanation: 'Pairs can become Pongs or eyes, and connected tiles can become sequences.'),
    QuizQuestion(question: 'If you are far from winning late in the round, what is often best?',
        options: ['Switch to defense', 'Discard randomly', 'Always call Pong', 'Reveal your hand'],
        correctIndex: 0,
        explanation: 'Late in the round, a slow hand is risky. Defense can prevent you from dealing into someone else\'s win.'),
    QuizQuestion(
        question: 'Which tile best improves this hand toward a simple sequence structure?',
        options: ['m3', 'east', 'red', 'north'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm4', 'm5', 's2', 's3', 's4',
          'p6', 'p7', 'p8', 'red', 'red', 'east',
        ],
        explanation: 'm3 connects with m1-m2 and m4-m5, creating strong sequence options. Extra isolated honors are less flexible here.'),
  ]),

  Lesson(id: '5-4', stageId: 'strategy', title: 'Tile Counting',
      subtitle: 'Tracking visible tiles & probability', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Tile counting is simple: there are 4 copies of every tile. Count how many you can see (in your hand, exposed melds, discards).'),
    DialogueMessage(speaker: 'mj',
        text: 'Example: you need {{m3}} to win. You see 2 in your hand and 1 in discards. That leaves 1 unseen — slim chances! Maybe switch targets.'),
    DialogueMessage(speaker: 'mj',
        text: 'If you see 0 copies of a tile you need, all 4 are still available — great odds! If 3 are gone, only 1 remains — consider a backup plan.'),
    DialogueMessage(speaker: 'mj',
        text: 'Advanced: track which tiles are likely in opponents\' hands. If nobody has discarded {{red}} all round, someone is probably holding Dragons!'),
  ], questions: [
    QuizQuestion(question: 'How many copies of each tile exist?',
        options: ['2', '3', '4', '6'],
        correctIndex: 2,
        explanation: 'There are 4 copies of every tile in the set. Count visible ones to estimate availability.'),
    QuizQuestion(question: 'If you see 3 copies of a tile and need the 4th, what are the odds?',
        options: ['Good (75%)', 'Slim (only 1 remains)', 'Impossible', '50%'],
        correctIndex: 1,
        explanation: 'Only 1 copy remains unseen — low probability of drawing it.'),
    QuizQuestion(question: 'What does it mean if no Dragons have been discarded all round?',
        options: ['Nobody drew any', 'Someone is likely holding Dragons', 'Dragons were removed', 'It means nothing'],
        correctIndex: 1,
        explanation: 'If a tile type has not appeared all round, someone is almost certainly holding it.'),
  ]),

  Lesson(id: '5-5', stageId: 'strategy', title: 'Table Psychology',
      subtitle: 'Reading opponents & bluffing', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'Mahjong is as much about people as tiles! Watch how opponents act: quick discards = confident hand. Hesitation = tough decision.'),
    DialogueMessage(speaker: 'mj',
        text: 'Bluffing: deliberately discard a tile you DON\'T need to mislead others. If you discard {{m1}}, opponents think you don\'t want Wan — then surprise them!'),
    DialogueMessage(speaker: 'mj',
        text: 'Some players touch tiles before discarding. Others rearrange their hand constantly. These habits reveal information — learn to read them!'),
    DialogueMessage(speaker: 'mj',
        text: 'Stay calm yourself! Don\'t let opponents read YOU. Keep a poker face, maintain steady pace. MJ\'s secret: always look like you\'re 1 tile from winning!'),
  ], questions: [
    QuizQuestion(question: 'What might a quickly discarded tile indicate?',
        options: ['The player is in a hurry', 'The player is confident in their hand', 'The player is bored', 'The player wants to lose'],
        correctIndex: 1,
        explanation: 'Quick, confident discards often suggest the player has a clear hand-building plan.'),
    QuizQuestion(question: 'What is a bluff discard?',
        options: ['Discarding a tile you need', 'Discarding a tile to mislead opponents', 'Discarding all your tiles', 'Not discarding at all'],
        correctIndex: 1,
        explanation: 'Bluffing means discarding to make opponents think you do not need a certain suit.'),
    QuizQuestion(question: 'What should YOUR table demeanor be?',
        options: ['Show excitement when close to winning', 'Stay calm and steady (poker face)', 'Talk constantly', 'Look at others\' hands'],
        correctIndex: 1,
        explanation: 'Maintain a calm, steady demeanor to avoid revealing your hand strength to opponents.'),
  ]),

  Lesson(id: '5-6', stageId: 'strategy', title: 'Common Mistakes & Final Review',
      subtitle: 'Newbie errors to avoid + comprehensive review', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: 'You\'ve come so far! Let\'s cover common beginner mistakes so you can avoid them.'),
    DialogueMessage(speaker: 'mj',
        text: 'Mistake #1: Ponging too eagerly. Every Pong exposes your hand. Only Pong if it brings you closer to winning, not just because you can.'),
    DialogueMessage(speaker: 'mj',
        text: 'Mistake #2: Ignoring defense. Always check if your discard is safe, especially late in the hand.'),
    DialogueMessage(speaker: 'mj',
        text: 'Mistake #3: Not counting Faan. Many beginners build a complete hand only to realize it has only 2 Faan, which is not enough to win.'),
    DialogueMessage(speaker: 'mj',
        text: 'You now know all 36 lessons of Hong Kong Mahjong, from basic tiles to advanced strategy. Practice makes perfect!'),
  ], questions: [
    QuizQuestion(question: 'Why is Ponging too eagerly a mistake?',
        options: [
          'It exposes your hand and may not improve your chance to win',
          'It gives your tiles to the dealer',
          'It immediately ends the round',
          'It removes your Faan',
        ],
        correctIndex: 0,
        explanation: 'Calling Pong reveals information. If it does not clearly improve your hand, staying concealed may be stronger.'),
    QuizQuestion(question: 'What is one of the worst outcomes in mahjong?',
        options: [
          'Dealing into someone else\'s winning hand',
          'Drawing no Flowers',
          'Winning by Self-Draw',
          'Having a pair early',
        ],
        correctIndex: 0,
        explanation: 'If you discard the winning tile, you may be the only player who pays, so defensive awareness matters.'),
    QuizQuestion(question: 'What should you always track before declaring a win?',
        options: ['Your Faan count', 'Only the number of tiles in the wall', 'The table color', 'Who shuffled fastest'],
        correctIndex: 0,
        explanation: 'In Hong Kong Mahjong, a complete hand still needs enough Faan, usually at least 3, to legally win.'),
    QuizQuestion(
        question: 'This hand has many Character tiles and honors. Which discard best keeps a Half Flush plan?',
        options: ['p4', 'm7', 'red', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm3', 'm5', 'm5', 'm5', 'm7',
          'm8', 'm9', 'east', 'east', 'red', 'p4',
        ],
        explanation: 'Half Flush uses one suit plus honors. Discarding p4 removes the off-suit tile and keeps the Character-plus-honors plan.'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 3: Guangdong Faan (6 lessons)
  //  ═══════════════════════════════════
  Lesson(id: '6-1', stageId: 'gdmj-fans', title: '一番 (上)',
      subtitle: '平糊、自摸、無花、正花、門風、圈風', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '歡迎進入真正嘅廣東麻雀番種世界！我哋會由淺入深，逐一拆解每一種番種嘅計算方法。首先係一番嘅牌型！'),
    DialogueMessage(speaker: 'mj',
        text: '平糊（1番）：任意4組順子加一對眼，而且對眼唔可以係番子。最基礎嘅一番牌型，好考你砌牌嘅基本功！',
        tileIds: ['m1','m2','m3','s2','s3','s4','p4','p5','p6','p1','p2','p3','s6','s6']),
    DialogueMessage(speaker: 'mj',
        text: '自摸（1番）：自己摸到食糊嘅牌。記住，自摸係一番，仲要三家一齊俾錢，收益比食出銃多好多！'),
    DialogueMessage(speaker: 'mj',
        text: '無花（1番）：食糊時成副牌冇任何花牌。冇花都有得加分，算係一種安慰獎。'),
    DialogueMessage(speaker: 'mj',
        text: '正花（1番）：食糊時有同自己門風一樣嘅花牌！東位＝1號花、南位＝2號花、西位＝3號花、北位＝4號花。坐啱位仲要摸到對應花牌，雙重好運！',
        tileIds: ['f_spring','f_summer','f_autumn','f_winter']),
    DialogueMessage(speaker: 'mj',
        text: '門風（1番）：食糊時擁有同自己坐位相同嘅刻子。例如你坐東位，手上有一個東嘅碰牌。',
        tileIds: ['east','east','east','m1','m2','m3','s2','s3','s4','p5','p6','p7','s9','s9']),
    DialogueMessage(speaker: 'mj',
        text: '圈風（1番）：同門風一樣道理，不過係睇當前圈。例如而家打東圈，你手上有東嘅刻子就加一番。圈風同門風可以疊加㗎！'),
  ], questions: [
    QuizQuestion(question: '平糊嘅對眼必須係咩牌？',
        options: ['番子（東南西北中發白）', '非番子嘅數字牌', '任何牌都得', '必定係風牌'],
        correctIndex: 1,
        explanation: '平糊要求4組順子加一對眼，而對眼必須係非番子嘅數字牌。'),
    QuizQuestion(question: '以下邊個描述係正確嘅「正花」？',
        options: ['有齊春夏秋冬四隻花', '摸到同自己門風一樣號碼嘅花牌',
         '食糊時冇花牌', '摸到梅蘭竹菊其中一組'],
        correctIndex: 1,
        explanation: '正花即係摸到同自己座位對應嘅花牌（東1南2西3北4）。'),
    QuizQuestion(question: '自摸食糊時，邊幾個要俾錢？',
        options: ['只有出銃嗰個', '三家都要俾', '莊家俾晒', '下家俾'],
        correctIndex: 1,
        explanation: '自摸係三家都要俾錢，所以收入比食出銃多好多。'),
    QuizQuestion(question: '以下邊個係平糊嘅例子？',
        options: ['m1', 'east', 'm5', 'red'], correctIndex: 0, type: QuizType.tileSelection,
        tiles: ['m1','m2','m3','s2','s3','s4','p4','p5','p6','p1','p2','p3','s6','s6'],
        explanation: '4組順子加一對非番子數字對眼（6索），正係平糊！'),
  ]),

  Lesson(id: '6-2', stageId: 'gdmj-fans', title: '一番 (下)',
      subtitle: '中發白、花么、門前清、海底撈月、搶槓', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '繼續一番牌型！呢幾個番種雖然都係一番，但喺實戰中好常見，掌握咗對你嘅勝率好有幫助。'),
    DialogueMessage(speaker: 'mj',
        text: '中發白（1番）：食糊時持有中、發、白其中一款刻子。即係你手上有三個紅中、三個發財或者三個白板，每款各自計一番。',
        tileIds: ['red','red','red','m1','m2','m3','s3','s4','s5','p6','p7','p8','s9','s9']),
    DialogueMessage(speaker: 'mj',
        text: '花么（1番）：食糊時只有一、九及番子組成嘅刻子與一對眼。簡單講就係：只得1、9同番子，冇中間數字！',
        tileIds: ['m1','m1','m1','s9','s9','s9','p1','p1','p1','east','east','east','red','red']),
    DialogueMessage(speaker: 'mj',
        text: '門前清／門清（1番）：冇上、碰、槓任何牌而食糊。完全靠自己摸牌！呢個係技術同耐心嘅考驗。'),
    DialogueMessage(speaker: 'mj',
        text: '海底撈月（1番）：以牌局最後一隻牌自摸食糊。成局牌差唔多摸晒，最後一隻竟然俾你摸到食糊！戲劇性十足！'),
    DialogueMessage(speaker: 'mj',
        text: '搶槓（1番）：當有人槓牌時，你啱啱好可以用嗰隻牌食糊！搶槓當自摸計，被搶嗰家要包牌。記住，呢個係針對「加槓」先有效！'),
  ], questions: [
    QuizQuestion(question: '「中發白」番種要求手上有咩？',
        options: ['中發白各一隻', '中發白其中一款嘅刻子（三隻一樣）',
         '中發白三款各一對', '中發白順序排列'],
        correctIndex: 1,
        explanation: '中發白：持有中、發、白其中一款刻子（三隻一樣），每款獨立計一番。'),
    QuizQuestion(question: '花么嘅牌面只能包含咩牌？',
        options: ['只有1-5嘅牌', '一、九及番子', '只有花牌', '任何順子'],
        correctIndex: 1,
        explanation: '花么只能由一（1）、九（9）同番子（東南西北中發白）組成。'),
    QuizQuestion(question: '門前清（門清）嘅條件係咩？',
        options: ['可以上牌但不能碰', '冇上、碰、槓任何牌',
         '只有槓牌冇上碰', '可以碰但不能上'],
        correctIndex: 1,
        explanation: '門前清即係完全冇上過、碰過、槓過任何牌，全靠自己摸。'),
    QuizQuestion(question: '搶槓食糊點樣計？',
        options: ['當出銃計', '當自摸計，被搶嗰家包牌',
         '唔計番', '當流局'],
        correctIndex: 1,
        explanation: '搶槓當自摸計算，而且被搶嘅一家要包晒三家嘅錢。'),
    QuizQuestion(question: '海底撈月係指咩？',
        options: ['第一隻牌食糊', '最後一隻牌自摸食糊',
         '摸到花牌食糊', '槓後摸牌食糊'],
        correctIndex: 1,
        explanation: '海底撈月：牌局最後一隻牌，俾你自摸食糊！'),
  ]),

  Lesson(id: '6-3', stageId: 'gdmj-fans', title: '兩番 & 三番',
      subtitle: '一台花、槓上自摸、混一色、對對糊、花糊', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '進階到兩番同三番嘅世界！呢度嘅牌型開始有明顯嘅威力，係實戰中最常見到嘅中級番種。'),
    DialogueMessage(speaker: 'mj',
        text: '一台花（2番）：持有「春夏秋冬」或「梅蘭竹菊」其中一組花牌。記住，係一組四隻，唔係全部八隻！',
        tileIds: ['f_spring','f_summer','f_autumn','f_winter']),
    DialogueMessage(speaker: 'mj',
        text: '槓上自摸（2番）：槓之後摸返嚟嘅牌啱啱好可以食糊！注意，槓上自摸唔會同自摸番數重複計算，只會計較高嗰個。'),
    DialogueMessage(speaker: 'mj',
        text: '混一色（3番）：除咗有番子，其餘牌都係同一個花色。即係一副數字牌（萬/索/筒任一款）加埋番子混搭。好實用嘅牌型！',
        tileIds: ['m1','m2','m3','m5','m6','m7','m8','m8','m8','east','east','east','red','red']),
    DialogueMessage(speaker: 'mj',
        text: '對對糊（3番）：全部都係碰牌及一對眼，完全冇順子！每一組都係三隻一樣嘅牌，氣勢十足！',
        tileIds: ['m2','m2','m2','s5','s5','s5','p8','p8','p8','east','east','east','red','red']),
    DialogueMessage(speaker: 'mj',
        text: '花糊（3番）：一副牌有八隻花，只要你摸到其中7隻就可以食花糊，自摸計三番！摸齊8隻就變八仙過海（8番），更加勁！'),
  ], questions: [
    QuizQuestion(question: '「一台花」指咩？',
        options: ['摸齊八隻花牌', '持有春夏秋冬或梅蘭竹菊其中一組',
         '隨便一隻花牌', '冇花牌'],
        correctIndex: 1,
        explanation: '一台花：持有春夏秋冬（四季）或者梅蘭竹菊（四君子）其中一組四隻花牌。'),
    QuizQuestion(question: '混一色係幾多番？',
        options: ['1番', '2番', '3番', '5番'],
        correctIndex: 2,
        explanation: '混一色（一副數字牌+番子）係3番。'),
    QuizQuestion(question: '對對糊嘅特點係咩？',
        options: ['全部係順子', '全部係碰牌，冇順子',
         '全部係花牌', '只有番子'],
        correctIndex: 1,
        explanation: '對對糊：全部由碰牌（刻子）同對眼組成，冇任何順子。'),
    QuizQuestion(question: '花糊要摸到幾多隻花先可以食糊？',
        options: ['全部8隻', '7隻', '5隻', '3隻'],
        correctIndex: 1,
        explanation: '花糊：摸到7隻花牌即可食糊，自摸計3番。摸齊8隻就變大花糊（八仙過海）計8番！'),
    QuizQuestion(question: '以下邊個係混一色？',
        options: ['m1', 's1', 'p1', 'east'], correctIndex: 0, type: QuizType.tileSelection,
        tiles: ['m1','m2','m3','m5','m6','m7','m8','m8','m8','east','east','east','red','red'],
        explanation: '全部都係萬子牌加東同紅中，正係混一色（萬子+番子）！'),
    QuizQuestion(question: '以下邊個係對對糊？',
        options: ['m2', 'm5', 'm8', 's2'], correctIndex: 0, type: QuizType.tileSelection,
        tiles: ['m2','m2','m2','s5','s5','s5','p8','p8','p8','east','east','east','red','red'],
        explanation: '四組碰牌加一對眼，完全冇順子 — 典型對對糊！'),
  ]),

  Lesson(id: '6-4', stageId: 'gdmj-fans', title: '四番至七番',
      subtitle: '花幺九、小三元、小四喜、清一色', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '踏入中高番數區域！四至七番嘅牌型已經算係大牌，砌到出嚟分分鐘扭轉成局！'),
    DialogueMessage(speaker: 'mj',
        text: '花幺九／混老頭（4番）：只有幺九及番子嘅對對糊。即係全部牌都係1、9同番子，仲要全部都係碰牌！可以另計番牌㗎。',
        tileIds: ['m1','m1','m1','s9','s9','s9','p1','p1','p1','red','red','red','north','north']),
    DialogueMessage(speaker: 'mj',
        text: '小三元（5番）：集齊中、發、白其中兩組刻子，餘下嘅做一對眼，外加兩組牌（不論花色、碰、上）。差少少就係大三元㗎喇！',
        tileIds: ['red','red','red','green','green','green','white','white','m1','m2','m3','s2','s3','s4']),
    DialogueMessage(speaker: 'mj',
        text: '小四喜（6番）：東南西北刻子有其中三組，其餘做一對眼，加一組牌（不論碰、上）。三組風牌刻子氣勢已經好勁！',
        tileIds: ['east','east','east','south','south','south','west','west','west','north','north','m1','m2','m3']),
    DialogueMessage(speaker: 'mj',
        text: '清一色（7番）：成副牌同一個花色，冇任何番子或其他花色！純萬子、純索子或者純筒子都得。七番以上由玩家自訂，有八番、十番、十三番，俗稱爆棚！'),
  ], questions: [
    QuizQuestion(question: '花幺九（混老頭）係幾多番？',
        options: ['3番', '4番', '5番', '6番'],
        correctIndex: 1,
        explanation: '花幺九（混老頭）係4番，由1、9同番子組成嘅對對糊。'),
    QuizQuestion(question: '小三元嘅結構係點？',
        options: ['三組中發白刻子', '兩組中發白刻子+一對中發白眼',
         '一組中發白刻子', '冇中發白'],
        correctIndex: 1,
        explanation: '小三元：中發白其中兩款做刻子，餘下一款做對眼。'),
    QuizQuestion(question: '小四喜要幾多組風牌刻子？',
        options: ['一組', '兩組', '三組', '四組'],
        correctIndex: 2,
        explanation: '小四喜：東南西北刻子有三組，餘下一組做對眼。'),
    QuizQuestion(question: '清一色係幾多番？',
        options: ['5番', '6番', '7番', '8番'],
        correctIndex: 2,
        explanation: '清一色（純一色數字牌）係7番。七番以上由玩家自訂（俗稱爆棚）。'),
    QuizQuestion(question: '以下邊個係清一色？',
        options: ['s1', 'm1', 'p1', 'east'], correctIndex: 0, type: QuizType.tileSelection,
        tiles: ['s1','s2','s3','s3','s4','s5','s5','s6','s7','s8','s8','s8','s9','s9'],
        explanation: '全部索子，純一色，冇番子冇其他花色 — 清一色！'),
    QuizQuestion(question: '以下邊個係小三元？',
        options: ['m1', 'red', 'green', 'white'], correctIndex: 1, type: QuizType.tileSelection,
        tiles: ['red','red','red','green','green','green','white','white','m1','m2','m3','s2','s3','s4'],
        explanation: '紅中刻子+發財刻子+白板對眼，配合兩組順子 — 小三元！'),
  ]),

  Lesson(id: '6-5', stageId: 'gdmj-fans', title: '八番至十番',
      subtitle: '大三元、槓上槓自摸、坎坎糊、大花糊、九子連環、清幺九、字一色', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '八番以上係真正嘅大牌！呢啲牌型一出現，成枱人都會屏息靜氣。我哋一齊嚟認識呢七種強勁牌型！'),
    DialogueMessage(speaker: 'mj',
        text: '大三元（8番）：中、發、白三組刻子，加一組牌（不論碰、上）及一對眼。三款箭牌全部做刻子，霸氣盡露！',
        tileIds: ['red','red','red','green','green','green','white','white','white','m1','m2','m3','s9','s9']),
    DialogueMessage(speaker: 'mj',
        text: '槓上槓自摸（8番）：連續兩次明槓、暗槓後自摸！中間如果補咗花牌再自摸仲會加1番。雙重槓上開花，運氣爆棚！'),
    DialogueMessage(speaker: 'mj',
        text: '坎坎糊（8番）：4組3隻一樣嘅牌，外加一對眼。必須自摸，唔可以靠碰或槓！全部都係自己摸返嚟嘅刻子，難度極高。'),
    DialogueMessage(speaker: 'mj',
        text: '大花糊／八仙過海（8番）：摸齊八隻花可即時食糊，計八番自摸！呢個係花糊嘅終極版，比花糊仲要多5番。',
        tileIds: ['f_spring','f_summer','f_autumn','f_winter','f_plum','f_orchid','f_chrys','f_bamboo']),
    DialogueMessage(speaker: 'mj',
        text: '九子連環（10番）：門前清集齊同花色1112345678999，加其中任何一隻牌。必須全部自己摸返嚟，唔可以上碰槓！',
        tileIds: ['m1','m1','m1','m2','m3','m4','m5','m6','m7','m8','m9','m9','m9','m5']),
    DialogueMessage(speaker: 'mj',
        text: '清幺九／清老頭（10番）：只有幺九牌嘅對對糊，例牌不另計其他牌型。全部都係1同9，中間數字完全冇！',
        tileIds: ['m1','m1','m1','m9','m9','m9','s1','s1','s1','s9','s9','s9','p1','p1']),
    DialogueMessage(speaker: 'mj',
        text: '字一色（10番）：全部牌由東南西北中發白組成，冇任何數字牌！極其罕有，一世人可能都摸唔到一次。',
        tileIds: ['east','east','east','south','south','south','west','west','west','red','red','red','green','green']),
  ], questions: [
    QuizQuestion(question: '大三元係幾多番？',
        options: ['6番', '7番', '8番', '10番'], correctIndex: 2,
        explanation: '大三元（中發白三組刻子）係8番。'),
    QuizQuestion(question: '大花糊（八仙過海）要摸齊幾多隻花？',
        options: ['6隻', '7隻', '8隻', '4隻'], correctIndex: 2,
        explanation: '大花糊要摸齊全部八隻花牌（春夏秋冬+梅蘭竹菊），即八仙過海！'),
    QuizQuestion(question: '字一色包含咩牌？',
        options: ['只有數字牌', '只有番子（風牌+箭牌）',
         '數字牌+番子', '只有花牌'], correctIndex: 1,
        explanation: '字一色全部由東南西北中發白七種番子組成，冇任何數字牌。'),
    QuizQuestion(question: '九子連環嘅牌型係咩？',
        options: ['任意順子組合', '1112345678999加任何一隻同花色牌',
         '全部碰牌', '十三隻唔同嘅牌'], correctIndex: 1,
        explanation: '九子連環：同花色1112345678999，加任何一隻同花色牌。必須門清！'),
    QuizQuestion(question: '坎坎糊有咩限制？',
        options: ['可以碰牌', '必須自摸，唔可以靠碰或槓',
         '一定要有花牌', '要有一組順子'], correctIndex: 1,
        explanation: '坎坎糊4組刻子必須全部自己摸返嚟，唔可以碰或槓，仲要自摸食糊。'),
    QuizQuestion(question: '以下邊個係大三元？',
        options: ['red', 'm1', 'east', 'green'], correctIndex: 0, type: QuizType.tileSelection,
        tiles: ['red','red','red','green','green','green','white','white','white','m1','m2','m3','s9','s9'],
        explanation: '中發白三款箭牌全部做刻子 — 大三元！'),
  ]),

  Lesson(id: '6-6', stageId: 'gdmj-fans', title: '十三番 & 番數點數表',
      subtitle: '大四喜、十三么、十八羅漢、天地人糊 + 點數對照', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '歡迎嚟到番種教學嘅最後一課 — 十三番爆棚牌型！呢啲全部都係例牌（最高賠付），一世人見到一次都算好運。'),
    DialogueMessage(speaker: 'mj',
        text: '大四喜（13番）：東南西北刻子各有一組，加一對眼。四組風牌全部做刻子，麻雀界嘅傳說級牌型！',
        tileIds: ['east','east','east','south','south','south','west','west','west','north','north','north','red','red']),
    DialogueMessage(speaker: 'mj',
        text: '十三么（13番）：集齊一筒九筒、一索九索、一萬九萬，東南西北中發白，再加任何一隻做眼。共13種唔同嘅牌！',
        tileIds: ['m1','m9','s1','s9','p1','p9','east','south','west','north','red','green','white','m1']),
    DialogueMessage(speaker: 'mj',
        text: '十八羅漢（13番）：有四組槓牌加一對眼，總共18隻牌！每槓一次就可以補一隻牌，即係有4次額外摸牌機會！',
        tileIds: ['m1','m1','m1','m1','s5','s5','s5','s5','p9','p9','p9','p9','red','red','red','red','east','east']),
    DialogueMessage(speaker: 'mj',
        text: '天糊（13番）：莊家出第一隻牌後即食糊。冇上、碰或明槓牌，開局第一輪就完結！'),
    DialogueMessage(speaker: 'mj',
        text: '地糊（13番）：冇上、碰或明槓牌，喺第一輪摸牌即食糊。閒家一摸牌就食得出！'),
    DialogueMessage(speaker: 'mj',
        text: '人糊（13番）：開局第一輪即食別家出銃。人哋打出第一隻牌你就食糊，快到冇朋友！'),
    DialogueMessage(speaker: 'mj',
        text: '以下係番數同點數嘅完整對照表，記熟佢對你實戰好有用！'),
    DialogueMessage(speaker: 'mj',
        text: '一番：出銃4點／自摸6點\n二番：出銃8點／自摸12點\n三番：出銃16點／自摸24點\n四番：出銃32點／自摸48點\n五番：出銃48點／自摸72點\n六番：出銃64點／自摸96點\n七番：出銃96點／自摸144點\n八番：出銃128點／自摸192點\n九番：出銃192點／自摸288點\n十番：出銃256點／自摸384點\n十三番為例牌（爆棚），通常有自訂最高賠付上限。'),
  ], questions: [
    QuizQuestion(question: '大四喜要幾多組風牌刻子？',
        options: ['兩組', '三組', '四組', '一組'], correctIndex: 2,
        explanation: '大四喜：東南西北四款風牌全部做刻子！'),
    QuizQuestion(question: '十三么需要集齊邊啲牌？',
        options: ['全部1-9', '13種么九及番子牌+一隻重複做眼',
         '全部番子', '全部花牌'], correctIndex: 1,
        explanation: '十三么：一萬九萬、一索九索、一筒九筒、東南西北中發白，共13種+重複一隻做眼。'),
    QuizQuestion(question: '十八羅漢有幾多組槓牌？',
        options: ['2組', '3組', '4組', '5組'], correctIndex: 2,
        explanation: '十八羅漢 = 4組槓牌 + 1對眼 = 18隻牌。'),
    QuizQuestion(question: '天糊同地糊嘅主要分別係？',
        options: ['天糊係莊家，地糊係閒家', '天糊係閒家，地糊係莊家',
         '冇分別', '天糊要自摸，地糊要出銃'], correctIndex: 0,
        explanation: '天糊：莊家出第一隻牌即食。地糊：閒家第一輪摸牌即食。'),
    QuizQuestion(question: '根據點數表，三番自摸每家俾幾多點？',
        options: ['8點', '16點', '24點', '32點'], correctIndex: 2,
        explanation: '三番自摸點數＝24點。每番點數逐級倍增。'),
    QuizQuestion(question: '以下邊個係大四喜？',
        options: ['east', 'south', 'red', 'green'], correctIndex: 0, type: QuizType.tileSelection,
        tiles: ['east','east','east','south','south','south','west','west','west','north','north','north','red','red'],
        explanation: '東南西北四款風牌全部做刻子，加紅中做眼 — 大四喜！'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 4: Practical Skills (3 lessons)
  // ═══════════════════════════════════
  Lesson(id: '7-1', stageId: 'practical', title: '圈數規則',
      subtitle: '四圈制、座位安排、莊家輪替', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '學完番種，係時候了解實戰知識喇！麻雀唔係淨係識食糊就得，仲要識規矩！第一堂：圈數規則。'),
    DialogueMessage(speaker: 'mj',
        text: '香港麻雀共設四圈：東圈 → 南圈 → 西圈 → 北圈。每打完一圈就換下一個圈，打齊四圈先叫打完一局。'),
    DialogueMessage(speaker: 'mj',
        text: '每位玩家每局至少做莊一次，每圈至少打四局（因為四個玩家輪流做莊）。簡單講：一圈最少四局，一局最少十六局。'),
    DialogueMessage(speaker: 'mj',
        text: '莊家食糊需要「冧莊」（繼續做莊），否則過莊俾下家。即係話：你贏就繼續做莊，輸咗就輪到下一位！'),
    DialogueMessage(speaker: 'mj',
        text: '開局前抽「東南西北」四隻風牌決定座位：抽到東嘅玩家可以優先揀位，其他按南→西→北逆時針順序入座。東位玩家就係第一圈嘅起始莊家！'),
  ], questions: [
    QuizQuestion(question: '香港麻雀總共有幾多個圈？',
        options: ['2個', '3個', '4個', '5個'], correctIndex: 2,
        explanation: '香港麻雀設四圈：東圈、南圈、西圈、北圈。'),
    QuizQuestion(question: '一圈最少要打幾多局？',
        options: ['2局', '4局', '8局', '16局'], correctIndex: 1,
        explanation: '每圈至少打四局，因為四位玩家各做一次莊。'),
    QuizQuestion(question: '「冧莊」係咩意思？',
        options: ['放棄做莊', '莊家食糊後繼續做莊',
         '換人做莊', '結束牌局'], correctIndex: 1,
        explanation: '冧莊：莊家食糊後繼續連任做莊。'),
    QuizQuestion(question: '開局抽風牌時，抽到「東」嘅玩家有咩特權？',
        options: ['可以多摸一隻牌', '可以優先揀位',
         '自動贏一局', '唔使俾錢'], correctIndex: 1,
        explanation: '抽到東嘅玩家可以優先選擇座位，其他玩家按南西北逆時針入座。'),
  ]),

  Lesson(id: '7-2', stageId: 'practical', title: '洗牌與分牌',
      subtitle: '洗牌疊牌、擲骰定莊', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '第二堂實戰課：洗牌同分牌。呢個係每局開始前嘅必要步驟，做得唔好會畀人鬧㗎！'),
    DialogueMessage(speaker: 'mj',
        text: '洗牌後，每位玩家各出36隻牌（因為一副牌144隻 ÷ 4人 = 36隻），分上下兩排疊起、每排18隻。所以每個人面前會有兩層高嘅牌牆！'),
    DialogueMessage(speaker: 'mj',
        text: '疊好之後，四位玩家一齊將牌牆推出麻雀枱中間，形成一個方形嘅牌牆。呢個就係「牌山」或者叫「牌牆」。'),
    DialogueMessage(speaker: 'mj',
        text: '跟住要「擲莊」：由東位玩家擲骰決定第一局嘅莊家。由東位起計做1，逆時針數到骰子總和嘅位置，嗰位就係第一局嘅莊家。'),
    DialogueMessage(speaker: 'mj',
        text: '例如：東位玩家擲骰擲到3同5，總和=8。由東(1)→南(2)→西(3)→北(4)→東(5)→南(6)→西(7)→北(8)，8就係北位，北位玩家做第一局莊家！'),
  ], questions: [
    QuizQuestion(question: '一副麻雀牌144隻，每位玩家要疊幾多隻？',
        options: ['24隻', '30隻', '36隻', '48隻'], correctIndex: 2,
        explanation: '144 ÷ 4 = 36，每位玩家疊36隻，分上下排每排18隻。'),
    QuizQuestion(question: '「擲莊」由邊個玩家執行？',
        options: ['任何玩家', '東位玩家', '莊家', '最年長玩家'], correctIndex: 1,
        explanation: '擲莊由東位玩家擲骰決定第一局莊家。'),
    QuizQuestion(question: '擲莊時點樣數莊家位置？',
        options: ['順時針數', '逆時針數',
         '由南位開始數', '隨機數'], correctIndex: 1,
        explanation: '由東位起計做1，逆時針數到骰子總和。'),
    QuizQuestion(question: '如果東位擲骰總和=9，邊個做第一局莊家？',
        options: ['東位', '南位', '西位', '北位'], correctIndex: 0,
        explanation: '東(1)→南(2)→西(3)→北(4)→東(5)→南(6)→西(7)→北(8)→東(9)，9=東位。'),
  ]),

  Lesson(id: '7-3', stageId: 'practical', title: '取牌與補花',
      subtitle: '擲骰取牌、跳牌、補花流程', dialogues: [
    DialogueMessage(speaker: 'mj',
        text: '最後一堂實戰課：取牌同補花。呢個步驟做錯，成局牌都要重新嚟過，一定要記熟！'),
    DialogueMessage(speaker: 'mj',
        text: '首先，莊家擲骰決定取牌位置。由莊家自己開始逆時針起計，骰子總和係幾多，就從第(總和+1)隻牌開始取。例如骰子總和=9，就從第10隻牌開始攞。'),
    DialogueMessage(speaker: 'mj',
        text: '每人每次取4隻牌（即係上下兩層各2隻），順時針輪流取。每人都取咗3輪（12隻）之後，莊家要「跳牌」：莊家先取第1隻同第3隻（共2隻），閒家各取1隻。最終：莊家14隻，閒家13隻。'),
    DialogueMessage(speaker: 'mj',
        text: '如果取牌過程中攞到花牌，需要即時「補花」！將花牌亮出放喺自己面前，然後由牌牆尾端補返一隻牌。補花由莊家開始，順時針輪流補。'),
    DialogueMessage(speaker: 'mj',
        text: '補花時如果又抽到花牌，需要等其他玩家都補好花之後先再補（即係要排隊）。等所有人補完花，由莊家打出第一隻牌，正式開始牌局！'),
  ], questions: [
    QuizQuestion(question: '如果骰子總和=9，要從第幾隻牌開始取？',
        options: ['第9隻', '第10隻', '第8隻', '第1隻'], correctIndex: 1,
        explanation: '骰子總和+1，即9+1=10，從第10隻開始取。'),
    QuizQuestion(question: '每人每次取幾多隻牌？',
        options: ['1隻', '2隻', '4隻', '6隻'], correctIndex: 2,
        explanation: '每人每次取4隻（上下兩層各2隻）。'),
    QuizQuestion(question: '莊家跳牌攞幾多隻？閒家攞幾多隻？',
        options: ['莊2閒1', '莊1閒2', '莊3閒2', '莊2閒2'], correctIndex: 0,
        explanation: '莊家跳牌取2隻（第1同第3隻），閒家各取1隻。莊家共14隻，閒家13隻。'),
    QuizQuestion(question: '補花嘅順序係點？',
        options: ['隨機補', '由莊家開始，順時針補',
         '由閒家開始補', '邊個有花邊個補先'], correctIndex: 1,
        explanation: '補花由莊家開始，順時針輪流補。補花又中花要等其他人補完先再補。'),
  ]),

  // ═══════════════════════════════════
  //  STAGE 6: Common Winning Hands (1 lesson)
  // ═══════════════════════════════════
  Lesson(
    id: '8-1',
    stageId: 'stage6',
    title: 'Common Winning Hands',
    subtitle: 'Half Flush, Full Flush, All Pongs & stacking',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text: 'Let\'s master the most common winning hand patterns! First: Half Flush (混一色). This means ALL your melds use only one suit PLUS honor tiles. {{m1}}{{m2}}{{m3}} + {{m7}}{{m7}}{{m7}} + {{m4}}{{m5}}{{m6}} + {{east}}{{east}}{{east}} + {{red}}{{red}} — all Characters with East and Red Dragon. Worth 3 Faan!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Full Flush (清一色) is even stronger: your entire 14-tile hand is ONE suit, with zero honor tiles. {{p1}}{{p2}}{{p3}} {{p4}}{{p5}}{{p6}} {{p7}}{{p8}}{{p9}} {{p2}}{{p3}}{{p4}} + {{p5}}{{p5}} — pure Circles! This beautiful hand is worth 7 Faan. Harder to build, but it pays big!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Two other common patterns worth knowing: All Pongs (对对糊) — every meld is a triplet, no sequences at all, worth 3 Faan. Ping Hu (平糊) — all sequences with a suited pair, worth 1 Faan. All Pongs feels powerful; Ping Hu is the most common basic win. Knowing which pattern your tiles lean toward helps you plan every discard!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Pro tip: patterns STACK! The same hand can qualify for multiple fan types. Half Flush (3) + All Pongs (3) = 6 Faan. Full Flush (7) + All Pongs (3) = 10 Faan! Always review your complete hand before declaring — you might have more faan than you think. Stacking is how pros turn good hands into great ones!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which of these describes Half Flush (混一色)?',
        options: [
          'All tiles in one suit, no honors',
          'One suit + honor tiles',
          'All triplets, no sequences',
          'All sequences with suited pair',
        ],
        correctIndex: 1,
        explanation: 'Half Flush means all your melds use one suit plus honor tiles (winds and dragons). Worth 3 Faan.',
      ),
      QuizQuestion(
        question: 'What fan type does this hand belong to?',
        options: ['m2', 'east', 's5', 'red'],
        correctIndex: 1,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm3', 'm7', 'm7', 'm7', 'm4',
          'm5', 'm6', 'east', 'east', 'east', 'red', 'red',
        ],
        explanation: 'All Characters plus East and Red Dragon honors — this is Half Flush (混一色), worth 3 Faan.',
      ),
      QuizQuestion(
        question: 'Sort these hand types from most common to least common',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m2', 'east', 's9'],
        explanation: 'Ping Hu (all sequences) is the most common winning pattern. Half Flush (one suit + honors) comes next. Full Flush (pure one suit) is the rarest of the three basic patterns.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 7: Defense & Reading (1 lesson)
  // ═══════════════════════════════════
  Lesson(
    id: '9-1',
    stageId: 'stage7',
    title: 'Defense & Reading',
    subtitle: 'Safe tiles, following suit & discard reading',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text: 'Defense wins games! A safe tile (安全牌) is one unlikely to give an opponent their winning tile. The golden rule: a tile your opponent just discarded is 100% safe — they clearly don\'t need it, or they would have kept it!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Following suit (跟打) is a simple defensive tactic: when unsure what\'s safe, copy the player before you. If they discard {{m4}}, you can safely discard {{m4}} too. Since they just threw it and nobody claimed it, it\'s very likely safe for everyone. This works especially well in the mid-to-late game!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Reading the discard pool is an art! If an opponent has discarded lots of Character tiles like {{m1}}{{m2}}{{m4}}{{m6}}{{m8}}, they\'re probably NOT building Characters. They might be collecting Bamboo or Circles instead. The suits with the fewest discards are the ones opponents are most likely holding!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Dangerous tiles (危險牌) to watch for: tiles that haven\'t appeared at all this round — someone might be waiting for them! Middle suited tiles (4, 5, 6) are especially risky because each connects to many possible sequences. Late in the round, avoid discarding unseen middle tiles. Terminals (1, 9) and honors are generally safer.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which tile is the safest to discard?',
        options: [
          'A tile your opponent just discarded',
          'A middle suited tile (4-5-6)',
          'A tile nobody has seen all round',
          'A Dragon tile you drew on turn 1',
        ],
        correctIndex: 0,
        explanation: 'A tile just discarded by an opponent is the safest — they clearly don\'t need it, and nobody else claimed it either.',
      ),
      QuizQuestion(
        question: 'Based on these discards, what suit is the opponent likely building?',
        options: ['m5', 's5', 'p5', 'east'],
        correctIndex: 1,
        type: QuizType.tileSelection,
        tiles: [
          'm1', 'm2', 'm4', 'm5', 'm7', 'm9',
          'p1', 'p3', 'p5', 'p6', 'p8',
          's2', 'east',
        ],
        explanation: 'The opponent has discarded many Character (Wan) and Circle (Tong) tiles, but almost no Bamboo (Tiao). They are likely building a Bamboo hand!',
      ),
      QuizQuestion(
        question: 'Sort these tiles from safest (left) to most dangerous (right) to discard late in the round',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['east', 'p9', 'm5'],
        explanation: 'Already-discarded honors are safest. Terminal tiles (1, 9) have fewer sequence connections than middle tiles (4-5-6). Middle suited tiles are the most dangerous because they complete many possible waits.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 8: Limit Hands & Etiquette (1 lesson)
  // ═══════════════════════════════════
  Lesson(
    id: '10-1',
    stageId: 'stage8',
    title: 'Limit Hands & Etiquette',
    subtitle: 'Thirteen Orphans, Heavenly Hand & table manners',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text: 'Welcome to the legendary hands! Thirteen Orphans (十三么) is one of mahjong\'s most famous limit hands. You need: {{m1}}{{m9}}{{s1}}{{s9}}{{p1}}{{p9}} plus {{east}}{{south}}{{west}}{{north}}{{red}}{{green}}{{white}} — one of each terminal and honor, then one duplicate as your pair. That\'s 13 unique tiles + 1 repeat = 14 tiles total. Incredibly rare!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Heavenly Hand (天糊) and Earthly Hand (地糊) are the rarest wins in mahjong! Heavenly Hand: the dealer wins immediately after drawing their initial 14 tiles — the game ends before anyone takes a turn! Earthly Hand: a non-dealer wins on their very first draw. Both are instant limit hands paying the maximum. Most players go their entire lives without seeing one!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Table etiquette matters as much as skill! Good manners: play at a steady pace (don\'t make others wait), place tiles gently (no slamming the table), and clearly announce "Hu!" when you win. Bad manners to avoid: slow playing (故意拖慢), peeking at others\' hands, arguing loudly about rules, or eating greasy food that stains the tiles. Be the player everyone enjoys playing with!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Let\'s practice faan calculation with a real hand! {{s1}}{{s2}}{{s3}} {{s4}}{{s5}}{{s6}} {{s7}}{{s8}}{{s9}} {{red}}{{red}}{{red}} + {{east}}{{east}}. Let\'s count: it\'s all Bamboo suited tiles plus Red Dragon and East Wind honors → Half Flush (3 Faan). Plus a Red Dragon Pong → +1 Faan. If you win by self-draw → +1 Faan. Total: 5 Faan! Practice counting every hand — it becomes second nature!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which tiles are required for Thirteen Orphans (十三么)?',
        options: [
          'All suited tiles 1-9 in one suit',
          'One of each terminal (1 & 9) and honor tile + one duplicate',
          'All four Winds as Pongs',
          'All three Dragons as Pongs',
        ],
        correctIndex: 1,
        explanation: 'Thirteen Orphans needs 13 unique tiles: 1 and 9 of each suit (6 tiles), all 7 honors (7 tiles), plus one duplicate as the pair.',
      ),
      QuizQuestion(
        question: 'Calculate the faan for this hand (self-draw win): {{s1}}{{s2}}{{s3}} {{s4}}{{s5}}{{s6}} {{s7}}{{s8}}{{s9}} {{red}}{{red}}{{red}} + {{east}}{{east}}',
        options: ['m1', 'm3', 'm5', 'm7'],
        correctIndex: 2,
        type: QuizType.tileSelection,
        tiles: [
          's1', 's2', 's3', 's4', 's5', 's6', 's7',
          's8', 's9', 'red', 'red', 'red', 'east', 'east',
        ],
        explanation: 'Half Flush (3 Faan) + Red Dragon Pong (1 Faan) + Self-Draw (1 Faan) = 5 Faan total.',
      ),
      QuizQuestion(
        question: 'Sort these hand types by faan value from lowest to highest',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m2', 'east', 's9'],
        explanation: 'Ping Hu = 1 Faan (lowest). Half Flush = 3 Faan (middle). Full Flush = 7 Faan (highest). Faan values grow quickly as hand difficulty increases!',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 9: Reading Opponents (1 lesson)
  // ═══════════════════════════════════
  Lesson(
    id: '11-1',
    stageId: 'stage9',
    title: 'Reading Opponents',
    subtitle: 'Discard analysis, tells & reading the table',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text: 'Reading opponents starts with watching their discards! When an opponent discards {{m1}}{{m2}}{{m4}}{{m7}}{{m9}}, they\'re clearly not building a Characters hand. The suits they discard most are the ones they DON\'T need. Look for the suit with the fewest discards — that\'s what they\'re collecting!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Following suit (跟打) is a key defensive read. If the player before you discards {{s5}} and nobody claims it, and then the next player also discards {{s5}}, they\'re signaling they have nothing better to play. When opponents keep following suit with safe tiles, they\'re likely far from ready — no dangerous hand forming!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Time tells a story! A player who hesitates 10+ seconds before discarding is probably near winning — weighing which tile to keep for their wait. A player who instantly discards is either very confident or very safe. In the late game, watch whose turns slow down — they\'re the ones to defend against!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Called tiles expose hand direction! If a player calls Pong on {{east}}{{east}}{{east}}, they\'re likely going for a Wind-based hand. If they Chow {{s3}}{{s4}}{{s5}}, they\'re building Bamboo. Each open meld reveals ~3 tiles of their strategy. The more they open, the more you can read. Use this to avoid discarding what they might need!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'An opponent has discarded mostly Characters and Circles but almost no Bamboo. What are they likely building?',
        options: [
          'A Characters hand',
          'A Circles hand',
          'A Bamboo hand',
          'An Honors hand',
        ],
        correctIndex: 2,
        explanation: 'The suit with the fewest discards reveals what the opponent is holding. Minimal Bamboo discards = they are collecting Bamboo tiles.',
      ),
      QuizQuestion(
        question: 'You see an opponent call Pong on {{red}}{{red}}{{red}}. What does this reveal about their hand?',
        options: ['m5', 's5', 'red', 'east'],
        correctIndex: 2,
        type: QuizType.tileSelection,
        tiles: ['m1', 'm4', 's2', 's7', 'p3', 'p8', 'red', 'east'],
        explanation: 'The Red Dragon Pong reveals they have at least one Dragon set. Their hand likely includes more Dragons or is aiming for a Half Flush with honors.',
      ),
      QuizQuestion(
        question: 'Sort these opponent behaviors from least threatening (left) to most threatening (right)',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['east', 'm5', 's9'],
        explanation: 'Following suit with honors = safe/not ready → Quick mid-tile discard = moderate → Long hesitation = likely tenpai (listening).',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 10: Advanced Tactics (1 lesson)
  // ═══════════════════════════════════
  Lesson(
    id: '12-1',
    stageId: 'stage10',
    title: 'Advanced Tactics',
    subtitle: 'Pace control, Kong strategy & deception',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text: 'Pace control is psychological warfare! Playing quickly creates pressure — opponents feel rushed and may make mistakes. Playing slowly makes opponents second-guess: "Are they near winning? Should I play safe?" Vary your pace deliberately to keep opponents off balance. A sudden pause mid-game can be as effective as a fast flurry!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Kong (槓) strategy has layers! Concealed Kong (暗槓) hides information — opponents don\'t know what you\'ve locked away, making them play more cautiously. Open Kong (明槓) is risky: it reveals a set AND gives opponents an extra draw. But if you Kong a tile someone else might need, you deny them! The best Kong is one that hurts opponents while boosting your hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Wait selection (聽牌) is where champions are made. A multi-sided wait like {{s3}}{{s4}}{{s5}}{{s6}} gives you 4 winning tiles, but a single wait on {{east}} might pay more faan. The trade-off: broader waits win more often; narrow waits win bigger. In late game with opponents near ready, take the broader wait. When far ahead, gamble on the high-value wait!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Bluffing (偷雞) is an art! Discard {{m3}} and {{m4}} early to make opponents think you\'re NOT building Characters — then quietly collect {{m5}}{{m6}}{{m7}}. Discard a dragon to signal "I don\'t need honors," then collect the other two. Misdirection works because players track discards. The best bluffs look natural — don\'t overdo it or observant opponents will catch on!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'You\'re far behind in points. Should you choose a broad 4-sided wait or a narrow single wait on a Dragon?',
        options: [
          'Narrow single wait on Dragon — you need the big faan to catch up',
          'Broad 4-sided wait — winning is more important',
          'Fold the hand and play pure defense',
          'Always choose the broader wait regardless of score',
        ],
        correctIndex: 0,
        explanation: 'When behind, you need high-value wins. A Dragon wait with extra faan can close the gap. When ahead, prioritize the broader wait to seal the win.',
      ),
      QuizQuestion(
        question: 'You want to bluff that you\'re building Bamboo. Which tile should you discard early?',
        options: ['s2', 'm5', 'p8', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['s2', 's5', 's8', 'm3', 'm7', 'p1', 'p6', 'east'],
        explanation: 'Discarding {{s2}} early signals you don\'t need Bamboo (even though you\'re secretly collecting {{s5}}{{s8}}). Early discards carry the strongest signal.',
      ),
      QuizQuestion(
        question: 'Sort these Kong strategies from safest to riskiest',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m2', 'east', 's9'],
        explanation: 'Concealed Kong = safest (no info revealed) → Supplemental Kong (add to existing Pong) = moderate risk → Open Kong (declare from hand) = riskiest (most info revealed + gives opponents draws).',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 11: Risk Management (1 lesson)
  // ═══════════════════════════════════
  Lesson(
    id: '13-1',
    stageId: 'stage11',
    title: 'Risk Management',
    subtitle: 'Danger assessment, folding & end-game decisions',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text: 'Situational awareness is everything! When you\'re leading in points, play conservatively — discard safe tiles, avoid risky Pongs that break up your defense. When you\'re trailing, take calculated risks — break up safe patterns to chase bigger hands. The scoreboard should dictate your playstyle every round. Play the score, not just the tiles!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Dangerous tile identification can save you from dealing in! Fresh tiles (生張) — tiles no one has discarded yet — are the riskiest, especially in late game. Middle suited tiles like {{m4}}{{m5}}{{m6}} connect to the most sequences. If {{m5}} hasn\'t been seen all round and it\'s turn 12+, that\'s a potential bomb! Never discard unseen middle tiles when opponents might be listening.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Folding (棄糊) is the smartest play when your hand is terrible. If by turn 8 you have no sequences, no pairs, and scattered honors, accept reality: this hand won\'t win. Switch to pure defense — only discard tiles opponents have already thrown. Breaking your hand to play safe tiles preserves your points better than chasing a 5% chance of winning and 95% chance of dealing in!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'End-game decisions in the final 3-4 turns are the most critical moments in mahjong. You\'re one tile from winning with {{s7}}{{s8}} waiting for {{s6}} or {{s9}}. But {{s6}} hasn\'t appeared all round — it\'s a dangerous fresh tile for others too! Three choices: push (discard risky tiles to chase the win), fold (break your wait, play safe), or gamble (keep your wait but only self-draw). Your score position determines which is right!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Turn 14, you\'re leading by 30 points. Your hand needs one more tile to win, but discarding would require throwing an unseen {{m5}}. What should you do?',
        options: [
          'Discard {{m5}} and chase the win — fortune favors the bold',
          'Fold the hand — preserve the lead with safe discards',
          'Call Riichi to pressure opponents',
          'Wait for a self-draw only',
        ],
        correctIndex: 1,
        explanation: 'When leading, preservation beats aggression. Dealing into someone\'s hand could erase your lead. Fold and protect your points advantage.',
      ),
      QuizQuestion(
        question: 'It\'s late game and you must discard one of these tiles. Which is the most dangerous?',
        options: ['m5', 'east', 'p1', 'red'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['m5', 'east', 'p1', 'p9', 'red', 'green', 'south'],
        explanation: '{{m5}} is a middle suited tile connecting to the most sequences (m3-m4-m5, m4-m5-m6, m5-m6-m7, m6-m7-m8). Honors like {{east}} and terminals like {{p1}} are relatively safer.',
      ),
      QuizQuestion(
        question: 'Sort these end-game decisions from most conservative to most aggressive',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m2', 'east', 's9'],
        explanation: 'Fold hand (0% win, 0% deal-in risk) → Self-draw only (moderate win chance, no deal-in risk) → Push/Riichi (highest win chance, highest deal-in risk).',
      ),
    ],
  ),
];
