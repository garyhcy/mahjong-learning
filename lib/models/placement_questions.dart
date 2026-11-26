import 'placement_question.dart';

/// 16 placement questions, four per tier, all taken from verified lessons.
const List<PlacementQuestion> placementQuestions = [
  PlacementQuestion(
    tier: 1,
    lessonId: "1-1",
    prompt: "How many different tile faces are in a full 144-tile set?",
    options: ["34", "36", "42", "44"],
    correctIndexes: [2],
  ),
  PlacementQuestion(
    tier: 1,
    lessonId: "2-1",
    prompt: "Which of these are valid Sequences (Chow)? Select all that apply.",
    options: [
      "{{m4}}{{m5}}{{m6}}",
      "{{p2}}{{p3}}{{p4}}",
      "{{s8}}{{s9}}{{s1}}",
      "{{m6}}{{p7}}{{s8}}",
    ],
    correctIndexes: [0, 1],
  ),
  PlacementQuestion(
    tier: 1,
    lessonId: "3-1",
    prompt: "How many rounds does a full game have?",
    options: ["1", "2", "3", "4"],
    acceptedAnswers: ["4", "four", "4 rounds", "four rounds"],
  ),
  PlacementQuestion(
    tier: 1,
    lessonId: "4-1",
    prompt:
        "You win a 3-Faan hand on a discard (出銃). How much does the discarder pay?",
    options: ["4", "8", "12", "16"],
    correctIndexes: [1],
  ),
  PlacementQuestion(
    tier: 2,
    lessonId: "5-1",
    prompt:
        "A hand is four Pongs plus a pair. Can it also be scored as 平糊 (All Chows)?",
    options: [
      "Yes, if the hand is concealed",
      "Yes, if it is won by self-draw",
      "No — 平糊 needs four Chows and no triplets",
      "No — 平糊 needs honor tiles",
    ],
    correctIndexes: [2],
  ),
  PlacementQuestion(
    tier: 2,
    lessonId: "6-1",
    prompt: "Which statements about flower scoring are correct?",
    options: [
      "One matching seat flower is worth 1 Faan",
      "All four Seasons together (一台花) are worth 2 Faan in total",
      "A hand holding no flowers at all scores 無花 for 1 Faan",
      "Every flower you declare is worth 1 Faan",
    ],
    correctIndexes: [0, 1, 2],
  ),
  PlacementQuestion(
    tier: 2,
    lessonId: "7-1",
    prompt: "Which of these are worth exactly 1 Faan? (Select all that apply)",
    options: [
      "Self-draw (自摸)",
      "Concealed hand (門前清)",
      "No Flowers (無花)",
      "All Pongs (對對糊)",
      "Full Flush (清一色)",
    ],
    correctIndexes: [0, 1, 2],
  ),
  PlacementQuestion(
    tier: 2,
    lessonId: "7-2",
    prompt:
        "You win a 5-Faan hand on a discard. How much does the discarder pay?",
    acceptedAnswers: ["24", "\$24", "twenty-four", "twenty four"],
  ),
  PlacementQuestion(
    tier: 3,
    lessonId: "8-1",
    prompt:
        "An opponent who kept every honour tile for ten turns now discards {{south}}. What does this most likely mean?",
    options: [
      "They have given up on an honour-based plan",
      "They are collecting honours harder than before",
      "They have no hand at all",
      "Their hand is already complete",
    ],
    correctIndexes: [0],
  ),
  PlacementQuestion(
    tier: 3,
    lessonId: "9-1",
    prompt:
        "What does a successful decoy discard actually buy you? (Select all that apply)",
    options: [
      "Opponents treat your real suit as safe and throw it to you",
      "You get claim chances on the tiles you need",
      "A guaranteed win in that round",
      "Extra faan on the scoring table",
      "Protection from being robbed on a kong",
    ],
    correctIndexes: [0, 1],
  ),
  PlacementQuestion(
    tier: 3,
    lessonId: "10-1",
    prompt:
        "Turn 14. Which of these factors make a tile more dangerous to discard?",
    options: [
      "It is a fresh middle tile that nobody has thrown",
      "The target opponent threw it themselves earlier this rotation",
      "It is an honour tile that has not appeared at all yet",
      "Three of its four copies are already visible",
    ],
    correctIndexes: [0, 2],
  ),
  PlacementQuestion(
    tier: 3,
    lessonId: "10-2",
    prompt:
        "You are exactly 24 points behind with one hand left. A 5-Faan win on a discard pays 24 points. What is true?",
    options: [
      "A 5-Faan discard win ties it, and a 5-Faan self-draw wins it outright",
      "Only a 10-Faan limit hand can help",
      "You must fold because the gap cannot be closed",
      "A 3-Faan self-draw ties it",
    ],
    correctIndexes: [0],
  ),
  PlacementQuestion(
    tier: 4,
    lessonId: "11-1",
    prompt:
        "You hold {{m2}}{{m3}}{{m4}}{{m5}}{{m6}}{{p7}}{{p8}}{{p9}}{{s4}}{{s4}}{{s9}}{{east}}{{red}}. How many complete melds do you already have?",
    options: [
      "Two melds, with two more to complete",
      "Three melds, with one more to complete",
      "One meld, with three more to complete",
      "Four melds, so the hand is already complete",
    ],
    correctIndexes: [0],
  ),
  PlacementQuestion(
    tier: 4,
    lessonId: "12-1",
    prompt:
        "A tile discarded by an opponent stops being absolutely safe as soon as...",
    options: [
      "they draw another tile",
      "the same tile is discarded by a second player",
      "they call Pong on a different tile",
      "the wall drops below twenty tiles",
    ],
    correctIndexes: [0],
  ),
  PlacementQuestion(
    tier: 4,
    lessonId: "13-1",
    prompt: "How many dragon triplets does Small Three Dragons 小三元 require?",
    options: ["One", "Two", "Three", "Four"],
    correctIndexes: [1],
  ),
  PlacementQuestion(
    tier: 4,
    lessonId: "14-1",
    prompt: "How many faan is Big Flower Hand 大花糊 worth?",
    options: ["3 faan", "7 faan", "8 faan", "10 faan"],
    correctIndexes: [3],
  ),
];
