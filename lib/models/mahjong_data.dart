import 'package:flutter/material.dart';
import '../i18n/content_strings.dart';
import '../services/app_i18n.dart';

// Learning Stage
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

  double get progress => lessonCount > 0 ? completedLessons / lessonCount : 0;

  String get localizedTitle => trContent('stage.$id.title', title);
  String get localizedSubtitle => trContent('stage.$id.subtitle', subtitle);
}

// Dialogue message
class DialogueMessage {
  final String speaker; // 'mj' (Panda MJ) or 'user'
  final String text;
  final Widget? widget;
  final List<String>? tileIds;

  DialogueMessage({
    required this.speaker,
    required this.text,
    this.widget,
    this.tileIds,
  });

  /// Returns a copy with localized text for [lessonId] at position [index].
  DialogueMessage localized(String lessonId, int index) {
    if (AppI18n.current != DisplayLang.zh) return this;
    final zh = contentStringsZh['dialogue.$lessonId.d$index.text'];
    if (zh == null) return this;
    return DialogueMessage(
      speaker: speaker,
      text: zh,
      widget: widget,
      tileIds: tileIds,
    );
  }
}

// Fan type definition
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

// Lesson
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

  String get localizedTitle => trContent('lesson.$id.title', title);
  String get localizedSubtitle => trContent('lesson.$id.subtitle', subtitle);

  /// Dialogues with localized text based on current language.
  List<DialogueMessage> get localizedDialogues => [
    for (int i = 0; i < dialogues.length; i++) dialogues[i].localized(id, i),
  ];

  /// Questions with localized text based on current language.
  List<QuizQuestion> get localizedQuestions => [
    for (int i = 0; i < questions.length; i++) questions[i].localized(id, i),
  ];
}

/// A left/right pair used by matching questions.
class QuestionPair {
  final String left;
  final String right;

  const QuestionPair({required this.left, required this.right});
}

// Quiz question
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final QuizType type;
  final List<String>? tiles;

  /// Indices of every correct option (multi-select questions). When null the
  /// single [correctIndex] is used.
  final List<int>? correctIndexes;

  /// Accepted free-text answers (fill-in-the-blank). Comparison ignores case,
  /// whitespace and trailing punctuation so English and Chinese answers both
  /// pass.
  final List<String>? acceptedAnswers;

  /// Correct pairings for matching questions.
  final List<QuestionPair>? pairs;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.type = QuizType.singleChoice,
    this.tiles,
    this.correctIndexes,
    this.acceptedAnswers,
    this.pairs,
  });

  /// Every correct option index, regardless of how the question was declared.
  List<int> get allCorrectIndexes =>
      (correctIndexes != null && correctIndexes!.isNotEmpty)
      ? correctIndexes!
      : <int>[correctIndex];

  /// Returns a copy with localized text for [lessonId] at position [index].
  QuizQuestion localized(String lessonId, int index) {
    if (AppI18n.current != DisplayLang.zh) return this;
    final prefix = 'quiz.$lessonId.q$index';
    return QuizQuestion(
      question: contentStringsZh['$prefix.question'] ?? question,
      options: [
        for (int j = 0; j < options.length; j++)
          contentStringsZh['$prefix.option_${j + 1}'] ?? options[j],
      ],
      correctIndex: correctIndex,
      explanation: contentStringsZh['$prefix.explanation'] ?? explanation,
      type: type,
      tiles: tiles,
      correctIndexes: correctIndexes,
      acceptedAnswers: acceptedAnswers == null
          ? null
          : [
              for (int j = 0; j < acceptedAnswers!.length; j++)
                contentStringsZh['$prefix.answer_${j + 1}'] ??
                    acceptedAnswers![j],
            ],
      pairs: pairs == null
          ? null
          : [
              for (int j = 0; j < pairs!.length; j++)
                QuestionPair(
                  left:
                      contentStringsZh['$prefix.pair_left_${j + 1}'] ??
                      pairs![j].left,
                  right:
                      contentStringsZh['$prefix.pair_right_${j + 1}'] ??
                      pairs![j].right,
                ),
            ],
    );
  }
}

enum QuizType {
  /// Exactly one option is correct.
  singleChoice,

  /// Two or more options are correct; the user toggles every right one.
  multiChoice,

  /// Pick one mahjong tile out of the offered tiles.
  tileSelection,

  /// Drag mahjong tiles into the correct order.
  tileOrdering,

  /// Type the answer into a text field.
  fillBlank,

  /// Connect every item on the left with the right item.
  matching,
}

// Leaderboard user
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

// ═══════════════════════════════════════════════════════
//  12-Stage Learning Path (4 Chapters)
// ═══════════════════════════════════════════════════════
final List<LearningStage> defaultStages = [
  // Chapter 1: Getting Started
  LearningStage(
    id: 'stage1',
    title: 'Mahjong Basics',
    subtitle: 'Tiles, suits & table setup',
    icon: Icons.grid_view_rounded,
    color: const Color(0xFF4CAF50),
    lessonCount: 8,
    isUnlocked: true,
  ),
  LearningStage(
    id: 'stage2',
    title: 'Basic Combinations',
    subtitle: 'Sequences, triplets & pairs',
    icon: Icons.extension_rounded,
    color: const Color(0xFF66BB6A),
    lessonCount: 6,
  ),
  LearningStage(
    id: 'stage3',
    title: 'How to Play',
    subtitle: 'Drawing, discarding & claiming',
    icon: Icons.swap_horiz_rounded,
    color: const Color(0xFFE8B93E),
    lessonCount: 8,
  ),
  LearningStage(
    id: 'stage4',
    title: 'Winning Conditions',
    subtitle: '4 melds + 1 pair & minimum faan',
    icon: Icons.celebration_rounded,
    color: const Color(0xFF8B4513),
    lessonCount: 6,
  ),
  // Chapter 2: Advanced Rules
  LearningStage(
    id: 'stage5',
    title: 'Special Hands',
    subtitle: 'Thirteen Orphans, All Pongs & more',
    icon: Icons.auto_awesome,
    color: const Color(0xFF7B1FA2),
    lessonCount: 5,
  ),
  LearningStage(
    id: 'stage6',
    title: 'Flowers & Kong',
    subtitle: 'Flower tiles, Kong declarations & replacements',
    icon: Icons.local_florist_rounded,
    color: const Color(0xFFE91E63),
    lessonCount: 5,
  ),
  LearningStage(
    id: 'stage7',
    title: 'Scoring Rules',
    subtitle: 'Faan values, payment & calculation',
    icon: Icons.stars_rounded,
    color: const Color(0xFF2E7D32),
    lessonCount: 6,
  ),
  // Chapter 3: Strategy & Tactics
  LearningStage(
    id: 'stage8',
    title: 'Basic Tactics',
    subtitle: 'Reading discards & defense',
    icon: Icons.psychology_rounded,
    color: const Color(0xFF1565C0),
    lessonCount: 6,
  ),
  LearningStage(
    id: 'stage9',
    title: 'Advanced Tactics',
    subtitle: 'Pace control, bluffing & Kong strategy',
    icon: Icons.visibility,
    color: const Color(0xFF5C6BC0),
    lessonCount: 5,
  ),
  LearningStage(
    id: 'stage10',
    title: 'Risk Management',
    subtitle: 'Danger assessment & end-game decisions',
    icon: Icons.balance,
    color: const Color(0xFFD84315),
    lessonCount: 5,
  ),
  // Chapter 4: Practice & Simulation
  LearningStage(
    id: 'stage11',
    title: 'Simulated Games',
    subtitle: 'Full-round scenarios with guidance',
    icon: Icons.sports_esports_rounded,
    color: const Color(0xFF00897B),
    lessonCount: 5,
  ),
  LearningStage(
    id: 'stage12',
    title: 'Challenge Mode',
    subtitle: 'Timed challenges & special conditions',
    icon: Icons.emoji_events_rounded,
    color: const Color(0xFFFF6F00),
    lessonCount: 5,
  ),
];

// ═══════════════════════════════════════════════════════
//  Complete Curriculum (12 Stages, 70 Lessons)
// ═══════════════════════════════════════════════════════

final List<Lesson> allLessonsData = defaultLessons;

final List<Lesson> defaultLessons = [
  // ═══════════════════════════════════
  //  STAGE 1: Mahjong Basics (8 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '1-1',
    stageId: 'stage1',
    title: 'Welcome to Mahjong!',
    subtitle: 'What is Cantonese Mahjong?',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Welcome! I\'m MJ, your mahjong guide. Together we\'ll master Hong Kong-style Cantonese Mahjong — one of the world\'s most popular tile games!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Mahjong is played by 4 players using 144 tiles. The goal? Build a complete hand of 14 tiles before anyone else. Think of it like a puzzle race!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'A standard set has: 3 suited families (Characters 萬, Circles 筒, Bamboo 索), 4 Winds, 3 Dragons, and 8 Flowers. Each suited tile has 4 copies!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Don\'t worry about memorizing everything now. We\'ll learn step by step. Let\'s start with the tiles!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['4', 'four', '4 players', 'four players'],
        question: 'How many players are in a standard mahjong game?',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
        explanation: 'Mahjong is always played with exactly 4 players.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['144', '144 tiles'],
        question: 'How many tiles are in a complete mahjong set?',
        options: ['108', '136', '144', '152'],
        correctIndex: 2,
        explanation:
            'A standard Cantonese mahjong set has 144 tiles including flowers.',
      ),
      QuizQuestion(
        question: 'What is the goal of mahjong?',
        options: [
          'Discard all your tiles',
          'Build a complete hand of 14 tiles',
          'Collect the most points',
          'Get rid of all flowers',
        ],
        correctIndex: 1,
        explanation:
            'The goal is to complete a winning hand of 14 tiles (4 melds + 1 pair) before other players.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many tiles are in a set that has no Flower tiles?',
        options: ['108', '120', '136', '144'],
        correctIndex: 2,
        acceptedAnswers: ['136', '136 tiles', 'one hundred thirty-six'],
        explanation: '144 tiles minus the 8 Flower tiles leaves 136.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these belong to a standard mahjong tile set? (Select all that apply)',
        options: [
          'Suited tiles (Characters, Circles, Bamboo)',
          'Wind tiles',
          'Dragon tiles',
          'Flower tiles',
          'Poker cards',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2, 3],
        explanation:
            'The set is 108 suited + 16 Wind + 12 Dragon + 8 Flower tiles; playing cards are not part of it.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each tile group to its total in a 144-tile set.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Suited tiles', right: '108'),
          QuestionPair(left: 'Wind tiles', right: '16'),
          QuestionPair(left: 'Dragon tiles', right: '12'),
          QuestionPair(left: 'Flower tiles', right: '8'),
        ],
        explanation: '108 + 16 + 12 + 8 = 144 tiles.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Select the honor tile.',
        options: ['red', 'm5', 'p5', 's5'],
        correctIndex: 0,
        tiles: const [
          'm5',
          'p5',
          's5',
          'red',
          'green',
          'white',
          'east',
          'south',
        ],
        explanation:
            '{{red}} is a Dragon, and Dragons are honor tiles; the other three options are suited tiles.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'How many different tile faces are in a full 144-tile set?',
        options: ['34', '36', '42', '44'],
        correctIndex: 2,
        explanation:
            '27 suited numbers + 4 Winds + 3 Dragons + 8 Flowers = 42 distinct tiles.',
      ),
    ],
  ),

  Lesson(
    id: '1-2',
    stageId: 'stage1',
    title: 'Suited Tiles: Characters',
    subtitle: 'The Wan (萬) family',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s meet the first suit: Characters (萬/Wan). These are numbered 1-9 and show Chinese number characters.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Here they are: {{m1}} {{m2}} {{m3}} {{m4}} {{m5}} {{m6}} {{m7}} {{m8}} {{m9}}. Each has 4 copies in the set, so there are 36 Character tiles total!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Characters are often called "Wan" (萬) because the Chinese character 萬 appears on each tile. Easy to recognize!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Tip: Characters can form sequences (like 1-2-3) or triplets (like 5-5-5). We\'ll learn about these combinations soon!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['9', 'nine', '9 tiles'],
        question: 'How many different Character tiles are there?',
        options: ['4', '7', '9', '13'],
        correctIndex: 2,
        explanation:
            'Characters are numbered 1 through 9, giving 9 different tiles.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['4', 'four', '4 copies'],
        question: 'How many copies of each Character tile exist?',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
        explanation: 'Every tile in mahjong has exactly 4 copies.',
      ),
      QuizQuestion(
        question: 'Which of these is a Character (Wan) tile?',
        options: ['m3', 'p3', 's3', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['m1', 'm2', 'm3', 'p1', 'p2', 'p3', 's1', 's2', 's3'],
        explanation:
            '{{m3}} is 3 of Characters (Wan). Tiles starting with "m" are Characters.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many Character tiles are in a complete set?',
        options: ['9', '24', '36', '48'],
        correctIndex: 2,
        acceptedAnswers: ['36', '36 tiles', 'thirty-six'],
        explanation: '9 ranks × 4 copies each = 36 Character tiles.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are Character (Wan) tiles? (Select all that apply)',
        options: ['{{m1}}', '{{p1}}', '{{m5}}', '{{s5}}', '{{m9}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 4],
        explanation:
            'm1, m5 and m9 are Characters; p1 is a Circle and s5 is Bamboo.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question: 'Put these Character tiles in ascending order.',
        options: const [],
        correctIndex: 0,
        tiles: const ['m2', 'm6', 'm9'],
        explanation:
            'Characters run 1 to 9, so {{m2}} comes before {{m6}} and {{m9}}.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Which tile completes the run {{m7}} {{m8}} ___ ?',
        options: ['m9', 'm6', 'm5', 'p9'],
        correctIndex: 0,
        tiles: const ['m9', 'm6', 'm5', 'p9', 'm1', 'm7', 's9', 'p8'],
        explanation:
            '{{m7}} {{m8}} needs {{m9}} to make the run 7-8-9 in Characters.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each tile marker to its tile family.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'm1', right: 'Characters (Wan)'),
          QuestionPair(left: 'p1', right: 'Circles (Tong)'),
          QuestionPair(left: 's1', right: 'Bamboo (Suo)'),
          QuestionPair(left: 'east', right: 'Wind'),
        ],
        explanation:
            'm = Characters, p = Circles, s = Bamboo; east is a Wind, not a suit.',
      ),
    ],
  ),

  Lesson(
    id: '1-3',
    stageId: 'stage1',
    title: 'Suited Tiles: Circles',
    subtitle: 'The Tong (筒) family',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Next up: Circles (筒/Tong)! These show circular dot patterns, numbered 1-9.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Here they are: {{p1}} {{p2}} {{p3}} {{p4}} {{p5}} {{p6}} {{p7}} {{p8}} {{p9}}. The dots make them easy to count!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Fun fact: Circles are sometimes called "coins" because they look like ancient Chinese coins. The more dots, the higher the number!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Like Characters, Circles can form sequences and triplets. 36 Circle tiles total (9 types × 4 copies).',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Match each tile family to how it looks.',
        options: const [],
        correctIndex: 0,
        type: QuizType.matching,
        pairs: const [
          QuestionPair(left: 'Characters', right: 'Chinese characters'),
          QuestionPair(left: 'Circles', right: 'Dot/circle patterns'),
          QuestionPair(left: 'Bamboo', right: 'Bamboo sticks'),
          QuestionPair(left: 'Winds', right: 'Wind symbols'),
        ],
        explanation:
            'Each suit has a distinct look: Characters show Chinese numerals, Circles show dots, Bamboo shows sticks, and Winds show compass names.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['36', 'thirty-six', '36 tiles'],
        question: 'How many Circle tiles are in a complete set?',
        options: ['9', '18', '27', '36'],
        correctIndex: 3,
        explanation: '9 different Circle tiles × 4 copies each = 36 total.',
      ),
      QuizQuestion(
        question: 'Select the Circle (Tong) tile',
        options: ['p5', 'm5', 's5', 'red'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['m5', 'p5', 's5', 'red', 'green', 'white', 'east', 'south'],
        explanation:
            '{{p5}} is 5 of Circles (Tong). Tiles starting with "p" are Circles.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many dots does the 9 Circles tile show?',
        options: ['3', '6', '9', '12'],
        correctIndex: 2,
        acceptedAnswers: ['9', 'nine', '9 dots'],
        explanation:
            'A Circle tile shows as many dots as its number, so 9 Circles has 9 dots.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are Circle (Tong) tiles? (Select all that apply)',
        options: ['{{p2}}', '{{m2}}', '{{p7}}', '{{s7}}', '{{p9}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 4],
        explanation:
            'p2, p7 and p9 are Circles; m2 is a Character and s7 is Bamboo.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question: 'Put these Circle tiles in descending order (highest first).',
        options: const [],
        correctIndex: 0,
        tiles: const ['p8', 'p4', 'p1'],
        explanation:
            'Descending means highest first: {{p8}} then {{p4}} then {{p1}}.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Circle tile to its dot count.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'p1', right: '1 dot'),
          QuestionPair(left: 'p5', right: '5 dots'),
          QuestionPair(left: 'p9', right: '9 dots'),
        ],
        explanation:
            'Circle tiles are numbered by the count of dots on the face.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'In Cantonese, the Circles suit is called...',
        options: ['Tong (筒)', 'Wan (萬)', 'Suo (索)', 'Faan (番)'],
        correctIndex: 0,
        explanation:
            'Circles are Tong (筒), Characters are Wan (萬) and Bamboo are Suo (索).',
      ),
    ],
  ),

  Lesson(
    id: '1-4',
    stageId: 'stage1',
    title: 'Suited Tiles: Bamboo',
    subtitle: 'The Suo (索) family',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The third suit: Bamboo (索/Suo)! These show bamboo stick patterns, numbered 1-9.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Here they are: {{s1}} {{s2}} {{s3}} {{s4}} {{s5}} {{s6}} {{s7}} {{s8}} {{s9}}. Note: 1 Bamboo often shows a bird instead of a stick!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Bamboo tiles are sometimes called "sticks" or "strings" in English. They represent strings of coins tied together.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Now you know all 3 suits! Characters (萬), Circles (筒), Bamboo (索) — 108 suited tiles in total (36 × 3).',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is special about the 1 Bamboo tile?',
        options: [
          'It shows a bird',
          'It has no markings',
          'It is red colored',
          'It counts as an honor',
        ],
        correctIndex: 0,
        explanation:
            'The 1 Bamboo tile traditionally shows a bird (sparrow) instead of a single bamboo stick.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['108', '108 tiles'],
        question: 'How many suited tiles are there in total?',
        options: ['36', '72', '108', '144'],
        correctIndex: 2,
        explanation: '3 suits × 9 numbers × 4 copies = 108 suited tiles.',
      ),
      QuizQuestion(
        question: 'Arrange these Bamboo tiles in order: 2, 3, 4',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['s2', 's3', 's4'],
        explanation: 'Bamboo tiles in sequence: {{s2}} → {{s3}} → {{s4}}.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many Bamboo tiles are in a complete set?',
        options: ['9', '27', '36', '54'],
        correctIndex: 2,
        acceptedAnswers: ['36', '36 tiles', 'thirty-six'],
        explanation: '9 ranks × 4 copies each = 36 Bamboo tiles.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are Bamboo (Suo) tiles? (Select all that apply)',
        options: ['{{s3}}', '{{m3}}', '{{s6}}', '{{p6}}', '{{s9}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 4],
        explanation:
            's3, s6 and s9 are Bamboo; m3 is a Character and p6 is a Circle.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Select the tile that is NOT a Bamboo tile.',
        options: ['s4', 's8', 'p8', 's2'],
        correctIndex: 2,
        tiles: const ['s4', 's8', 'p8', 's2', 'm4', 'p4', 'east', 's6'],
        explanation: '{{p8}} is a Circle; s4, s8 and s2 are all Bamboo.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Bamboo tile to its rank.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 's1', right: '1 Bamboo (the bird)'),
          QuestionPair(left: 's5', right: '5 Bamboo'),
          QuestionPair(left: 's9', right: '9 Bamboo'),
        ],
        explanation:
            'Bamboo tiles run 1 to 9, and the 1 Bamboo is drawn as a bird.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Which three suits make up the 108 suited tiles?',
        options: [
          'Characters, Circles and Bamboo',
          'Winds, Dragons and Flowers',
          'Characters, Winds and Dragons',
          'Circles, Bamboo and Flowers',
        ],
        correctIndex: 0,
        explanation:
            'Only Characters, Circles and Bamboo are suited; Winds, Dragons and Flowers are not.',
      ),
    ],
  ),

  Lesson(
    id: '1-5',
    stageId: 'stage1',
    title: 'Honor Tiles: Winds',
    subtitle: 'East, South, West, North',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Beyond the 3 suits, we have Honor tiles! First: the 4 Winds — {{east}} {{south}} {{west}} {{north}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Each Wind has 4 copies (16 Wind tiles total). Winds are special: they cannot form sequences! Only triplets (3 of the same).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'In each round, one Wind is the "prevailing wind" and each player has a "seat wind." Matching these gives bonus points (Faan)!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The seating order goes: East → South → West → North, counter-clockwise around the table.',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['16', '16 tiles'],
        question: 'How many Wind tiles are there in total?',
        options: ['4', '8', '12', '16'],
        correctIndex: 3,
        explanation: '4 types of Wind × 4 copies each = 16 Wind tiles.',
      ),
      QuizQuestion(
        question: 'Can Wind tiles form a sequence?',
        options: [
          'Yes, East-South-West',
          'Yes, any 3 winds',
          'No, only triplets',
          'Only with Dragons',
        ],
        correctIndex: 2,
        explanation:
            'Wind tiles cannot form sequences. They can only form triplets (3 identical winds).',
      ),
      QuizQuestion(
        question: 'Select the North Wind tile',
        options: ['north', 'south', 'east', 'west'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['east', 'south', 'west', 'north', 'm1', 'p1', 's1', 'red'],
        explanation: '{{north}} is the North Wind tile.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many copies of each Wind tile are in a set?',
        options: ['1', '2', '4', '8'],
        correctIndex: 2,
        acceptedAnswers: ['4', 'four', '4 copies'],
        explanation: 'Each Wind has 4 copies, just like every suited tile.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are Wind tiles? (Select all that apply)',
        options: ['{{east}}', '{{red}}', '{{south}}', '{{green}}', '{{north}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 4],
        explanation:
            'East, South and North are Winds; red and green are Dragons.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Select the Wind that comes right after East in seating order.',
        options: ['south', 'west', 'north', 'east'],
        correctIndex: 0,
        tiles: const [
          'east',
          'south',
          'west',
          'north',
          'red',
          'green',
          'white',
          'm1',
        ],
        explanation:
            'Seating order runs East, South, West, North, so {{south}} follows East.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Wind to its seat number.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'East', right: 'Seat 1'),
          QuestionPair(left: 'South', right: 'Seat 2'),
          QuestionPair(left: 'West', right: 'Seat 3'),
          QuestionPair(left: 'North', right: 'Seat 4'),
        ],
        explanation:
            'Seats are numbered in order: East 1, South 2, West 3, North 4.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You are South and the round wind is South. Your South triplet is worth how much?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 2,
        explanation:
            'A Wind triplet scores 1 Faan for seat wind and 1 Faan for round wind, so they double to 2.',
      ),
    ],
  ),

  Lesson(
    id: '1-6',
    stageId: 'stage1',
    title: 'Honor Tiles: Dragons',
    subtitle: 'Red, Green & White Dragons',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The 3 Dragons are the most powerful honor tiles: {{red}} (Red/中), {{green}} (Green/發), {{white}} (White/白).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Each Dragon has 4 copies (12 Dragon tiles total). Like Winds, Dragons cannot form sequences — only triplets!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'A triplet of any Dragon is always worth 1 Faan. Collect all three Dragon triplets? That\'s "Large Three Dragons" (大三元) — worth 5 Faan, plus 3 more for the triplets, so 8 Faan in total!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: Red (中) = center/hit, Green (發) = fortune/prosperity, White (白) = blank/pure. These are iconic mahjong symbols!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['12', '12 tiles'],
        question: 'How many Dragon tiles are there in total?',
        options: ['3', '6', '9', '12'],
        correctIndex: 3,
        explanation: '3 types of Dragon × 4 copies each = 12 Dragon tiles.',
      ),
      QuizQuestion(
        question: 'What is a triplet of Dragons worth?',
        options: ['0 Faan', '1 Faan', '3 Faan', '5 Faan'],
        correctIndex: 1,
        explanation: 'Any Dragon triplet (Pong) is worth 1 Faan.',
      ),
      QuizQuestion(
        question: 'Which is the Green Dragon (發)?',
        options: ['green', 'red', 'white', 'east'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['red', 'green', 'white', 'east', 'south', 'west', 'north'],
        explanation:
            '{{green}} is the Green Dragon (發), representing fortune and prosperity.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many different Dragon tiles are there?',
        options: ['2', '3', '4', '6'],
        correctIndex: 1,
        acceptedAnswers: ['3', 'three', '3 dragons'],
        explanation: 'Red, Green and White make 3 Dragons, each with 4 copies.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are Dragon tiles? (Select all that apply)',
        options: ['{{red}}', '{{east}}', '{{green}}', '{{white}}', '{{north}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 3],
        explanation:
            'Red, Green and White are Dragons; east and north are Winds.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Dragon to its Chinese name.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Red Dragon', right: '紅中'),
          QuestionPair(left: 'Green Dragon', right: '發財'),
          QuestionPair(left: 'White Dragon', right: '白板'),
        ],
        explanation:
            'The three Dragons are 紅中 (red), 發財 (green) and 白板 (white).',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Select a tile that can never be part of a sequence.',
        options: ['east', 'm1', 'p5', 's9'],
        correctIndex: 0,
        tiles: const ['east', 'm1', 'p5', 's9', 'red', 'm5', 'p1', 's5'],
        explanation:
            'Only suited tiles form runs; an honor like {{east}} cannot.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Triplets of all three Dragons make which hand?',
        options: [
          'Small Three Dragons (小三元)',
          'Large Three Dragons (大三元)',
          'All Honors (字一色)',
          'Mixed One Suit (混一色)',
        ],
        correctIndex: 1,
        explanation:
            'Large Three Dragons is 5 Faan, plus 3 Faan from the Dragon triplets, for 8 Faan in total.',
      ),
    ],
  ),

  Lesson(
    id: '1-7',
    stageId: 'stage1',
    title: 'Flower Tiles',
    subtitle: 'Seasons & plants bonus tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Finally: Flower tiles! There are 8 unique flowers — 4 Seasons and 4 Plants. Unlike other tiles, each flower exists only ONCE!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Seasons: {{f_spring}} {{f_summer}} {{f_autumn}} {{f_winter}}. Plants: {{f_plum}} {{f_orchid}} {{f_chrys}} {{f_bamboo}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Flowers are bonus tiles! When you draw one, place it face-up and draw a replacement. Each MATCHING flower for your seat (正花/門風花) = 1 Faan. Non-matching flowers give 0 Faan individually. Collecting a complete set of 4 Seasons OR 4 Plants (一台花) = 2 Faan on its own, with no extra seat-flower Faan on top. Also, having NO flowers at all = 1 Faan (無花)!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Each seat is assigned flowers: East gets Spring+Plum, South gets Summer+Orchid, West gets Autumn+Chrysanthemum, North gets Winter+Bamboo. Only YOUR assigned flowers count - drawing someone else\'s flower gives 0 Faan!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['8', 'eight', '8 flowers'],
        question: 'How many Flower tiles exist in a set?',
        options: ['4', '6', '8', '12'],
        correctIndex: 2,
        explanation: 'There are 8 unique Flower tiles: 4 Seasons + 4 Plants.',
      ),
      QuizQuestion(
        question: 'What happens when you draw a Flower tile?',
        options: [
          'Discard it',
          'Keep it in hand',
          'Place it face-up and draw a replacement',
          'Give it to another player',
        ],
        correctIndex: 2,
        explanation:
            'Flowers are placed face-up immediately and you draw a replacement tile.',
      ),
      QuizQuestion(
        question: 'When does a Flower tile give you 1 Faan?',
        options: [
          'Always, any flower you draw',
          'Only if it matches your seat (e.g. East needs Spring or Plum)',
          'Only if you collect all 8 flowers',
          'Flowers never give Faan',
        ],
        correctIndex: 1,
        explanation:
            'A flower only counts as YOUR flower (正花) when it matches your seat wind. East: Spring+Plum, South: Summer+Orchid, West: Autumn+Chrysanthemum, North: Winter+Bamboo. Drawing another player\'s flower gives 0 Faan.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many copies of each Flower tile are in a set?',
        options: ['1', '2', '4', '8'],
        correctIndex: 0,
        acceptedAnswers: ['1', 'one', '1 copy'],
        explanation:
            'There are 8 Flowers and each one exists only once, so 1 copy each.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are Flower tiles? (Select all that apply)',
        options: [
          '{{f_spring}}',
          '{{f_plum}}',
          '{{east}}',
          '{{f_chrys}}',
          '{{red}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'Spring, Plum and Chrysanthemum are Flowers; east is a Wind and red is a Dragon.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each seat to its two flowers.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'East', right: 'Spring + Plum'),
          QuestionPair(left: 'South', right: 'Summer + Orchid'),
          QuestionPair(left: 'West', right: 'Autumn + Chrysanthemum'),
          QuestionPair(left: 'North', right: 'Winter + Bamboo'),
        ],
        explanation:
            'Each seat owns one Season and one Plant: East 1, South 2, West 3, North 4.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Select the Flower that belongs to the South seat.',
        options: ['f_orchid', 'f_plum', 'f_chrys', 'f_bamboo'],
        correctIndex: 0,
        tiles: const [
          'f_spring',
          'f_summer',
          'f_autumn',
          'f_winter',
          'f_plum',
          'f_orchid',
          'f_chrys',
          'f_bamboo',
        ],
        explanation:
            'South\'s flowers are Summer and Orchid, so {{f_orchid}} is South\'s flower.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Collecting all four Seasons or all four Plants is worth how much?',
        options: ['1 Faan', '2 Faan', '3 Faan', '5 Faan'],
        correctIndex: 1,
        explanation:
            'A complete set of four Seasons or four Plants (一台花) counts as 2 Faan in total; seat flowers are not added on top.',
      ),
    ],
  ),

  Lesson(
    id: '1-8',
    stageId: 'stage1',
    title: 'Stage 1 Review',
    subtitle: 'Test your tile knowledge!',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Excellent! You now know all 144 tiles: 108 suited (Characters, Circles, Bamboo), 16 Winds, 12 Dragons, and 8 Flowers!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text: 'Let\'s do a quick review to make sure everything sticks. Ready?',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which tiles can form sequences?',
        options: [
          'Only suited tiles (Characters, Circles, Bamboo)',
          'Only Winds',
          'Only Dragons',
          'All tiles',
        ],
        correctIndex: 0,
        explanation:
            'Only suited tiles (numbered 1-9) can form sequences. Honors cannot.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['144', '144 tiles'],
        question: 'How many total tiles are in a Cantonese mahjong set?',
        options: ['108', '136', '144', '148'],
        correctIndex: 2,
        explanation:
            '108 suited + 16 Winds + 12 Dragons + 8 Flowers = 144 tiles.',
      ),
      QuizQuestion(
        question: 'Arrange these tile types by quantity (most to fewest)',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m1', 'east', 'f_spring'],
        explanation:
            'Suited tiles (4 copies each) > Wind/Dragon tiles (4 copies each but fewer types) > Flower tiles (1 copy each). By total count: Suited (108) > Winds (16) > Dragons (12) > Flowers (8).',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many honor tiles (Winds plus Dragons) are in a set?',
        options: ['19', '24', '28', '32'],
        correctIndex: 2,
        acceptedAnswers: ['28', '28 tiles', 'twenty-eight'],
        explanation: '16 Wind tiles + 12 Dragon tiles = 28 honor tiles.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are honor tiles? (Select all that apply)',
        options: ['{{east}}', '{{m1}}', '{{red}}', '{{white}}', '{{s9}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 3],
        explanation:
            'Winds and Dragons are honors; m1 and s9 are suited tiles.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each tile to its family.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'm5', right: 'Characters'),
          QuestionPair(left: 'p5', right: 'Circles'),
          QuestionPair(left: 's5', right: 'Bamboo'),
          QuestionPair(left: 'white', right: 'Dragon'),
        ],
        explanation:
            'The letter in the tile id names the family: m Characters, p Circles, s Bamboo; white is a Dragon.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question: 'Arrange the Winds in seating order, starting from East.',
        options: const [],
        correctIndex: 0,
        tiles: const ['east', 'south', 'west', 'north'],
        explanation: 'Play moves East, South, West, North around the table.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Select the tile that scores 1 Faan as a triplet on its own.',
        options: ['red', 'm5', 'p5', 's5'],
        correctIndex: 0,
        tiles: const [
          'red',
          'green',
          'white',
          'm5',
          'p5',
          's5',
          'east',
          'north',
        ],
        explanation:
            'A Dragon triplet is 1 Faan on its own, while a suited triplet has no separate Faan.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 2: Basic Combinations (6 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '2-1',
    stageId: 'stage2',
    title: 'Sequences (Chow)',
    subtitle: '3 consecutive suited tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Time to learn combinations! A Sequence (Chow/順子) is 3 consecutive tiles of the SAME suit. Like {{m1}}{{m2}}{{m3}} or {{p5}}{{p6}}{{p7}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Important rules: Sequences must be the same suit (no mixing!), and they must be consecutive numbers. {{m1}}{{m2}}{{m3}} is valid, but {{m1}}{{m3}}{{m5}} is NOT.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Also, sequences don\'t wrap around! {{m8}}{{m9}}{{m1}} is NOT valid. The highest sequence is 7-8-9.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Only suited tiles can form sequences. Winds and Dragons cannot! You can\'t make East-South-West as a sequence.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which is a valid sequence?',
        options: [
          '{{m1}}{{m2}}{{m3}}',
          '{{m1}}{{p2}}{{s3}}',
          '{{east}}{{south}}{{west}}',
          '{{m8}}{{m9}}{{m1}}',
        ],
        correctIndex: 0,
        explanation:
            'A valid sequence must be 3 consecutive tiles of the same suit. {{m1}}{{m2}}{{m3}} is correct.',
      ),
      QuizQuestion(
        question: 'Can honor tiles form sequences?',
        options: [
          'Yes, Winds can',
          'Yes, Dragons can',
          'No, never',
          'Only with suited tiles',
        ],
        correctIndex: 2,
        explanation:
            'Honor tiles (Winds and Dragons) can never form sequences. Only suited tiles can.',
      ),
      QuizQuestion(
        question: 'Arrange to form a valid Bamboo sequence',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['s4', 's5', 's6'],
        explanation: '{{s4}}{{s5}}{{s6}} forms a valid Bamboo sequence.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are valid Sequences (Chow)? Select all that apply.',
        options: [
          '{{m4}}{{m5}}{{m6}}',
          '{{p2}}{{p3}}{{p4}}',
          '{{s8}}{{s9}}{{s1}}',
          '{{m6}}{{p7}}{{s8}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'A Chow is 3 consecutive tiles in one suit, so {{s8}}{{s9}}{{s1}} fails because sequences do not wrap around and {{m6}}{{p7}}{{s8}} mixes three suits.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each three-tile group to what it is.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: '{{s3}}{{s4}}{{s5}}', right: 'Valid Sequence'),
          QuestionPair(
            left: '{{s3}}{{s5}}{{s7}}',
            right: 'Not a sequence (gap)',
          ),
          QuestionPair(
            left: '{{m9}}{{m1}}{{m2}}',
            right: 'Not a sequence (wraps)',
          ),
          QuestionPair(
            left: '{{east}}{{south}}{{west}}',
            right: 'Not a sequence (honors)',
          ),
        ],
        explanation:
            'Consecutive same-suit tiles make a Chow; a gap breaks the run, 9-1-2 wraps around the end, and honor tiles have no numbers at all.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many tiles are in one Sequence (Chow)?',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
        acceptedAnswers: ['3', 'three', '3 tiles'],
        explanation:
            'A Chow is exactly 3 consecutive tiles, which is why four Chows plus a pair fill the 14-tile winning hand.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Select the middle tile that completes this Sequence: {{m4}}___{{m6}}',
        options: ['m3', 'm5', 'm7', 'm8'],
        correctIndex: 1,
        tiles: const ['m3', 'm5', 'm7', 'm8'],
        explanation:
            '{{m4}}{{m5}}{{m6}} is the only run through both given tiles, so {{m5}} is the one tile that fits in the gap.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange these tiles into the highest possible valid Sequence.',
        options: const [],
        correctIndex: 0,
        tiles: const ['m7', 'm8', 'm9'],
        explanation:
            '7-8-9 is the highest Chow in any suit, because 8-9-1 would wrap around and is never allowed.',
      ),
    ],
  ),

  Lesson(
    id: '2-2',
    stageId: 'stage2',
    title: 'Triplets (Pong)',
    subtitle: '3 identical tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'A Triplet (Pong/刻子) is 3 identical tiles. Like {{m5}}{{m5}}{{m5}} or {{east}}{{east}}{{east}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Unlike sequences, triplets work with ANY tile — suited tiles, Winds, or Dragons! Three of the same = Pong.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'You can form a Pong by collecting tiles yourself, OR by claiming another player\'s discard. We\'ll learn claiming rules later!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'A "concealed Pong" (formed entirely from your draws) is worth more than an "exposed Pong" (formed by claiming a discard).',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is a Pong (triplet)?',
        options: [
          '3 consecutive tiles',
          '3 identical tiles',
          '2 identical tiles',
          '4 identical tiles',
        ],
        correctIndex: 1,
        explanation:
            'A Pong is exactly 3 identical tiles, like three 5-Characters.',
      ),
      QuizQuestion(
        question: 'Which tiles can form a Pong?',
        options: [
          'Only suited tiles',
          'Only honor tiles',
          'Any tile type',
          'Only Dragons',
        ],
        correctIndex: 2,
        explanation:
            'Any tile can form a Pong — suited tiles, Winds, or Dragons. You just need 3 identical copies.',
      ),
      QuizQuestion(
        question: 'Select the tile that completes this Pong: {{red}}{{red}}___',
        options: ['red', 'green', 'white', 'm1'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['red', 'green', 'white', 'm1', 'p1', 's1', 'east'],
        explanation:
            'A Pong needs 3 identical tiles. {{red}}{{red}} needs another {{red}} to complete.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are valid Pongs (Triplets)? Select all that apply.',
        options: [
          '{{west}}{{west}}{{west}}',
          '{{s9}}{{s9}}{{s9}}',
          '{{m2}}{{m3}}{{m4}}',
          '{{red}}{{green}}{{white}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'A Pong is 3 identical tiles of any type, so the three Wests and three 9-Bamboo both count, while {{m2}}{{m3}}{{m4}} is a Chow and the three different Dragons are not identical.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Select the tile that makes a Pong out of your pair, not a Chow: {{p7}}{{p7}}___',
        options: ['p7', 'p6', 'p8', 's7'],
        correctIndex: 0,
        tiles: const ['p7', 'p6', 'p8', 's7'],
        explanation:
            'A Pong needs 3 identical tiles, so the pair needs a third {{p7}}; {{p6}} or {{p8}} would not complete any meld.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many identical tiles are needed to make a Pong?',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
        acceptedAnswers: ['3', 'three', '3 tiles'],
        explanation:
            'A Pong is exactly 3 identical tiles, while a 4th copy of the same tile would make it a Kong instead.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Pong term to its meaning.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Pong', right: '3 identical tiles'),
          QuestionPair(
            left: 'Concealed Pong',
            right: 'All 3 tiles drawn by you',
          ),
          QuestionPair(
            left: 'Exposed Pong',
            right: 'Completed by claiming a discard',
          ),
        ],
        explanation:
            'A Pong is 3 identical tiles, and it is concealed when you drew all three yourself but exposed when the third came from another player\'s discard.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Why is {{east}}{{east}}{{east}} a valid Pong but {{east}}{{south}}{{west}} is not?',
        options: [
          'East is a Dragon tile',
          'Honor tiles have no numbers, so only identical copies can form a meld',
          'Winds may only be used in pairs',
          'Because East is the dealer',
        ],
        correctIndex: 1,
        explanation:
            'Winds and Dragons carry no rank, so they can never line up as consecutive tiles and only identical copies can form a Pong.',
      ),
    ],
  ),

  Lesson(
    id: '2-3',
    stageId: 'stage2',
    title: 'Pairs (Eyes)',
    subtitle: '2 identical tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'A Pair (對子/Eyes) is simply 2 identical tiles. Like {{p3}}{{p3}} or {{west}}{{west}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Every winning hand needs exactly ONE pair. The pair is sometimes called the "eyes" (眼) of the hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Any tile can be your pair — suited tiles, Winds, or Dragons. But remember: you need exactly one pair, no more, no less!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The pair itself does NOT add Faan. A pair of Dragons or your seat Wind gives 0 extra Faan - the Faan comes from having a Dragon TRIPLET or seat Wind TRIPLET, not from the pair!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['1', 'one', '1 pair'],
        question: 'How many pairs does a standard winning hand need?',
        options: ['0', '1', '2', '3'],
        correctIndex: 1,
        explanation:
            'A standard winning hand needs exactly 1 pair (the "eyes") plus 4 melds.',
      ),
      QuizQuestion(
        question: 'Which can be used as a pair?',
        options: [
          'Only suited tiles',
          'Only honor tiles',
          'Any tile type',
          'Only Dragons',
        ],
        correctIndex: 2,
        explanation: 'Any tile can serve as the pair in your winning hand.',
      ),
      QuizQuestion(
        question: 'Does a pair of Dragons or your seat Wind add Faan?',
        options: [
          'Yes, 1 Faan each',
          'No, a pair never adds Faan',
          'Yes, but only for Dragons',
          'Yes, but only for seat Wind',
        ],
        correctIndex: 1,
        explanation:
            'A pair (2 tiles) does NOT add Faan. Only a TRIPLET (3 tiles) of Dragons or your seat Wind gives 1 Faan. The pair is just the required "eyes" of a winning hand.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each hand part to how many tiles it uses.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Pair (eyes)', right: '2 identical tiles'),
          QuestionPair(left: 'Chow', right: '3 consecutive same-suit tiles'),
          QuestionPair(left: 'Pong', right: '3 identical tiles'),
          QuestionPair(left: 'Kong', right: '4 identical tiles'),
        ],
        explanation:
            'The pair is the only 2-tile unit; Chow and Pong both use 3 tiles and a Kong uses 4, yet each meld still counts as 3 for hand structure.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Select the tile that completes this pair: {{p3}}___',
        options: ['p3', 'p4', 'p2', 'm3'],
        correctIndex: 0,
        tiles: const ['p3', 'p4', 'p2', 'm3'],
        explanation:
            'A pair is 2 identical tiles, so {{p3}}{{p3}} is the pair; {{p2}} or {{p4}} would only start a run.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these can serve as the pair (eyes) of a winning hand? Select all that apply.',
        options: [
          '{{west}}{{west}}',
          '{{red}}{{red}}',
          '{{m3}}{{m4}}',
          '{{east}}{{south}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'Any two identical tiles can be the eyes, so a West pair and a Red Dragon pair both work, but {{m3}}{{m4}} and {{east}}{{south}} are not identical.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Which statement about the pair is correct?',
        options: [
          'A hand may hold two pairs if it has only three melds',
          'A hand with 4 melds and 2 pairs is a valid win',
          'A standard win is 4 melds plus exactly 1 pair',
          'The pair must always be a suited tile',
        ],
        correctIndex: 2,
        explanation:
            'The standard hand is 4 melds + exactly 1 pair = 14 tiles, so an extra pair leaves the hand one meld short.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many tiles are in a Pair (eyes)?',
        options: ['1', '2', '3', '4'],
        correctIndex: 1,
        acceptedAnswers: ['2', 'two', '2 tiles'],
        explanation:
            'A pair is 2 identical tiles, and a winning hand contains exactly one such pair.',
      ),
    ],
  ),

  Lesson(
    id: '2-4',
    stageId: 'stage2',
    title: 'Quads (Kong)',
    subtitle: '4 identical tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'A Kong (槓) is 4 identical tiles! It\'s like a super-Pong. Example: {{s7}}{{s7}}{{s7}}{{s7}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When you declare a Kong, you place it aside and draw a replacement tile. This keeps your hand at the right size.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'There are 3 types: Concealed Kong (all 4 from draws), Exposed Kong (claim a discard), and Supplemental Kong (add 4th tile to existing Pong).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Kongs are powerful! They give you a replacement draw (keeping your hand size) and reveal information to opponents. Note: a Kong itself does NOT add Faan - the Faan comes from other hand features like All Pongs or a dragon triplet. Use Kongs wisely!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['4', 'four', '4 tiles'],
        question: 'How many tiles make a Kong?',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
        explanation: 'A Kong consists of 4 identical tiles.',
      ),
      QuizQuestion(
        question: 'What happens after declaring a Kong?',
        options: [
          'You skip your turn',
          'You draw a replacement tile',
          'You discard 2 tiles',
          'Nothing special',
        ],
        correctIndex: 1,
        explanation:
            'After declaring a Kong, you draw a replacement tile to maintain your hand size.',
      ),
      QuizQuestion(
        question: 'Does declaring a Kong itself add Faan?',
        options: [
          'Yes, 1 Faan per Kong',
          'No, a Kong itself gives 0 Faan',
          'Yes, but only concealed Kong',
          'Yes, but only exposed Kong',
        ],
        correctIndex: 1,
        explanation:
            'A Kong itself does NOT add Faan. Its benefit is the replacement draw and that it can support other Faan hands (e.g. All Pongs). Faan comes from the hand pattern, not from the Kong declaration.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are Kongs? Select all that apply.',
        options: [
          '{{s7}}{{s7}}{{s7}}{{s7}}',
          '{{red}}{{red}}{{red}}{{red}}',
          '{{m1}}{{m1}}{{m1}}',
          '{{p4}}{{p5}}{{p6}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'A Kong is 4 identical tiles of any type, so four 7-Bamboo and four Red Dragons qualify, while three 1-Character is a Pong and {{p4}}{{p5}}{{p6}} is a Chow.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Kong type to how it is formed.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Concealed Kong',
            right: 'All 4 tiles drawn by you',
          ),
          QuestionPair(
            left: 'Exposed Kong',
            right: 'Completed by claiming a discard',
          ),
          QuestionPair(
            left: 'Supplemental Kong',
            right: '4th tile added to an existing Pong',
          ),
        ],
        explanation:
            'The three Kongs differ only in where the 4th tile comes from: your own draws, another player\'s discard, or upgrading a Pong you already exposed.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many Kongs does the 十八羅漢 (18 Arhats) hand require?',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
        acceptedAnswers: ['4', 'four', '4 kongs'],
        explanation:
            '十八羅漢 is the four-Kong limit hand: 4 Kongs of 4 tiles each plus a pair makes 18 physical tiles.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Select the tile that upgrades this Pong into a Kong: {{m7}}{{m7}}{{m7}}___',
        options: ['m7', 'm8', 'm6', 'p7'],
        correctIndex: 0,
        tiles: const ['m7', 'm8', 'm6', 'p7'],
        explanation:
            'A Kong is 4 identical tiles, so adding the last {{m7}} turns the Pong into a supplemental Kong.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A Kong is 4 tiles, so why does a hand with one Kong still count as a normal 4-meld hand?',
        options: [
          'Because the Kong replaces your pair',
          'Because a Kong counts as one 3-tile meld and the replacement draw restores your hand size',
          'Because Kongs are ignored when scoring structure',
          'Because you discard one tile after declaring a Kong',
        ],
        correctIndex: 1,
        explanation:
            'A Kong counts as a single meld (3 tiles) for structure, and the replacement draw keeps your hand at the right size, so the hand is still 4 melds + 1 pair.',
      ),
    ],
  ),

  Lesson(
    id: '2-5',
    stageId: 'stage2',
    title: 'The Winning Hand Structure',
    subtitle: '4 melds + 1 pair = Win!',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Now let\'s put it all together! A standard winning hand = 4 melds + 1 pair = 14 tiles total.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Each "meld" can be a Sequence (Chow), Triplet (Pong), or Kong. Mix and match! Example: 3 sequences + 1 triplet + 1 pair = Win!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example winning hand: {{m1}}{{m2}}{{m3}} + {{p4}}{{p5}}{{p6}} + {{s7}}{{s8}}{{s9}} + {{east}}{{east}}{{east}} + {{red}}{{red}} = 14 tiles, valid win!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'But wait — in Cantonese Mahjong, you also need a MINIMUM of 3 Faan to win! Just having 4 melds + 1 pair isn\'t enough. We\'ll learn about Faan later.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the standard winning hand structure?',
        options: [
          '3 melds + 2 pairs',
          '4 melds + 1 pair',
          '5 melds',
          '4 pairs + 2 melds',
        ],
        correctIndex: 1,
        explanation:
            'The standard winning hand is 4 melds (sequences/triplets/kongs) + 1 pair.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['14', 'fourteen', '14 tiles'],
        question: 'How many tiles in a standard winning hand?',
        options: ['13', '14', '15', '16'],
        correctIndex: 1,
        explanation:
            '4 melds × 3 tiles + 1 pair × 2 tiles = 14 tiles (Kongs count as 3 for hand purposes).',
      ),
      QuizQuestion(
        question:
            'In Cantonese Mahjong, what else do you need besides the correct structure?',
        options: [
          'At least 1 Dragon',
          'Minimum 3 Faan',
          'All concealed tiles',
          'At least 1 Kong',
        ],
        correctIndex: 1,
        explanation:
            'Cantonese Mahjong requires a minimum of 3 Faan to declare a win.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are valid winning-hand structures? Select all that apply.',
        options: [
          '4 Chows + 1 Pair',
          '2 Chows + 2 Pongs + 1 Pair',
          '4 Pongs + 1 Kong',
          '3 Pongs + 1 Pair',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'Any mix of 4 melds plus 1 pair wins, but 4 Pongs + 1 Kong is 5 melds with no pair and 3 Pongs + 1 Pair is only 11 tiles.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You hold {{m1}}{{m2}}{{m3}} {{p4}}{{p5}}{{p6}} {{s7}}{{s8}}{{s9}} {{east}}{{east}}{{east}} {{m9}}. Select the tile that completes the win.',
        options: ['m9', 'm8', 'p9', 'east'],
        correctIndex: 0,
        tiles: const ['m9', 'm8', 'p9', 'east'],
        explanation:
            'The hand already has 4 melds, so the 13th tile only needs to pair up: {{m9}}{{m9}} is the eyes and completes 14 tiles.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each structure term to its meaning.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Meld', right: 'A Chow, Pong or Kong'),
          QuestionPair(left: 'Eyes', right: 'The one pair a hand needs'),
          QuestionPair(
            left: 'Kong',
            right: '4 identical tiles counted as one meld',
          ),
        ],
        explanation:
            'Every winning hand is 4 melds of these three kinds plus the single pair known as the eyes.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'A hand of four Kongs plus a pair physically shows how many tiles?',
        options: ['14', '15', '16', '18'],
        correctIndex: 3,
        acceptedAnswers: ['18', 'eighteen', '18 tiles'],
        explanation:
            'Each Kong adds one extra physical tile to the 14-tile frame, so 4 Kongs + 1 pair shows 18 tiles.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Rank matters in a Chow: arrange these Character tiles from lowest to highest.',
        options: const [],
        correctIndex: 0,
        tiles: const ['m2', 'm5', 'm8'],
        explanation:
            'Character tiles run 1 to 9, so the ascending order is {{m2}}{{m5}}{{m8}} — the same reading order a Chow must follow.',
      ),
    ],
  ),

  Lesson(
    id: '2-6',
    stageId: 'stage2',
    title: 'Stage 2 Review',
    subtitle: 'Combination mastery check',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Great progress! You now know all the building blocks: Sequences, Triplets, Pairs, and Kongs. Let\'s test your understanding!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: Sequence = 3 consecutive same-suit tiles, Triplet = 3 identical tiles, Pair = 2 identical tiles, Kong = 4 identical tiles.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which combination can ONLY be formed with suited tiles?',
        options: ['Sequence (Chow)', 'Triplet (Pong)', 'Pair', 'Kong'],
        correctIndex: 0,
        explanation:
            'Only sequences require consecutive numbers, which only suited tiles have. Triplets, pairs, and kongs work with any tile.',
      ),
      QuizQuestion(
        question: 'Arrange these to form a valid sequence',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['p7', 'p8', 'p9'],
        explanation:
            '{{p7}}{{p8}}{{p9}} is a valid Circle sequence — the highest possible.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['4', 'four', '4 melds'],
        question: 'How many melds does a winning hand need?',
        options: ['3', '4', '5', '6'],
        correctIndex: 1,
        explanation:
            'A standard winning hand needs exactly 4 melds plus 1 pair.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each combination to its tile count.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Pair', right: '2 identical tiles'),
          QuestionPair(left: 'Chow', right: '3 consecutive same-suit tiles'),
          QuestionPair(left: 'Pong', right: '3 identical tiles'),
          QuestionPair(left: 'Kong', right: '4 identical tiles'),
        ],
        explanation:
            'The four building blocks are 2, 3, 3 and 4 tiles, and only the Kong\'s extra tile is absorbed by a replacement draw.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements are true? Select all that apply.',
        options: [
          'A Chow must stay within one suit',
          'A Kong counts as one meld for hand structure',
          'A pair of Dragons adds 1 Faan',
          'Honor tiles can form a Chow',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'Chows never mix suits and a Kong is one meld, but a Dragon pair adds no Faan and honors cannot form runs at all.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You hold {{s2}}{{s3}}{{s4}} {{p6}}{{p7}}{{p8}} {{m5}}{{m5}}{{m5}} {{west}}{{west}}{{west}} {{red}}. Select the tile that completes 4 melds + 1 pair.',
        options: ['red', 'green', 'white', 'east'],
        correctIndex: 0,
        tiles: const ['red', 'green', 'white', 'east'],
        explanation:
            'With four melds already set, the lone {{red}} only needs a partner, so a second Red Dragon completes the eyes.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Which of these is NOT a valid winning hand?',
        options: [
          '3 Chows + 1 Pong + 1 Pair',
          '4 Pongs + 1 Pair',
          '2 Chows + 1 Pong + 2 Pairs',
          '1 Chow + 3 Pongs + 1 Pair',
        ],
        correctIndex: 2,
        explanation:
            'The third option is only 3 melds and two pairs, which is 13 tiles with the wrong shape, while the others are all 4 melds + 1 pair.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'How many Faan are needed to declare a win in Hong Kong mahjong?',
        options: ['1', '2', '3', '5'],
        correctIndex: 2,
        acceptedAnswers: ['3', 'three', '3 faan'],
        explanation:
            'Three Faan is the minimum to win (三番起糊), and 10 Faan is the cap on any hand.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 3: How to Play (8 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '3-1',
    stageId: 'stage3',
    title: 'Table Setup',
    subtitle: 'Seating, dice & the wall',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s learn how a game starts! First, determine seating. Players draw Wind tiles to decide seats: East, South, West, North (counter-clockwise).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'East is the dealer and always goes first. The dealer position rotates when East doesn\'t win. A full game has 4 rounds (East, South, West, North round). Important: even on a draw (washout/流局), the dealer does NOT keep the seat — the deal rotates. This applies even at the last hand of North round!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Next, build the Wall: all 144 tiles are shuffled face-down, then each player builds a row of 18 stacks (2 tiles high) = 36 tiles per player.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The dealer rolls dice to determine where to break the wall and start dealing. This ensures randomness!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Who goes first in a mahjong game?',
        options: ['North', 'South', 'East', 'West'],
        correctIndex: 2,
        explanation: 'East (the dealer) always takes the first turn.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['36', '36 tiles'],
        question: 'How many tiles does each player stack in the wall?',
        options: ['18', '34', '36', '72'],
        correctIndex: 2,
        explanation:
            'Each player builds 18 stacks of 2 tiles = 36 tiles per player (144 total ÷ 4).',
      ),
      QuizQuestion(
        question: 'In which direction do seats go?',
        options: ['Clockwise', 'Counter-clockwise', 'Random', 'Alphabetical'],
        correctIndex: 1,
        explanation: 'Seats go counter-clockwise: East → South → West → North.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are true about the dealer (East)?',
        options: [
          'Takes the first turn of the hand',
          'Starts with 14 tiles',
          'Keeps the deal after a washout',
          'Is paid double for winning',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'East starts with 14 tiles and discards first, while a washout still passes the deal on and the dealer gets no scoring bonus.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many rounds does a full game have?',
        options: ['1', '2', '3', '4'],
        correctIndex: 3,
        acceptedAnswers: ['4', 'four', '4 rounds', 'four rounds'],
        explanation:
            'A full game runs four rounds: East, South, West and North.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each setup step with what it decides.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Dice roll', right: 'Where the wall is broken'),
          QuestionPair(
            left: 'Wind tile draw',
            right: 'Which seat each player takes',
          ),
          QuestionPair(
            left: 'Washout (流局)',
            right: 'The deal still passes to the next player',
          ),
        ],
        explanation:
            'The dice only pick the break point, the wind draw fixes seats, and a washout rotates the deal.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Rounds run East, South, West, North. Which Wind tile marks the second round?',
        options: ['east', 'south', 'west', 'north'],
        correctIndex: 1,
        explanation: 'The South round is the second of the four rounds.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange the Wind tiles in seating order, starting from the dealer.',
        options: const [],
        correctIndex: 0,
        tiles: const ['east', 'south', 'west', 'north'],
        explanation:
            'Seats and turns run counter-clockwise: East, South, West, North.',
      ),
    ],
  ),

  Lesson(
    id: '3-2',
    stageId: 'stage3',
    title: 'Dealing Tiles',
    subtitle: 'Starting hands & the deal',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'After breaking the wall, dealing begins! Each player takes 4 tiles at a time, going around 3 times = 12 tiles each.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Then each player takes 1 more tile, giving everyone 13 tiles. The dealer (East) takes 1 extra = 14 tiles to start.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Why does East get 14? Because East goes first by discarding! Other players start with 13 and will draw to 14 on their turn.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'After dealing, check for Flowers! If you have any, declare them face-up and draw replacements from the back of the wall.',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['13', 'thirteen', '13 tiles'],
        question: 'How many tiles does each non-dealer start with?',
        options: ['12', '13', '14', '16'],
        correctIndex: 1,
        explanation:
            'Non-dealers start with 13 tiles. They draw to 14 on their turn.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['14', 'fourteen', '14 tiles'],
        question: 'How many tiles does the dealer (East) start with?',
        options: ['12', '13', '14', '16'],
        correctIndex: 2,
        explanation:
            'The dealer starts with 14 tiles and begins by discarding one.',
      ),
      QuizQuestion(
        question: 'What do you do if you have Flower tiles after dealing?',
        options: [
          'Keep them in hand',
          'Discard them',
          'Declare them and draw replacements',
          'Give them to East',
        ],
        correctIndex: 2,
        explanation:
            'Flower tiles are declared face-up immediately, and you draw replacement tiles.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements about the deal are correct?',
        options: [
          'Tiles are taken four at a time',
          'Players go three times round before the single tile',
          'The dealer finishes with 13 tiles',
          'Flowers are kept hidden in the hand',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'The deal is four tiles three times round plus one each, the dealer holds 14, and flowers are shown.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many times does the deal go round taking four tiles?',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
        acceptedAnswers: ['3', 'three', '3 times', 'three times'],
        explanation:
            'Three passes of four tiles give everyone 12 before the single tile.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each situation with what happens.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'You are dealt a Flower',
            right: 'Show it and draw a replacement',
          ),
          QuestionPair(
            left: 'You are the dealer',
            right: 'You start by discarding',
          ),
          QuestionPair(
            left: 'You are a non-dealer',
            right: 'You wait with 13 tiles for your first draw',
          ),
          QuestionPair(
            left: 'The wall is broken',
            right: 'Dealing starts from that point',
          ),
        ],
        explanation:
            'Flowers leave the hand immediately, and only East begins by discarding because East already holds 14 tiles.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Which of these must be declared face-up and replaced?',
        options: ['f_plum', 'm1', 'east', 'white'],
        correctIndex: 0,
        explanation:
            'Flower tiles are declared and replaced; the other three stay in your hand.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Where does a replacement tile for a Flower come from?',
        options: [
          'The back of the wall',
          'The front of the wall',
          'The discard pile',
          'The player on your left',
        ],
        correctIndex: 0,
        explanation:
            'Flower replacements are drawn from the back (end) of the wall.',
      ),
    ],
  ),

  Lesson(
    id: '3-3',
    stageId: 'stage3',
    title: 'Drawing & Discarding',
    subtitle: 'The basic turn cycle',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Each turn is simple: Draw 1 tile from the wall → Look at your hand → Discard 1 tile face-up. That\'s it!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'After drawing, you temporarily have 14 tiles. You must discard 1 to return to 13 (unless you win!).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Turns go counter-clockwise: East → South → West → North → East → ... until someone wins or the wall runs out.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Pro tip: Discarded tiles are placed face-up in front of you in order. This information is public — smart players read discards!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the basic turn sequence?',
        options: [
          'Discard then draw',
          'Draw then discard',
          'Draw two then discard two',
          'Draw from another player',
        ],
        correctIndex: 1,
        explanation:
            'Each turn: Draw 1 tile from the wall, then discard 1 tile.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['13', 'thirteen', '13 tiles'],
        question: 'How many tiles should you have after discarding?',
        options: ['12', '13', '14', '15'],
        correctIndex: 1,
        explanation: 'After discarding, your hand returns to 13 tiles.',
      ),
      QuizQuestion(
        question: 'In which direction do turns proceed?',
        options: ['Clockwise', 'Counter-clockwise', 'Random', 'Dealer decides'],
        correctIndex: 1,
        explanation: 'Turns proceed counter-clockwise around the table.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which are true during a normal turn?',
        options: [
          'You draw one tile from the wall',
          'You temporarily hold 14 tiles',
          'You discard one tile face-up',
          'You may discard two tiles instead',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation: 'A turn is draw one, hold 14, then discard exactly one.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'You hold 14 tiles after drawing. How many must you discard?',
        options: ['0', '1', '2', '3'],
        correctIndex: 1,
        acceptedAnswers: ['1', 'one', '1 tile', 'one tile'],
        explanation: 'Discarding one tile returns your hand to 13.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each situation with what you do.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'You draw a tile you cannot use',
            right: 'Discard it at the end of your turn',
          ),
          QuestionPair(
            left: 'You draw your winning tile',
            right: 'Declare the win instead of discarding',
          ),
          QuestionPair(
            left: 'You declare a Kong',
            right: 'Draw a replacement before discarding',
          ),
          QuestionPair(
            left: 'The wall runs out',
            right: 'The hand ends in a washout',
          ),
        ],
        explanation:
            'Drawing never forces a discard when you can win, and a Kong adds a replacement draw to the turn.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'East has just discarded. Whose turn is next?',
        options: ['south', 'west', 'north', 'east'],
        correctIndex: 0,
        explanation: 'Turns pass counter-clockwise, so South plays after East.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Where are your discards placed?',
        options: [
          'Face-up in front of you, in order',
          'Face-down in the centre',
          'Back into the wall',
          'Into the dealer\'s row',
        ],
        correctIndex: 0,
        explanation:
            'Every player keeps a face-up row of discards, which is public information.',
      ),
    ],
  ),

  Lesson(
    id: '3-4',
    stageId: 'stage3',
    title: 'Claiming: Chow',
    subtitle: 'Taking a discard for a sequence',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You don\'t always have to draw from the wall! You can claim (take) another player\'s discard to complete a meld. Let\'s start with Chow (吃).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Chow means taking a discard to complete a sequence. Example: You have {{m4}}{{m5}}, and the player before you discards {{m3}} — you can call "Chow!"',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'IMPORTANT: You can only Chow from the player directly before you (to your left in turn order). Not from across or two seats away!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'After calling Chow, reveal the completed sequence face-up. Then discard 1 tile. Your turn replaces the normal draw.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Who can you Chow from?',
        options: [
          'Any player',
          'Only the player before you',
          'Only the player across',
          'Only the dealer',
        ],
        correctIndex: 1,
        explanation:
            'You can only Chow from the player immediately before you in turn order.',
      ),
      QuizQuestion(
        question: 'What does a Chow complete?',
        options: ['A triplet', 'A sequence', 'A pair', 'A kong'],
        correctIndex: 1,
        explanation:
            'Chow is specifically for completing a sequence (3 consecutive same-suit tiles).',
      ),
      QuizQuestion(
        question: 'After calling Chow, what must you do?',
        options: [
          'Draw from the wall',
          'Discard a tile',
          'Skip your turn',
          'Draw 2 tiles',
        ],
        correctIndex: 1,
        explanation:
            'After claiming a Chow, you reveal the sequence and then discard a tile.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which conditions must be met to call Chow?',
        options: [
          'You hold two suited tiles that complete a run',
          'The discard comes from the player on your left',
          'The completed run is three consecutive tiles of one suit',
          'Any player at the table may feed your Chow',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'A Chow is a suited run fed only by the player immediately before you.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'You hold {{m4}}{{m5}}. Which discard completes a Chow?',
        options: ['m3', 'm7', 'p3', 'east'],
        correctIndex: 0,
        explanation:
            '{{m3}}{{m4}}{{m5}} is a run, while {{m7}} would need a {{m6}} you do not hold.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange these tiles into a Chow that uses your {{m3}} and {{m5}}.',
        options: const [],
        correctIndex: 0,
        tiles: const ['m3', 'm4', 'm5'],
        explanation:
            '{{m3}}{{m4}}{{m5}} is three consecutive tiles in one suit.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many tiles do you reveal when you call Chow?',
        options: ['2', '3', '4', '5'],
        correctIndex: 1,
        acceptedAnswers: ['3', 'three', '3 tiles', 'three tiles'],
        explanation:
            'A Chow is a three-tile run shown face-up with the claimed discard.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question:
            'Match the two tiles you hold with the discard you need for a Chow.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 's5 and s6', right: 's4 or s7'),
          QuestionPair(left: 'm8 and m9', right: 'm7 only'),
          QuestionPair(left: 'p1 and p2', right: 'p3 only'),
          QuestionPair(left: 'east and east', right: 'No Chow is possible'),
        ],
        explanation:
            'A run stays inside 1 to 9 in one suit, so 8-9 takes only 7, 1-2 takes only 3, and honour tiles cannot be chowed.',
      ),
    ],
  ),

  Lesson(
    id: '3-5',
    stageId: 'stage3',
    title: 'Claiming: Pong',
    subtitle: 'Taking a discard for a triplet',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Pong (碰) means claiming a discard to complete a triplet. Example: You have {{east}}{{east}}, someone discards {{east}} — call "Pong!"',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Unlike Chow, you can Pong from ANY player, regardless of seating position! Pong has priority over Chow.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'After calling Pong, reveal the triplet face-up, then discard 1 tile. Play continues from your position (skipping players in between).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Warning: An exposed Pong (from claiming) is worth less than a concealed Pong (from your own draws). Consider if it\'s worth revealing!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Can you Pong from any player?',
        options: [
          'Only from the player before you',
          'Only from the dealer',
          'Yes, from any player',
          'Only from the player across',
        ],
        correctIndex: 2,
        explanation:
            'You can Pong from any player at the table, regardless of position.',
      ),
      QuizQuestion(
        question: 'Which has higher priority?',
        options: [
          'Chow over Pong',
          'Pong over Chow',
          'They are equal',
          'Depends on the round',
        ],
        correctIndex: 1,
        explanation:
            'Pong always has priority over Chow when multiple players want the same discard.',
      ),
      QuizQuestion(
        question: 'What is the downside of calling Pong?',
        options: [
          'You lose a turn',
          'The exposed meld is worth less',
          'You must discard 2 tiles',
          'You cannot win that round',
        ],
        correctIndex: 1,
        explanation:
            'Exposed melds (from claiming) are generally worth less than concealed melds.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which are true about a Pong?',
        options: [
          'You may claim it from any player',
          'It beats a Chow for the same discard',
          'You discard one tile after revealing it',
          'It gives you a replacement draw from the back of the wall',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'Pong comes from any seat and outranks Chow; the replacement draw belongs to Kong.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'You hold {{s7}}{{s7}}. Which discard completes a Pong?',
        options: ['s7', 's6', 's8', 'p7'],
        correctIndex: 0,
        explanation:
            'A Pong needs the identical tile; {{s6}} or {{s8}} would make a Chow and {{p7}} is another suit.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match what you hold with the claim it allows.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Two identical tiles', right: 'Pong'),
          QuestionPair(left: 'Three identical tiles', right: 'Kong'),
          QuestionPair(left: 'Two tiles one apart in one suit', right: 'Chow'),
          QuestionPair(
            left: 'Four melds and a pair worth 3+ faan',
            right: 'Win',
          ),
        ],
        explanation:
            'Each claim is defined by how many tiles you already hold and whether they match or run.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'After calling Pong, how many tiles must you discard?',
        options: ['0', '1', '2', '3'],
        correctIndex: 1,
        acceptedAnswers: ['1', 'one', '1 tile', 'one tile'],
        explanation:
            'Claiming takes you to 14 tiles, so one discard brings you back to 13.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'After your Pong, who plays next?',
        options: [
          'The player after you',
          'The player who discarded',
          'The dealer',
          'The player across',
        ],
        correctIndex: 0,
        explanation:
            'Play resumes from your seat, skipping the players in between.',
      ),
    ],
  ),

  Lesson(
    id: '3-6',
    stageId: 'stage3',
    title: 'Claiming: Kong',
    subtitle: 'Taking a discard for a quad',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Kong (槓) claiming works like Pong but for 4 tiles. You have 3 identical tiles, someone discards the 4th — call "Kong!"',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'After declaring Kong, reveal it and draw a replacement tile from the back of the wall. Then discard as normal.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'You can also declare a Concealed Kong (all 4 from draws) or a Supplemental Kong (add to an existing Pong). Both get replacement draws!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Priority order for claims: Win (highest) > Kong > Pong > Chow (lowest). Winning always takes priority!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the priority order for claiming discards?',
        options: [
          'Chow > Pong > Kong > Win',
          'Win > Kong > Pong > Chow',
          'All equal',
          'Pong > Win > Chow > Kong',
        ],
        correctIndex: 1,
        explanation:
            'Priority from highest to lowest: Win > Kong > Pong > Chow.',
      ),
      QuizQuestion(
        question: 'After declaring a Kong, where do you draw from?',
        options: [
          'Front of the wall',
          'Back of the wall',
          'Another player',
          'You don\'t draw',
        ],
        correctIndex: 1,
        explanation:
            'Kong replacement tiles are drawn from the back (end) of the wall.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['3', 'three', '3 types'],
        question: 'How many types of Kong are there?',
        options: ['1', '2', '3', '4'],
        correctIndex: 2,
        explanation:
            'Three types: Exposed Kong (claim discard), Concealed Kong (all from draws), Supplemental Kong (add to Pong).',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are ways to make a Kong?',
        options: [
          'Claim a discard while holding three identical tiles',
          'Draw all four identical tiles yourself',
          'Add the fourth tile to an existing Pong',
          'Claim a discard that matches two tiles in your hand',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'The three Kong types are exposed, concealed and supplemental, while two matching tiles are only a Pong.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many identical tiles make a Kong?',
        options: ['2', '3', '4', '5'],
        correctIndex: 2,
        acceptedAnswers: ['4', 'four', '4 tiles', 'four tiles'],
        explanation: 'A Kong is a meld of four identical tiles.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Kong type with how it is made.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Exposed Kong',
            right: 'Claim the fourth tile from a discard',
          ),
          QuestionPair(left: 'Concealed Kong', right: 'Draw all four yourself'),
          QuestionPair(
            left: 'Supplemental Kong',
            right: 'Add the fourth tile to your Pong',
          ),
          QuestionPair(
            left: 'Replacement tile',
            right: 'Taken from the back of the wall',
          ),
        ],
        explanation:
            'The three kinds differ in where the fourth tile comes from, and all of them take a replacement from the wall\'s end.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'You hold {{red}}{{red}}{{red}}. Which discard may you Kong?',
        options: ['red', 'green', 'white', 'east'],
        correctIndex: 0,
        explanation: 'A Kong needs the fourth copy of the identical tile.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Why do you draw a replacement after declaring a Kong?',
        options: [
          'The Kong takes four tiles into one meld',
          'The dealer awards a free tile',
          'The wall owes you a Flower',
          'You must replace the tile you discarded',
        ],
        correctIndex: 0,
        explanation:
            'Four tiles become one meld, so the replacement keeps your hand at full size.',
      ),
    ],
  ),

  Lesson(
    id: '3-7',
    stageId: 'stage3',
    title: 'Declaring a Win',
    subtitle: 'Self-draw & claiming wins',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The moment you\'ve been waiting for — winning! There are 2 ways to win: Self-draw (自摸) or Claiming a discard (食糊).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Self-draw: You draw the tile you need from the wall. This is worth extra Faan! Call "Self-draw!" and reveal your hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Claiming win: Someone discards the tile you need. Call "Win!" (食糊). This has the highest priority — beats Pong, Kong, and Chow!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: In Cantonese Mahjong, your winning hand must have at least 3 Faan. If you don\'t have enough Faan, you cannot declare a win!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which way of winning gives extra Faan?',
        options: [
          'Claiming a discard',
          'Self-draw',
          'Both give the same',
          'Neither gives Faan',
        ],
        correctIndex: 1,
        explanation:
            'Self-draw (自摸) gives 1 extra Faan compared to winning by claiming a discard.',
      ),
      QuizQuestion(
        question:
            'What is the minimum Faan needed to win in Cantonese Mahjong?',
        options: ['1 Faan', '2 Faan', '3 Faan', '5 Faan'],
        correctIndex: 2,
        explanation:
            'Cantonese Mahjong requires a minimum of 3 Faan to declare a win.',
      ),
      QuizQuestion(
        question:
            'What happens if you have a complete hand but less than 3 Faan?',
        options: [
          'You win anyway',
          'You cannot declare a win',
          'You get half points',
          'The dealer decides',
        ],
        correctIndex: 1,
        explanation:
            'Without the minimum 3 Faan, you cannot declare a win even with a complete hand structure.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are valid ways to win?',
        options: [
          'Drawing your winning tile from the wall',
          'Claiming a discard that completes your hand',
          'Reaching at least 3 faan',
          'Claiming any discard that completes a pair',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'You win by self-draw or by claiming a discard, and only with 3 faan or more.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'What is the faan cap, however big the hand?',
        options: ['5', '8', '10', '13'],
        correctIndex: 2,
        acceptedAnswers: ['10', 'ten', '10 faan', 'ten faan'],
        explanation: 'Every hand counts as at most 10 faan under these rules.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match how the hand ends with who pays.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Discard win (出銃)',
            right: 'The discarder pays the full value',
          ),
          QuestionPair(
            left: 'Self-draw (自摸)',
            right: 'Each of the other three pays half value',
          ),
          QuestionPair(left: 'Washout (流局)', right: 'No points are exchanged'),
        ],
        explanation:
            '半銃制 means the discarder pays in full, while a self-draw is split in half across the three other players.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You hold {{m1}}{{m2}} and need one tile to win. Which discard completes your run?',
        options: ['m3', 'm4', 'p3', 'east'],
        correctIndex: 0,
        explanation:
            '{{m1}}{{m2}} waits only on {{m3}}, because a run cannot wrap past 9.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You self-draw a 4-faan hand. How much do you collect in total?',
        options: ['8', '16', '24', '32'],
        correctIndex: 2,
        explanation:
            'At 4 faan a discard win pays 16, so self-draw pays each player 8 for 24 in total.',
      ),
    ],
  ),

  Lesson(
    id: '3-8',
    stageId: 'stage3',
    title: 'Stage 3 Review',
    subtitle: 'Game flow mastery check',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You now understand the complete game flow! Setup → Deal → Draw/Discard cycle → Claim or Win. Let\'s review!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Key concepts: Chow (sequence, only from left), Pong (triplet, from anyone), Kong (quad, replacement draw), Win (highest priority).',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'A player discards {{m5}}. You have {{m5}}{{m5}} and the player to your right has {{m4}}{{m6}}. Who gets the tile?',
        options: [
          'The player with {{m4}}{{m6}} (Chow)',
          'You (Pong)',
          'First to call',
          'Neither',
        ],
        correctIndex: 1,
        explanation:
            'Pong has priority over Chow. You get the tile for your triplet.',
      ),
      QuizQuestion(
        question: 'What happens when the wall runs out and no one wins?',
        options: [
          'East wins by default',
          'The game is a draw',
          'Everyone loses points',
          'Reshuffle and continue',
        ],
        correctIndex: 1,
        explanation:
            'When the wall is exhausted with no winner, the hand is a draw (流局). No points are exchanged.',
      ),
      QuizQuestion(
        question: 'Arrange the claim priority from highest to lowest',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['red', 'east', 's1'],
        explanation:
            'Win (highest priority) → Pong/Kong (middle) → Chow (lowest priority).',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which claims may you make from any player\'s discard?',
        options: ['Chow', 'Pong', 'Kong', 'Win'],
        correctIndex: 1,
        correctIndexes: [1, 2, 3],
        explanation:
            'Only Chow is limited to the player on your left; the other claims may come from any seat.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each stage of the hand with its rule.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Deal', right: 'The dealer starts with 14 tiles'),
          QuestionPair(
            left: 'Normal turn',
            right: 'Draw one tile, then discard one',
          ),
          QuestionPair(
            left: 'Kong',
            right: 'The replacement comes from the back of the wall',
          ),
          QuestionPair(
            left: 'Wall exhausted',
            right: 'Washout, with no points exchanged',
          ),
        ],
        explanation:
            'The flow runs deal, draw and discard, claim, then win or washout.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'A discard win at 6 faan pays how many points?',
        options: ['24', '32', '48', '64'],
        correctIndex: 1,
        acceptedAnswers: ['32', 'thirty-two', '32 points'],
        explanation: 'The 半銃制 table pays 32 for a 6-faan discard win.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You hold {{p8}}{{p9}} and the player on your left discards. Which tile may you Chow?',
        options: ['p7', 'p6', 's9', 'east'],
        correctIndex: 0,
        explanation:
            '{{p8}}{{p9}} waits only on {{p7}}, since a run cannot go past 9.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You need one tile for a 3-faan win; the player across needs the same tile for a Pong. Who gets it?',
        options: [
          'The player across, because Pong is a claim',
          'You, because a win outranks every claim',
          'Whoever calls first',
          'Nobody; the tile is dead',
        ],
        correctIndex: 1,
        explanation:
            'A declared win beats Kong, Pong and Chow on the same discard.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 4: Winning Conditions (6 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '4-1',
    stageId: 'stage4',
    title: 'The 3-Faan Minimum',
    subtitle: 'Why structure alone isn\'t enough',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'In Cantonese Mahjong, having 4 melds + 1 pair isn\'t enough to win. You need at least 3 Faan (番) — bonus points from special patterns!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Faan come from many sources: specific tile combinations, how you win, flowers, and more. The more Faan, the more you get paid!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Common 3-Faan combinations: All Chows + Self-draw + No Flowers (平糊), or Mixed One Suit (混一色), or All Pongs (對對糊).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Think of Faan as a quality check — it ensures games are interesting and players aim for meaningful hands, not just any random combination!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the minimum Faan to win in Cantonese Mahjong?',
        options: ['1', '2', '3', '5'],
        correctIndex: 2,
        explanation: 'You need at least 3 Faan to declare a winning hand.',
      ),
      QuizQuestion(
        question: 'What is Faan?',
        options: [
          'The number of tiles',
          'Bonus points from special patterns',
          'The number of melds',
          'Your seat position',
        ],
        correctIndex: 1,
        explanation:
            'Faan are bonus points awarded for special patterns, tile combinations, and winning conditions.',
      ),
      QuizQuestion(
        question: 'Which of these ARE sources of Faan?',
        options: [
          'Dragon triplets',
          'Flower tiles',
          'Having exactly 13 tiles',
          'Self-draw',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        type: QuizType.multiChoice,
        explanation:
            'Dragon triplets, flowers and self-draw all score Faan. Having exactly 13 tiles is just the normal hand size between turns.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'A hand is worth 2 Faan. How many more Faan do you need to reach the 3-Faan minimum?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['1', 'one', '1 faan', 'one faan'],
        explanation: '2 Faan is exactly one short of the 3-Faan minimum.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements about Faan scoring are correct?',
        options: [
          'You need at least 3 Faan to win',
          '10 Faan is the cap, and every limit hand (例牌) counts as 10 Faan',
          'A 6-Faan hand won on a discard (出銃) is paid 32',
          'Each extra Faan doubles the payout',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'Payouts rise 8, 16, 24, 32, 48, 64, 96, 128 — they do not double with every Faan.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each pattern to its Faan value.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Self-draw (自摸)', right: '1 Faan'),
          QuestionPair(left: 'Mixed One Suit (混一色)', right: '3 Faan'),
          QuestionPair(left: 'Pure One Suit (清一色)', right: '7 Faan'),
          QuestionPair(left: 'Thirteen Orphans (十三么)', right: '10 Faan'),
        ],
        explanation:
            'These are the Gary values: 自摸 1, 混一色 3, 清一色 7, and 十三么 is a limit hand at 10.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You win a 3-Faan hand on a discard (出銃). How much does the discarder pay?',
        options: ['4', '8', '12', '16'],
        correctIndex: 1,
        explanation: 'In 半銃制 the discarder alone pays the full 8 at 3 Faan.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A limit hand (例牌) counts as 10 Faan and is won on a discard. How much is paid?',
        options: ['64', '96', '128', '192'],
        correctIndex: 2,
        explanation:
            '10 Faan on a discard is 128; 192 is the total collected on a self-draw, not a discard.',
      ),
    ],
  ),

  Lesson(
    id: '4-2',
    stageId: 'stage4',
    title: 'Common Winning Hands',
    subtitle: 'All Chows, All Pongs & Mixed Suit',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s learn the most common winning hands! First: All Chows (平糊) — your hand is all sequences + pair. Worth 1 Faan (need self-draw + no flowers for 3).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'All Pongs (對對糊) — every meld is a triplet! No sequences at all. This is worth 3 Faan by itself. Example: {{m2}}{{m2}}{{m2}} + {{p5}}{{p5}}{{p5}} + {{s8}}{{s8}}{{s8}} + {{east}}{{east}}{{east}} + {{red}}{{red}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Mixed One Suit (混一色) — all tiles from ONE suit plus honor tiles. Worth 3 Faan! Example: all Characters + some Winds/Dragons.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'These three are your bread and butter! All Pongs and Mixed One Suit both reach 3 Faan alone, making them reliable winning strategies.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How much is All Pongs (對對糊) worth?',
        options: ['1 Faan', '2 Faan', '3 Faan', '5 Faan'],
        correctIndex: 2,
        explanation:
            'All Pongs is worth 3 Faan, meeting the minimum requirement by itself.',
      ),
      QuizQuestion(
        question: 'What is Mixed One Suit (混一色)?',
        options: [
          'All tiles from one suit only',
          'One suit + honor tiles',
          'All honor tiles',
          'Two suits mixed',
        ],
        correctIndex: 1,
        explanation:
            'Mixed One Suit means all tiles from one suit PLUS honor tiles (Winds/Dragons).',
      ),
      QuizQuestion(
        question: 'All Chows (平糊) is worth how many Faan?',
        options: ['0', '1', '2', '3'],
        correctIndex: 1,
        explanation:
            'All Chows alone is only 1 Faan. You need additional Faan (like self-draw) to reach the 3-Faan minimum.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Which of these tiles could NOT appear in a Mixed One Suit (混一色) hand built on Characters plus honor tiles?',
        options: ['p5', 'm5', 'east', 'red'],
        correctIndex: 0,
        explanation:
            '混一色 uses only one suit plus honors, so any Dot tile breaks the pattern.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange these three tiles into a valid Chow (sequence) — the building block of All Chows (平糊).',
        options: const [],
        correctIndex: 0,
        tiles: const ['s7', 's8', 's9'],
        explanation:
            'A Chow is three consecutive tiles of the same suit, here 7-8-9 of Bamboo.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each hand shape to its name.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Four Chows and a pair', right: 'All Chows (平糊)'),
          QuestionPair(
            left: 'Four triplets and a pair, no Chows',
            right: 'All Pongs (對對糊)',
          ),
          QuestionPair(
            left: 'One suit plus honor tiles',
            right: 'Mixed One Suit (混一色)',
          ),
        ],
        explanation:
            'These are the three bread-and-butter shapes: 平糊, 對對糊 and 混一色.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many Faan is Mixed One Suit (混一色) worth on its own?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['3', 'three', '3 faan', 'three faan'],
        explanation:
            '混一色 is a 3-Faan pattern, so it meets the minimum by itself.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'All Pongs (對對糊) and Mixed One Suit (混一色) are each worth 3 Faan. What does that mean for you?',
        options: [
          'Either one alone meets the 3-Faan minimum',
          'They must be combined to reach 3 Faan',
          'They cancel each other out',
          'They only count if the hand is concealed',
        ],
        correctIndex: 0,
        explanation:
            'Each is a 3-Faan pattern in its own right, so either one alone can be declared.',
      ),
    ],
  ),

  Lesson(
    id: '4-3',
    stageId: 'stage4',
    title: 'Dragon & Wind Faan',
    subtitle: 'Honor tile bonuses',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Honor tile triplets are easy Faan! Any Dragon Pong ({{red}}{{red}}{{red}}, {{green}}{{green}}{{green}}, or {{white}}{{white}}{{white}}) = 1 Faan each.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Wind Pongs give 1 Faan if they match your seat wind OR the prevailing wind. If it matches BOTH, that\'s 2 Faan from one Pong!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: You\'re East seat in the East round. A Pong of {{east}}{{east}}{{east}} = 2 Faan (seat wind + prevailing wind). Very powerful!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Strategy tip: Collecting Dragon and matching Wind triplets is one of the easiest ways to reach 3 Faan!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How much is a Dragon Pong worth?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 1,
        explanation:
            'Any Dragon triplet (Red, Green, or White) is worth 1 Faan.',
      ),
      QuizQuestion(
        question: 'When is a Wind Pong worth 2 Faan?',
        options: [
          'Always',
          'When it matches both seat and prevailing wind',
          'When you have 2 Wind Pongs',
          'Never',
        ],
        correctIndex: 1,
        explanation:
            'A Wind Pong is worth 2 Faan when it matches both your seat wind AND the prevailing wind.',
      ),
      QuizQuestion(
        question:
            'You\'re South seat in the East round. How much is {{south}}{{south}}{{south}} worth?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 1,
        explanation:
            'South matches your seat wind (1 Faan) but not the prevailing wind (East round). Total: 1 Faan.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'You are East seat in the East round. Which of these Pongs score Faan for you?',
        options: [
          '{{red}}{{red}}{{red}}',
          '{{east}}{{east}}{{east}}',
          '{{south}}{{south}}{{south}}',
          '{{white}}{{white}}{{white}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'Red and White dragons score 1 each and East matches both your seat wind and the round wind, while South matches neither.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question:
            'Match each dragon pattern to its total value with the dragon triplets counted.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'One dragon triplet', right: '1 Faan'),
          QuestionPair(left: 'Small Three Dragons (小三元)', right: '5 Faan'),
          QuestionPair(left: 'Big Three Dragons (大三元)', right: '8 Faan'),
        ],
        explanation:
            '小三元 is 3 Faan plus its two dragon triplets (5); 大三元 is 5 plus three (8).',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You are East seat in the East round. Which of these triplets is worth 2 Faan?',
        options: ['east', 'south', 'red', 'north'],
        correctIndex: 0,
        explanation:
            'Only the East triplet matches both your seat wind and the round wind, scoring 1 + 1.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Your hand has two dragon triplets and the third dragon as the pair. Counting the 小三元 pattern and the two dragon triplets, the total is ___ Faan.',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['5', 'five', '5 faan', 'five faan'],
        explanation:
            '小三元 is 3 Faan and the two dragon triplets add 2 more, for 5.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'How many Faan does Big Three Dragons (大三元) score in total?',
        options: ['3', '5', '8', '10'],
        correctIndex: 2,
        explanation:
            'The 大三元 pattern is 5 Faan and the three dragon triplets add 3 more, for 8.',
      ),
    ],
  ),

  Lesson(
    id: '4-4',
    stageId: 'stage4',
    title: 'Self-Draw & Concealed Hand',
    subtitle: 'Winning method bonuses',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'HOW you win matters! Self-draw (自摸) = 1 Faan bonus. You completed your hand by drawing from the wall yourself.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Concealed Hand (門前清) = 1 Faan bonus. This means you never called Chow, Pong, or Kong — your entire hand was built from draws only!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'These stack! Self-draw + Concealed Hand = 2 Faan just from your winning method. Add 1 Dragon Pong = 3 Faan minimum reached!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Concealed hands are harder (no claiming!) but more rewarding. They also hide information from opponents — they can\'t see what you\'re building!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How much is Self-draw (自摸) worth?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 1,
        explanation: 'Self-draw gives 1 Faan bonus.',
      ),
      QuizQuestion(
        question: 'What is a Concealed Hand (門前清)?',
        options: [
          'No flowers',
          'Never claimed any discards',
          'All honor tiles',
          'Won on the first turn',
        ],
        correctIndex: 1,
        explanation:
            'A Concealed Hand means you never called Chow, Pong, or Kong — entirely self-drawn.',
      ),
      QuizQuestion(
        question: 'Self-draw + Concealed Hand + 1 Dragon Pong = ?',
        options: ['1 Faan', '2 Faan', '3 Faan', '4 Faan'],
        correctIndex: 2,
        explanation:
            '1 (Self-draw) + 1 (Concealed) + 1 (Dragon Pong) = 3 Faan. Minimum reached!',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Self-draw (自摸) and Concealed Hand (門前清) are worth 1 Faan each. Using just these two, the total is ___ Faan.',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['2', 'two', '2 faan', 'two faan'],
        explanation: '1 + 1 = 2 Faan from the winning method alone.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these leave your hand still concealed (門前清)?',
        options: [
          'You called Chow once',
          'You called Pong once',
          'You never called Chow, Pong or Kong',
          'You built the whole hand from your own draws',
        ],
        correctIndex: 2,
        correctIndexes: [2, 3],
        explanation:
            'Any call — Chow, Pong or Kong — breaks 門前清; only a fully self-built hand keeps it.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each winning method to what happened.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: '搶槓 (Robbing the Kong)',
            right:
                'You win on the tile an opponent adds to a Pong to make a Kong',
          ),
          QuestionPair(
            left: '槓上自摸 (Kong replacement draw)',
            right: 'You win on the replacement tile drawn after a Kong',
          ),
          QuestionPair(
            left: '海底撈月 (Last tile)',
            right: 'You win on the final tile of the wall',
          ),
        ],
        explanation:
            'All three are 1-Faan winning-method bonuses in the Gary rules.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'How much is 搶槓 (robbing the Kong) worth?',
        options: ['1 Faan', '2 Faan', '3 Faan', '5 Faan'],
        correctIndex: 0,
        explanation: '搶槓 is a 1-Faan winning-method bonus.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A 3-Faan hand is won by self-draw. How much does each opponent pay?',
        options: ['4', '8', '12', '16'],
        correctIndex: 0,
        explanation:
            '3 Faan pays 8 on a discard, so on a self-draw each of the three players pays half — 4.',
      ),
    ],
  ),

  Lesson(
    id: '4-5',
    stageId: 'stage4',
    title: 'Flower Faan & No Flowers',
    subtitle: 'Bonus from flower tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'A Flower only gives 1 Faan if it is YOUR flower (正花) - matching your seat wind. East: Spring+Plum, South: Summer+Orchid, West: Autumn+Chrysanthemum, North: Winter+Bamboo. Drawing another player\'s flower gives 0 Faan!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Interestingly, having NO flowers is also worth 1 Faan! It\'s called "No Flowers" (無花). This helps All Chow hands reach 3 Faan.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Flower Faan calculation: East seat with {{f_spring}} and {{f_plum}} = 2 Faan (both are East\'s flowers). But a South seat drawing {{f_spring}} = 0 Faan - it is NOT their flower!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'In standard Hong Kong Cantonese rules, ONLY your matching flower (正花) gives 1 Faan. Non-matching flowers give 0 Faan - they just get replaced with a new draw. Some house rules add bonuses for collecting all 4 of a group, but we use the standard rule!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How much is a matching Flower (正花) worth?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 1,
        explanation:
            'A flower that matches your seat wind (正花) gives 1 Faan. A non-matching flower gives 0 Faan.',
      ),
      QuizQuestion(
        question: 'What is "No Flowers" (無花) worth?',
        options: ['0 Faan', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 1,
        explanation: 'Having no Flower tiles at all is worth 1 Faan.',
      ),
      QuizQuestion(
        question:
            'You are South seat and draw {{f_spring}}. How much Faan from this flower?',
        options: ['0 Faan (not your flower)', '1 Faan', '2 Faan', '3 Faan'],
        correctIndex: 0,
        explanation:
            'South\'s flowers are Summer+Orchid. {{f_spring}} belongs to East, so South gets 0 Faan from it (just draw a replacement).',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each seat to its two flowers.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'East', right: 'Spring & Plum'),
          QuestionPair(left: 'South', right: 'Summer & Orchid'),
          QuestionPair(left: 'West', right: 'Autumn & Chrysanthemum'),
          QuestionPair(left: 'North', right: 'Winter & Bamboo'),
        ],
        explanation:
            'Seat flowers follow the numbers 1-4: East 1, South 2, West 3, North 4.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange the four seat winds in the order numbered 1 to 4 for flower assignment.',
        options: const [],
        correctIndex: 0,
        tiles: const ['east', 'south', 'west', 'north'],
        explanation: 'The seat numbering is East 1, South 2, West 3, North 4.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You are West seat. Which of these flowers is your 正花 (matching flower)?',
        options: ['f_autumn', 'f_spring', 'f_summer', 'f_bamboo'],
        correctIndex: 0,
        explanation:
            'West\'s flowers are Autumn and Chrysanthemum, so only {{f_autumn}} scores for West.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'East seat holds all four flower tiles: {{f_plum}} {{f_orchid}} {{f_chrys}} {{f_bamboo}}. How many Faan is that as 一台花?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['2', 'two', '2 faan', 'two faan'],
        explanation:
            '一台花 counts as 2 Faan in total; the seat flower is not added on top of it.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'You are South seat. Which of these give you Faan?',
        options: [
          'Holding {{f_summer}}',
          'Holding {{f_orchid}}',
          'Holding {{f_spring}}',
          'Having no flowers at all',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'South\'s flowers are Summer and Orchid, 無花 is worth 1 Faan, and Spring belongs to East so it gives South nothing.',
      ),
    ],
  ),

  Lesson(
    id: '4-6',
    stageId: 'stage4',
    title: 'Stage 4 Review',
    subtitle: 'Winning conditions mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Excellent! You now understand winning conditions in Cantonese Mahjong. Let\'s review the key Faan sources!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: 3 Faan minimum! Common paths: All Pongs (3), Mixed Suit (3), or combine smaller Faan: Dragon Pong + Self-draw + Concealed/Flowers.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which hand type alone meets the 3-Faan minimum?',
        options: ['All Chows', 'All Pongs', 'Concealed Hand', 'Self-draw'],
        correctIndex: 1,
        explanation:
            'All Pongs (對對糊) is worth 3 Faan by itself, meeting the minimum requirement.',
      ),
      QuizQuestion(
        question: 'You have: All Chows + Self-draw + No Flowers. Total Faan?',
        options: ['1 Faan', '2 Faan', '3 Faan', '4 Faan'],
        correctIndex: 2,
        explanation:
            '1 (All Chows) + 1 (Self-draw) + 1 (No Flowers) = 3 Faan. Minimum reached!',
      ),
      QuizQuestion(
        question: 'Which gives the MOST Faan from a single Pong?',
        options: [
          'Any Dragon Pong',
          'A Wind matching only seat wind',
          'A Wind matching both seat and prevailing wind',
          'A suited tile Pong',
        ],
        correctIndex: 2,
        explanation:
            'A Wind Pong matching both seat and prevailing wind gives 2 Faan — the most from a single Pong.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are worth 1 Faan?',
        options: [
          'Self-draw (自摸)',
          'Concealed hand (門前清)',
          'No Flowers (無花)',
          'All Pongs (對對糊)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation: '自摸, 門前清 and 無花 are 1 Faan each; 對對糊 is 3 Faan.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each pattern to its Faan value.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'All Chows (平糊)', right: '1 Faan'),
          QuestionPair(left: 'Mixed One Suit (混一色)', right: '3 Faan'),
          QuestionPair(
            left: 'Small Three Dragons (小三元, dragons counted)',
            right: '5 Faan',
          ),
          QuestionPair(
            left: 'Eighteen Arhats (十八羅漢, four Kongs)',
            right: '10 Faan',
          ),
        ],
        explanation:
            '平糊 is 1, 混一色 3, 小三元 with its two dragon triplets 5, and 十八羅漢 is a limit hand at 10.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'A hand scores 8 Faan and is won by self-draw. Each of the three opponents pays ___ points.',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['32', 'thirty-two', 'thirty two'],
        explanation:
            '8 Faan pays 64 on a discard, so each opponent pays half — 32.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Your hand is worth 12 Faan but it is a limit hand (例牌). How is it scored?',
        options: [
          'As 10 Faan',
          'As 12 Faan',
          'As 8 Faan',
          'It cannot be declared',
        ],
        correctIndex: 0,
        explanation:
            '10 Faan is the cap and every limit hand counts as exactly 10.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Two players each reach 3 Faan — one wins on a discard, one by self-draw. Which collects more in total?',
        options: [
          'The discard winner, 8',
          'The self-draw winner, 12 in total',
          'They collect the same',
          'Whichever player is dealer collects more',
        ],
        correctIndex: 1,
        explanation:
            '出銃 pays 8 from one player, while 自摸 collects 4 from each of three players — 12 in total.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 5: Special Hands (5 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '5-1',
    stageId: 'stage5',
    title: 'All Pongs',
    subtitle: 'Every meld is a triplet',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'All Pongs (對對糊) means every meld in your hand is a Pong (triplet) — no Chows allowed! Worth 3 Faan.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: {{m3}}{{m3}}{{m3}} {{p7}}{{p7}}{{p7}} {{s1}}{{s1}}{{s1}} {{east}}{{east}}{{east}} {{red}}{{red}} — four Pongs plus a pair!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Strategy: Claim Pongs aggressively when going for All Pongs. But be careful — exposing too many melds tells opponents your plan!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'All Pongs combines well with other Faan: + Dragon Pong (1), + Seat Wind (1), + Mixed One Suit (3). Stack them up!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How much is All Pongs (對對糊) worth?',
        options: ['1 Faan', '2 Faan', '3 Faan', '5 Faan'],
        correctIndex: 2,
        explanation: 'All Pongs is worth 3 Faan.',
      ),
      QuizQuestion(
        question: 'Can you have a Chow in an All Pongs hand?',
        options: ['Yes', 'No', 'Only if concealed', 'Only one Chow'],
        correctIndex: 1,
        explanation:
            'All Pongs requires every meld to be a Pong or Kong — no Chows allowed.',
      ),
      QuizQuestion(
        question: 'All Pongs (3) + Red Dragon Pong (1) + Self-draw (1) = ?',
        options: ['3 Faan', '4 Faan', '5 Faan', '6 Faan'],
        correctIndex: 2,
        explanation:
            '3 + 1 + 1 = 5 Faan. Different Faan sources stack together!',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which statements about 坎坎糊 (four concealed Pungs) are correct?',
        options: [
          'It is a limit hand worth 10 Faan',
          'A Kong is allowed among the four sets',
          'A single-tile wait (單吊) may win on a discard',
          'A pair wait (對碰) must be won by self-draw',
        ],
        correctIndex: 0,
        correctIndexes: [0, 2, 3],
        explanation:
            '坎坎糊 is a 10-Faan limit hand with four concealed Pungs and no Kongs; a single wait may take a discard but a pair wait must be self-drawn.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each hand shape to what it is called.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Four Pongs or Kongs plus a pair',
            right: '對對糊 — 3 Faan',
          ),
          QuestionPair(left: 'Four Chows plus a pair', right: '平糊 — 1 Faan'),
          QuestionPair(left: 'Four Kongs', right: '十八羅漢 — 10 Faan'),
          QuestionPair(
            left: 'One suit plus honor tiles',
            right: '混一色 — 3 Faan',
          ),
        ],
        explanation:
            'All Pongs is 對對糊, its all-Chow opposite is 平糊, four Kongs is 十八羅漢, and one suit with honors is 混一色.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Going for All Pongs, your 13 tiles are {{m3}}{{m3}}{{m3}} {{p7}}{{p7}}{{p7}} {{s1}}{{s1}}{{s1}} {{red}}{{red}}{{red}} {{east}}. Which tile completes the hand?',
        options: ['east', 'm3', 'p7', 's2'],
        correctIndex: 0,
        explanation:
            '{{east}} becomes the pair for the eyes; the other four sets are already triplets.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'All Pongs is 3 Faan and Mixed One Suit is 3 Faan. An All Pongs hand built from one suit plus honors scores how many Faan in total?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['6', 'six', '6 faan', 'six faan'],
        explanation:
            'The two patterns stack, so 3 + 3 = 6 Faan, safely under the 10-Faan cap.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A hand is four Pongs plus a pair. Can it also be scored as 平糊 (All Chows)?',
        options: [
          'Yes, if the hand is concealed',
          'Yes, if it is won by self-draw',
          'No — 平糊 needs four Chows and no triplets',
          'No — 平糊 needs honor tiles',
        ],
        correctIndex: 2,
        explanation:
            '平糊 requires four Chows with no Pong or Kong, so it can never combine with 對對糊.',
      ),
    ],
  ),

  Lesson(
    id: '5-2',
    stageId: 'stage5',
    title: 'Thirteen Orphans',
    subtitle: 'The legendary limit hand',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Thirteen Orphans (十三么) is the most legendary hand in mahjong! You need: one of each terminal and honor tile, plus one duplicate. A limit hand!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The 13 unique tiles: {{m1}}{{m9}}{{p1}}{{p9}}{{s1}}{{s9}}{{east}}{{south}}{{west}}{{north}}{{red}}{{green}}{{white}} — plus one more of any of these as the pair.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'This is a limit hand! In our rules, Thirteen Orphans is counted as 10 Faan (the maximum) - the same as all limit hands. Extremely rare but incredibly satisfying!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Strategy: If you start with 8+ different terminals/honors, consider going for it. But it\'s risky — you need very specific tiles!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['13', 'thirteen', '13 tiles'],
        question: 'How many unique tiles do you need for Thirteen Orphans?',
        options: ['10', '11', '12', '13'],
        correctIndex: 3,
        explanation:
            'You need all 13 different terminal and honor tiles, plus one duplicate.',
      ),
      QuizQuestion(
        question: 'Which tiles are used in Thirteen Orphans?',
        options: [
          'All 1s and 9s + all honors',
          'All suited tiles',
          'Only honor tiles',
          'Only terminals',
        ],
        correctIndex: 0,
        explanation:
            'Thirteen Orphans uses all 1s and 9s (terminals) from each suit, plus all 7 honor tiles.',
      ),
      QuizQuestion(
        question: 'Is Thirteen Orphans a limit hand?',
        options: [
          'No, it\'s 3 Faan',
          'No, it\'s 5 Faan',
          'Yes, maximum Faan',
          'Only if self-drawn',
        ],
        correctIndex: 2,
        explanation:
            'Thirteen Orphans is always a limit hand — maximum Faan regardless of other bonuses.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each part of Thirteen Orphans (十三么) to its count.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Terminal types in the set (1s and 9s)',
            right: '6',
          ),
          QuestionPair(left: 'Honor types in the set', right: '7'),
          QuestionPair(left: 'Types duplicated to make the pair', right: '1'),
        ],
        explanation:
            'Six terminals (1 and 9 of each suit) and seven honors make the 13 types, one of which is duplicated.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements about Thirteen Orphans (十三么) are correct?',
        options: [
          'It needs one of each of the 13 terminal and honor types',
          'One of those types is duplicated to form the pair',
          'It has no melds at all — no Chows, Pongs or Kongs',
          'It may include one Chow as long as the hand stays concealed',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            '十三么 is 13 single tiles plus one duplicate, so it contains no Chows, Pongs or Kongs.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Which of these tiles is NOT used in Thirteen Orphans (十三么)?',
        options: ['m5', 'm1', 'p9', 'white'],
        correctIndex: 0,
        explanation:
            'Only 1s, 9s and honor tiles qualify, so the middle tile {{m5}} never appears.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'How many tiles does a completed Thirteen Orphans (十三么) hand contain?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['14', 'fourteen', '14 tiles', 'fourteen tiles'],
        explanation:
            'Thirteen different types plus the duplicated tile make 14 tiles.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Your opponent declares a concealed Kong (暗槓). Which hand is allowed to rob it?',
        options: [
          'Any hand worth at least 3 Faan',
          'Only Thirteen Orphans (十三么)',
          'Only Full Flush (清一色)',
          'Only All Pongs (對對糊)',
        ],
        correctIndex: 1,
        explanation:
            '搶槓 normally only robs an added Kong, but 十三么 is the one hand that may rob a concealed Kong.',
      ),
    ],
  ),

  Lesson(
    id: '5-3',
    stageId: 'stage5',
    title: 'Full Flush',
    subtitle: 'One suit, no honors',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Full Flush (清一色) means your ENTIRE hand is one suit — no honor tiles at all! Worth 7 Faan. Very powerful!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: All Characters — {{m1}}{{m2}}{{m3}}{{m4}}{{m5}}{{m6}}{{m7}}{{m8}}{{m9}}{{m1}}{{m2}}{{m3}}{{m5}}{{m5}}. Pure Characters!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Compare: Mixed One Suit (混一色) = one suit + honors = 3 Faan. Full Flush (清一色) = one suit ONLY = 7 Faan. Much harder but much more rewarding!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Warning: Full Flush is obvious to opponents! If they see you only discarding other suits, they\'ll know what you\'re building and play defensively.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How much is Full Flush worth?',
        options: ['3 Faan', '5 Faan', '7 Faan', '10 Faan'],
        correctIndex: 2,
        explanation: 'Full Flush (清一色) is worth 7 Faan.',
      ),
      QuizQuestion(
        question: 'What is the difference between Mixed Suit and Full Flush?',
        options: [
          'Mixed allows 2 suits',
          'Full Flush has no honor tiles',
          'Mixed is worth more',
          'No difference',
        ],
        correctIndex: 1,
        explanation:
            'Mixed One Suit allows honor tiles alongside one suit (3 Faan). Full Flush is purely one suit with no honors (7 Faan).',
      ),
      QuizQuestion(
        question: 'What is the main risk of going for Full Flush?',
        options: [
          'It\'s not worth enough Faan',
          'Opponents can easily read your hand',
          'You can\'t self-draw',
          'You need too many tiles',
        ],
        correctIndex: 1,
        explanation:
            'When you discard all other suits, opponents can clearly see you\'re building a Full Flush and will avoid discarding your suit.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Your hand is a Full Flush (清一色) in Bamboo. Which of these tiles would break it?',
        options: ['m5', 's1', 's9', 's5'],
        correctIndex: 0,
        explanation:
            '清一色 uses exactly one suit with no honors, so any Character tile breaks the flush.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange these Character tiles into a Chow — Full Flush restricts the suit, not the meld shape.',
        options: const [],
        correctIndex: 0,
        tiles: const ['m2', 'm3', 'm4'],
        explanation:
            'A Chow is three consecutive tiles of one suit, so 2-3-4 of Characters is correct.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these hands are Full Flush (清一色)?',
        options: [
          '{{m1}}{{m2}}{{m3}} {{m4}}{{m5}}{{m6}} {{m7}}{{m8}}{{m9}} {{m5}}{{m5}}{{m5}} {{m9}}{{m9}}',
          '{{s2}}{{s3}}{{s4}} {{s5}}{{s6}}{{s7}} {{s7}}{{s8}}{{s9}} {{s1}}{{s1}}{{s1}} {{s9}}{{s9}}',
          '{{p1}}{{p2}}{{p3}} {{p4}}{{p5}}{{p6}} {{red}}{{red}}{{red}} {{p7}}{{p8}}{{p9}} {{p5}}{{p5}}',
          '{{east}}{{east}}{{east}} {{red}}{{red}}{{red}} {{white}}{{white}}{{white}} {{north}}{{north}}{{north}} {{south}}{{south}}',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'The first two are single-suit hands, while the third carries a Dragon triplet and the fourth is all honors (字一色).',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Full Flush is 7 Faan and All Pongs is 3 Faan. A one-suit All Pongs hand with no honors scores how many Faan?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['10', 'ten', '10 faan', 'ten faan'],
        explanation: '7 + 3 = 10 Faan, which lands exactly on the 10-Faan cap.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Does Full Flush (清一色) require a particular meld type?',
        options: [
          'Yes, it must be all Chows',
          'Yes, it must be all Pongs',
          'No — it only restricts the suit',
          'No — honor tiles are also allowed',
        ],
        correctIndex: 2,
        explanation:
            '清一色 is defined by suit alone, so Chows and Pongs can be mixed freely.',
      ),
    ],
  ),

  Lesson(
    id: '5-4',
    stageId: 'stage5',
    title: 'All Honors & All Terminals',
    subtitle: 'Extreme limit hands',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'All Honors (字一色) — every tile is a Wind or Dragon. Limit hand! Extremely rare since there are only 7 types of honor tiles.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'All Terminals (清么九) — every tile is a 1 or 9. No middle tiles, no honors. Also a limit hand! Only 6 types of terminals to work with.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'These are "dream hands" — incredibly rare but worth maximum points. You might play hundreds of games before seeing one!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'More achievable: Half Flush with All Pongs, or Mixed Terminals (混老頭) — terminals + honors, worth around 5-6 Faan.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is All Honors (字一色)?',
        options: [
          'All Winds only',
          'All Dragons only',
          'All Wind and Dragon tiles',
          'All suited tiles',
        ],
        correctIndex: 2,
        explanation:
            'All Honors means every tile in your hand is a Wind or Dragon tile.',
      ),
      QuizQuestion(
        question: 'Are All Honors and All Terminals limit hands?',
        options: [
          'Only All Honors',
          'Only All Terminals',
          'Both are limit hands',
          'Neither',
        ],
        correctIndex: 2,
        explanation:
            'Both All Honors and All Terminals are limit hands worth maximum Faan.',
      ),
      QuizQuestion(
        question: 'Which of these are terminals?',
        options: ['{{m1}}', '{{m5}}', '{{s9}}', '{{east}}'],
        correctIndex: 0,
        correctIndexes: [0, 2],
        type: QuizType.multiChoice,
        explanation:
            'Terminals are the 1s and 9s of each suited family. {{m5}} is a middle tile and {{east}} is an honor, not a terminal.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these tiles can appear in 清么九 (All Terminals)?',
        options: ['{{m1}}', '{{s5}}', '{{p9}}', '{{east}}', '{{m9}}'],
        correctIndex: 0,
        correctIndexes: [0, 2, 4],
        explanation:
            '清么九 uses only the 1s and 9s of the three suits — no middle tiles and no honors.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each limit hand to the tiles it allows.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: '字一色 (All Honors)',
            right: 'Winds and Dragons only',
          ),
          QuestionPair(
            left: '清么九 (All Terminals)',
            right: '1s and 9s only, no honors',
          ),
          QuestionPair(
            left: '清一色 (Full Flush)',
            right: 'One suit only, no honors',
          ),
          QuestionPair(
            left: '混一色 (Mixed One Suit)',
            right: 'One suit plus honors',
          ),
        ],
        explanation:
            'These four hands differ exactly in which tile groups are permitted.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'How many different tile types can appear in 清么九 (All Terminals)?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['6', 'six', '6 types', 'six types'],
        explanation:
            'Each suit contributes a 1 and a 9, so only six types qualify.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Which of these tiles could NOT appear in 字一色 (All Honors)?',
        options: ['east', 'red', 'm1', 'white'],
        correctIndex: 2,
        explanation:
            '字一色 is made only of Wind and Dragon tiles, so any suited tile is impossible.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            '{{m1}}{{m1}}{{m1}} {{m9}}{{m9}}{{m9}} {{p1}}{{p1}}{{p1}} {{s9}}{{s9}}{{s9}} {{p9}}{{p9}} — which hand is this?',
        options: [
          '清么九 (All Terminals)',
          '字一色 (All Honors)',
          '清一色 (Full Flush)',
          '混一色 (Mixed One Suit)',
        ],
        correctIndex: 0,
        explanation:
            'Every tile is a 1 or a 9 with no honors, which is exactly 清么九 — a 10-Faan limit hand.',
      ),
    ],
  ),

  Lesson(
    id: '5-5',
    stageId: 'stage5',
    title: 'Stage 5 Review',
    subtitle: 'Special hands mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Amazing! You now know the most important special hands. Let\'s review!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'All Pongs (3 Faan), Thirteen Orphans (limit), Full Flush (7 Faan), All Honors (limit), All Terminals (limit). These are the hands that make mahjong exciting!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which special hand is worth the LEAST Faan?',
        options: ['All Pongs', 'Thirteen Orphans', 'Full Flush', 'All Honors'],
        correctIndex: 0,
        explanation:
            'All Pongs is worth 3 Faan. Full Flush is 7 Faan. Thirteen Orphans and All Honors are limit hands (maximum).',
      ),
      QuizQuestion(
        question:
            'Which hand does NOT follow the standard 4 melds + 1 pair structure?',
        options: [
          'All Pongs',
          'Full Flush',
          'Thirteen Orphans',
          'Mixed One Suit',
        ],
        correctIndex: 2,
        explanation:
            'Thirteen Orphans requires one of each terminal and honor tile plus a duplicate — it breaks the standard structure.',
      ),
      QuizQuestion(
        question:
            'You have 9 different terminals and honors in your starting hand. What special hand should you consider?',
        options: ['All Pongs', 'Thirteen Orphans', 'Full Flush', 'All Honors'],
        correctIndex: 1,
        explanation:
            'With 9+ different terminals/honors, Thirteen Orphans is a strong possibility since you need all 13 types.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each special hand to what it requires.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Thirteen Orphans (十三么)',
            right: 'One of each of the 13 terminal and honor types',
          ),
          QuestionPair(
            left: 'All Pongs (對對糊)',
            right: 'Four triplets or Kongs plus a pair',
          ),
          QuestionPair(
            left: 'Full Flush (清一色)',
            right: 'A single suit with no honors',
          ),
          QuestionPair(
            left: '字一色 (All Honors)',
            right: 'Winds and Dragons only',
          ),
        ],
        explanation:
            'Each name maps to one defining condition: all 13 singles, all triplets, one suit, or honors only.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are limit hands counted as 10 Faan?',
        options: [
          '十三么 (Thirteen Orphans)',
          '字一色 (All Honors)',
          '清一色 (Full Flush)',
          '清么九 (All Terminals)',
          '對對糊 (All Pongs)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            '清一色 is 7 Faan and 對對糊 is 3; the other three are 例牌 scored at 10.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'A limit hand is won by self-draw. How much does each of the three opponents pay?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['64', 'sixty-four', 'sixty four', '64 each'],
        explanation:
            'At 10 Faan a self-draw costs each opponent 64, for 192 collected in total.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange these tiles into a Chow — the meld All Pongs forbids but Full Flush allows.',
        options: const [],
        correctIndex: 0,
        tiles: const ['s4', 's5', 's6'],
        explanation:
            'A Chow is three consecutive tiles of one suit, so 4-5-6 of Bamboo is correct.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A hand is four Pongs plus a pair, all in one suit with no honors. How many Faan does it score?',
        options: ['3 Faan', '7 Faan', '10 Faan', '6 Faan'],
        correctIndex: 2,
        explanation: '清一色 (7) + 對對糊 (3) = 10 Faan, which is the cap.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 6: Flowers & Kong (5 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '6-1',
    stageId: 'stage6',
    title: 'Flower Tile Basics',
    subtitle: 'Types, matching & replacement',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s dive deeper into Flowers! The 8 flowers are split into two groups: Seasons ({{f_spring}}{{f_summer}}{{f_autumn}}{{f_winter}}) and Plants ({{f_plum}}{{f_orchid}}{{f_chrys}}{{f_bamboo}}).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Each seat has matching flowers: East = Spring/Plum (#1), South = Summer/Orchid (#2), West = Autumn/Chrysanthemum (#3), North = Winter/Bamboo (#4).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When you draw a Flower, immediately declare it face-up and draw a replacement from the back of the wall. This can chain — if you draw another Flower, declare and draw again!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'One MATCHING flower (正花) = 1 Faan; non-matching flowers give 0 Faan (you still declare and replace). Collecting all four Seasons or all four Plants (一台花) = 2 Faan in total — the seat flower is not added on top of it.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Match each seat to its two flowers.',
        options: const [],
        correctIndex: 0,
        type: QuizType.matching,
        pairs: const [
          QuestionPair(left: 'East', right: 'Spring & Plum'),
          QuestionPair(left: 'South', right: 'Summer & Orchid'),
          QuestionPair(left: 'West', right: 'Autumn & Chrysanthemum'),
          QuestionPair(left: 'North', right: 'Winter & Bamboo'),
        ],
        explanation:
            'Each seat owns one season and one plant: East = Spring + Plum, South = Summer + Orchid, West = Autumn + Chrysanthemum, North = Winter + Bamboo.',
      ),
      QuizQuestion(
        question:
            'What happens if you draw a Flower during a replacement draw?',
        options: [
          'Keep it in hand',
          'Declare it and draw another replacement',
          'Discard it',
          'Give it to the dealer',
        ],
        correctIndex: 1,
        explanation:
            'If you draw a Flower during replacement, declare it and draw yet another replacement. This can chain!',
      ),
      QuizQuestion(
        question:
            'You are East seat and draw Spring (your flower) + Plum (your flower). How much Faan?',
        options: [
          '0 Faan',
          '1 Faan',
          '2 Faan (1 per matching flower)',
          '4 Faan',
        ],
        correctIndex: 2,
        explanation:
            'Standard rule: each matching flower (正花) = 1 Faan. East matching flowers are Spring+Plum, so 2 matching = 2 Faan. Non-matching flowers give 0 Faan.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question: 'Which of these is a Plant tile rather than a Season?',
        options: ['f_orchid', 'f_spring', 'f_summer', 'f_winter'],
        correctIndex: 0,
        explanation:
            'Orchid is one of the four Plants; Spring, Summer and Winter belong to the Seasons.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements about flower scoring are correct?',
        options: [
          'One matching seat flower is worth 1 Faan',
          'All four Seasons together (一台花) are worth 2 Faan in total',
          'A hand holding no flowers at all scores 無花 for 1 Faan',
          'Every flower you declare is worth 1 Faan',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'Only a matching seat flower scores 1 Faan; a complete 一台花 pays 2 in total, and a flowerless hand takes 無花 for 1.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'You hold all four Plants ({{f_plum}} {{f_orchid}} {{f_chrys}} {{f_bamboo}}). How many Faan does this 一台花 score in total?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['2', 'two', '2 faan', 'two faan'],
        explanation:
            'A complete set of four Seasons or four Plants is 2 Faan in total, and the seat flower is not added on top.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each flower number to the flower that carries it.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'Season #2', right: 'Summer'),
          QuestionPair(left: 'Plant #1', right: 'Plum'),
          QuestionPair(left: 'Season #4', right: 'Winter'),
          QuestionPair(left: 'Plant #4', right: 'Bamboo'),
        ],
        explanation:
            'Seasons and Plants are each numbered 1 to 4, so the second Season is Summer and the fourth Plant is Bamboo.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Put the four Season tiles in seat order: East, South, West, North.',
        options: const [],
        correctIndex: 0,
        tiles: const ['f_spring', 'f_summer', 'f_autumn', 'f_winter'],
        explanation:
            'Seasons run Spring, Summer, Autumn, Winter for East, South, West and North in that order.',
      ),
    ],
  ),

  Lesson(
    id: '6-2',
    stageId: 'stage6',
    title: 'Kong Declarations',
    subtitle: 'When and how to declare Kong',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s master Kong strategy! Remember the 3 types: Exposed Kong (明槓), Concealed Kong (暗槓), and Supplemental Kong (加槓).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Exposed Kong: Someone discards a tile and you have 3 of it. Call "Kong!" Reveal all 4 tiles face-up. Draw replacement.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Concealed Kong: You draw the 4th copy yourself. Declare it face-DOWN (opponents see it\'s a Kong but not which tile). Draw replacement.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Supplemental Kong: You already have an exposed Pong, then draw the 4th tile. Add it to the Pong to make a Kong. Draw replacement.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which Kong type keeps the tile identity hidden?',
        options: [
          'Exposed Kong',
          'Concealed Kong',
          'Supplemental Kong',
          'All show the tiles',
        ],
        correctIndex: 1,
        explanation:
            'Concealed Kong is placed face-down, hiding which tile it is from opponents.',
      ),
      QuizQuestion(
        question:
            'You have {{m3}}{{m3}}{{m3}} exposed as a Pong. You draw {{m3}}. What can you do?',
        options: [
          'Nothing special',
          'Declare Supplemental Kong',
          'Declare Concealed Kong',
          'Must discard it',
        ],
        correctIndex: 1,
        explanation:
            'Adding a 4th tile to an existing exposed Pong creates a Supplemental Kong.',
      ),
      QuizQuestion(
        question: 'After any Kong declaration, what do you do?',
        options: [
          'Discard immediately',
          'Draw a replacement tile',
          'Skip your turn',
          'The round ends',
        ],
        correctIndex: 1,
        explanation:
            'After declaring any type of Kong, you draw a replacement tile from the back of the wall.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Kong type to how it is formed.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: '明槓 (Exposed Kong)',
            right: 'Claim a discard while holding three copies',
          ),
          QuestionPair(
            left: '加槓 (Added Kong)',
            right: 'Add the fourth tile to your own exposed Pong',
          ),
          QuestionPair(
            left: '暗槓 (Concealed Kong)',
            right: 'Draw the fourth copy yourself and keep it face-down',
          ),
        ],
        explanation:
            'Exposed Kongs come from a discard, Added Kongs extend your own Pong, and Concealed Kongs are completed from your own draw.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You hold {{s5}}{{s5}}{{s5}}. Which discarded tile can you claim for an Exposed Kong?',
        options: ['s5', 's4', 'p5', 's6'],
        correctIndex: 0,
        explanation:
            'A Kong needs four identical tiles, so only the fourth {{s5}} can be claimed.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements about Kongs are correct?',
        options: [
          'A Kong counts as one meld of 3 tiles in hand structure but uses 4 physical tiles',
          'A Concealed Kong does not break 門前清',
          'A declared Kong adds 1 Faan by itself',
          'After any Kong you draw a replacement tile from the back of the wall',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'Kongs give a replacement draw and preserve 門前清 when concealed, but the Kong itself carries no Faan.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many physical tiles does one declared Kong use?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['4', 'four', '4 tiles', 'four tiles'],
        explanation:
            'A Kong is four copies of one tile, counted as a 3-tile meld when you read the hand.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You have three concealed {{p9}} in hand and draw the fourth. What is the correct declaration?',
        options: [
          'Concealed Kong: place it face-down, then draw a replacement',
          'Exposed Kong: turn all four tiles face-up',
          'Added Kong on your exposed Pong',
          'Discard the fourth copy',
        ],
        correctIndex: 0,
        explanation:
            'Completing a Kong from your own draw is a Concealed Kong, declared face-down with a replacement draw.',
      ),
    ],
  ),

  Lesson(
    id: '6-3',
    stageId: 'stage6',
    title: 'Kong on Kong (槓上槓)',
    subtitle: 'Chain Kongs & special wins',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'What if your Kong replacement tile lets you declare ANOTHER Kong? That\'s Kong on Kong (槓上槓)! You draw another replacement and continue.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Even more exciting: winning on a Kong replacement tile is called "Win on Kong" (槓上自摸), worth 1 Faan. Note: winning after two consecutive Kongs is "Kong-on-Kong Self-draw" (槓上槓自摸), which IS a limit hand (10 Faan). The Kong itself does not add Faan; only hand patterns (like All Pongs) do.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'There\'s also "Robbing the Kong" (搶槓): when someone declares a Supplemental Kong, if that tile completes YOUR hand, you can steal it to win!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Robbing the Kong is dramatic! The player thought they were getting a bonus, but instead they dealt into your winning hand. It counts as them dealing to you.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is "Win on Kong" (槓上自摸)?',
        options: [
          'Winning by declaring a Kong',
          'Winning on the replacement tile after a Kong',
          'Winning by robbing a Kong',
          'Having 4 Kongs',
        ],
        correctIndex: 1,
        explanation:
            'Win on Kong means your Kong replacement tile completes your winning hand.',
      ),
      QuizQuestion(
        question: 'When can you "Rob the Kong" (搶槓)?',
        options: [
          'When someone declares any Kong',
          'Only when someone declares a Supplemental Kong',
          'When someone declares a Concealed Kong',
          'Anytime',
        ],
        correctIndex: 1,
        explanation:
            'You can only Rob a Supplemental Kong (adding to an existing Pong) — not an Exposed Kong. The one exception is Thirteen Orphans, which may rob a Concealed Kong.',
      ),
      QuizQuestion(
        question: 'How is a robbed Kong paid?',
        options: [
          'The player who declared the Kong pays the whole self-draw amount alone',
          'Every opponent pays an equal share',
          'The dealer pays for the whole table',
          'Nothing extra is paid',
        ],
        correctIndex: 0,
        explanation:
            '搶槓當包自摸: the player whose Kong was robbed pays the full self-draw total by himself, as if he had packed the hand.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'The pattern 槓上自摸 (winning on the replacement tile after a Kong) is listed at how many Faan?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['1', 'one', '1 faan', 'one faan'],
        explanation: '槓上自摸 is a 1-Faan pattern on the Gary Faan list.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which statements about Kong chains and robbing are correct?',
        options: [
          'Winning after two consecutive Kongs (槓上槓自摸) is a limit hand at 10 Faan',
          '搶槓 normally applies to an Added Kong (加槓)',
          'Thirteen Orphans (十三么) may rob even a Concealed Kong',
          'You may rob an Exposed Kong claimed from a discard',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'A double-Kong self-draw is a limit hand, robbing normally targets an Added Kong, and only Thirteen Orphans may rob a Concealed Kong.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Kong term to what it means.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: '槓上自摸',
            right: 'Win on the replacement tile after one Kong',
          ),
          QuestionPair(
            left: '槓上槓自摸',
            right: 'Win after two consecutive Kongs, 10 Faan',
          ),
          QuestionPair(
            left: '搶槓',
            right: 'Win by taking the tile of someone\'s Added Kong',
          ),
        ],
        explanation:
            'One Kong replacement win is 1 Faan, two chained Kongs make the 10-Faan limit, and 搶槓 takes an Added Kong tile.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Your Kong replacement tile is the fourth copy of another tile you already hold three of. What happens next?',
        options: [
          'Declare a second Kong and draw another replacement',
          'Discard it and end your turn',
          'Return it and draw a normal tile instead',
          'You may only declare one Kong per turn',
        ],
        correctIndex: 0,
        explanation:
            'Kongs can chain: the new fourth copy allows another Kong, followed by another replacement draw.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You normally cannot rob a Concealed Kong. Which hand is the exception?',
        options: [
          'Thirteen Orphans (十三么)',
          'All Pongs (對對糊)',
          'Mixed One Suit (混一色)',
          'Pure One Suit (清一色)',
        ],
        correctIndex: 0,
        explanation:
            'The rules let Thirteen Orphans rob a Concealed Kong, which ordinary hands cannot do.',
      ),
    ],
  ),

  Lesson(
    id: '6-4',
    stageId: 'stage6',
    title: 'Kong Strategy',
    subtitle: 'When to Kong and when not to',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Should you always declare a Kong when you can? NO! Sometimes it\'s better to keep the 4th tile in hand. Let\'s learn when.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Declare Kong when: You want the replacement draw, you are going for All Pongs and need the Kong, or your hand needs the extra tile.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'DON\'T Kong when: The tile is useful in a sequence (e.g., you have {{m4}}{{m4}}{{m4}}{{m5}}{{m6}} — keeping {{m4}} in a sequence might be better!).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Also avoid Supplemental Kong when opponents might be close to winning — they could Rob your Kong! Read the table before declaring.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'You have {{s5}}{{s5}}{{s5}}{{s4}}{{s6}}. Should you Kong the {{s5}}?',
        options: [
          'Yes, always Kong',
          'No, {{s5}} is useful in the sequence {{s4}}{{s5}}{{s6}}',
          'Only if concealed',
          'Only in the first round',
        ],
        correctIndex: 1,
        explanation:
            'Keeping {{s5}} in the sequence {{s4}}{{s5}}{{s6}} gives you a complete meld. Kong-ing would break this.',
      ),
      QuizQuestion(
        question: 'When is Supplemental Kong risky?',
        options: [
          'When you\'re winning',
          'When opponents might be close to winning',
          'In the first round',
          'Never risky',
        ],
        correctIndex: 1,
        explanation:
            'Opponents can Rob your Supplemental Kong if the tile completes their hand. Risky when they seem close to winning!',
      ),
      QuizQuestion(
        question: 'What is the main benefit of declaring a Kong?',
        options: [
          'Extra replacement draw',
          'Opponents lose a turn',
          'You can discard 2 tiles',
          'The round ends',
        ],
        correctIndex: 0,
        explanation:
            'Kong gives you an extra replacement draw - a chance to get the tile you need. The Kong itself does NOT add Faan; only hand patterns (like All Pongs) do.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'You hold three {{p4}} plus {{p3}} and {{p5}}. Put the run tiles in ascending order to see the meld you keep by not Kong-ing.',
        options: const [],
        correctIndex: 0,
        tiles: const ['p3', 'p4', 'p5'],
        explanation:
            'Keeping {{p4}} inside {{p3}}{{p4}}{{p5}} gives a finished run, so the extra copy is not always worth a Kong.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each table situation to the better Kong decision.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Opponents look close to winning',
            right: 'Skip the Added Kong',
          ),
          QuestionPair(
            left: 'You are going for All Pongs',
            right: 'Kong, the meld is needed',
          ),
          QuestionPair(
            left: 'The fourth tile also fits a run you need',
            right: 'Keep it in hand',
          ),
        ],
        explanation:
            'A late Added Kong invites 搶槓, while a Kong that builds All Pongs or frees a useless tile is worth taking.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which are good reasons to declare a Kong?',
        options: [
          'You want the extra replacement draw',
          'Your hand is going for All Pongs (對對糊)',
          'The fourth tile is useless in any run or pair you could build',
          'You want to reveal more information to your opponents',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'Kong for the replacement draw, for All Pongs, or to shed a dead tile, never to give information away.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question: 'How many Faan does declaring a Kong add by itself?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['0', 'zero', 'none', '0 faan'],
        explanation:
            'A Kong has no Faan value of its own; only patterns such as 槓上自摸 or All Pongs score.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You are keeping your hand fully concealed for 門前清. Which Kong can you still declare without breaking it?',
        options: [
          'Concealed Kong (暗槓)',
          'Exposed Kong (明槓)',
          'Added Kong (加槓)',
          'Any Kong breaks 門前清',
        ],
        correctIndex: 0,
        explanation:
            'Only a Concealed Kong leaves 門前清 intact; claiming or adding to a meld breaks it.',
      ),
    ],
  ),

  Lesson(
    id: '6-5',
    stageId: 'stage6',
    title: 'Stage 6 Review',
    subtitle: 'Flowers & Kong mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You\'ve mastered Flowers and Kongs! These add depth and excitement to the game. Let\'s do a final review.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Key takeaways: Flowers = free Faan, Kong = extra replacement draw (useful for patterns like All Pongs) but with risks. Kong itself does NOT add Faan. Always consider the game situation before declaring!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'You\'re West seat. Which flowers are yours?',
        options: [
          'Spring & Plum',
          'Summer & Orchid',
          'Autumn & Chrysanthemum',
          'Winter & Bamboo',
        ],
        correctIndex: 2,
        explanation:
            'West seat matches Autumn (Season #3) and Chrysanthemum (Plant #3).',
      ),
      QuizQuestion(
        question:
            'An opponent declares Supplemental Kong with {{red}}. You need {{red}} to win. What can you do?',
        options: [
          'Nothing',
          'Rob the Kong to win',
          'Call Pong instead',
          'Ask for a redeal',
        ],
        correctIndex: 1,
        explanation:
            'You can Rob the Supplemental Kong! Declare your win and take the tile.',
      ),
      QuizQuestion(
        question: 'Which gives the most information to opponents?',
        options: [
          'Concealed Kong',
          'Exposed Kong',
          'Supplemental Kong',
          'They all reveal the same',
        ],
        correctIndex: 1,
        explanation:
            'Exposed Kong shows all 4 tiles face-up, revealing the most information. Concealed Kong is face-down.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which review statements are correct?',
        options: [
          'All four Seasons (一台花) score 2 Faan in total',
          'The matching seat flower is not added on top of that 2 Faan',
          'A declared Kong adds 1 Faan by itself',
          '搶槓 can rob an Added Kong (加槓)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            '一台花 pays 2 in total without stacking the seat flower, and 搶槓 targets an Added Kong, but a Kong alone is worth 0 Faan.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each term to its scoring or rule summary.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: '一台花',
            right: 'Four Seasons or four Plants, 2 Faan in total',
          ),
          QuestionPair(
            left: '槓上自摸',
            right: 'Win on the Kong replacement tile, 1 Faan',
          ),
          QuestionPair(
            left: '十八羅漢',
            right: 'Four Kongs, a limit hand at 10 Faan',
          ),
          QuestionPair(left: '搶槓', right: 'Win by robbing an Added Kong'),
        ],
        explanation:
            'These are the Stage 6 headline values: 2 for 一台花, 1 for 槓上自摸, 10 for 十八羅漢 and 搶槓 on an Added Kong.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            '十八羅漢 (four Kongs) is a limit hand. How many Faan does it score?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['10', 'ten', '10 faan', 'ten faan'],
        explanation:
            'Every limit hand including 十八羅漢 is scored at the 10-Faan cap.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You already hold {{f_plum}} {{f_orchid}} {{f_chrys}}. Which tile completes 一台花?',
        options: ['f_bamboo', 'f_spring', 'f_winter', 'f_summer'],
        correctIndex: 0,
        explanation:
            'The Plants are Plum, Orchid, Chrysanthemum and Bamboo, so Bamboo completes the set.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You are East and hold all four Seasons, which include your seat flower Spring. How many Faan do your flowers score?',
        options: ['1 Faan', '2 Faan', '3 Faan', '4 Faan'],
        correctIndex: 1,
        explanation:
            '一台花 is 2 Faan in total and the seat flower inside the set is not added again.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 7: Scoring Rules (6 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '7-1',
    stageId: 'stage7',
    title: 'Faan Chart Overview',
    subtitle: 'Common Faan values at a glance',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Time to master scoring! In Cantonese Mahjong, Faan determines how much the winner gets paid. More Faan = more money (on a fixed Faan-to-money table)!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Common Faan values: All Chows (1), Self-draw (1), No Flowers (1), Concealed Hand (1), Dragon Pong (1), Seat/Prevailing Wind (1 each).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Medium Faan: All Pongs (3), Mixed One Suit (3), Small Three Dragons (5), Small Four Winds (6).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'High Faan: Full Flush (7), Big Three Dragons (大三元) at 8. Then the limit hands (例牌) all pay the maximum 10 Faan: Thirteen Orphans (十三么), All Honors (字一色), All Terminals (清么九), Big and Small Four Winds, Nine Gates (九子連環) and Big Flower Win (大花糊).',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which is worth MORE Faan?',
        options: [
          'All Chows (1)',
          'All Pongs (3)',
          'Self-draw (1)',
          'No Flowers (1)',
        ],
        correctIndex: 1,
        explanation:
            'All Pongs is worth 3 Faan, more than All Chows, Self-draw, or No Flowers (each 1 Faan).',
      ),
      QuizQuestion(
        question: 'How much is Full Flush (清一色) worth?',
        options: ['3 Faan', '5 Faan', '7 Faan', '10 Faan'],
        correctIndex: 2,
        explanation: 'Full Flush is worth 7 Faan.',
      ),
      QuizQuestion(
        question: 'What happens to payment as Faan increases?',
        options: [
          'It doubles each time',
          'It rises on a fixed table (8,16,24,32,48,64,96,128)',
          'It stays the same',
          'It decreases',
        ],
        correctIndex: 1,
        explanation:
            'Payment rises with Faan but NOT by doubling. The common Hong Kong table uses 3F=\$8, 4F=\$16, 5F=\$24, 6F=\$32, 7F=\$48, 8F=\$64, 9F=\$96, 10F=\$128 (the limit).',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each hand to its Faan value in the chart.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'All Chows (平糊)', right: '1 Faan'),
          QuestionPair(left: 'All Pongs (對對糊)', right: '3 Faan'),
          QuestionPair(left: 'Small Three Dragons (小三元)', right: '5 Faan'),
          QuestionPair(left: 'Full Flush (清一色)', right: '7 Faan'),
        ],
        explanation:
            'The chart gives 平糊 1, 對對糊 3, 小三元 5 once its two Dragon Pongs are counted, and 清一色 7.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are worth exactly 1 Faan? (Select all that apply)',
        options: [
          'Self-draw (自摸)',
          'Concealed hand (門前清)',
          'No Flowers (無花)',
          'All Pongs (對對糊)',
          'Full Flush (清一色)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            '自摸, 門前清 and 無花 sit in the 1-Faan block, while 對對糊 is 3 Faan and 清一色 is 7.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are 3-Faan hands? (Select all that apply)',
        options: [
          'Mixed One Suit (混一色)',
          'All Pongs (對對糊)',
          'Small Flower Win (小花糊, seven flowers)',
          'All Chows (平糊)',
          'Full Flush (清一色)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            '混一色, 對對糊 and 小花糊 are all 3 Faan, while 平糊 is 1 and 清一色 is 7.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'A complete set of four Seasons (一台花) is worth how many Faan in total?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['2', 'two', '2 faan', 'two faan'],
        explanation:
            '一台花 is scored as 2 Faan as a whole, and the matching seat flower is not added on top of that.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Which of these tiles could never appear in a Full Flush (清一色) hand?',
        options: ['p5', 'm5', 's5', 'red'],
        correctIndex: 3,
        explanation:
            '清一色 is one suit with no honors, so any Dragon tile is impossible in it.',
      ),
    ],
  ),

  Lesson(
    id: '7-2',
    stageId: 'stage7',
    title: 'Payment Calculation',
    subtitle: 'Base points & multipliers',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Payment in Cantonese Mahjong uses a fixed Faan-to-money table. It does NOT double each Faan - the common table is: 3F=\$8, 4F=\$16, 5F=\$24, 6F=\$32, 7F=\$48, 8F=\$64, 9F=\$96, 10F=\$128 (limit).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Common fixed table: 3F=\$8, 4F=\$16, 5F=\$24, 6F=\$32, 7F=\$48, 8F=\$64, 9F=\$96, 10F=\$128 (the cap). Payment rises steadily - NOT by doubling per Faan!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Who pays? (Half-fire / 半銃 system) If you win by discard: the DISCARDER pays the FULL amount. If you self-draw: each of the 3 opponents pays HALF the amount (so you collect 1.5x total).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: 3-Faan = \$8. By discard: discarder pays the FULL \$8. By self-draw: each of 3 opponents pays HALF (\$4), so you collect \$4 × 3 = \$12 total. Self-draw collects from all 3 but at half rate each.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'You win with 4 Faan by claiming a discard. Who pays?',
        options: [
          'All 3 opponents pay equally',
          'Only the discarder pays the full amount',
          'Discarder pays full, others pay half',
          'The dealer pays',
        ],
        correctIndex: 1,
        explanation:
            'Half-fire system: by discard, only the discarder pays - the FULL amount. The other two players pay nothing.',
      ),
      QuizQuestion(
        question:
            'You win with 3 Faan by self-draw. How much do you collect total?',
        options: [
          '\$8 (from one player)',
          '\$24 (\$8 × 3 full)',
          '\$12 (\$4 × 3 half)',
          '\$4 (from one player)',
        ],
        correctIndex: 2,
        explanation:
            'Half-fire self-draw: each of 3 opponents pays HALF. 3F=\$8, half=\$4, so \$4 × 3 = \$12 total.',
      ),
      QuizQuestion(
        question:
            'Going from 3 Faan to 5 Faan, how does payment change on the common table?',
        options: [
          '\$8 -> \$32 (doubles twice)',
          '\$8 -> \$24 (rises on the fixed table)',
          '\$8 -> \$16 (adds \$4)',
          'No change',
        ],
        correctIndex: 1,
        explanation:
            'Fixed table: 3F=\$8, 4F=\$16, 5F=\$24. Payment rises steadily, it does NOT double per Faan.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'You win a 5-Faan hand on a discard. How much does the discarder pay?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['24', r'$24', 'twenty-four', 'twenty four'],
        explanation:
            'The table sets 5 Faan at 24, and on a discard the discarder pays that full amount.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these statements about the 半銃制 table are true? (Select all that apply)',
        options: [
          '3 Faan by discard pays 8',
          '6 Faan by self-draw collects 48 in total',
          '4 Faan by discard pays 32',
          'Every extra Faan doubles the payout',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            '3 Faan pays 8 and 6 Faan self-draw is 16 from each of three players, while 4 Faan pays 16 and the table never doubles.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each Faan value to what the discarder pays.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: '3 Faan', right: '8'),
          QuestionPair(left: '4 Faan', right: '16'),
          QuestionPair(left: '5 Faan', right: '24'),
          QuestionPair(left: '6 Faan', right: '32'),
        ],
        explanation:
            'The discard column of the table runs 8, 16, 24, 32 for 3 to 6 Faan.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You self-draw a 7-Faan hand. What does each opponent pay, and what do you collect in total?',
        options: [
          '24 each, 72 in total',
          '48 each, 144 in total',
          '16 each, 48 in total',
          '24 each, 96 in total',
        ],
        correctIndex: 0,
        explanation:
            '7 Faan is 48 on a discard, so half is 24 from each of three players for 72 in total.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Three opponents each pay you 32 on a self-draw. How many Faan was your hand?',
        options: ['6 Faan', '7 Faan', '8 Faan', '10 Faan'],
        correctIndex: 2,
        explanation:
            '32 each is half of 64, and the table pays 64 on a discard at 8 Faan.',
      ),
    ],
  ),

  Lesson(
    id: '7-3',
    stageId: 'stage7',
    title: 'Stacking Faan',
    subtitle: 'Combining multiple bonuses',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Faan from different sources stack! A hand can have multiple Faan sources added together.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: Mixed One Suit (3) + Dragon Pong (1) + Self-draw (1) + 2 Flowers (2) = 7 Faan total! That\'s \$128!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'But some Faan are exclusive — you can\'t have both All Chows AND All Pongs (impossible!). Or both Full Flush AND Mixed Suit.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Strategy: When building your hand, count potential Faan early. Aim for combinations that stack well together!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'All Pongs (3) + Dragon Pong (1) + Self-draw (1) = ?',
        options: ['3 Faan', '4 Faan', '5 Faan', '6 Faan'],
        correctIndex: 2,
        explanation: '3 + 1 + 1 = 5 Faan total. Different Faan sources stack!',
      ),
      QuizQuestion(
        question: 'Can you have both All Chows and All Pongs?',
        options: [
          'Yes',
          'No, they are mutually exclusive',
          'Only if concealed',
          'Only with self-draw',
        ],
        correctIndex: 1,
        explanation:
            'Impossible! A hand is either all sequences (All Chows) or all triplets (All Pongs), never both.',
      ),
      QuizQuestion(
        question:
            'Mixed One Suit (3) + Seat Wind Pong (1) + Prevailing Wind Pong (1) + Self-draw (1) = ?',
        options: ['3 Faan', '5 Faan', '6 Faan', '7 Faan'],
        correctIndex: 2,
        explanation: '3 + 1 + 1 + 1 = 6 Faan. Multiple small bonuses add up!',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Mixed One Suit (3) + All Pongs (3) + one seat flower (1): how many Faan is that in total?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['7', 'seven', '7 faan', 'seven faan'],
        explanation:
            'The three sources stack to 3 + 3 + 1 = 7 Faan, which pays 48 on a discard.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these pairs can never be scored together in one hand? (Select all that apply)',
        options: [
          'Full Flush (清一色) and Mixed One Suit (混一色)',
          'All Honors (字一色) and Full Flush (清一色)',
          'All Chows (平糊) and Concealed Hand (門前清)',
          'Mixed One Suit (混一色) and All Pongs (對對糊)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            '清一色 allows no honors while 混一色 needs them, and 字一色 is all honors while 清一色 is all one suit.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each stacked combination to its total Faan.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: 'All Chows + self-draw', right: '2 Faan'),
          QuestionPair(left: 'All Pongs + self-draw', right: '4 Faan'),
          QuestionPair(
            left: 'Mixed One Suit + Dragon Pong + self-draw',
            right: '5 Faan',
          ),
          QuestionPair(left: 'Full Flush + self-draw', right: '8 Faan'),
        ],
        explanation:
            'The sources add up to 1 + 1, 3 + 1, 3 + 1 + 1 and 7 + 1, giving 2, 4, 5 and 8 Faan.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these hands reach the 3-Faan minimum to win? (Select all that apply)',
        options: [
          'All Chows + self-draw + concealed hand',
          'One Dragon Pong + self-draw',
          'All Pongs with no other bonus',
          '一台花 + self-draw',
        ],
        correctIndex: 0,
        correctIndexes: [0, 2, 3],
        explanation:
            'The three winners total 3, 3 and 3 Faan, while one Dragon Pong plus self-draw is only 2 and falls short.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange the four Season tiles in their numbered order to form the complete set called 一台花.',
        options: const [],
        correctIndex: 0,
        tiles: const ['f_spring', 'f_summer', 'f_autumn', 'f_winter'],
        explanation:
            'Spring to Winter is 1 to 4, and the complete set of four Seasons is scored as one 2-Faan 一台花.',
      ),
    ],
  ),

  Lesson(
    id: '7-4',
    stageId: 'stage7',
    title: 'Limit Hands & Maximum',
    subtitle: 'The cap on scoring',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The maximum (limit) is 10 Faan. Once you hit 10 Faan, extra Faan don\'t increase payment further.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'There are 12 automatic limit hands (例牌), all counted as 10 Faan (the maximum): All Honors (字一色), Small Four Winds (小四喜), Big Four Winds (大四喜), All Concealed Pungs (坎坎糊), Eighteen Arhats (十八羅漢), All Terminals (清么九), Heavenly Hand (天糊), Earthly Hand (地糊), Thirteen Orphans (十三么), Kong-on-Kong Self-draw (槓上槓自摸), Nine Gates (九子連環), Big Flower Win (大花糊).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Heavenly Hand (天糊): The dealer wins on their initial 14 tiles! Earthly Hand (地糊): Non-dealer wins on their first draw. Both are instant limit!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'On the common table, 10 Faan = \$128 is the cap. Whether you have 10 Faan or 13 Faan, payment is the same \$128. But the bragging rights differ!',
      ),
    ],
    questions: [
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['10', 'ten', '10 faan'],
        question: 'What is the Faan limit?',
        options: ['5 Faan', '8 Faan', '10 Faan', '13 Faan'],
        correctIndex: 2,
        explanation:
            'The limit is 10 Faan. Once you hit 10 Faan, extra Faan don\'t increase payment further.',
      ),
      QuizQuestion(
        question: 'What is a Heavenly Hand (天糊)?',
        options: [
          'Winning with all honor tiles',
          'Dealer wins on initial 14 tiles',
          'Winning by robbing a Kong',
          'Getting all 8 flowers',
        ],
        correctIndex: 1,
        explanation:
            'Heavenly Hand means the dealer\'s initial 14 tiles already form a winning hand. Instant limit!',
      ),
      QuizQuestion(
        question:
            'At a 10-Faan limit, what happens if your hand counts 12 Faan?',
        options: [
          'Pays double',
          'Pays the same as 10 Faan (the limit)',
          'Pays less',
          'Disqualified',
        ],
        correctIndex: 1,
        explanation:
            'Once you hit the 10-Faan limit, extra Faan don\'t increase payment. 12 Faan pays the same as 10 Faan.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are NOT limit (例牌) hands? (Select all that apply)',
        options: [
          'Large Three Dragons (大三元) — 8 Faan in total',
          'Thirteen Orphans (十三么)',
          'Full Flush (清一色) — 7 Faan',
          'Heavenly Hand (天糊)',
          'Big Flower Win (大花糊)',
        ],
        correctIndex: 0,
        correctIndexes: [0, 2],
        explanation:
            '大三元 is 5 Faan plus its three Dragon Pongs for 8, and 清一色 is 7, so neither is one of the 10-Faan limit hands.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'How many limit (例牌) hands does the reference chart list, all of them counting as 10 Faan?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['12', 'twelve', '12 hands', 'twelve hands'],
        explanation:
            'The chart lists twelve 例牌 hands, and each one is scored as exactly 10 Faan regardless of its shape.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each limit hand to what it means.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Earthly Hand (地糊)',
            right: 'Non-dealer wins East\'s very first discard',
          ),
          QuestionPair(
            left: 'Eighteen Arhats (十八羅漢)',
            right: 'Four Kongs in one hand',
          ),
          QuestionPair(
            left: 'All Honors (字一色)',
            right: 'Every tile is a Wind or Dragon',
          ),
          QuestionPair(
            left: 'Big Flower Win (大花糊)',
            right: 'All eight Flower tiles drawn',
          ),
        ],
        explanation:
            'All four are 例牌 hands, so each one is scored as exactly 10 Faan no matter how many bonuses it would otherwise collect.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Which of these tiles could NOT appear in an All Terminals (清么九) hand?',
        options: ['m1', 's9', 'm5', 'p9'],
        correctIndex: 2,
        explanation: '清么九 uses only 1s and 9s, so a 5 is impossible in it.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A limit hand pays 128 on a discard. How much more is that than a 9-Faan hand?',
        options: ['16', '24', '32', '64'],
        correctIndex: 2,
        explanation:
            'The table pays 96 at 9 Faan and 128 at the 10-Faan cap, a difference of 32.',
      ),
    ],
  ),

  Lesson(
    id: '7-5',
    stageId: 'stage7',
    title: 'Dealer Rotation',
    subtitle: 'East wind & the dealer turn',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'In Hong Kong Cantonese Mahjong, the dealer (East) has NO special payment bonus. Whether dealer or not, winners and payers follow the same half-fire rules.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Dealer rotation: If East wins (by discard or self-draw), they stay as dealer for the next hand (連莊). If East does not win, the dealer position rotates clockwise to the next player.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'A full game = 4 rounds (East, South, West, North). Each round has at least 4 hands (one per dealer). Minimum 16 hands per full game!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Being dealer is still important: you get the first draw and you keep the dealer seat as long as you win. But there is no extra 50% payment - that rule does NOT apply in standard Hong Kong play.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What happens when the dealer wins?',
        options: [
          'Dealer rotates anyway',
          'Dealer stays (連莊)',
          'Game ends',
          'Everyone pays double',
        ],
        correctIndex: 1,
        explanation:
            'When the dealer wins, they remain as dealer for the next hand.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        acceptedAnswers: ['4', 'four', '4 rounds'],
        question: 'How many rounds in a full game?',
        options: ['1', '2', '4', '8'],
        correctIndex: 2,
        explanation:
            'A full game has 4 rounds: East, South, West, and North round.',
      ),
      QuizQuestion(
        question:
            'Does the dealer get a payment bonus in Hong Kong Cantonese Mahjong?',
        options: [
          'Yes, +50%',
          'Yes, double',
          'No, dealer pays/receives the same as others',
          'Only when self-drawing',
        ],
        correctIndex: 2,
        explanation:
            'In standard Hong Kong Cantonese Mahjong, the dealer has NO payment bonus. Payment follows the half-fire rules regardless of dealer status.',
      ),
      QuizQuestion(
        question: 'What happens to the dealer on a draw (washout/流局)?',
        options: [
          'Dealer keeps the seat (連莊)',
          'Dealer rotates - the deal passes on',
          'Dealer pays a penalty',
          'The game ends',
        ],
        correctIndex: 1,
        explanation:
            'On a draw, the dealer does NOT keep the seat - the deal rotates. This applies even at the last hand of North round.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these are true about the dealer seat and the round structure? (Select all that apply)',
        options: [
          'East is the prevailing wind during the East round',
          'A full game of four rounds is at least 16 hands',
          'Every seat gets at least one dealer hand in each round',
          'The dealer\'s winning hand counts double Faan',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 2],
        explanation:
            'Each round carries its own prevailing wind, four dealer hands make 16 in a full game, and the dealer gets no Faan bonus.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each term to its meaning.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: '一圈 (a round)',
            right: 'Four dealer hands, one per seat',
          ),
          QuestionPair(
            left: '四圈 (a full game)',
            right: 'East, South, West and North rounds',
          ),
          QuestionPair(left: '莊家', right: 'The dealer, seated East'),
          QuestionPair(left: '閒家', right: 'Any of the three non-dealer seats'),
        ],
        explanation:
            'A round is one pass of the deal through all four seats, and four such rounds make a full game.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Four rounds with at least four hands each: what is the minimum number of hands in a full game?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['16', 'sixteen', '16 hands'],
        explanation:
            'Four rounds times at least four dealer hands each gives a minimum of 16 hands.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You are East (the dealer) and a non-dealer self-draws an 8-Faan hand. How much do you pay?',
        options: ['16', '32', '48', '64'],
        correctIndex: 1,
        explanation:
            '8 Faan is 64 on a discard, so every opponent including the dealer pays half, 32, with no dealer surcharge.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'Arrange the four round winds in the order the rounds are played.',
        options: const [],
        correctIndex: 0,
        tiles: const ['east', 'south', 'west', 'north'],
        explanation:
            'A full game runs East, South, West and North round, one round for each prevailing wind.',
      ),
    ],
  ),

  Lesson(
    id: '7-6',
    stageId: 'stage7',
    title: 'Stage 7 Review',
    subtitle: 'Scoring mastery check',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You now understand the full scoring system! Faan → Payment → Who pays. Let\'s test your calculation skills!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: Faan stack, payment uses a fixed table (NOT doubling), self-draw = 3 opponents each pay half, discard = discarder pays full only, and there\'s a table limit.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Full Flush (7) + Self-draw (1) = ? Faan',
        options: ['7 Faan', '8 Faan', '9 Faan', '10 Faan'],
        correctIndex: 1,
        explanation:
            '7 + 1 = 8 Faan. Two more Faan would hit the 10-Faan limit!',
      ),
      QuizQuestion(
        question:
            'You win 6 Faan by discard. Using the common table, how much does the discarder pay?',
        options: ['\$24', '\$32', '\$48', '\$128'],
        correctIndex: 1,
        explanation:
            'Common table: 6F=\$32. By discard the discarder pays the FULL \$32 (others pay nothing in half-fire).',
      ),
      QuizQuestion(
        question: 'Why is self-draw still profitable even at half rate each?',
        options: [
          'You collect from all 3 opponents (1.5x total)',
          'It gives more Faan',
          'Dealer bonus',
          'Extra turn',
        ],
        correctIndex: 0,
        explanation:
            'Half-fire self-draw: 3 opponents each pay half, totaling 1.5x the base. Discard: only the discarder pays full (1x).',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Which of these payment statements are correct? (Select all that apply)',
        options: [
          '3 Faan by discard: the discarder pays 8',
          '5 Faan by self-draw: 12 from each opponent, 36 in total',
          '7 Faan by discard: the discarder pays 56',
          '9 Faan by self-draw: 48 from each opponent',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'The table pays 8 at 3 Faan and half of 24 from each player at 5 Faan, while 7 Faan pays 48, not 56.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'You self-draw a 6-Faan hand. How much do you collect in total?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['48', r'$48', 'forty-eight', 'forty eight'],
        explanation:
            '6 Faan is 32 on a discard, so each opponent pays 16 and three of them make 48 in total.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Full Flush (7) + Concealed Hand (1) + one seat flower (1) is 9 Faan and is won on a discard. What does the discarder pay?',
        options: ['64', '96', '128', '48'],
        correctIndex: 1,
        explanation:
            'The sources stack to 7 + 1 + 1 = 9 Faan, and the table pays 96 on a discard.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question:
            'Match each Faan value to the total you collect on a self-draw.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(left: '4 Faan', right: '24'),
          QuestionPair(left: '6 Faan', right: '48'),
          QuestionPair(left: '8 Faan', right: '96'),
          QuestionPair(left: '10 Faan', right: '192'),
        ],
        explanation:
            'Each of the three opponents pays half of 16, 32, 64 and 128, giving totals of 24, 48, 96 and 192.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'A hand counts 12 Faan and is won by self-draw. What does each opponent pay?',
        options: ['48 each', '64 each', '96 each', '128 each'],
        correctIndex: 1,
        explanation:
            'The 12 Faan is capped at 10, whose 128 discard payment is split into 64 from each opponent.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 8: Basic Tactics (6 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '8-1',
    stageId: 'stage8',
    title: 'Reading Discards',
    subtitle: 'What opponents\' discards reveal',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The discard pile is your crystal ball! Every tile an opponent throws tells you something about their hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'If someone discards {{m1}}{{m9}} early, they probably don\'t want Characters terminals. If they keep discarding all suits EXCEPT Bamboo, they might be building a Bamboo flush!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Key principle: Early discards of a suit suggest they DON\'T need that suit. Late discards of honors suggest they\'re not collecting them.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Watch for patterns! If someone suddenly stops discarding a suit they were throwing before, they might have picked up useful tiles in that suit.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'An opponent discards {{p2}}{{p5}}{{p8}} in their first 3 turns. What can you infer?',
        options: [
          'They\'re building Circles',
          'They probably don\'t need Circles',
          'They\'re going for All Honors',
          'Nothing useful',
        ],
        correctIndex: 1,
        explanation:
            'Discarding multiple Circles early strongly suggests they don\'t need that suit.',
      ),
      QuizQuestion(
        question:
            'An opponent has discarded no Bamboo tiles all game. What might they be doing?',
        options: [
          'They have no Bamboo',
          'They might be building a Bamboo flush',
          'They\'re going for All Honors',
          'They\'re playing randomly',
        ],
        correctIndex: 1,
        explanation:
            'Keeping all Bamboo tiles suggests they might be building a Bamboo flush (Mixed or Full).',
      ),
      QuizQuestion(
        question: 'When is a discard MOST informative?',
        options: [
          'First 3 turns',
          'Middle of the game',
          'Last 3 turns',
          'All equally informative',
        ],
        correctIndex: 0,
        explanation:
            'Early discards are most informative because players discard tiles they definitely don\'t need first.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'An opponent discards {{east}} on their first turn. Which conclusions are reasonable?',
        options: [
          'They are unlikely to be collecting honour tiles',
          '{{east}} is safe to discard against them for the rest of this rotation',
          'They are definitely building a single-suit flush',
          'They no longer hold any honour tiles',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'An early honour discard says little about suit shape, but it does mean they cannot use that honour against you this rotation.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'An opponent throws {{s1}}, {{s5}} and {{s9}} in their first three turns but keeps every Dot tile. Which suit are they most likely collecting?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['circles', 'circle', 'dots', 'dot', 'pins', 'pin'],
        explanation:
            'Throwing Bamboo at every rank early says Bamboo is not their suit, so the suit they never touch is the likely target.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each discard pattern to the most likely reading.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Throws {{p1}} and {{p9}} on turn 1',
            right: 'Circles terminals are not needed',
          ),
          QuestionPair(
            left: 'Discards every Character drawn, turn after turn',
            right: 'Characters are not their suit',
          ),
          QuestionPair(
            left: 'Throws honours on every early turn',
            right: 'Not collecting honour tiles',
          ),
          QuestionPair(
            left: 'Suddenly stops discarding Bamboo',
            right: 'May have picked up Bamboo',
          ),
        ],
        explanation:
            'Early discards reveal what a hand does not want, while a sudden change of pattern reveals what it has started to collect.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'Four early discards from the same opponent are shown. Which one is the strongest evidence that they are avoiding the middle of that suit?',
        options: ['s5', 'east', 'p1', 'm9'],
        correctIndex: 0,
        explanation:
            'A middle tile is the most useful tile in its suit, so throwing it early is the clearest sign the suit is unwanted.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'An opponent who kept every honour tile for ten turns now discards {{south}}. What does this most likely mean?',
        options: [
          'They have given up on an honour-based plan',
          'They are collecting honours harder than before',
          'They have no hand at all',
          'Their hand is already complete',
        ],
        correctIndex: 0,
        explanation:
            'A late honour discard usually means the honour plan was dropped once the hand took its real shape.',
      ),
    ],
  ),

  Lesson(
    id: '8-2',
    stageId: 'stage8',
    title: 'Safe Tile Theory',
    subtitle: 'Minimizing deal-in risk',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'A "safe tile" is one unlikely to help opponents win. The safest tiles are ones already discarded by the player you\'re worried about - BUT only within the SAME turn-rotation!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Why? If they threw {{east}} this rotation, they can\'t need {{east}} for a Pong right now. That tile is absolutely safe against them - until they draw again!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Once an opponent draws a new tile, their previous discard is no longer guaranteed safe. It becomes only RELATIVELY safe - they might have picked up a tile that now pairs with it. Re-assess every rotation!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Other safe tiles: tiles that multiple opponents have discarded, tiles where all 4 copies are visible, and tiles adjacent to their discards. Dangerous tiles: fresh tiles (never seen before), middle tiles (4,5,6) in late game.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'An opponent discarded {{m5}} earlier this rotation. How safe is {{m5}} against them right now?',
        options: [
          'Absolutely safe (this rotation)',
          'Relatively safe only',
          'Dangerous',
          'Unknown',
        ],
        correctIndex: 0,
        explanation:
            'Within the same rotation (before they draw again), a tile they discarded is absolutely safe - they cannot need it for a Pong or Win.',
      ),
      QuizQuestion(
        question:
            'An opponent discarded {{m5}} two turns ago, and has since drawn twice. How safe is {{m5}} now?',
        options: [
          'Still absolutely safe',
          'Only relatively safe',
          'Completely dangerous',
          'Cannot be discarded',
        ],
        correctIndex: 1,
        explanation:
            'Once the opponent has drawn again, their old discard is no longer guaranteed safe - it becomes only relatively safe. Their hand may have changed.',
      ),
      QuizQuestion(
        question: 'Which tile is most dangerous in late game?',
        options: [
          'A tile 3 copies are visible',
          'A tile the opponent discarded',
          'A fresh middle tile never seen',
          'A terminal tile',
        ],
        correctIndex: 2,
        explanation:
            'Fresh middle tiles (4,5,6) connect to the most sequences and haven\'t been seen — maximum danger!',
      ),
      QuizQuestion(
        question: 'Rank these from safest to most dangerous to discard',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['east', 'p1', 'm5'],
        explanation:
            'Previously discarded honor (safest) → Terminal tile (moderate) → Fresh middle tile (most dangerous).',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these make a tile safer to discard?',
        options: [
          'All four copies are already visible on the table',
          'The opponent you fear discarded it earlier this rotation',
          'Nobody has discarded this tile yet',
          'Two different opponents have already discarded it',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'Visible copies and discards by the players you fear both cut the chance that the tile completes their hand.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question:
            'Match each situation to how safe that tile is against the player you fear.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'They discarded it earlier this rotation',
            right: 'Absolutely safe against them until they draw',
          ),
          QuestionPair(
            left: 'They discarded it, then drew twice',
            right: 'Only relatively safe',
          ),
          QuestionPair(
            left: 'All four copies lie on the table',
            right: 'Cannot be won on at all',
          ),
          QuestionPair(
            left: 'Never seen in the game, mid-hand',
            right: 'Most dangerous',
          ),
        ],
        explanation:
            'Absolute safety lasts only until the opponent draws again, while four visible copies means no fifth copy exists to win on.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Why is a tile with all four copies visible completely safe to discard?',
        options: [
          'No opponent can hold or wait on a fifth copy',
          'It must be an honour tile',
          'Every player has already thrown it',
          'It must be a terminal tile',
        ],
        correctIndex: 0,
        explanation:
            'There are only four copies of any tile, so once all four are visible nobody can complete a pair, pong or wait with it.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Which of these is NOT a reason for a tile to be safe?',
        options: [
          'The threatening opponent discarded it this rotation',
          'All four copies are visible',
          'It is a fresh middle tile nobody has played',
          'Two opponents have already thrown it away',
        ],
        correctIndex: 2,
        explanation:
            'A fresh middle tile is the classic danger tile, because it connects to many sequences and all four copies are still live.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'You can see all four copies of {{p6}} on the table. How many copies could an opponent still be waiting on?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['0', 'zero', 'none', 'no copies'],
        explanation:
            'All four copies are accounted for, so no opponent can be waiting on a tile that no longer exists in play.',
      ),
    ],
  ),

  Lesson(
    id: '8-3',
    stageId: 'stage8',
    title: 'Defensive Play',
    subtitle: 'When to fold your hand',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Sometimes the best play is NOT to win! Defensive play (打防守) means prioritizing safe discards over building your hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When to play defensively: Your hand is weak (far from winning), an opponent seems close to winning (few tiles left, called Pongs), or you\'re leading in points.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Folding (棄糊): Completely abandon your hand and only discard safe tiles. Break up your melds if needed to find safe discards!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: Not dealing into someone\'s hand is just as valuable as winning yourself. A draw (流局) is better than paying a big hand!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'When should you consider folding?',
        options: [
          'When you\'re close to winning',
          'When your hand is weak and opponents seem close',
          'In the first round',
          'Never',
        ],
        correctIndex: 1,
        explanation:
            'Fold when your hand is far from winning and opponents appear close to completing theirs.',
      ),
      QuizQuestion(
        question: 'What does "folding" mean in mahjong?',
        options: [
          'Leaving the game',
          'Abandoning your hand to play only safe tiles',
          'Declaring a draw',
          'Discarding all honor tiles',
        ],
        correctIndex: 1,
        explanation:
            'Folding means giving up on winning and only discarding tiles that are safe against opponents.',
      ),
      QuizQuestion(
        question: 'Is a draw (流局) better than dealing into a big hand?',
        options: [
          'No, always try to win',
          'Yes, you lose nothing in a draw',
          'They\'re the same',
          'Only if you\'re the dealer',
        ],
        correctIndex: 1,
        explanation:
            'A draw costs you nothing. Dealing into a big hand (7+ Faan) could cost you \$128+!',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which situations call for folding rather than pushing?',
        options: [
          'Your hand is several tiles from ready and two opponents have called melds',
          'You are comfortably leading and the hand is nearly over',
          'You are one tile from a cheap win and nobody looks close',
          'An opponent has three exposed melds and discards are getting dangerous',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'Folding pays when your own hand is far off or you have something to protect and someone else is close.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each table situation to the right response.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Four tiles from ready, opponent holds three melds',
            right: 'Fold and discard only safe tiles',
          ),
          QuestionPair(
            left: 'One tile from a cheap win, nobody threatening',
            right: 'Push for the win',
          ),
          QuestionPair(
            left: 'Leading late, your winning tile is dangerous',
            right: 'Hold the tile and take the draw',
          ),
          QuestionPair(
            left: 'Far behind with five turns left',
            right: 'Push a bigger hand and accept risk',
          ),
        ],
        explanation:
            'Defence is a choice about relative position, not a fixed rule, so the same hand can call for folding or pushing.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'A player who folds scores nothing, but also pays nothing when the hand ends in a ___.',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['draw', 'a draw', 'tie', '流局'],
        explanation:
            'A drawn hand involves no payments at all, which is why folding can cost less than chasing a hopeless win.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Is it ever right to break up a meld you already hold just to find a safe discard?',
        options: [
          'Yes, when an opponent is clearly close and no safe tile is free',
          'No, a meld must never be broken',
          'Only on the first turn',
          'Only if you are the dealer',
        ],
        correctIndex: 0,
        explanation:
            'When folding, the hand\'s value is already given up, so structure can be sacrificed to avoid dealing in.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'You are far behind on points with ten tiles left in the wall and no opponent looks close. What is the best approach?',
        options: [
          'Push for a bigger hand and accept some risk',
          'Fold immediately and discard only honours',
          'Stop drawing tiles',
          'Discard randomly to hide your shape',
        ],
        correctIndex: 0,
        explanation:
            'A player who needs points cannot profit from a draw, so taking risk to chase a larger hand is the correct trade.',
      ),
    ],
  ),

  Lesson(
    id: '8-4',
    stageId: 'stage8',
    title: 'Efficiency & Waiting',
    subtitle: 'Maximizing your winning tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Tile efficiency (牌效率) means choosing discards that maximize the number of tiles that can complete your hand (waiting tiles/聽牌).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: You need one tile to win. Waiting on {{m3}} OR {{m6}} (2 types, 8 possible tiles) is better than waiting on only {{m3}} (1 type, 4 tiles).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Broader waits = higher chance of winning. A 3-sided wait (三面聽) is amazing! Example: {{m3}}{{m4}}{{m5}}{{m6}} waiting for {{m2}}, {{m4}}, or {{m7}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When choosing what to discard, always count: "If I throw this, how many tiles can complete my hand?" Pick the discard that leaves the most options!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is "tile efficiency"?',
        options: [
          'Using the fewest tiles',
          'Maximizing the number of tiles that can complete your hand',
          'Discarding quickly',
          'Having no useless tiles',
        ],
        correctIndex: 1,
        explanation:
            'Tile efficiency means choosing discards that maximize your winning tile count.',
      ),
      QuizQuestion(
        question: 'Which wait is broader?',
        options: [
          'Waiting for 1 specific tile',
          'Waiting for 2 different tiles',
          'Waiting for 3 different tiles',
          'They\'re all the same',
        ],
        correctIndex: 2,
        explanation:
            'A 3-sided wait gives you the most possible tiles to win with — highest probability!',
      ),
      QuizQuestion(
        question:
            'You can wait on {{m3}} (4 copies left) or {{m3}}+{{m6}} (7 copies left). Which is better?',
        options: [
          '{{m3}} only',
          '{{m3}}+{{m6}}',
          'Both equal',
          'Depends on the round',
        ],
        correctIndex: 1,
        explanation:
            'More possible winning tiles = higher chance of completing your hand. 7 > 4.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'You hold {{m2}}{{m3}}. Arrange its two winning tiles from lowest to highest.',
        options: const [],
        correctIndex: 0,
        tiles: const ['m1', 'm4'],
        explanation:
            'A 23 shape is a two-sided wait, because both {{m1}} and {{m4}} complete the run.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'You hold {{m4}}{{m6}}. How many different tile types complete this closed wait?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['1', 'one', '1 tile', 'one tile'],
        explanation:
            'A closed wait has a hole in the middle, so only {{m5}} can fill it.',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'Which of these are two-sided waits?',
        options: [
          '{{m2}}{{m3}} waiting on {{m1}} or {{m4}}',
          '{{p7}}{{p8}} waiting on {{p6}} or {{p9}}',
          '{{s5}}{{s7}} waiting on {{s6}} only',
          '{{m1}}{{m2}} waiting on {{m3}} only',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1],
        explanation:
            'A two-sided wait accepts two different tiles, so it has about twice as many winning tiles as a closed wait.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You want flexible waits. Which of these single tiles is the least useful to keep?',
        options: ['m1', 'm5', 'p5', 's5'],
        correctIndex: 0,
        explanation:
            'A terminal only fits one run, while a middle tile fits several, so terminals are the least flexible tiles to hold.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question: 'Which pair of tiles forms a closed wait (kanchan)?',
        options: [
          '{{s5}}{{s7}}',
          '{{m2}}{{m3}}',
          '{{p7}}{{p8}}',
          '{{m8}}{{m9}}',
        ],
        correctIndex: 0,
        explanation:
            'The pair {{s5}}{{s7}} is one rank apart with a gap in the middle, which is the definition of a closed wait.',
      ),
    ],
  ),

  Lesson(
    id: '8-5',
    stageId: 'stage8',
    title: 'Tempo & Initiative',
    subtitle: 'Controlling the pace of play',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Tempo in mahjong means how fast you\'re progressing toward a win. Calling Pong/Chow speeds you up but reveals information!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Fast play (速攻): Call melds aggressively, aim for quick cheap wins. Good when you have a clear path to 3 Faan.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Slow play (慢打): Stay concealed, build a bigger hand. Good when you have potential for high Faan but need time.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Read the table! If opponents are playing fast, you might need to speed up or switch to defense. If everyone\'s slow, you have time to build.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the trade-off of calling Pong/Chow?',
        options: [
          'Faster progress but reveals information',
          'Slower progress but hides information',
          'No trade-off',
          'Loses Faan',
        ],
        correctIndex: 0,
        explanation:
            'Calling melds speeds up your hand but exposes tiles, letting opponents read your strategy.',
      ),
      QuizQuestion(
        question: 'When is fast play (速攻) best?',
        options: [
          'When you have a clear quick path to 3 Faan',
          'When building a limit hand',
          'In the first round always',
          'When opponents are playing slowly',
        ],
        correctIndex: 0,
        explanation:
            'Fast play works best when you can clearly reach 3 Faan quickly with available melds.',
      ),
      QuizQuestion(
        question:
            'An opponent calls 3 Pongs in 5 turns. What does this suggest?',
        options: [
          'They\'re playing slowly',
          'They\'re close to winning — be defensive!',
          'They\'re bluffing',
          'They have a weak hand',
        ],
        correctIndex: 1,
        explanation:
            'Three exposed Pongs means they only need 1 more meld + pair. They\'re very close to winning!',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question: 'What does calling a Pong cost you?',
        options: [
          'It exposes part of your hand to opponents',
          'It spends a turn you could have used to reshape your hand',
          'It stops you from ever winning by self-draw',
          'It forfeits the 1-Faan 門前清 bonus on an otherwise concealed hand',
        ],
        correctIndex: 0,
        correctIndexes: [0, 1, 3],
        explanation:
            'A call speeds the hand up but reveals tiles, reduces flexibility, and ends the concealed bonus.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each situation to the tempo choice that fits it.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'One cheap meld away from a 3-Faan win, wall still deep',
            right: 'Call the meld and speed up',
          ),
          QuestionPair(
            left: 'Promising 混一色 with plenty of tiles left',
            right: 'Stay concealed and build',
          ),
          QuestionPair(
            left: 'Two opponents have called melds and the wall is thin',
            right: 'Slow down and defend',
          ),
          QuestionPair(
            left: 'Far behind on points with few tiles left',
            right: 'Push for a big hand',
          ),
        ],
        explanation:
            'Tempo should follow the table: speed up when a cheap win is near, slow down when others are faster or the wall is short.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'An opponent calls Chow on their second turn. What is the main information this gives you?',
        options: [
          'Which suit they are collecting',
          'Their exact winning tile',
          'Nothing at all',
          'Their current score',
        ],
        correctIndex: 0,
        explanation:
            'A Chow shows three tiles of one suit, which points to that suit without revealing the wait.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Staying concealed for the whole hand keeps 門前清, worth how many Faan?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['1', 'one', '1 faan', 'one faan'],
        explanation:
            '門前清 is a 1-Faan pattern, so any call that breaks concealment gives up exactly one Faan.',
      ),
      QuizQuestion(
        type: QuizType.tileSelection,
        question:
            'You are racing for the fastest possible win. Which of these single tiles is the least useful to hold?',
        options: ['east', 'm4', 'p5', 's6'],
        correctIndex: 0,
        explanation:
            'A lone honour needs two matching copies to become a meld, which is the slowest way to build a fast hand.',
      ),
    ],
  ),

  Lesson(
    id: '8-6',
    stageId: 'stage8',
    title: 'Stage 8 Review',
    subtitle: 'Basic tactics mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You now have a tactical toolkit! Reading discards, safe tiles, defense, efficiency, and tempo. Let\'s put it all together!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The best players balance offense and defense every turn. Ask: "Can I win? Is it worth the risk? What\'s the safest play?"',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'Turn 12. You\'re 1 tile from winning but the tile is dangerous. You\'re leading in points. What do you do?',
        options: [
          'Discard it anyway — winning is everything',
          'Hold it and play safe — protect your lead',
          'Call timeout',
          'Discard a random tile',
        ],
        correctIndex: 1,
        explanation:
            'When leading, protect your advantage. Dealing into someone could erase your lead. Play safe!',
      ),
      QuizQuestion(
        question: 'What is the FIRST thing to check before discarding?',
        options: [
          'Your own hand',
          'The wall count',
          'What opponents have discarded',
          'The score',
        ],
        correctIndex: 2,
        explanation:
            'Always check opponents\' discards first to assess what\'s safe and what\'s dangerous.',
      ),
      QuizQuestion(
        question:
            'Rank these strategies from most aggressive to most defensive',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['red', 'east', 's1'],
        explanation:
            'Fast play/calling melds (most aggressive) → Balanced concealed play (middle) → Full fold/defense (most defensive).',
      ),
      QuizQuestion(
        type: QuizType.multiChoice,
        question:
            'Turn 12. You are two tiles from ready and one opponent holds three melds. Which actions are correct?',
        options: [
          'Check what that opponent has discarded this rotation',
          'Discard a fresh middle tile to keep your own shape',
          'Break your hand to find a safe tile if no safe tile is free',
          'Count how many copies of each candidate tile are already visible',
        ],
        correctIndex: 0,
        correctIndexes: [0, 2, 3],
        explanation:
            'Against a player who is close, safety comes first, so read their discards and visible copies rather than protecting shape.',
      ),
      QuizQuestion(
        type: QuizType.matching,
        question: 'Match each tactic to what it means.',
        options: const [],
        correctIndex: 0,
        pairs: const [
          QuestionPair(
            left: 'Reading discards',
            right: 'Inferring a hand from what an opponent throws',
          ),
          QuestionPair(
            left: 'Absolute safety',
            right: 'A tile the opponent discarded earlier this rotation',
          ),
          QuestionPair(
            left: 'Folding',
            right: 'Discarding safe tiles instead of chasing your win',
          ),
          QuestionPair(
            left: 'Tile efficiency',
            right: 'Maximising the tiles that complete your hand',
          ),
        ],
        explanation:
            'These four ideas are the whole tactical toolkit: read the table, judge safety, know when to fold, and count your outs.',
      ),
      QuizQuestion(
        type: QuizType.tileOrdering,
        question:
            'An opponent is one tile from winning. Arrange these discards from safest to most dangerous: {{red}}, which they threw earlier this rotation; {{p9}}, of which three copies are visible; {{s2}}, which nobody has played.',
        options: const [],
        correctIndex: 0,
        tiles: const ['red', 'p9', 's2'],
        explanation:
            'A tile they already discarded is safe this rotation, three visible copies leave only one live copy, and an unseen tile leaves all four.',
      ),
      QuizQuestion(
        type: QuizType.fillBlank,
        question:
            'Three copies of {{s8}} are visible on the table. How many copies can an opponent still be holding?',
        options: const [],
        correctIndex: 0,
        acceptedAnswers: ['1', 'one', '1 copy', 'one copy'],
        explanation:
            'Four copies exist in total, so with three visible exactly one copy is still live and it may be in any hand or the wall.',
      ),
      QuizQuestion(
        type: QuizType.singleChoice,
        question:
            'Which single habit improves both your attack and your defence?',
        options: [
          'Watching every discard and counting visible copies',
          'Calling the first meld offered every hand',
          'Never discarding honour tiles',
          'Always keeping one pair in hand',
        ],
        correctIndex: 0,
        explanation:
            'Discard reading and copy counting drive both your own wait choices and your safety judgements, so one habit serves both sides.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 9: Advanced Tactics (5 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '9-1',
    stageId: 'stage9',
    title: 'Bluffing & Deception',
    subtitle: 'Misleading opponents through discards',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Advanced players use deception! You can mislead opponents about what you\'re building through strategic discards.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Example: You\'re building a Bamboo flush. Discard a Bamboo tile early (like {{s2}}) to make opponents think you DON\'T want Bamboo!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Early discards carry the strongest signal. If you throw {{s2}} on turn 1, opponents assume Bamboo is safe to discard to you. Perfect trap!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Counter-bluffing: If an opponent\'s discards seem "too perfect," they might be bluffing! Experienced players question obvious patterns.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'You\'re secretly building Bamboo flush. What should you discard early?',
        options: [
          'A Bamboo tile you don\'t need',
          'A Character tile',
          'A Dragon',
          'A Wind',
        ],
        correctIndex: 0,
        explanation:
            'Discarding a Bamboo early makes opponents think you don\'t need Bamboo, so they\'ll freely discard Bamboo to you.',
      ),
      QuizQuestion(
        question: 'Why do early discards carry stronger signals?',
        options: [
          'They\'re worth more',
          'Players discard what they definitely don\'t need first',
          'The dealer sees them',
          'They affect the wall',
        ],
        correctIndex: 1,
        explanation:
            'Players typically discard their most useless tiles first, so early discards strongly indicate what they don\'t need.',
      ),
      QuizQuestion(
        question:
            'An opponent discards {{s1}} on turn 1 but then keeps all Bamboo. What might be happening?',
        options: [
          'They genuinely don\'t need Bamboo',
          'They might be bluffing — actually building Bamboo',
          'They\'re playing randomly',
          'They\'re folding',
        ],
        correctIndex: 1,
        explanation:
            'Discarding one Bamboo early then keeping all others is a classic bluff pattern for a Bamboo flush!',
      ),
    ],
  ),

  Lesson(
    id: '9-2',
    stageId: 'stage9',
    title: 'Advanced Kong Tactics',
    subtitle: 'Using Kong as a strategic weapon',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Kong isn\'t just about bonus tiles — it\'s a strategic weapon! A well-timed Kong can disrupt opponents\' plans.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Concealed Kong advantage: Removes 4 tiles from play that opponents might need. If you Kong all 4 of {{m5}}, no one can use {{m5}} in sequences!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Delayed Kong: Sometimes hold the 4th tile and declare Kong later. Why? To get the replacement draw at a more strategic moment.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Kong denial: If you have 3 of a tile an opponent needs, they can never complete that Pong! Holding tiles defensively is powerful.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What strategic advantage does Concealed Kong provide?',
        options: [
          'Extra Faan only',
          'Removes tiles opponents might need from play',
          'Skips opponents\' turns',
          'Reveals opponent hands',
        ],
        correctIndex: 1,
        explanation:
            'Kong-ing 4 tiles removes them from the game entirely, potentially breaking opponents\' sequences.',
      ),
      QuizQuestion(
        question: 'Why might you delay declaring a Kong?',
        options: [
          'It\'s against the rules',
          'To get the replacement draw at a better time',
          'To confuse the dealer',
          'You can\'t delay',
        ],
        correctIndex: 1,
        explanation:
            'Delaying Kong lets you choose when to get the replacement draw — useful for timing strategy.',
      ),
      QuizQuestion(
        question:
            'You hold 3 copies of {{red}}. An opponent likely needs {{red}}. What\'s the defensive benefit?',
        options: [
          'None',
          'They can never complete a Red Dragon Pong',
          'You get extra Faan',
          'They must fold',
        ],
        correctIndex: 1,
        explanation:
            'Holding 3 copies means only 1 remains — the opponent can never get 3 for a Pong!',
      ),
    ],
  ),

  Lesson(
    id: '9-3',
    stageId: 'stage9',
    title: 'Opponent Profiling',
    subtitle: 'Reading playing styles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Every player has tendencies! Some always go for big hands, others play fast and cheap. Identifying styles helps you predict their moves.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Aggressive players: Call melds early, aim for quick wins. Against them, play defensively when they have 2+ exposed melds.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Conservative players: Stay concealed, build big hands. They\'re dangerous in late game! Watch for sudden changes in their discard pattern.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Adaptive players: Change strategy based on their starting hand. Hardest to read! Focus on their current-round discards rather than past behavior.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'An opponent always calls Pong on the first available tile. What type are they?',
        options: [
          'Conservative',
          'Aggressive/Fast player',
          'Adaptive',
          'Defensive',
        ],
        correctIndex: 1,
        explanation:
            'Calling melds immediately indicates an aggressive, fast-play style.',
      ),
      QuizQuestion(
        question:
            'How should you play against an aggressive opponent with 2 exposed Pongs?',
        options: [
          'Play aggressively too',
          'Play defensively — they\'re close to winning',
          'Ignore them',
          'Call more Chows',
        ],
        correctIndex: 1,
        explanation:
            'Two exposed Pongs means they need only 1 more meld + pair. Be very careful with your discards!',
      ),
      QuizQuestion(
        question:
            'A conservative player suddenly starts discarding safe tiles. What does this suggest?',
        options: [
          'They\'re bored',
          'They might be close to winning and playing safe',
          'They\'re folding',
          'Nothing',
        ],
        correctIndex: 2,
        explanation:
            'A conservative player switching to safe discards likely means they\'re folding — their hand didn\'t develop well.',
      ),
    ],
  ),

  Lesson(
    id: '9-4',
    stageId: 'stage9',
    title: 'Pace Control',
    subtitle: 'Manipulating game speed',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You can influence the game\'s pace! Calling melds speeds up the game (fewer wall tiles remain). Staying concealed slows it down.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Speed up when: You\'re close to winning and want to finish before opponents catch up. Each Pong/Chow call shortens the game!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Slow down when: You need time to build a big hand, or you want the wall to run out (draw) when you\'re leading in points.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Pro move: If you\'re leading and an opponent is close to a big hand, DON\'T call melds. Let the wall run out for a draw!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How does calling Pong/Chow affect game pace?',
        options: [
          'Slows it down',
          'Speeds it up (fewer tiles in wall)',
          'No effect',
          'Depends on the tile',
        ],
        correctIndex: 1,
        explanation:
            'Each claim skips draws from the wall, effectively shortening the game.',
      ),
      QuizQuestion(
        question:
            'You\'re leading by 50 points. An opponent seems close to a limit hand. Best strategy?',
        options: [
          'Race to win first',
          'Don\'t call melds, let the wall run out',
          'Fold immediately',
          'Call Kong for extra draws',
        ],
        correctIndex: 1,
        explanation:
            'When leading, a draw preserves your lead. Don\'t speed up the game when an opponent has a dangerous hand!',
      ),
      QuizQuestion(
        question: 'When is speeding up the game beneficial?',
        options: [
          'When you\'re close to winning',
          'When you\'re far from winning',
          'When you\'re leading',
          'Always',
        ],
        correctIndex: 0,
        explanation:
            'Speed up when you\'re close to winning — finish before opponents can catch up or improve their hands.',
      ),
    ],
  ),

  Lesson(
    id: '9-5',
    stageId: 'stage9',
    title: 'Stage 9 Review',
    subtitle: 'Advanced tactics mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Excellent! You now have advanced tools: bluffing, Kong tactics, opponent profiling, and pace control. These separate good players from great ones!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Remember: Advanced tactics are situational. The right play depends on your hand, your opponents, and the game state. Stay flexible!',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'What is the most important factor in choosing between offense and defense?',
        options: [
          'Your seat position',
          'The current game situation (hand strength, score, opponents)',
          'The round number',
          'Your lucky tile',
        ],
        correctIndex: 1,
        explanation:
            'The game situation — your hand strength, score position, and opponents\' states — determines the best strategy.',
      ),
      QuizQuestion(
        question:
            'You suspect an opponent is bluffing about not needing Circles. What should you do?',
        options: [
          'Discard Circles freely',
          'Be cautious with Circle discards',
          'Call their bluff',
          'Fold immediately',
        ],
        correctIndex: 1,
        explanation:
            'If you suspect a bluff, be cautious. Don\'t freely discard the suit they might actually be collecting!',
      ),
      QuizQuestion(
        question:
            'Rank these Kong types from least to most information revealed',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['m1', 'east', 's5'],
        explanation:
            'Concealed Kong (face-down, least info) → Supplemental Kong (adds to known Pong) → Exposed Kong (all face-up, most info).',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 10: Risk Management (5 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '10-1',
    stageId: 'stage10',
    title: 'Danger Assessment',
    subtitle: 'Identifying risky tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Risk management starts with identifying dangerous tiles. The danger level depends on: tile type, game stage, and opponents\' behavior.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Most dangerous: Fresh middle tiles (4,5,6) in late game. {{m5}} connects to sequences 3-4-5, 4-5-6, and 5-6-7 — maximum danger!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Moderate danger: Fresh terminal tiles (1,9) and honor tiles that haven\'t appeared. Less sequence connections but still risky for Pongs.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Safest: Tiles already discarded by the target opponent, tiles with 3+ copies visible, and tiles adjacent to their recent discards.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Why are middle tiles (4,5,6) the most dangerous?',
        options: [
          'They\'re worth more Faan',
          'They connect to the most sequences',
          'They\'re rarer',
          'Opponents always collect them',
        ],
        correctIndex: 1,
        explanation:
            'Middle tiles connect to 3 different sequences each (e.g., 5 works in 3-4-5, 4-5-6, and 5-6-7).',
      ),
      QuizQuestion(
        question: 'It\'s turn 14. Which discard is most dangerous?',
        options: ['m5', 'east', 'p1', 'red'],
        correctIndex: 0,
        type: QuizType.tileSelection,
        tiles: ['m5', 'east', 'p1', 'p9', 'red', 'green', 'south'],
        explanation:
            '{{m5}} is a middle tile — maximum sequence connections. In late game, fresh middle tiles are the most dangerous.',
      ),
      QuizQuestion(
        question:
            'A tile has 3 copies visible (discarded/exposed). How dangerous is the 4th copy?',
        options: [
          'Very dangerous',
          'Moderately dangerous',
          'Safe — no one can Pong it',
          'Depends on the suit',
        ],
        correctIndex: 2,
        explanation:
            'With 3 copies visible, no one can Pong the 4th. It can only complete a sequence — relatively safe.',
      ),
    ],
  ),

  Lesson(
    id: '10-2',
    stageId: 'stage10',
    title: 'Score-Based Decisions',
    subtitle: 'Playing the scoreboard',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Your score position should dictate your strategy! Leading? Play safe. Trailing? Take risks. This is "playing the scoreboard."',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When LEADING: Prioritize defense, aim for draws, avoid risky discards. A draw preserves your lead. Don\'t gamble what you\'ve earned!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When TRAILING: Take calculated risks, go for bigger hands, accept some danger. You need to win big to catch up — safe play won\'t close the gap.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'When EVEN: Play balanced. Build your hand efficiently but don\'t take unnecessary risks. Let your opponents make mistakes!',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'You\'re leading by 40 points in the final round. Best strategy?',
        options: [
          'Go for a limit hand',
          'Play defensively and aim for draws',
          'Play normally',
          'Be aggressive to extend the lead',
        ],
        correctIndex: 1,
        explanation:
            'When leading in the final round, protect your lead! Draws preserve your advantage.',
      ),
      QuizQuestion(
        question: 'You\'re trailing by 60 points. What should you aim for?',
        options: [
          'Quick 3-Faan hands',
          'Bigger hands (5+ Faan) to close the gap',
          'Only defense',
          'Fold every hand',
        ],
        correctIndex: 1,
        explanation:
            'When trailing significantly, you need big wins to catch up. Small wins won\'t close a 60-point gap.',
      ),
      QuizQuestion(
        question:
            'You\'re far behind. Should you choose a broad 4-sided wait or a narrow wait on a Dragon?',
        options: [
          'Narrow Dragon wait — need big Faan to catch up',
          'Broad wait — winning is more important',
          'Always fold when behind',
          'Doesn\'t matter',
        ],
        correctIndex: 0,
        explanation:
            'When behind, you need high-value wins. A Dragon wait with extra Faan can close the gap.',
      ),
    ],
  ),

  Lesson(
    id: '10-3',
    stageId: 'stage10',
    title: 'Folding Decisions',
    subtitle: 'When to give up on winning',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Knowing when to fold is a sign of mastery! Fold when: your hand is hopeless by turn 8-10, or an opponent is clearly about to win big.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Signs your hand is hopeless: No complete melds by turn 8, scattered tiles with no clear direction, too many isolated tiles.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'How to fold: Only discard tiles that opponents have already thrown. Break up your own melds to find safe discards if needed!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The math: If you have a 5% chance of winning and a 30% chance of dealing into a big hand, folding saves you money in the long run!',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'By turn 8, you have no complete melds and scattered tiles. What should you do?',
        options: [
          'Keep trying to win',
          'Consider folding and playing safe',
          'Call any available Chow',
          'Discard all honors',
        ],
        correctIndex: 1,
        explanation:
            'No melds by turn 8 means you\'re very far from winning. Folding to avoid dealing in is the smart play.',
      ),
      QuizQuestion(
        question: 'When folding, what should you discard?',
        options: [
          'Your most useful tiles',
          'Tiles opponents have already discarded',
          'Random tiles',
          'Only honor tiles',
        ],
        correctIndex: 1,
        explanation:
            'When folding, only discard tiles that are proven safe — ones opponents have already thrown.',
      ),
      QuizQuestion(
        question: 'Is folding a sign of weakness?',
        options: [
          'Yes, always try to win',
          'No, it\'s a sign of smart play',
          'Only beginners fold',
          'Only fold as dealer',
        ],
        correctIndex: 1,
        explanation:
            'Folding is a sign of mastery! Knowing when NOT to play is just as important as knowing when to push.',
      ),
    ],
  ),

  Lesson(
    id: '10-4',
    stageId: 'stage10',
    title: 'End-Game Decisions',
    subtitle: 'The critical final turns',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The last 3-4 turns are the most critical! Tensions are high, walls are thin, and every discard could decide the game.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Three end-game options: PUSH (discard risky tiles to chase your win), FOLD (play only safe tiles), or SELF-DRAW ONLY (keep your wait but don\'t discard dangerously).',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Push when: You\'re trailing and need to win this hand. Fold when: You\'re leading and can\'t afford to deal in. Self-draw only: When your wait is good but discarding is risky.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The wall count matters! With 4 tiles left, there are only 4 more draws. Calculate: Can I self-draw in 1-2 turns? If unlikely, fold!',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'Turn 16, 4 tiles left in the wall. You\'re 1 tile from winning but must discard a dangerous tile. You\'re leading. What do you do?',
        options: [
          'Push — discard the dangerous tile',
          'Fold — play safe and accept the draw',
          'Self-draw only — hope to draw your winning tile',
          'Call timeout',
        ],
        correctIndex: 1,
        explanation:
            'Leading + dangerous discard + few tiles left = fold. A draw preserves your lead safely.',
      ),
      QuizQuestion(
        question:
            'Rank end-game strategies from most conservative to most aggressive',
        options: [],
        correctIndex: 0,
        type: QuizType.tileOrdering,
        tiles: ['east', 'p1', 'm5'],
        explanation:
            'Fold (0% risk) → Self-draw only (moderate) → Push (highest risk, highest reward).',
      ),
      QuizQuestion(
        question: 'When is "Push" the correct end-game strategy?',
        options: [
          'When leading',
          'When trailing and need this win',
          'Always in the last turn',
          'Never',
        ],
        correctIndex: 1,
        explanation:
            'Push when you\'re behind and need to win this hand to stay competitive. The risk is justified.',
      ),
    ],
  ),

  Lesson(
    id: '10-5',
    stageId: 'stage10',
    title: 'Stage 10 Review',
    subtitle: 'Risk management mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You\'re now a strategic thinker! Danger assessment, score-based decisions, folding, and end-game play. These skills win tournaments!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The key principle: Every decision should consider RISK vs REWARD. What do you gain? What could you lose? Make the math work in your favor!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the core principle of risk management?',
        options: [
          'Always play safe',
          'Always be aggressive',
          'Balance risk vs reward based on game situation',
          'Copy what opponents do',
        ],
        correctIndex: 2,
        explanation:
            'Risk management is about making decisions where the expected reward justifies the risk taken.',
      ),
      QuizQuestion(
        question:
            'Turn 14, you\'re leading. An opponent just discarded {{m5}} - the exact tile your hand needs to win, and {{m5}} hasn\'t appeared all game. Should you claim it to win?',
        options: [
          'Yes, claim it and win',
          'No! It\'s a trap - too dangerous, keep waiting for self-draw',
          'Only if you\'re East',
          'Depends on the suit',
        ],
        correctIndex: 0,
        explanation:
            'You need {{m5}} to win and an opponent just discarded it - that\'s a direct win by discard! Claim it immediately. The "dangerous fresh tile" concern applies to DISCARDING, not to claiming your winning tile.',
      ),
      QuizQuestion(
        question: 'What separates intermediate players from advanced players?',
        options: [
          'Knowing tile names',
          'Knowing when NOT to win',
          'Playing faster',
          'Having lucky tiles',
        ],
        correctIndex: 1,
        explanation:
            'Advanced players know when to fold, when to play safe, and when winning isn\'t worth the risk.',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 11: Simulated Games (5 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '11-1',
    stageId: 'stage11',
    title: 'Opening Hand Analysis',
    subtitle: 'Evaluating your starting 13 tiles',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s practice real game scenarios! First skill: analyzing your opening hand. What do you look for in your initial 13 tiles?',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Step 1: Count pairs, connected tiles, and isolated tiles. More connections = better hand potential.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Step 2: Identify possible directions. Can you go All Pongs? Mixed Suit? Full Flush? Or just a quick All Chows?',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Step 3: Plan your first 3 discards. Usually discard isolated honors first (unless going for Mixed Suit), then isolated terminals.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'Your opening hand has 4 pairs and scattered tiles. What direction should you consider?',
        options: ['All Chows', 'All Pongs', 'Full Flush', 'Thirteen Orphans'],
        correctIndex: 1,
        explanation:
            '4 pairs means you already have potential Pongs! Try to build All Pongs (3 Faan) by drawing matching tiles.',
      ),
      QuizQuestion(
        question:
            'Your hand is mostly Bamboo with 2 honor tiles. Best direction?',
        options: [
          'All Pongs',
          'Mixed One Suit (Bamboo + honors)',
          'Thirteen Orphans',
          'All Chows',
        ],
        correctIndex: 1,
        explanation:
            'Mostly one suit + some honors = perfect setup for Mixed One Suit (3 Faan)!',
      ),
      QuizQuestion(
        question:
            'What should you typically discard first from your opening hand?',
        options: [
          'Middle tiles',
          'Connected tiles',
          'Isolated honor tiles',
          'Pairs',
        ],
        correctIndex: 2,
        explanation:
            'Isolated honors (not part of pairs or potential Pongs) are usually discarded first as they have the least meld potential.',
      ),
    ],
  ),

  Lesson(
    id: '11-2',
    stageId: 'stage11',
    title: 'Mid-Game Decisions',
    subtitle: 'Turns 5-10 strategy',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'The mid-game (turns 5-10) is where strategies solidify. By now you should have a clear direction for your hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Key mid-game questions: Am I on track to win? Should I call that Chow/Pong? Is anyone else close to winning?',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'If you\'re on track: Focus on efficiency. Choose discards that maximize your waiting tiles. Consider calling melds to speed up.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'If you\'re NOT on track: Reassess! Can you pivot to a different hand? Or should you start playing defensively?',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'Turn 7. You have 2 complete melds and a clear path to winning. An opponent calls their 2nd Pong. What do you do?',
        options: [
          'Ignore them and keep building',
          'Speed up — call melds to finish before them',
          'Fold immediately',
          'Wait and see',
        ],
        correctIndex: 1,
        explanation:
            'You\'re both close! Speed up to finish before them. Call melds if available to accelerate your hand.',
      ),
      QuizQuestion(
        question:
            'Turn 8. Your hand has no clear direction and 0 complete melds. Best action?',
        options: [
          'Keep trying random combinations',
          'Start transitioning to defense',
          'Call any available meld',
          'Discard all pairs',
        ],
        correctIndex: 1,
        explanation:
            'No direction by turn 8 means you\'re unlikely to win. Start playing safe to avoid dealing in.',
      ),
      QuizQuestion(
        question: 'When should you pivot your hand direction?',
        options: [
          'Never, commit to your plan',
          'When a better opportunity clearly presents itself',
          'Every turn',
          'Only in the first round',
        ],
        correctIndex: 1,
        explanation:
            'Pivot when draws clearly point to a better direction — but only if it\'s a clear improvement, not just different.',
      ),
    ],
  ),

  Lesson(
    id: '11-3',
    stageId: 'stage11',
    title: 'Calling Decisions',
    subtitle: 'When to Chow, Pong, or pass',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Every time an opponent discards, you face a decision: Call (Chow/Pong) or Pass? Let\'s build a framework!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'CALL when: It completes a meld you need, it doesn\'t reveal too much about your hand, and you\'re playing a fast strategy.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'PASS when: You\'re building a concealed hand (for Concealed Hand Faan), the meld would make your strategy obvious, or you have better options in hand.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Special case: Always Pong a Dragon if you have 2! Dragon Pongs are free Faan and don\'t reveal much about your suit direction.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'You have {{red}}{{red}} in hand. Someone discards {{red}}. Should you Pong?',
        options: [
          'Yes — free Faan!',
          'No — stay concealed',
          'Only if you\'re East',
          'Only in late game',
        ],
        correctIndex: 0,
        explanation:
            'Almost always Pong Dragons! It\'s 1 free Faan and doesn\'t reveal your suit direction.',
      ),
      QuizQuestion(
        question:
            'You\'re building a concealed hand for the Faan bonus. Someone discards a tile you need. Should you call?',
        options: [
          'Yes, always call',
          'No — calling loses your Concealed Hand Faan',
          'Only for Pong',
          'Only for Chow',
        ],
        correctIndex: 1,
        explanation:
            'Calling any meld breaks your Concealed Hand status, losing that 1 Faan bonus. Only call if the speed advantage outweighs it.',
      ),
      QuizQuestion(
        question:
            'You\'re building Bamboo flush. Someone discards {{s4}} and you have {{s3}}{{s5}}. Should you Chow?',
        options: [
          'Yes — completes a meld',
          'No — it reveals you\'re collecting Bamboo',
          'Only if it\'s your last meld needed',
          'Never Chow in flush',
        ],
        correctIndex: 1,
        explanation:
            'Calling Chow on Bamboo reveals your flush strategy! Opponents will stop discarding Bamboo. Usually better to pass.',
      ),
    ],
  ),

  Lesson(
    id: '11-4',
    stageId: 'stage11',
    title: 'Full Hand Simulation',
    subtitle: 'Play through a complete hand',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Let\'s simulate a full hand! Opening: {{m2}}{{m3}}{{m5}}{{m5}}{{p1}}{{p4}}{{p5}}{{p6}}{{s3}}{{s4}}{{s7}}{{east}}{{red}}. What\'s your plan?',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Analysis: Circles have a complete meld ({{p4}}{{p5}}{{p6}}), Characters have potential ({{m2}}{{m3}} need {{m1}} or {{m4}}), {{m5}}{{m5}} is a pair, Bamboo has {{s3}}{{s4}} needing {{s2}} or {{s5}}.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Direction: General hand (All Chows possible). Discard isolated tiles first: {{east}} then {{s7}} then {{p1}}. Keep the pair {{m5}}{{m5}} and connected tiles.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'After a few draws, you might pick up {{m4}} (completing {{m2}}{{m3}}{{m4}}) or {{s5}} (completing {{s3}}{{s4}}{{s5}}). Build toward 4 melds + pair!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'From the hand above, what should you discard FIRST?',
        options: ['{{m5}}', '{{east}}', '{{p5}}', '{{s3}}'],
        correctIndex: 1,
        explanation:
            '{{east}} is an isolated honor tile with no pair and limited Pong potential. Discard it first!',
      ),
      QuizQuestion(
        question: 'You draw {{m4}}. What does this complete?',
        options: [
          'A pair',
          'The sequence {{m2}}{{m3}}{{m4}}',
          'A Pong',
          'Nothing useful',
        ],
        correctIndex: 1,
        explanation:
            '{{m4}} completes the sequence with {{m2}}{{m3}} — now you have a full meld!',
      ),
      QuizQuestion(
        question:
            'After discarding {{east}} and {{s7}}, and drawing {{m4}} and {{s2}}, how many complete melds do you have?',
        options: ['1', '2', '3', '4'],
        correctIndex: 2,
        explanation:
            '{{m2}}{{m3}}{{m4}}, {{p4}}{{p5}}{{p6}}, and {{s2}}{{s3}}{{s4}} — 3 complete melds! One more + pair to win.',
      ),
    ],
  ),

  Lesson(
    id: '11-5',
    stageId: 'stage11',
    title: 'Stage 11 Review',
    subtitle: 'Simulation mastery',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'You\'ve practiced real game decision-making! Opening analysis, mid-game pivots, calling decisions, and full hand play-through.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'The key skill: Think ahead! Every discard should consider not just this turn, but the next 3-4 turns. Plan your path to victory!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What is the most important skill in simulated play?',
        options: [
          'Memorizing all tiles',
          'Thinking ahead and planning multiple turns',
          'Playing as fast as possible',
          'Always going for big hands',
        ],
        correctIndex: 1,
        explanation:
            'Planning ahead — considering future draws and discards — is the most important skill for consistent winning.',
      ),
      QuizQuestion(
        question:
            'Your opening hand has 8 Bamboo tiles, 3 honors, and 2 Characters. Best direction?',
        options: [
          'All Chows',
          'Mixed One Suit (Bamboo)',
          'Full Flush (Bamboo)',
          'All Pongs',
        ],
        correctIndex: 1,
        explanation:
            '8 Bamboo + 3 honors = strong Mixed One Suit potential (3 Faan). Full Flush is possible but harder (need to discard all honors).',
      ),
      QuizQuestion(
        question:
            'Turn 6. You have 1 meld and your hand could go two directions. What helps you decide?',
        options: [
          'Flip a coin',
          'Count which direction has more available tiles remaining',
          'Always pick the higher Faan option',
          'Ask another player',
        ],
        correctIndex: 1,
        explanation:
            'Count remaining tiles for each direction. The path with more available tiles is more likely to succeed!',
      ),
    ],
  ),

  // ═══════════════════════════════════
  //  STAGE 12: Real Game Challenge (5 lessons)
  // ═══════════════════════════════════
  Lesson(
    id: '12-1',
    stageId: 'stage12',
    title: 'Multi-Player Awareness',
    subtitle: 'Tracking all opponents simultaneously',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'In real games, you face 3 opponents at once! You need to track all of them while building your own hand. Let\'s practice!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Divide your attention: 60% on your hand, 20% on the most dangerous opponent, 10% each on the other two.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Who\'s most dangerous? The player with the most exposed melds, the player who stopped discarding a suit, or the player with the longest streak.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Quick scan each turn: Before discarding, glance at all 3 opponents\' exposed melds and recent discards. Takes 2 seconds but saves you money!',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'How should you divide attention in a 4-player game?',
        options: [
          '100% on your hand',
          '25% on each player equally',
          'Mostly your hand + focus on the most dangerous opponent',
          'Only watch the dealer',
        ],
        correctIndex: 2,
        explanation:
            'Focus mostly on your hand but pay extra attention to the most dangerous opponent.',
      ),
      QuizQuestion(
        question:
            'Player A has 2 Pongs exposed. Player B has 0. Player C has 1 Chow. Who is most dangerous?',
        options: ['Player A', 'Player B', 'Player C', 'All equal'],
        correctIndex: 0,
        explanation:
            'Player A with 2 exposed Pongs is closest to winning — they only need 1 more meld + pair!',
      ),
      QuizQuestion(
        question: 'What should you check BEFORE every discard?',
        options: [
          'The time',
          'All opponents\' exposed melds and recent discards',
          'Your score only',
          'The wall count only',
        ],
        correctIndex: 1,
        explanation:
            'Quick scan of all opponents\' exposed melds and recent discards helps you avoid dangerous discards.',
      ),
    ],
  ),

  Lesson(
    id: '12-2',
    stageId: 'stage12',
    title: 'Pressure Situations',
    subtitle: 'Making decisions under pressure',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Real games have pressure! Someone declares "Pong!" loudly, the wall is running low, and you need to decide quickly. Let\'s practice staying calm.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Pressure situation 1: You\'re 1 tile from winning, but the only tile you can discard is dangerous. Push or fold?',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Framework: Risk = (chance of dealing in) × (cost if dealt in). Reward = (chance of winning) × (value of your hand). If Reward > Risk, push!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Pressure situation 2: Two opponents seem close to winning. Do you play safe against both? Usually yes — fold and wait for the next hand!',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'You\'re 1 tile from a 5-Faan hand. The discard is moderately dangerous. You\'re trailing. Should you push?',
        options: [
          'Yes — high reward and you need to catch up',
          'No — always play safe',
          'Only if you\'re the dealer',
          'Fold immediately',
        ],
        correctIndex: 0,
        explanation:
            'Trailing + high-value hand + moderate (not extreme) risk = push! You need big wins to catch up.',
      ),
      QuizQuestion(
        question:
            'Two opponents have 2+ exposed melds each. Your hand is mediocre. Best play?',
        options: [
          'Race them both',
          'Fold and play safe',
          'Target the weaker one',
          'Call timeout',
        ],
        correctIndex: 1,
        explanation:
            'Two dangerous opponents + mediocre hand = fold. The risk of dealing in is too high from two directions.',
      ),
      QuizQuestion(
        question: 'What is the decision framework for risky discards?',
        options: [
          'Always push',
          'Always fold',
          'Compare Risk (chance × cost) vs Reward (chance × value)',
          'Ask other players',
        ],
        correctIndex: 2,
        explanation:
            'Compare expected risk vs expected reward. Push when reward exceeds risk, fold when it doesn\'t.',
      ),
    ],
  ),

  Lesson(
    id: '12-3',
    stageId: 'stage12',
    title: 'Adapting to Table Dynamics',
    subtitle: 'Adjusting to different opponents',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Every table is different! The same strategy won\'t work everywhere. You need to adapt to your specific opponents.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Tight table (everyone plays safe): You can be more aggressive! Opponents won\'t challenge you, so build bigger hands freely.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Loose table (everyone plays aggressively): Play tighter! Let them deal into each other while you wait for safe opportunities.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Mixed table: Identify the weakest player and position yourself to win from their discards. Avoid confronting the strongest player directly.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'At a tight/safe table, what strategy works best?',
        options: [
          'Play even safer',
          'Be more aggressive — opponents won\'t challenge you',
          'Fold every hand',
          'Copy their style',
        ],
        correctIndex: 1,
        explanation:
            'At a tight table, aggression is rewarded because opponents are unlikely to push back or deal into you.',
      ),
      QuizQuestion(
        question: 'At a loose/aggressive table, what strategy works best?',
        options: [
          'Be even more aggressive',
          'Play tighter and let them deal into each other',
          'Fold every hand',
          'Leave the table',
        ],
        correctIndex: 1,
        explanation:
            'At a loose table, patience wins. Let aggressive players make mistakes and deal into each other.',
      ),
      QuizQuestion(
        question: 'How do you identify the weakest player?',
        options: [
          'They have the lowest score',
          'They make predictable mistakes and discard dangerously',
          'They talk the most',
          'They play the fastest',
        ],
        correctIndex: 1,
        explanation:
            'The weakest player makes predictable mistakes — discarding dangerously, calling melds unnecessarily, or failing to read the table.',
      ),
    ],
  ),

  Lesson(
    id: '12-4',
    stageId: 'stage12',
    title: 'Session Management',
    subtitle: 'Playing well over many hands',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'A mahjong session is 16+ hands. Winning the session means consistent good decisions, not just one lucky hand!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Avoid tilt! After a bad loss, don\'t chase losses with risky play. Take a breath, reset, and play your normal game.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Bankroll awareness: Track your running total. Adjust aggression based on whether you\'re up or down for the session.',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Endurance: Stay focused in late rounds! Many players get sloppy after 10+ hands. Consistent focus is your edge.',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'You just lost a big hand (8 Faan dealt to you). What should you do next?',
        options: [
          'Go all-in on the next hand to recover',
          'Take a breath and play your normal game',
          'Fold the next 5 hands',
          'Blame the other player',
        ],
        correctIndex: 1,
        explanation:
            'Don\'t tilt! Reset mentally and play your normal strategy. Chasing losses leads to more losses.',
      ),
      QuizQuestion(
        question: 'What is "tilt" in mahjong?',
        options: [
          'A special hand',
          'Playing emotionally after a bad result',
          'A type of Kong',
          'Winning streak',
        ],
        correctIndex: 1,
        explanation:
            'Tilt is playing emotionally (usually too aggressively) after a bad result. It leads to poor decisions.',
      ),
      QuizQuestion(
        question:
            'You\'re up 40 points after 12 hands. 4 hands remain. Best approach?',
        options: [
          'Go for limit hands',
          'Protect your lead with balanced/safe play',
          'Fold every remaining hand',
          'Play the same as hand 1',
        ],
        correctIndex: 1,
        explanation:
            'With a lead and few hands left, protect it! Play balanced — don\'t take unnecessary risks.',
      ),
    ],
  ),

  Lesson(
    id: '12-5',
    stageId: 'stage12',
    title: 'Stage 12 Review — Graduation!',
    subtitle: 'You\'re ready for real games!',
    dialogues: [
      DialogueMessage(
        speaker: 'mj',
        text:
            'Congratulations! You\'ve completed the entire Ludi Mahjong course! You now have the knowledge to play Cantonese Mahjong confidently!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'You\'ve learned: Tiles, melds, game flow, winning conditions, special hands, flowers, Kongs, scoring, tactics, strategy, and real-game skills!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Final advice: The best way to improve is to PLAY! Apply what you\'ve learned, review your mistakes, and keep having fun. Mahjong is a lifetime game!',
      ),
      DialogueMessage(
        speaker: 'mj',
        text:
            'Go find 3 friends, set up a table, and enjoy! Remember: it\'s a game — win or lose, the joy is in the play. Good luck! 🀄',
      ),
    ],
    questions: [
      QuizQuestion(
        question:
            'What is the single most important thing for improving at mahjong?',
        options: [
          'Memorizing all Faan values',
          'Playing real games and learning from mistakes',
          'Reading more books',
          'Watching others play',
        ],
        correctIndex: 1,
        explanation:
            'Practice is king! Play real games, analyze your decisions, and learn from both wins and losses.',
      ),
      QuizQuestion(
        question:
            'What should you focus on as a new player in your first real games?',
        options: [
          'Winning every hand',
          'Limit hands only',
          'Making good decisions and not dealing in',
          'Playing as fast as possible',
        ],
        correctIndex: 2,
        explanation:
            'Focus on decision quality, not results. Good decisions + avoiding deal-ins = long-term success!',
      ),
      QuizQuestion(
        question: 'You\'ve completed all 12 stages! What\'s next?',
        options: [
          'Nothing, you\'re done',
          'Play real games and keep learning!',
          'Start over from Stage 1',
          'Wait for more lessons',
        ],
        correctIndex: 1,
        explanation:
            'The real learning starts now! Take your knowledge to the table and enjoy the game. You\'re ready!',
      ),
    ],
  ),
];
