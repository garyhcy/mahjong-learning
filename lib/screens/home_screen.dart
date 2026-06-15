import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/mahjong_data.dart';
import '../main.dart';
import '../widgets/mascot_widget.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final totalLessons = game.stages.fold(0, (sum, s) => sum + s.lessonCount);
    final progressFraction = game.completedLessons / totalLessons;
    final audio = AudioService();
    String greetingMessage;
    if (game.completedLessons == 0) {
      greetingMessage = 'Start your Ludi journey!';
    } else if (progressFraction < 0.5) {
      greetingMessage = 'Keep going!';
    } else if (progressFraction < 1.0) {
      greetingMessage = 'Almost there!';
    } else {
      greetingMessage = 'Master of Ludi!';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ludi',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD94040))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _statBadge(Icons.local_fire_department_rounded,
                    '${game.streak}', const Color(0xFFE8B93E)),
                const SizedBox(width: 8),
                _statBadge(Icons.stars_rounded, '${game.xp} XP',
                    const Color(0xFFD94040)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 问候卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD94040), Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const MascotWidget(
                        expression: MascotExpression.idle,
                        size: 60.0,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          greetingMessage,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: game.xp / game.xpToNextLevel,
                      backgroundColor: Colors.white.withAlpha(50),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFE8B93E)),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level: ${game.userLevel}  ·  ${game.xp} / ${game.xpToNextLevel} XP  ·  ${game.completedLessons} / $totalLessons lessons',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withAlpha(200),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Continue Learning button ──
            _ContinueButton(game: game),
            const SizedBox(height: 24),

            Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD94040),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Your Learning Path',
                    style: GoogleFonts.nunito(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
                'Tap a stage to jump to its lessons',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: const Color(0xFF757575))),
            const SizedBox(height: 16),

            // 学习路径
            ...game.stages.asMap().entries.map((entry) {
              final i = entry.key;
              final stage = entry.value;
              final isLast = i == game.stages.length - 1;
              final isStaggered = i % 2 == 1;
              return Padding(
                padding: EdgeInsets.only(left: isStaggered ? 16.0 : 0),
                child: _buildStageCard(context, game, stage, isLast, audio),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildStageCard(
      BuildContext context, GameState game, LearningStage stage, bool isLast, AudioService audio) {
    final isCompleted = stage.progress >= 1.0;
    final isInProgress = stage.progress > 0 && !isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: stage.isUnlocked
            ? () {
                audio.playTap();
                game.navigateToStage(stage.id);
                MainShell.mainShellKey.currentState?.switchToTab(1);
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stage.isUnlocked
                          ? stage.color
                          : const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                      border: isInProgress
                          ? Border.all(
                              color: const Color(0xFFD94040), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: stage.isUnlocked
                          ? Icon(stage.icon,
                              color: Colors.white,
                              size: 18)
                          : Icon(Icons.lock_rounded,
                              size: 16,
                              color: const Color(0xFFBDBDBD)),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: stage.isUnlocked
                          ? stage.color.withAlpha(76)
                          : const Color(0xFFE0E0E0),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Stack(
                children: [
                  // Watermark icon background
                  Positioned(
                    right: -16,
                    bottom: -16,
                    child: Icon(
                      stage.icon,
                      size: 80,
                      color: (stage.isUnlocked ? stage.color : const Color(0xFFE0E0E0))
                          .withAlpha(15),
                    ),
                  ),
                  // Shimmer overlay for unlocked cards
                  if (stage.isUnlocked && !isCompleted)
                    _ShimmerOverlay(
                      color: stage.color.withAlpha(12),
                    ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: stage.isUnlocked
                          ? Colors.white
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: stage.isUnlocked
                          ? [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: isInProgress
                            ? const Color(0xFFD94040)
                            : stage.isUnlocked
                                ? stage.color.withAlpha(30)
                                : const Color(0xFFE0E0E0),
                        width: isInProgress ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(stage.title,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: stage.isUnlocked
                                        ? const Color(0xFF2D2D2D)
                                        : const Color(0xFFBDBDBD),
                                  )),
                            ),
                            if (isCompleted)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF2E7D32), size: 20),
                            if (!stage.isUnlocked)
                              const Icon(Icons.lock_rounded,
                                  size: 18, color: Color(0xFFBDBDBD)),
                            if (stage.isUnlocked && !isCompleted)
                              Icon(Icons.chevron_right_rounded,
                                  size: 20, color: stage.color),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(stage.subtitle,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: stage.isUnlocked
                                  ? const Color(0xFF757575)
                                  : const Color(0xFFBDBDBD),
                            )),
                        if (stage.isUnlocked &&
                            stage.completedLessons > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: stage.progress,
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        stage.color),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${stage.completedLessons}/${stage.lessonCount} · ${(stage.progress * 100).toInt()}%',
                                style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF9E9E9E)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerOverlay extends StatefulWidget {
  final Color color;
  const _ShimmerOverlay({required this.color});

  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  widget.color,
                  Colors.transparent,
                ],
                stops: [
                  _controller.value - 1,
                  _controller.value,
                  _controller.value,
                ],
              ).createShader(bounds);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.color.withAlpha(8),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final GameState game;
  const _ContinueButton({required this.game});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  double _scale = 1.0;

  void _onTap() {
    final game = widget.game;
    final hasProgress = game.lastLessonId != null &&
        game.isLessonCompleted(game.lastLessonId!) == false;
    final targetLesson = hasProgress
        ? game.lastLessonId!
        : (game.completedLessons == 0 ? '1-1' : game.lastLessonId ?? '1-1');

    setState(() => _scale = 0.97);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _scale = 1.0);
    });
    game.loadLesson(targetLesson);
    MainShell.mainShellKey.currentState?.switchToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final hasProgress = game.lastLessonId != null &&
        game.isLessonCompleted(game.lastLessonId!) == false;
    final label = hasProgress
        ? 'Continue Learning'
        : (game.completedLessons == 0
            ? 'Start First Lesson'
            : 'Continue Learning');

    return SizedBox(
      width: double.infinity,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: ElevatedButton.icon(
          onPressed: _onTap,
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD94040),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
