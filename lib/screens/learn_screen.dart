import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/wrong_answer.dart';
import '../models/mahjong_data.dart';
import '../models/quiz_answer.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/mahjong_tile.dart';
import '../widgets/quiz/question_inputs.dart';
import '../widgets/quiz/tile_markers.dart';
import '../services/audio_service.dart';
import '../services/app_i18n.dart';
import 'paywall_screen.dart';

/// ── LearnScreen ──
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String? _selectedStageId;
  final Map<String, GlobalKey> _stageKeys = {};
  final Map<String, GlobalKey> _lessonKeys = {};
  late final AudioService _audio;

  // Multi-choice selection state
  final Set<int> _selectedOptions = {};

  // Tile ordering state
  List<String> _shuffledOrderingTiles = [];
  bool _orderingSubmitted = false;

  // Fill-in-the-blank answer
  String _answerText = '';

  // Matching answers: left item -> chosen right item
  Map<String, String> _matches = {};

  // Lesson intro card (shown before the dialogue starts) — Gary 2026-11-24 D3a
  bool _showLessonIntro = false;

  // Quiz feedback state
  bool? _feedbackCorrect;
  bool _feedbackActive = false;

  // Press scale state
  int? _pressedOptionIndex;

  /// Detect mascot expression from message text.
  MascotExpression _getMascotExpression(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('correct') ||
        lower.contains('well done') ||
        lower.contains('great') ||
        lower.contains('excellent') ||
        lower.contains('right') ||
        lower.contains('good')) {
      return MascotExpression.happy;
    }
    if (lower.contains('wrong') ||
        lower.contains('try again') ||
        lower.contains('not quite') ||
        lower.contains('incorrect') ||
        lower.contains('no,')) {
      return MascotExpression.sad;
    }
    if (lower.contains('wow') ||
        lower.contains('amazing') ||
        lower.contains('incredible') ||
        lower.contains('unbelievable') ||
        lower.contains('fantastic')) {
      return MascotExpression.excited;
    }
    if (lower.contains('think') ||
        lower.contains('consider') ||
        lower.contains('strategy') ||
        lower.contains('analyze') ||
        lower.contains('plan')) {
      return MascotExpression.thinking;
    }
    if (lower.contains('proud') ||
        lower.contains('achievement') ||
        lower.contains('unlocked') ||
        lower.contains('congratulations') ||
        lower.contains('congrats')) {
      return MascotExpression.content;
    }
    return MascotExpression.happy;
  }

  @override
  void initState() {
    super.initState();
    _audio = AudioService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameState>();
      if (game.targetStageId != null) {
        _handleStageNavigation(game);
      }
    });
  }

  void _handleStageNavigation(GameState game) {
    final target = game.targetStageId;
    game.clearTargetStage();
    if (target == null) return;
    setState(() {
      _selectedStageId = target;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      final key = _stageKeys[target];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    if (game.showOnboarding) {
      return _buildOnboarding(game);
    }

    if (game.currentLessonId != null) {
      return _buildLessonView(game);
    }

    return _buildStageList(game);
  }

  // ═══ Onboarding ═══
  Widget _buildOnboarding(GameState game) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/tiles/p1.png',
                width: 100,
                height: 133,
                errorBuilder: (context, error, stackTrace) =>
                    Text('🐼', style: GoogleFonts.nunito(fontSize: 80)),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Ludi!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Learn board games step by step.\nI\'m your panda guide!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => game.completeOnboarding(),
                child: const Text('Start Learning'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ Stage / Lesson List ═══
  Widget _buildStageList(GameState game) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Choose Your Lesson',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${game.completedLessons} / ${game.stages.fold(0, (sum, s) => sum + s.lessonCount)} lessons completed',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedStageId == null)
              ..._buildStageCards(game)
            else
              ..._buildLessonCards(game),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStageCards(GameState game) {
    return game.stages.asMap().entries.map((entry) {
      final stageIdx = entry.key;
      final stage = entry.value;
      final key = _stageKeys.putIfAbsent(stage.id, () => GlobalKey());
      // Completion of the previous stage drives the unlock (Duolingo-style).
      final prevStage = stageIdx > 0 ? game.stages[stageIdx - 1] : null;
      final prevCompleted = prevStage?.completedLessons ?? 0;
      final prevTotal = prevStage?.lessonCount ?? 0;
      final prevFullyDone = prevTotal > 0 && prevCompleted >= prevTotal;
      final unlockProgress = prevTotal > 0
          ? (prevCompleted / prevTotal).clamp(0.0, 1.0).toDouble()
          : 0.0;

      return Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: stage.isUnlocked
              ? () => setState(() => _selectedStageId = stage.id)
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stage.isUnlocked ? Colors.white : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    stage.isUnlocked &&
                        stage.completedLessons > 0 &&
                        stage.completedLessons < stage.lessonCount
                    ? const Color(0xFF4CAF50)
                    : stage.isUnlocked
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFFEEEEEE),
                width:
                    stage.isUnlocked &&
                        stage.completedLessons > 0 &&
                        stage.completedLessons < stage.lessonCount
                    ? 2
                    : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: stage.isUnlocked
                        ? stage.color.withAlpha(25)
                        : const Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      stage.icon,
                      color: stage.isUnlocked
                          ? stage.color
                          : const Color(0xFFBDBDBD),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.localizedTitle,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: stage.isUnlocked
                              ? const Color(0xFF2D2D2D)
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.localizedSubtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: stage.isUnlocked
                              ? const Color(0xFF757575)
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (stage.isUnlocked && stage.progress >= 1.0)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF2E7D32),
                        size: 22,
                      )
                    else if (stage.isUnlocked) ...[
                      Text(
                        '${stage.completedLessons}/${stage.lessonCount}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: stage.color,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.lock_rounded,
                        size: 18,
                        color: const Color(0xFFBDBDBD),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prevTotal > 0 ? '$prevCompleted/$prevTotal' : '',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 56,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: unlockProgress,
                            minHeight: 4,
                            backgroundColor: const Color(0xFFE0E0E0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              prevFullyDone
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFFA726),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (stage.isUnlocked) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: stage.color,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildLessonCards(GameState game) {
    final stage = game.stages.firstWhere(
      (s) => s.id == _selectedStageId,
      orElse: () => game.stages.first,
    );
    final lessons = game.allLessons
        .where((l) => l.stageId == _selectedStageId)
        .toList();
    lessons.sort((a, b) => a.id.compareTo(b.id));

    return [
      GestureDetector(
        onTap: () => setState(() => _selectedStageId = null),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_rounded, size: 16, color: stage.color),
              const SizedBox(width: 4),
              Text(
                stage.localizedTitle,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: stage.color,
                ),
              ),
            ],
          ),
        ),
      ),
      ...lessons.map((lesson) {
        final key = _lessonKeys.putIfAbsent(lesson.id, () => GlobalKey());
        final completed = game.isLessonCompleted(lesson.id);
        final unlocked = game.isLessonUnlocked(lesson.id);
        final bestAccuracy = game.getLessonBestAccuracy(lesson.id);
        // Gary 2026-11-24 (D2a): a crown means a perfect run, check means done.
        final crowned = completed && bestAccuracy >= 100;
        final isCurrent = game.lastLessonId == lesson.id && !completed;

        return Padding(
          key: key,
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: unlocked ? () => _openLesson(game, lesson.id) : null,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFFE8F5E9)
                    : unlocked
                    ? Colors.white
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEEEEEE),
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed
                          ? (crowned
                                ? const Color(0xFFF9A825)
                                : const Color(0xFF2E7D32))
                          : isCurrent
                          ? const Color(0xFF4CAF50)
                          : unlocked
                          ? const Color(0xFFE8F5E9)
                          : Colors.transparent,
                      border: !completed && !isCurrent && unlocked
                          ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: completed
                          ? Icon(
                              crowned
                                  ? Icons.workspace_premium_rounded
                                  : Icons.check_rounded,
                              color: Colors.white,
                              size: crowned ? 20 : 18,
                            )
                          : isCurrent
                          ? Text(
                              '▶',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : !unlocked
                          ? Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: const Color(0xFFBDBDBD),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.localizedTitle,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: unlocked
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: completed
                                ? const Color(0xFF9E9E9E)
                                : unlocked
                                ? const Color(0xFF2D2D2D)
                                : const Color(0xFFBDBDBD),
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (!unlocked) ...[
                          const SizedBox(height: 2),
                          Text(
                            game.getUnlockConditionText(lesson.id),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (completed)
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF2E7D32),
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    ];
  }

  // ═══ Lesson Content View ═══
  Widget _buildLessonView(GameState game) {
    final lesson = game.currentLesson;
    if (lesson == null) return const SizedBox.shrink();

    final titleText = game.isReviewMode
        ? 'Review: Wrong Answers'
        : lesson.localizedTitle;

    // Find stage color for dynamic background
    Color stageColor = const Color(0xFF4CAF50);
    try {
      final stage = game.stages.firstWhere((s) => s.id == lesson.stageId);
      stageColor = stage.color;
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (game.isReviewMode) {
              game.exitReview();
            }
            game.clearLesson();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                titleText,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4CAF50),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            // Hearts indicator (hidden in review mode)
            if (!game.isReviewMode) _buildHeartsIndicator(game),
          ],
        ),
      ),
      body: GestureDetector(
        // Gary 2026-11-24 (P1): the whole lesson body advances the dialogue,
        // not just the narrow dialogue column on the left.
        behavior: HitTestBehavior.opaque,
        onTap: _canAdvanceDialogue(game) ? () => _advanceDialogue(game) : null,
        child: Container(
          // Fill the body: without an explicit size the dialogue column only
          // grew to the width of its bubble, leaving a dead strip on the right.
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [stageColor.withAlpha(8), Colors.white],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: game.quizFinished
                    ? _buildQuizResult(game)
                    : game.showFailure
                    ? _buildFailureView(game)
                    : game.dialogueIndex < game.dialogue.length
                    ? (_showLessonIntro
                          ? _buildLessonIntro(game)
                          : _buildDialogueArea(game))
                    : _buildQuizArea(game),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hearts indicator for lesson AppBar ──
  Widget _buildHeartsIndicator(GameState game) {
    final hearts = game.hearts;
    final maxHearts = game.maxHearts;
    final isPremium = game.isPremium;

    if (isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFE65100),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '∞',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE65100),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hearts <= 1 ? const Color(0xFFFFEBEE) : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          maxHearts,
          (i) => Padding(
            padding: EdgeInsets.only(left: i > 0 ? 2 : 0),
            child: Icon(
              i < hearts
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 16,
              color: i < hearts
                  ? const Color(0xFFE53935)
                  : const Color(0xFFBDBDBD),
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogue Area ──
  /// Opens a lesson and shows the intro card first (Gary 2026-11-24 D3a).
  void _openLesson(GameState game, String lessonId) {
    setState(() {
      _showLessonIntro = true;
      _answerText = '';
      _matches = {};
      _selectedOptions.clear();
    });
    game.loadLesson(lessonId);
  }

  /// True while the lesson is showing a dialogue step that can be advanced.
  bool _canAdvanceDialogue(GameState game) =>
      !game.quizFinished &&
      !game.showFailure &&
      game.dialogueIndex < game.dialogue.length;

  void _advanceDialogue(GameState game) {
    if (!_canAdvanceDialogue(game)) return;
    _audio.playTap();
    final advanced = game.advanceDialogue();
    if (!advanced) {
      game.startQuiz(game.currentQuestions);
    }
  }

  /// Mascot pose: keyword match wins, otherwise the poses rotate through the
  /// lesson so the teacher does not freeze on one face (Gary 2026-11-24 P2).
  MascotExpression _expressionFor(GameState game) {
    final text = game.dialogue[game.dialogueIndex].text.toLowerCase();
    final hasKeyword =
        text.contains('correct') ||
        text.contains('well done') ||
        text.contains('great') ||
        text.contains('excellent') ||
        text.contains('right') ||
        text.contains('good') ||
        text.contains('wrong') ||
        text.contains('try again') ||
        text.contains('not quite') ||
        text.contains('incorrect') ||
        text.contains('wow') ||
        text.contains('amazing') ||
        text.contains('think') ||
        text.contains('strategy') ||
        text.contains('proud') ||
        text.contains('congrat');
    if (hasKeyword)
      return _getMascotExpression(game.dialogue[game.dialogueIndex].text);
    const rotation = <MascotExpression>[
      MascotExpression.content,
      MascotExpression.thinking,
      MascotExpression.wink,
      MascotExpression.excited,
    ];
    return rotation[game.dialogueIndex % rotation.length];
  }

  /// Lesson intro card — shown before the dialogue so a lesson never starts
  /// by accident (Gary 2026-11-24 D3a).
  Widget _buildLessonIntro(GameState game) {
    final lesson = game.currentLesson;
    final title = lesson?.localizedTitle ?? '';
    final questionCount = game.currentQuestions.length;
    final lessonId = game.currentLessonId;
    final best = lessonId == null ? 0 : game.getLessonBestAccuracy(lessonId);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MascotWidget(
                size: MascotSize.medium.value,
                expression: MascotExpression.content,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$questionCount questions',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF757575),
                ),
              ),
              if (best > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Best so far: $best%',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF57F17),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showLessonIntro = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() {
                  _showLessonIntro = false;
                  _advanceDialogue(game);
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Skip the lesson intro',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogueArea(GameState game) {
    final msg = game.dialogue[game.dialogueIndex];
    final isSpeaker = msg.speaker == 'mj';
    final expression = _expressionFor(game);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(game.dialogueIndex),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            const Spacer(),
            if (isSpeaker)
              MascotWidget(
                size: MascotSize.medium.value,
                expression: expression,
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B93E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text('🙋', style: GoogleFonts.nunito(fontSize: 36)),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              isSpeaker ? 'Ludi Sensei' : 'You',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSpeaker
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE8B93E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildDialogueBubble(msg),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to continue',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: const Color(0xFFBDBDBD),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// Parse dialogue text, replacing {{tile_id}} markers with tile image widgets.
  List<InlineSpan> _parseDialogueText(String text) => parseTileMarkers(text);

  Widget _buildDialogueBubble(DialogueMessage msg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: _parseDialogueText(msg.text))),
        if (msg.tileIds != null && msg.tileIds!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Center(
            child: Wrap(
              spacing: 3,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: msg.tileIds!
                  .map((id) => MahjongTile(tileId: id, size: 52))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  // ── Quiz Area ──
  /// Collects the answer state and callbacks every question widget needs.
  QuestionInputConfig _questionInputConfig(GameState game, QuizQuestion q) {
    return QuestionInputConfig(
      selected: _selectedOptions,
      orderingTiles: _shuffledOrderingTiles,
      answerText: _answerText,
      matches: _matches,
      feedbackActive: _feedbackActive,
      feedbackCorrect: _feedbackCorrect,
      pressedOption: _pressedOptionIndex,
      onOptionTap: (idx) => setState(() {
        if (q.type == QuizType.multiChoice) {
          if (!_selectedOptions.add(idx)) {
            _selectedOptions.remove(idx);
          }
        } else {
          _selectedOptions
            ..clear()
            ..add(idx);
        }
      }),
      onPressedOption: (idx) => setState(() => _pressedOptionIndex = idx),
      onReorder: (oldIndex, newIndex) => setState(() {
        final tile = _shuffledOrderingTiles.removeAt(oldIndex);
        _shuffledOrderingTiles.insert(newIndex, tile);
      }),
      onTextChanged: (value) => setState(() => _answerText = value),
      onMatch: (left, right) => setState(() => _matches[left] = right),
      onSubmit: () => _submitForType(game, q),
    );
  }

  /// Routes the submit to the handler that builds the right [QuizAnswer].
  void _submitForType(GameState game, QuizQuestion q) {
    switch (q.type) {
      case QuizType.tileOrdering:
        _submitTileOrdering(game, q);
        break;
      case QuizType.fillBlank:
        _submitFillBlank(game, q);
        break;
      case QuizType.matching:
        _submitMatching(game, q);
        break;
      case QuizType.singleChoice:
      case QuizType.multiChoice:
      case QuizType.tileSelection:
        _submitMultiChoice(game, q);
        break;
    }
  }

  Widget _buildQuizArea(GameState game) {
    if (game.currentQuestions.isEmpty) return const SizedBox.shrink();

    final q = game.currentQuestions[game.currentQuestionIndex];
    final prompt = splitTrailingHand(q.question);

    // Initialize shuffled tiles for ordering questions
    if (q.type == QuizType.tileOrdering &&
        _shuffledOrderingTiles.isEmpty &&
        !_orderingSubmitted) {
      final tiles = List<String>.from(q.tiles ?? []);
      tiles.shuffle(Random());
      _shuffledOrderingTiles = tiles;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Progress
          Row(
            children: [
              Text(
                game.isReviewMode
                    ? 'Review ${game.currentQuestionIndex + 1} / ${game.currentQuestions.length}'
                    : 'Question ${game.currentQuestionIndex + 1} / ${game.currentQuestions.length}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  game.currentQuestions.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= game.currentQuestionIndex
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Question (supports {{tile_id}} markers). A trailing run of tiles is
          // the player's hand; it is laid out separately so it stays grouped.
          Text.rich(
            TextSpan(children: _parseDialogueText(prompt.text)),
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          if (prompt.handTiles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final tile in prompt.handTiles)
                  MahjongTile(tileId: tile, size: 36),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // ── Render by question type (one dispatch table, see
          // buildQuestionInput) ──
          buildQuestionInput(
            question: q,
            config: _questionInputConfig(game, q),
          ),
        ],
      ),
    );
  }

  /// Single submit path for every question type.
  ///
  /// Correctness comes from `isQuizAnswerCorrect`, the same function the
  /// provider uses, so the UI and the score can never disagree.
  void _submitAnswer(GameState game, QuizQuestion q, QuizAnswer answer) {
    final isCorrect = isQuizAnswerCorrect(q, answer);
    final isOrdering = q.type == QuizType.tileOrdering;

    setState(() {
      _feedbackActive = true;
      _feedbackCorrect = isCorrect;
      if (isOrdering) _orderingSubmitted = true;
    });

    if (isCorrect) {
      _audio.playCorrect();
      HapticFeedback.lightImpact();
    } else {
      _audio.playWrong();
      HapticFeedback.heavyImpact();
    }

    final delay = Duration(milliseconds: isOrdering ? 1200 : 800);
    Future.delayed(delay, () {
      if (!mounted) return;

      game.submitAnswer(answer, q);

      setState(() {
        _selectedOptions.clear();
        _answerText = '';
        _matches = {};
        _feedbackCorrect = null;
        _feedbackActive = false;
        _shuffledOrderingTiles = [];
        _orderingSubmitted = false;
      });
    });
  }

  void _submitMultiChoice(GameState game, QuizQuestion q) {
    final selected = _selectedOptions.toList();
    _submitAnswer(game, q, QuizAnswer.choice(selected));
  }

  void _submitTileOrdering(GameState game, QuizQuestion q) {
    _submitAnswer(
      game,
      q,
      QuizAnswer.ordering(List<String>.from(_shuffledOrderingTiles)),
    );
  }

  void _submitFillBlank(GameState game, QuizQuestion q) {
    _submitAnswer(game, q, QuizAnswer.text(_answerText));
  }

  void _submitMatching(GameState game, QuizQuestion q) {
    _submitAnswer(
      game,
      q,
      QuizAnswer.matching(Map<String, String>.from(_matches)),
    );
  }

  // ── Quiz Result ──
  Widget _buildQuizResult(GameState game) {
    final totalQuestions = game.isReviewMode
        ? game.reviewQuestions.length
        : game.currentQuestions.length;
    final correct = game.correctAnswers;
    final wrong = totalQuestions - correct;
    final accuracy = totalQuestions > 0
        ? ((correct / totalQuestions) * 100).toInt()
        : 0;
    final passed = correct >= totalQuestions / 2;

    // ── Celebration screen for passed normal-mode lessons ──
    if (passed && !game.isReviewMode) {
      return _buildCelebrationView(game, correct, totalQuestions, accuracy);
    }

    // ── Review mode or not-passed: keep the classic result screen ──
    return _buildClassicResultView(
      game,
      correct,
      wrong,
      totalQuestions,
      accuracy,
      passed,
    );
  }

  // ═══ Celebration View (matches the design mockup) ═══
  Widget _buildCelebrationView(
    GameState game,
    int correct,
    int total,
    int accuracy,
  ) {
    final elapsed = game.lessonElapsedSeconds;
    final mins = (elapsed ~/ 60).toString().padLeft(2, '0');
    final secs = (elapsed % 60).toString().padLeft(2, '0');
    final timeStr = '$mins:$secs';

    // Stars based on accuracy
    int stars = 1;
    if (accuracy >= 90)
      stars = 3;
    else if (accuracy >= 70)
      stars = 2;

    return Stack(
      children: [
        // Green gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF388E3C)],
            ),
          ),
        ),
        // Confetti decorations
        ..._buildConfetti(),
        // Content
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Panda mascot celebrating
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: const MascotWidget(
                          expression: MascotExpression.excited,
                          size: 140,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        AppI18n.t('lessonComplete.title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Stats card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // XP
                            _celebrationStatRow(
                              Icons.bolt_rounded,
                              '+20 XP',
                              const Color(0xFFE8B93E),
                            ),
                            const SizedBox(height: 16),
                            // Stars
                            _celebrationStarsRow(stars),
                            const SizedBox(height: 16),
                            // Time
                            _celebrationStatRow(
                              Icons.timer_rounded,
                              timeStr,
                              const Color(0xFF42A5F5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Continue Learning button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            _audio.playStageComplete();
                            setState(() {
                              _selectedOptions.clear();
                              _shuffledOrderingTiles = [];
                              _orderingSubmitted = false;
                            });
                            final nextId = game.getNextLessonId();
                            if (nextId != null) {
                              _openLesson(game, nextId);
                            } else {
                              game.clearLesson();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppI18n.t('lessonComplete.continue'),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Back to Lesson Map button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            _audio.playTap();
                            setState(() {
                              _selectedOptions.clear();
                              _shuffledOrderingTiles = [];
                              _orderingSubmitted = false;
                            });
                            game.clearLesson();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppI18n.t('lessonComplete.backToMap'),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _celebrationStatRow(IconData icon, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  Widget _celebrationStarsRow(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? const Color(0xFFE8B93E) : const Color(0xFFE0E0E0),
            size: 36,
          ),
        );
      }),
    );
  }

  List<Widget> _buildConfetti() {
    final rng = Random();
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFFCA28),
      const Color(0xFFFFFFFF),
      const Color(0xFFA5D6A7),
      const Color(0xFFFFAB91),
    ];
    return List.generate(20, (i) {
      final left = rng.nextDouble() * 100;
      final top = rng.nextDouble() * 60;
      final size = 6.0 + rng.nextDouble() * 8;
      final color = colors[i % colors.length];
      final isCircle = i % 3 == 0;
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withAlpha(120),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(2),
          ),
        ),
      );
    });
  }

  // ═══ Classic Result View (for review mode or not-passed) ═══
  Widget _buildClassicResultView(
    GameState game,
    int correct,
    int wrong,
    int totalQuestions,
    int accuracy,
    bool passed,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score circle with pulse animation
          _PulseScoreCircle(
            correct: correct,
            totalQuestions: totalQuestions,
            passed: passed,
          ),
          const SizedBox(height: 16),

          Text(
            game.isReviewMode
                ? 'Review Complete!'
                : passed
                ? 'Great Job!'
                : 'Keep Trying!',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: passed ? const Color(0xFF4CAF50) : const Color(0xFFE8B93E),
            ),
          ),
          const SizedBox(height: 12),

          // Stats cards
          Row(
            children: [
              _buildStatCard(
                'Accuracy',
                '$accuracy%',
                passed ? const Color(0xFF2E7D32) : const Color(0xFFE8B93E),
              ),
              const SizedBox(width: 12),
              _buildStatCard('Correct', '$correct', const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _buildStatCard(
                'Wrong',
                '$wrong',
                wrong > 0 ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // XP info (only in normal mode)
          if (!game.isReviewMode) ...[
            Text(
              '+${passed ? 20 : 5} XP',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE8B93E),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Wrong answer explanations
          if (wrong > 0) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE8B93E).withAlpha(80),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFE8B93E),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Review Mistakes',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8D6E00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(wrong > 3 ? 3 : wrong, (i) {
                    final waList = game.wrongAnswers;
                    if (i < waList.length) {
                      final wa = waList[waList.length - 1 - i];
                      return _buildWrongAnswerItem(game, wa);
                    }
                    return const SizedBox.shrink();
                  }),
                  if (wrong > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '...and ${wrong - 3} more',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          if (game.isReviewMode) ...[
            // Review mode buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  game.exitReview();
                  game.clearLesson();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  game.exitReview();
                  game.startWrongAnswerReview();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Retry Review',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Normal mode buttons (not passed)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => game.retryQuiz(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Retry Quiz',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Review wrong answers button
            if (wrong > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      game.startWrongAnswerReview();
                      setState(() {
                        _selectedOptions.clear();
                        _shuffledOrderingTiles = [];
                        _orderingSubmitted = false;
                      });
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(
                      'Review Wrong Answers ($wrong)',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8B93E),
                      side: const BorderSide(color: Color(0xFFE8B93E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

            // Next lesson
            TextButton(
              onPressed: game.hearts > 0
                  ? () {
                      setState(() {
                        _selectedOptions.clear();
                        _shuffledOrderingTiles = [];
                        _orderingSubmitted = false;
                      });
                      final nextId = game.getNextLessonId();
                      if (nextId != null) {
                        _openLesson(game, nextId);
                      } else {
                        game.clearLesson();
                      }
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next Lesson',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: game.hearts > 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: game.hearts > 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFBDBDBD),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongAnswerItem(GameState game, WrongAnswer wa) {
    // Find the lesson and question
    Lesson? lesson;
    try {
      lesson = game.allLessons.firstWhere((l) => l.id == wa.lessonId);
    } catch (_) {
      return const SizedBox.shrink();
    }

    if (wa.questionIndex < 0 || wa.questionIndex >= lesson.questions.length) {
      return const SizedBox.shrink();
    }

    final q = lesson.localizedQuestions[wa.questionIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.question,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 6),
            if (q.type != QuizType.tileOrdering &&
                q.correctIndex < q.options.length) ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Correct: ${q.options[q.correctIndex]}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (q.explanation != null && q.explanation!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                q.explanation!,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: const Color(0xFF757575),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Failure View ──
  Widget _buildFailureView(GameState game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💔', style: GoogleFonts.nunito(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Out of Hearts!',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hearts refill daily, or go Premium for unlimited!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Upgrade to Pro',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next Lesson',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Color(0xFFBDBDBD),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseScoreCircle extends StatefulWidget {
  final int correct;
  final int totalQuestions;
  final bool passed;

  const _PulseScoreCircle({
    required this.correct,
    required this.totalQuestions,
    required this.passed,
  });

  @override
  State<_PulseScoreCircle> createState() => _PulseScoreCircleState();
}

class _PulseScoreCircleState extends State<_PulseScoreCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passed = widget.passed;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: passed
                ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                : [const Color(0xFFE8B93E), const Color(0xFFFFCA28)],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (passed ? const Color(0xFF4CAF50) : const Color(0xFFE8B93E))
                      .withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.correct}',
                style: GoogleFonts.nunito(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                '/ ${widget.totalQuestions}',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
