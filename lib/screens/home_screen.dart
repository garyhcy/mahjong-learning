import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../screens/learn_screen.dart';
import '../services/audio_service.dart';
import '../widgets/mascot_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final totalLessons =
        game.stages.fold(0, (sum, s) => sum + s.lessonCount);
    final unitProgress = totalLessons > 0
        ? (game.completedLessons / totalLessons * 7).round().clamp(0, 7)
        : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── 背景裝飾 ───
            const _BackgroundTrees(),
            Column(
              children: [
                _buildTopBar(game),
                _buildUnitBanner(game, unitProgress),
                const SizedBox(height: 8),
                Expanded(child: _buildLearningPath(context, game)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 頂部狀態列 ───
  Widget _buildTopBar(GameState game) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Spacer(),
          _buildStat(
            icon: Icons.local_fire_department_rounded,
            value: '${game.streak}',
            color: const Color(0xFFFF7043),
          ),
          const SizedBox(width: 18),
          _buildStat(
            icon: Icons.diamond_rounded,
            value: '${game.xp}',
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(width: 18),
          _buildStat(
            icon: Icons.favorite_rounded,
            value: '${game.hearts}',
            color: const Color(0xFFEF5350),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A3520),
          ),
        ),
      ],
    );
  }

  // ─── 綠色單元橫幅 ───
  Widget _buildUnitBanner(GameState game, int unitProgress) {
    final currentStageIndex = game.stages.indexWhere(
      (s) => s.isUnlocked && s.progress < 1.0,
    );
    final stageIndex = currentStageIndex >= 0 ? currentStageIndex : 0;
    final stage = game.stages.isNotEmpty ? game.stages[stageIndex] : null;
    final title = stage?.title ?? 'Mahjong Basics';
    final stageNum = stageIndex + 1;
    final stageProgress = stage != null && stage.lessonCount > 0
        ? stage.completedLessons
        : 0;
    final stageTotal = stage?.lessonCount ?? 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF56A85C), Color(0xFF3D8B44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(80),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -15,
              right: 60,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(18),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(12),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 0,
              child: MascotWidget(
                expression: MascotExpression.wink,
                size: 110,
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              right: 115,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Stage $stageNum',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 8,
                            child: Row(
                              children: [
                                if (stageProgress > 0)
                                  Flexible(
                                    flex: stageProgress,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFD54F),
                                            Color(0xFFFFB300),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (stageTotal - stageProgress > 0)
                                  Flexible(
                                    flex: stageTotal - stageProgress,
                                    child: Container(
                                      color: Colors.white.withAlpha(45),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$stageProgress / $stageTotal',
                        style: GoogleFonts.nunito(
                          color: Colors.white.withAlpha(220),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 學習路徑 ───
  Widget _buildLearningPath(BuildContext context, GameState game) {
    final stages = game.stages;
    if (stages.isEmpty) {
      return const Center(
        child: Text(
          'No stages available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      itemCount: stages.length,
      itemBuilder: (context, i) {
        final stage = stages[i];
        final isCompleted = stage.progress >= 1.0;
        final isLocked = !stage.isUnlocked;
        final isLast = i == stages.length - 1;

        return _AnimatedPathNode(
          game: game,
          stage: stage,
          index: i + 1,
          isCompleted: isCompleted,
          isLocked: isLocked,
          isLast: isLast,
        );
      },
    );
  }
}

// ─── 帶動畫的路徑節點 ───
class _AnimatedPathNode extends StatefulWidget {
  final GameState game;
  final dynamic stage;
  final int index;
  final bool isCompleted;
  final bool isLocked;
  final bool isLast;

  const _AnimatedPathNode({
    required this.game,
    required this.stage,
    required this.index,
    required this.isCompleted,
    required this.isLocked,
    required this.isLast,
  });

  @override
  State<_AnimatedPathNode> createState() => _AnimatedPathNodeState();
}

class _AnimatedPathNodeState extends State<_AnimatedPathNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  final AudioService _audio = AudioService();
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.isLocked) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.isLocked) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    if (widget.isLocked) {
      // 鎖定節點：搖晃動畫
      _audio.playTap();
      setState(() => _isShaking = true);
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          if (mounted) setState(() => _isShaking = false);
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete the previous stage to unlock this one!',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF5D4037),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // 可用節點：播放音效並導航
      _audio.playTileClick();
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          widget.game.navigateToStage(widget.stage.id);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LearnScreen()),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 節點樣式
    final Color circleBg;
    final Color circleBorder;
    final Color shadowColor;
    final Color titleColor;
    final Widget nodeChild;

    final isBonusStage = (widget.index % 4 == 0);

    final currentStageIndex = widget.game.stages.indexWhere(
      (s) => s.isUnlocked && s.progress < 1.0,
    );
    final isCurrentStage = (widget.index - 1) == currentStageIndex;

    if (widget.isCompleted) {
      circleBg = const Color(0xFFFFF8E1);
      circleBorder = const Color(0xFFFFB300);
      shadowColor = const Color(0xFFFFB300);
      titleColor = const Color(0xFF2E7D32);
      nodeChild = Image.asset(
        'assets/images/crown.png',
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
    } else if (widget.isLocked && isBonusStage) {
      circleBg = const Color(0xFFEEEEEE);
      circleBorder = const Color(0xFFCECECE);
      shadowColor = Colors.transparent;
      titleColor = const Color(0xFFBDBDBD);
      nodeChild = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Image.asset(
          'assets/images/treasure_chest.png',
          width: 54,
          height: 54,
          fit: BoxFit.contain,
        ),
      );
    } else if (widget.isLocked) {
      circleBg = const Color(0xFFEEEEEE);
      circleBorder = const Color(0xFFCECECE);
      shadowColor = Colors.transparent;
      titleColor = const Color(0xFFBDBDBD);
      nodeChild = const Icon(Icons.lock_rounded,
          color: Color(0xFFBDBDBD), size: 30);
    } else if (isBonusStage && isCurrentStage) {
      circleBg = const Color(0xFFFFF8E1);
      circleBorder = const Color(0xFFFFB300);
      shadowColor = const Color(0xFFFFB300);
      titleColor = const Color(0xFFE65100);
      nodeChild = Image.asset(
        'assets/images/treasure_chest.png',
        width: 54,
        height: 54,
        fit: BoxFit.contain,
      );
    } else if (isCurrentStage) {
      circleBg = const Color(0xFF4CAF50);
      circleBorder = const Color(0xFF2E7D32);
      shadowColor = const Color(0xFF4CAF50);
      titleColor = const Color(0xFF1B5E20);
      nodeChild = const Icon(Icons.star_rounded,
          color: Colors.white, size: 38);
    } else if (isBonusStage) {
      circleBg = const Color(0xFFEEEEEE);
      circleBorder = const Color(0xFFCECECE);
      shadowColor = Colors.transparent;
      titleColor = const Color(0xFFBDBDBD);
      nodeChild = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Image.asset(
          'assets/images/treasure_chest.png',
          width: 54,
          height: 54,
          fit: BoxFit.contain,
        ),
      );
    } else {
      // 已解鎖但非當前的普通關卡：剔號
      circleBg = const Color(0xFFE8F5E9);
      circleBorder = const Color(0xFF81C784);
      shadowColor = Colors.transparent;
      titleColor = const Color(0xFF388E3C);
      nodeChild = const Icon(Icons.check_rounded,
          color: Color(0xFF4CAF50), size: 36);
    }

    final lineColor = widget.isCompleted
        ? const Color(0xFF4CAF50).withAlpha(120)
        : const Color(0xFFD0D0D0);

    return Column(
      children: [
        // 節點
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double scale;
              final double offsetX;
              if (_isShaking) {
                // 搖晃效果
                scale = 1.0;
                offsetX = _shakeAnimation.value * 6 *
                    (_controller.value < 0.5 ? 1 : -1);
              } else {
                // 縮放效果
                scale = _scaleAnimation.value;
                offsetX = 0;
              }
              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                    border: Border.all(color: circleBorder, width: 3.5),
                    boxShadow: shadowColor != Colors.transparent
                        ? [
                            BoxShadow(
                              color: shadowColor.withAlpha(80),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: nodeChild),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.index}. ${widget.stage.title}',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // 連線
        if (!widget.isLast)
          Container(
            width: 3.5,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

// ─── 背景圖片 ───
class _BackgroundTrees extends StatelessWidget {
  const _BackgroundTrees();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Image.asset(
          'assets/images/background.png',
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          repeat: ImageRepeat.repeatY,
        ),
      ),
    );
  }
}
