import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/mahjong_data.dart';
import '../widgets/mascot_widget.dart';
import '../services/audio_service.dart';

/// ── MahjongTile widget ──
class MahjongTile extends StatelessWidget {
  final String tileId;
  final double size;
  final bool highlighted;
  final bool? isCorrect;
  final bool isDragging;

  const MahjongTile({
    super.key,
    required this.tileId,
    this.size = 64,
    this.highlighted = false,
    this.isCorrect,
    this.isDragging = false,
  });

  Color get _borderColor {
    if (isCorrect == true) return const Color(0xFF2E7D32);
    if (isCorrect == false) return const Color(0xFFD94040);
    if (highlighted) return const Color(0xFFE8B93E);
    return const Color(0xFFE0D5C0);
  }

  double get _borderWidth {
    if (isCorrect != null || highlighted) return 2.5;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = isDragging ? size * 1.1 : size;
    final tileWidth = effectiveSize;
    final tileHeight = effectiveSize * 4 / 3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: tileWidth,
      height: tileHeight,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor, width: _borderWidth),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'assets/tiles/$tileId.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFFFF8F0),
            child: Center(
              child: Text(
                tileId,
                style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  // Quiz feedback state
  bool? _feedbackCorrect;
  bool _feedbackActive = false;

  // Press scale state
  int? _pressedOptionIndex;

  /// Detect mascot expression from message text.
  MascotExpression _getMascotExpression(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('correct') || lower.contains('well done') ||
        lower.contains('great') || lower.contains('excellent') ||
        lower.contains('right') || lower.contains('good')) {
      return MascotExpression.happy;
    }
    if (lower.contains('wrong') || lower.contains('try again') ||
        lower.contains('not quite') || lower.contains('incorrect') ||
        lower.contains('no,')) {
      return MascotExpression.sad;
    }
    if (lower.contains('wow') || lower.contains('amazing') ||
        lower.contains('incredible') || lower.contains('unbelievable') ||
        lower.contains('fantastic')) {
      return MascotExpression.surprised;
    }
    if (lower.contains('think') || lower.contains('consider') ||
        lower.contains('strategy') || lower.contains('analyze') ||
        lower.contains('plan')) {
      return MascotExpression.thinking;
    }
    if (lower.contains('proud') || lower.contains('achievement') ||
        lower.contains('unlocked') || lower.contains('congratulations') ||
        lower.contains('congrats')) {
      return MascotExpression.proud;
    }
    return MascotExpression.idle;
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
        Scrollable.ensureVisible(key!.currentContext!,
            duration: const Duration(milliseconds: 400));
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
                    Text('🐼',
                        style:
                            GoogleFonts.nunito(fontSize: 80)),
              ),
              const SizedBox(height: 24),
              Text('Welcome to Ludi!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD94040))),
              const SizedBox(height: 12),
              Text(
                'Learn board games step by step.\nI\'m your panda guide!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 15, color: const Color(0xFF757575)),
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
        title: Text('Learn',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD94040))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Choose Your Lesson',
                style: GoogleFonts.nunito(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
                '${game.completedLessons} / ${game.stages.fold(0, (sum, s) => sum + s.lessonCount)} lessons completed',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: const Color(0xFF757575))),
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
    return game.stages.map((stage) {
      final key = _stageKeys.putIfAbsent(
          stage.id, () => GlobalKey());
      final progress = stage.lessonCount > 0
          ? stage.completedLessons / stage.lessonCount
          : 0.0;
      final percent = (progress * 100).toInt();

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
                color: stage.isUnlocked && stage.completedLessons > 0 &&
                        stage.completedLessons < stage.lessonCount
                    ? const Color(0xFFD94040)
                    : stage.isUnlocked
                        ? const Color(0xFFE0E0E0)
                        : const Color(0xFFEEEEEE),
                width: stage.isUnlocked && stage.completedLessons > 0 &&
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
                    child: Icon(stage.icon,
                        color: stage.isUnlocked
                            ? stage.color
                            : const Color(0xFFBDBDBD),
                        size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stage.title,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: stage.isUnlocked
                                ? const Color(0xFF2D2D2D)
                                : const Color(0xFFBDBDBD),
                          )),
                      const SizedBox(height: 2),
                      Text(stage.subtitle,
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: stage.isUnlocked
                                  ? const Color(0xFF757575)
                                  : const Color(0xFFBDBDBD))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (stage.isUnlocked && stage.progress >= 1.0)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32), size: 22)
                    else if (stage.isUnlocked) ...[
                      Text(
                        '${stage.completedLessons}/${stage.lessonCount}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: stage.color,
                        ),
                      ),
                      Text('$percent%',
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: const Color(0xFF9E9E9E))),
                    ] else ...[
                      Icon(Icons.lock_rounded,
                          size: 20, color: const Color(0xFFBDBDBD)),
                    ],
                  ],
                ),
                if (stage.isUnlocked) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: stage.color),
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
              Icon(Icons.arrow_back_ios_rounded,
                  size: 16, color: stage.color),
              const SizedBox(width: 4),
              Text(stage.title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: stage.color,
                  )),
            ],
          ),
        ),
      ),
      ...lessons.map((lesson) {
        final key = _lessonKeys.putIfAbsent(
            lesson.id, () => GlobalKey());
        final completed = game.isLessonCompleted(lesson.id);
        final unlocked = game.isLessonUnlocked(lesson.id);
        final isCurrent = game.lastLessonId == lesson.id && !completed;

        return Padding(
          key: key,
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: unlocked ? () => game.loadLesson(lesson.id) : null,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFFFFF0F0)
                    : unlocked
                        ? Colors.white
                        : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFFD94040)
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
                          ? const Color(0xFF2E7D32)
                          : isCurrent
                              ? const Color(0xFFD94040)
                              : unlocked
                                  ? const Color(0xFFFFF0F0)
                                  : Colors.transparent,
                      border: !completed && !isCurrent && unlocked
                          ? Border.all(
                              color: const Color(0xFFD94040), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: completed
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : isCurrent
                              ? Text('▶',
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700))
                              : !unlocked
                                  ? Icon(Icons.lock_rounded,
                                      size: 16,
                                      color: const Color(0xFFBDBDBD))
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight:
                                unlocked ? FontWeight.w700 : FontWeight.w600,
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
                    Icon(Icons.check_circle_rounded,
                        color: const Color(0xFF2E7D32), size: 20),
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
        : lesson.title;

    // Find stage color for dynamic background
    Color stageColor = const Color(0xFFD94040);
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
        title: Text(titleText,
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD94040))),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              stageColor.withAlpha(8),
              Colors.white,
            ],
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
                          ? _buildDialogueArea(game)
                          : _buildQuizArea(game),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogue Area ──
  Widget _buildDialogueArea(GameState game) {
    final msg = game.dialogue[game.dialogueIndex];
    final isSpeaker = msg.speaker == 'mj';
    final expression = _getMascotExpression(msg.text);

    return GestureDetector(
      onTap: () {
        _audio.playTap();
        final advanced = game.advanceDialogue();
        if (!advanced) {
          game.startQuiz(game.currentQuestions);
        }
      },
      child: Padding(
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
                MascotWidget(size: MascotSize.medium.value, expression: expression)
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
                    child: Text('🙋',
                        style: GoogleFonts.nunito(fontSize: 36)),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                isSpeaker ? 'Ludi Sensei' : 'You',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSpeaker
                      ? const Color(0xFFD94040)
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
      ),
    );
  }

  /// Parse dialogue text, replacing {{tile_id}} markers with tile image widgets.
  List<InlineSpan> _parseDialogueText(String text) {
    final RegExp exp = RegExp(r'\{\{(.+?)\}\}');
    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in exp.allMatches(text)) {
      // Add text before this match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: GoogleFonts.nunito(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFF2D2D2D),
          ),
        ));
      }

      // Add tile image widget
      final tileId = match.group(1)!;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: MahjongTile(tileId: tileId, size: 32),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: GoogleFonts.nunito(
          fontSize: 15,
          height: 1.5,
          color: const Color(0xFF2D2D2D),
        ),
      ));
    }

    return spans;
  }

  Widget _buildDialogueBubble(DialogueMessage msg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: _parseDialogueText(msg.text)),
        ),
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
  Widget _buildQuizArea(GameState game) {
    if (game.currentQuestions.isEmpty) return const SizedBox.shrink();

    final q = game.currentQuestions[game.currentQuestionIndex];

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
                  color: const Color(0xFFD94040),
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
                          ? const Color(0xFFD94040)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Question
          Text(q.question,
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D))),
          const SizedBox(height: 20),

          // ── Render by question type ──
          if (q.type == QuizType.tileOrdering)
            _buildTileOrderingArea(game, q)
          else if (q.type == QuizType.tileSelection)
            _buildTileSelectionArea(game, q)
          else
            _buildMultiChoiceArea(game, q),
        ],
      ),
    );
  }

  // ── MultiChoice Area ──
  Widget _buildMultiChoiceArea(GameState game, QuizQuestion q) {
    return Column(
      children: [
        ...q.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isSelected = _selectedOptions.contains(idx);

          Color bgColor;
          Color borderColor;

          if (_feedbackActive) {
            if (isSelected && _feedbackCorrect == true) {
              bgColor = const Color(0xFFE8F5E9);
              borderColor = const Color(0xFF2E7D32);
            } else if (isSelected && _feedbackCorrect == false) {
              bgColor = const Color(0xFFFFEBEE);
              borderColor = const Color(0xFFD94040);
            } else if (idx == q.correctIndex && _feedbackCorrect == false) {
              // Show correct answer when wrong
              bgColor = const Color(0xFFE8F5E9);
              borderColor = const Color(0xFF2E7D32);
            } else {
              bgColor = Colors.white;
              borderColor = const Color(0xFFE0E0E0);
            }
          } else {
            bgColor = isSelected
                ? const Color(0xFFFFF0F0)
                : Colors.white;
            borderColor = isSelected
                ? const Color(0xFFD94040)
                : const Color(0xFFE0E0E0);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedScale(
              scale: _pressedOptionIndex == idx ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: GestureDetector(
                onTapDown: _feedbackActive
                    ? null
                    : (_) => setState(() => _pressedOptionIndex = idx),
                onTapUp: _feedbackActive
                    ? null
                    : (_) => setState(() => _pressedOptionIndex = null),
                onTapCancel: () =>
                    setState(() => _pressedOptionIndex = null),
                onTap: _feedbackActive
                    ? null
                    : () {
                        setState(() {
                          if (_selectedOptions.contains(idx)) {
                            _selectedOptions.remove(idx);
                          } else {
                            _selectedOptions.add(idx);
                          }
                        });
                      },
                child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected || _feedbackActive ? 2 : 1,
                  ),
                  boxShadow: isSelected && !_feedbackActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFD94040).withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    // Decorative dot on top-right corner
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFFD94040).withAlpha(40)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFFD94040)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD94040)
                              : const Color(0xFFBDBDBD),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(option,
                          style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _feedbackActive && !isSelected &&
                                      idx != q.correctIndex
                                  ? const Color(0xFFBDBDBD)
                                  : const Color(0xFF2D2D2D))),
                    ),
                    if (_feedbackActive && idx == q.correctIndex)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32), size: 20),
                    if (_feedbackActive &&
                        isSelected &&
                        _feedbackCorrect == false)
                      const Icon(Icons.cancel_rounded,
                          color: Color(0xFFD94040), size: 20),
                  ],
                ),
                ],
                ),
              ),
            ),
          ),
          );
        }),
        const SizedBox(height: 8),
        // Submit button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _selectedOptions.isEmpty || _feedbackActive
                ? null
                : () => _submitMultiChoice(game, q),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94040),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Submit Answer',
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Tile Selection Area ──
  Widget _buildTileSelectionArea(GameState game, QuizQuestion q) {
    final tiles = q.tiles ?? [];
    final options = q.options;

    return Column(
      children: [
        // Option buttons
        ...options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isSelected = _selectedOptions.contains(idx);

          Color bgColor;
          Color borderColor;

          if (_feedbackActive) {
            if (isSelected && _feedbackCorrect == true) {
              bgColor = const Color(0xFFE8F5E9);
              borderColor = const Color(0xFF2E7D32);
            } else if (isSelected && _feedbackCorrect == false) {
              bgColor = const Color(0xFFFFEBEE);
              borderColor = const Color(0xFFD94040);
            } else if (idx == q.correctIndex && _feedbackCorrect == false) {
              bgColor = const Color(0xFFE8F5E9);
              borderColor = const Color(0xFF2E7D32);
            } else {
              bgColor = Colors.white;
              borderColor = const Color(0xFFE0E0E0);
            }
          } else {
            bgColor = isSelected ? const Color(0xFFFFF0F0) : Colors.white;
            borderColor =
                isSelected ? const Color(0xFFD94040) : const Color(0xFFE0E0E0);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: _feedbackActive
                  ? null
                  : () {
                      setState(() {
                        _selectedOptions.clear();
                        _selectedOptions.add(idx);
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor,
                      width: isSelected || _feedbackActive ? 2 : 1),
                ),
                child: Row(
                  children: [
                    // Render MahjongTile for tile selection options
                    MahjongTile(
                      tileId: option,
                      size: 84,
                    ),
                    const Spacer(),
                    if (_feedbackActive && idx == q.correctIndex)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32), size: 20),
                    if (_feedbackActive && isSelected &&
                        _feedbackCorrect == false)
                      const Icon(Icons.cancel_rounded,
                          color: Color(0xFFD94040), size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _selectedOptions.isEmpty || _feedbackActive
                ? null
                : () => _submitMultiChoice(game, q),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94040),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Submit Answer',
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Tile Ordering Area ──
  Widget _buildTileOrderingArea(GameState game, QuizQuestion q) {
    final totalTiles = _shuffledOrderingTiles.length;
    final tileSize = totalTiles <= 3 ? 88.0 : totalTiles <= 4 ? 80.0 : 72.0;

    return Column(
      children: [
        // Instruction
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8B93E).withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.drag_indicator_rounded,
                  color: Color(0xFFE8B93E), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Drag tiles to arrange in the correct order',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF8D6E00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Draggable tile list
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5EC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8D5C0)),
          ),
          child: _feedbackActive
              ? _buildOrderingResult(q)
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _shuffledOrderingTiles.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final tile = _shuffledOrderingTiles.removeAt(oldIndex);
                      _shuffledOrderingTiles.insert(newIndex, tile);
                    });
                  },
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final scale = 1.0 + (animation.value * 0.08);
                        return Transform.scale(
                          scale: scale,
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(8),
                            shadowColor: Colors.black38,
                            child: child,
                          ),
                        );
                      },
                      child: child,
                    );
                  },
                  buildDefaultDragHandles: true,
                  itemBuilder: (context, index) {
                    final tile = _shuffledOrderingTiles[index];
                    return Container(
                      key: Key('tile_$tile'),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Order number
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD94040),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MahjongTile(
                            tileId: tile,
                            size: tileSize,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 16),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _feedbackActive
                ? null
                : () => _submitTileOrdering(game, q),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94040),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Submit Order',
                style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderingResult(QuizQuestion q) {
    final correctOrder = q.tiles ?? [];
    return Column(
      children: List.generate(_shuffledOrderingTiles.length, (index) {
        final userTile = _shuffledOrderingTiles[index];
        final correctTile = correctOrder.length > index ? correctOrder[index] : '';
        final isCorrect = userTile == correctTile;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCorrect
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD94040),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD94040),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              MahjongTile(
                tileId: userTile,
                size: 72,
                isCorrect: isCorrect,
              ),
              if (!isCorrect) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Color(0xFF757575)),
                const SizedBox(width: 8),
                MahjongTile(
                  tileId: correctTile,
                  size: 72,
                  isCorrect: true,
                ),
              ],
              const SizedBox(width: 10),
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFD94040),
                size: 22,
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Submit handlers ──
  void _submitMultiChoice(GameState game, QuizQuestion q) {
    final selected = _selectedOptions.toList();

    setState(() {
      _feedbackActive = true;

      if (game.isReviewMode) {
        _feedbackCorrect = selected.length == 1 &&
            selected.first == q.correctIndex;
      } else if (q.type == QuizType.multiChoice) {
        _feedbackCorrect = selected.length == 1 &&
            selected.first == q.correctIndex;
      } else {
        _feedbackCorrect = selected.isNotEmpty &&
            selected.first == q.correctIndex;
      }
    });

    if (_feedbackCorrect == true) {
      _audio.playCorrect();
      HapticFeedback.lightImpact();
    } else {
      _audio.playWrong();
      HapticFeedback.heavyImpact();
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (game.isReviewMode) {
        game.answerReviewQuestion(selected, null, q);
      } else {
        if (q.type == QuizType.multiChoice) {
          game.answerMultiChoice(selected, q);
        } else {
          game.answerQuestion(selected.isNotEmpty ? selected.first : 0, q);
        }
      }

      setState(() {
        _selectedOptions.clear();
        _feedbackCorrect = null;
        _feedbackActive = false;
        _shuffledOrderingTiles = [];
        _orderingSubmitted = false;
      });
    });
  }

  void _submitTileOrdering(GameState game, QuizQuestion q) {
    final userOrder = List<String>.from(_shuffledOrderingTiles);
    final correctOrder = q.tiles ?? [];
    bool isCorrect = userOrder.length == correctOrder.length &&
        List.generate(
            userOrder.length, (i) => userOrder[i] == correctOrder[i])
            .every((e) => e);

    setState(() {
      _feedbackActive = true;
      _orderingSubmitted = true;
      _feedbackCorrect = isCorrect;
    });

    if (isCorrect) {
      _audio.playCorrect();
      HapticFeedback.lightImpact();
    } else {
      _audio.playWrong();
      HapticFeedback.heavyImpact();
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (game.isReviewMode) {
        game.answerReviewQuestion([], userOrder, q);
      } else {
        game.answerTileOrdering(userOrder, q);
      }

      setState(() {
        _selectedOptions.clear();
        _feedbackCorrect = null;
        _feedbackActive = false;
        _shuffledOrderingTiles = [];
        _orderingSubmitted = false;
      });
    });
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
              color: passed
                  ? const Color(0xFFD94040)
                  : const Color(0xFFE8B93E),
            ),
          ),
          const SizedBox(height: 12),

          // Stats cards
          Row(
            children: [
              _buildStatCard('Accuracy', '$accuracy%',
                  passed ? const Color(0xFF2E7D32) : const Color(0xFFE8B93E)),
              const SizedBox(width: 12),
              _buildStatCard('Correct', '$correct',
                  const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _buildStatCard('Wrong', '$wrong',
                  wrong > 0 ? const Color(0xFFD94040) : const Color(0xFF9E9E9E)),
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
                  color: const Color(0xFFE8B93E)),
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
                border: Border.all(color: const Color(0xFFE8B93E).withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded,
                          color: Color(0xFFE8B93E), size: 20),
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
                  ...List.generate(
                    wrong > 3 ? 3 : wrong,
                    (i) {
                      // Find wrong questions from the current quiz
                      // In normal mode we track via feedback; show recent wrong answers
                      final waList = game.wrongAnswers;
                      if (i < waList.length) {
                        final wa = waList[waList.length - 1 - i];
                        return _buildWrongAnswerItem(game, wa);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
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
                  backgroundColor: const Color(0xFFD94040),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Done',
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
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
                  foregroundColor: const Color(0xFFD94040),
                  side: const BorderSide(color: Color(0xFFD94040)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Retry Review',
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ] else ...[
            // Normal mode buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => game.retryQuiz(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94040),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Retry Quiz',
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
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
                    label: Text('Review Wrong Answers ($wrong)',
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8B93E),
                      side: const BorderSide(color: Color(0xFFE8B93E)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),

            // Next lesson
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedOptions.clear();
                  _shuffledOrderingTiles = [];
                  _orderingSubmitted = false;
                });
                final nextId = game.getNextLessonId();
                if (nextId != null) {
                  game.loadLesson(nextId);
                } else {
                  game.clearLesson();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next Lesson',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD94040),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: Color(0xFFD94040)),
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
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: valueColor)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFF9E9E9E))),
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

    if (wa.questionIndex < 0 ||
        wa.questionIndex >= lesson.questions.length) {
      return const SizedBox.shrink();
    }

    final q = lesson.questions[wa.questionIndex];

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
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32), size: 16),
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
          Text('💔',
              style: GoogleFonts.nunito(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Out of Hearts!',
              style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD94040))),
          const SizedBox(height: 8),
          Text(
            'Hearts refill daily, or go Premium for unlimited!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 14, color: const Color(0xFF757575)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => game.retryQuiz(),
            child: const Text('Try Again'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              final nextId = game.getNextLessonId();
              if (nextId != null) {
                game.loadLesson(nextId);
              } else {
                game.clearLesson();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next Lesson',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD94040)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: Color(0xFFD94040)),
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
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: passed
                ? [const Color(0xFFD94040), const Color(0xFFFF7043)]
                : [const Color(0xFFE8B93E), const Color(0xFFFFCA28)],
          ),
          boxShadow: [
            BoxShadow(
              color: (passed
                      ? const Color(0xFFD94040)
                      : const Color(0xFFE8B93E))
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
