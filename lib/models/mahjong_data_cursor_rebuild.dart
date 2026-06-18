import 'package:flutter/material.dart';

/// Isolated from-scratch curriculum rebuild.
/// This file is intentionally separate and not wired into runtime yet.

enum CursorQuizType { multiChoice, tileSelection }

class CursorLearningStage {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int lessonCount;

  const CursorLearningStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lessonCount,
  });
}

class CursorQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final CursorQuizType type;
  final List<String>? tiles;

  const CursorQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.type = CursorQuizType.multiChoice,
    this.tiles,
  });
}

class CursorLesson {
  final String id;
  final String stageId;
  final String title;
  final String subtitle;
  final List<String> dialogue;
  final List<CursorQuizQuestion> questions;

  const CursorLesson({
    required this.id,
    required this.stageId,
    required this.title,
    required this.subtitle,
    required this.dialogue,
    required this.questions,
  });
}

const cursorStages = <CursorLearningStage>[
  CursorLearningStage(
    id: 'basics',
    title: 'The Basics',
    subtitle: 'Tiles, setup, and flow',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF4CAF50),
    lessonCount: 8,
  ),
  CursorLearningStage(
    id: 'how-to-play',
    title: 'How to Play',
    subtitle: 'Actions and turn rules',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFFE8B93E),
    lessonCount: 8,
  ),
  CursorLearningStage(
    id: 'winning-hands',
    title: 'Winning Hands',
    subtitle: 'Melds, waits, and hand forms',
    icon: Icons.celebration_rounded,
    color: Color(0xFF8B4513),
    lessonCount: 6,
  ),
  CursorLearningStage(
    id: 'scoring-faan',
    title: 'Scoring & Faan',
    subtitle: 'Faan logic and payout',
    icon: Icons.stars_rounded,
    color: Color(0xFF2E7D32),
    lessonCount: 8,
  ),
  CursorLearningStage(
    id: 'strategy',
    title: 'Strategy',
    subtitle: 'Defense and efficiency',
    icon: Icons.psychology_rounded,
    color: Color(0xFF6A1B9A),
    lessonCount: 6,
  ),
];

const _stage1 = <(String, String)>[
  ('What Is Mahjong?', 'Goal and table basics'),
  ('Tile Families', 'Characters, Bamboo, Circles'),
  ('Honor Tiles', 'Winds and Dragons'),
  ('Table Setup', 'Seats, wall, dealer'),
  ('Turn Flow', 'Draw then discard'),
  ('Meld Basics', 'Chow, Pong, Kong, Pair'),
  ('Winning Shape', '4 melds + 1 pair'),
  ('Stage 1 Review', 'Core terms and flow'),
];

const _stage2 = <(String, String)>[
  ('Draw and Discard', 'Hand efficiency'),
  ('Calling Pong', 'Triplet claim timing'),
  ('Calling Chow', 'Left player restriction'),
  ('Calling Kong', 'Extra draw and risk'),
  ('Priority Rules', 'Hu > Pong/Kong > Chow'),
  ('Concealed vs Exposed', 'Info tradeoffs'),
  ('Safe Discards', 'Reading danger tiles'),
  ('Stage 2 Review', 'Action decisions'),
];

const _stage3 = <(String, String)>[
  ('Ready Hand (Ting)', 'One tile from win'),
  ('Wait Types', 'Edge, closed, pair waits'),
  ('All Pongs', 'Triplet-heavy hand'),
  ('Flush Concepts', 'Half vs Full Flush'),
  ('Special Hands Intro', 'Rare high-value forms'),
  ('Stage 3 Review', 'Winning logic check'),
];

const _stage4 = <(String, String)>[
  ('What Is Faan?', 'Scoring minimum'),
  ('1-Faan Patterns', 'Small value hands'),
  ('2-3 Faan Patterns', 'Mid value structures'),
  ('Self Draw & Dealer', 'Who pays what'),
  ('Combining Faan', 'Stacking patterns'),
  ('Hand Comparison', 'Choose higher EV line'),
  ('Calculation Practice', 'Quick faan math'),
  ('Stage 4 Review', 'Scoring decisions'),
];

const _stage5 = <(String, String)>[
  ('Early Hand Planning', 'Choose a direction'),
  ('Mid-Game Defense', 'Stop feeding wins'),
  ('Tile Counting', 'Live outs awareness'),
  ('Opponent Reading', 'Discard inference'),
  ('Endgame Choices', 'Push or fold'),
  ('Final Review', 'Integrated strategy'),
];

final List<CursorLesson> cursorLessons = _buildCursorLessons();

List<CursorLesson> _buildCursorLessons() {
  return [
    ..._buildStage('1', 'basics', _stage1),
    ..._buildStage('2', 'how-to-play', _stage2),
    ..._buildStage('3', 'winning-hands', _stage3),
    ..._buildStage('4', 'scoring-faan', _stage4),
    ..._buildStage('5', 'strategy', _stage5),
  ];
}

List<CursorLesson> _buildStage(
  String stageNo,
  String stageId,
  List<(String, String)> specs,
) {
  return List<CursorLesson>.generate(specs.length, (i) {
    final lessonNo = i + 1;
    final (title, subtitle) = specs[i];
    final lessonId = '$stageNo-$lessonNo';
    return CursorLesson(
      id: lessonId,
      stageId: stageId,
      title: title,
      subtitle: subtitle,
      dialogue: [
        'MJ: In this lesson we focus on "$title".',
        'Use this step to build intuition, not just memorization.',
      ],
      questions: _questionsFor(stageId, lessonNo),
    );
  });
}

List<CursorQuizQuestion> _questionsFor(String stageId, int lessonNo) {
  switch (stageId) {
    case 'basics':
      return _basicsQuestions(lessonNo);
    case 'how-to-play':
      return _playQuestions(lessonNo);
    case 'winning-hands':
      return _winQuestions(lessonNo);
    case 'scoring-faan':
      return _scoreQuestions(lessonNo);
    case 'strategy':
      return _strategyQuestions(lessonNo);
    default:
      return const [];
  }
}

List<CursorQuizQuestion> _basicsQuestions(int lessonNo) {
  return [
    const CursorQuizQuestion(
      question: 'How many players are in standard Mahjong?',
      options: ['2', '3', '4', '5'],
      correctIndex: 2,
      explanation: 'Standard table size is four players.',
    ),
    const CursorQuizQuestion(
      question: 'What is the standard winning shape?',
      options: ['3 melds + 2 pairs', '4 melds + 1 pair', '7 random tiles', '5 pairs'],
      correctIndex: 1,
      explanation: 'Core shape is four melds and one pair.',
    ),
    if (lessonNo.isEven)
      const CursorQuizQuestion(
        question: 'Which tile is a Dragon tile?',
        options: ['red', 'east', 'm9', 's4'],
        correctIndex: 0,
        explanation: 'Red/Green/White are Dragons; east is a Wind.',
        type: CursorQuizType.tileSelection,
        tiles: ['east', 'south', 'west', 'north', 'red', 'green', 'white', 'm1', 'm9', 's1', 's9', 'p1', 'p9'],
      )
    else
      const CursorQuizQuestion(
        question: 'How many total suited tiles are in a 144-tile set?',
        options: ['96', '108', '120', '136'],
        correctIndex: 1,
        explanation: '3 suits × 9 ranks × 4 copies = 108.',
      ),
  ];
}

List<CursorQuizQuestion> _playQuestions(int lessonNo) {
  return [
    const CursorQuizQuestion(
      question: 'What is the normal turn order action?',
      options: ['Discard then draw', 'Draw then discard', 'Call then skip', 'Pass only'],
      correctIndex: 1,
      explanation: 'A standard turn is draw one tile then discard one.',
    ),
    const CursorQuizQuestion(
      question: 'Which claim has highest priority on a discard?',
      options: ['Chow', 'Pong', 'Kong', 'Win (Hu)'],
      correctIndex: 3,
      explanation: 'Hu overrides all other claims.',
    ),
    if (lessonNo % 3 == 0)
      const CursorQuizQuestion(
        question: 'You hold s3 and s4. Which discard lets you call Chow?',
        options: ['s2', 'red', 'east', 'p2'],
        correctIndex: 0,
        explanation: 's2 completes 2-3-4 in Bamboo.',
        type: CursorQuizType.tileSelection,
        tiles: ['s3', 's4', 'm1', 'm2', 'm3', 'p5', 'p6', 'p7', 'east', 'east', 'red', 'red', 'white'],
      )
    else
      const CursorQuizQuestion(
        question: 'After calling Pong, what must you do next?',
        options: ['Draw two tiles', 'Discard one tile', 'Pass turn silently', 'Reshuffle wall'],
        correctIndex: 1,
        explanation: 'Expose Pong and immediately discard one tile.',
      ),
  ];
}

List<CursorQuizQuestion> _winQuestions(int lessonNo) {
  return [
    const CursorQuizQuestion(
      question: 'What does “Ting” usually mean?',
      options: ['Already won', 'One tile from winning', 'No legal hand', 'Dealer only state'],
      correctIndex: 1,
      explanation: 'Ting means your hand is waiting for winning tile(s).',
    ),
    const CursorQuizQuestion(
      question: 'Which hand type has no sequences?',
      options: ['All Pongs', 'Half Flush', 'Mixed Triple Chow', 'Ping Hu'],
      correctIndex: 0,
      explanation: 'All Pongs uses triplets/kongs and one pair.',
    ),
    if (lessonNo.isOdd)
      const CursorQuizQuestion(
        question: 'Which tile completes this hand as a simple sequence wait?',
        options: ['p3', 'east', 'red', 'm9'],
        correctIndex: 0,
        explanation: 'p1-p2 waits for p3 to complete the chow.',
        type: CursorQuizType.tileSelection,
        tiles: ['m1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9', 'p1', 'p2', 'red', 'red'],
      )
    else
      const CursorQuizQuestion(
        question: 'A Full Flush uses:',
        options: ['One suit only, no honors', 'Two suits + dragons', 'Only honors', 'Any random mix'],
        correctIndex: 0,
        explanation: 'Full Flush is one suit without honors.',
      ),
  ];
}

List<CursorQuizQuestion> _scoreQuestions(int lessonNo) {
  return [
    const CursorQuizQuestion(
      question: 'What is the usual minimum to declare a win in HK rules?',
      options: ['1 faan', '2 faan', '3 faan', '5 faan'],
      correctIndex: 2,
      explanation: 'A common table minimum is 3 faan.',
    ),
    const CursorQuizQuestion(
      question: 'Self-draw generally means payment from:',
      options: ['Dealer only', 'Discarder only', 'All 3 opponents', 'No payment'],
      correctIndex: 2,
      explanation: 'On self-draw, all opponents pay.',
    ),
    if (lessonNo % 2 == 1)
      const CursorQuizQuestion(
        question: 'Which tile keeps this Half Flush plan (Characters + honors)?',
        options: ['m8', 's8', 'p8', 'green'],
        correctIndex: 0,
        explanation: 'Half Flush keeps one suit plus honors.',
        type: CursorQuizType.tileSelection,
        tiles: ['m2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm8', 'east', 'east', 'east', 'red', 'red'],
      )
    else
      const CursorQuizQuestion(
        question: 'A 5-faan hand is typically how much above base (relative)?',
        options: ['×2', '×4', '×8', '×16'],
        correctIndex: 1,
        explanation: 'Using doubling above threshold, 5-faan maps to ×4.',
      ),
  ];
}

List<CursorQuizQuestion> _strategyQuestions(int lessonNo) {
  return [
    const CursorQuizQuestion(
      question: 'When opponents look ready, your default adjustment is:',
      options: ['Push harder always', 'Shift to safer discards', 'Reveal full hand', 'Skip all turns'],
      correctIndex: 1,
      explanation: 'Defense reduces risk of dealing into a win.',
    ),
    const CursorQuizQuestion(
      question: 'Which tiles are often most dangerous to discard?',
      options: ['Middle numbers', 'Flowers', 'Any wind tile', 'Already dead tiles'],
      correctIndex: 0,
      explanation: 'Middle tiles connect to many waits.',
    ),
    if (lessonNo >= 3)
      const CursorQuizQuestion(
        question: 'Pick the safer late-game discard.',
        options: ['east', 'm5', 'p6', 's4'],
        correctIndex: 0,
        explanation: 'A repeatedly visible wind is often safest.',
        type: CursorQuizType.tileSelection,
        tiles: ['east', 'east', 'm2', 'm3', 'm4', 's4', 's5', 's6', 'p4', 'p5', 'p6', 'red', 'red'],
      )
    else
      const CursorQuizQuestion(
        question: 'Shanten is best described as:',
        options: ['Current score', 'Tiles away from ready/win', 'Dealer count', 'Flower bonus'],
        correctIndex: 1,
        explanation: 'Shanten tracks hand distance to completion.',
      ),
  ];
}
