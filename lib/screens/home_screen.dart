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
    final progressFraction =
        totalLessons > 0 ? game.completedLessons / totalLessons : 0.0;
    final audio = AudioService();

    String greetingMessage;
    String greetingTitle;
    if (game.completedLessons == 0) {
      greetingTitle = 'Welcome to Ludi!';
      greetingMessage = 'Start your mahjong journey today';
    } else if (progressFraction < 0.3) {
      greetingTitle = 'Keep it up!';
      greetingMessage = 'You\'re making great progress';
    } else if (progressFraction < 0.7) {
      greetingTitle = 'Almost there!';
      greetingMessage = 'Halfway to becoming a master';
    } else if (progressFraction < 1.0) {
      greetingTitle = 'So close!';
      greetingMessage = 'Just a few more lessons to go';
    } else {
      greetingTitle = 'Amazing!';
      greetingMessage = 'You are a Mahjong Master!';
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Hero Banner ──
              _HeroBanner(
                title: greetingTitle,
                subtitle: greetingMessage,
                game: game,
                totalLessons: totalLessons,
              ),
              const SizedBox(height: 20),

              // ── Stats Cards Row ──
              _StatsRow(game: game, totalLessons: totalLessons),
              const SizedBox(height: 20),

              // ── Continue Learning ──
              _ContinueButton(game: game),
              const SizedBox(height: 20),

              // ── Daily Challenge ──
              _DailyChallengeCard(game: game, audio: audio),
              const SizedBox(height: 28),

              // ── Learning Path Header ──
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
              Text('Tap a stage to jump to its lessons',
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: const Color(0xFF757575))),
              const SizedBox(height: 16),

              // ── Stage Cards ──
              ...game.stages.asMap().entries.map((entry) {
                final i = entry.key;
                final stage = entry.value;
                final isLast = i == game.stages.length - 1;
                final isStaggered = i % 2 == 1;
                return Padding(
                  padding: EdgeInsets.only(left: isStaggered ? 16.0 : 0),
                  child:
                      _buildStageCard(context, game, stage, isLast, audio),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, GameState game,
      LearningStage stage, bool isLast, AudioService audio) {
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
                          ? Icon(stage.icon, color: Colors.white, size: 18)
                          : Icon(Icons.lock_rounded,
                              size: 16, color: const Color(0xFFBDBDBD)),
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
                  Positioned(
                    right: -16,
                    bottom: -16,
                    child: Icon(
                      stage.icon,
                      size: 80,
                      color: (stage.isUnlocked
                              ? stage.color
                              : const Color(0xFFE0E0E0))
                          .withAlpha(15),
                    ),
                  ),
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
                                    backgroundColor:
                                        const Color(0xFFF5F5F5),
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

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final GameState game;
  final int totalLessons;

  const _HeroBanner({
    required this.title,
    required this.subtitle,
    required this.game,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFD94040), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD94040).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MascotWidget(
                expression: MascotExpression.happy,
                size: 72.0,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level ${game.userLevel}',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${game.xp} / ${game.xpToNextLevel} XP',
                          style: GoogleFonts.nunito(
                            color: Colors.white.withAlpha(180),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: game.xpToNextLevel > 0
                            ? game.xp / game.xpToNextLevel
                            : 0.0,
                        backgroundColor: Colors.white.withAlpha(40),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE8B93E)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${game.completedLessons} / $totalLessons lessons completed',
            style: GoogleFonts.nunito(
              color: Colors.white.withAlpha(160),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final GameState game;
  final int totalLessons;

  const _StatsRow({required this.game, required this.totalLessons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFE8B93E),
            value: '${game.streak}',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFFD94040),
            value: '${game.xp}',
            label: 'Total XP',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF2E7D32),
            value: '${game.completedLessons}/$totalLessons',
            label: 'Lessons',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final GameState game;
  final AudioService audio;

  const _DailyChallengeCard({required this.game, required this.audio});

  @override
  Widget build(BuildContext context) {
    final nextUncompleted = game.stages
        .where((s) => s.isUnlocked && s.progress < 1.0)
        .toList();

    if (nextUncompleted.isEmpty && game.stages.every((s) => s.progress >= 1.0)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8B93E), Color(0xFFF9A825)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B93E).withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Stages Complete!',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You are a true Mahjong Master!',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withAlpha(200),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const MascotWidget(
              expression: MascotExpression.proud,
              size: 56,
            ),
          ],
        ),
      );
    }

    final targetStage = nextUncompleted.first;
    return GestureDetector(
      onTap: () {
        audio.playTap();
        game.navigateToStage(targetStage.id);
        MainShell.mainShellKey.currentState?.switchToTab(1);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8F0), Color(0xFFFFF0E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8B93E).withAlpha(100),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B93E).withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8B93E).withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFE8B93E),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Challenge',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Continue ${targetStage.title} — ${targetStage.subtitle}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFFE8B93E),
              size: 24,
            ),
          ],
        ),
      ),
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
