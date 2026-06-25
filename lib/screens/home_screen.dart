import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../screens/learn_screen.dart';
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
            // ─── 背景裝飾小樹 ───
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
          // 熊貓頭像
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withAlpha(40),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const ClipOval(
              child: MascotWidget(
                expression: MascotExpression.happy,
                size: 44,
              ),
            ),
          ),
          const Spacer(),
          // 火焰 - 連續天數
          _buildStat(
            icon: Icons.local_fire_department_rounded,
            value: '${game.streak}',
            color: const Color(0xFFFF7043),
          ),
          const SizedBox(width: 18),
          // 鑽石 - 積分
          _buildStat(
            icon: Icons.diamond_rounded,
            value: '${game.xp}',
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(width: 18),
          // 愛心 - 生命
          _buildStat(
            icon: Icons.favorite_rounded,
            value: '5',
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
    final stage = game.stages.isNotEmpty ? game.stages.first : null;
    final title = stage?.title ?? '認識麻將';
    final stageNum = 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 120,
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 背景光暈裝飾
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
          // 內容
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左側文字區
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 單元標籤
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '第 $stageNum 單元',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 單元標題
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
                      // 進度條
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                height: 8,
                                child: Row(
                                  children: [
                                    if (unitProgress > 0)
                                      Flexible(
                                        flex: unitProgress,
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
                                    if (7 - unitProgress > 0)
                                      Flexible(
                                        flex: 7 - unitProgress,
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
                            '$unitProgress / 7',
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
                // 右側熊貓
                SizedBox(
                  width: 90,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MascotWidget(
                      expression: MascotExpression.wink,
                      size: 95,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 學習路徑：置中節點設計 ───
  Widget _buildLearningPath(BuildContext context, GameState game) {
    final stages = game.stages;
    if (stages.isEmpty) {
      return const Center(
        child: Text(
          '尚無學習單元',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      itemCount: stages.length,
      itemBuilder: (context, i) {
        final stage = stages[i];
        final isCompleted = stage.progress >= 1.0;
        final isLocked = !stage.isUnlocked;
        final isInProgress = stage.isUnlocked && !isCompleted;
        final isLast = i == stages.length - 1;

        return _buildCenteredPathNode(
          context: context,
          game: game,
          stage: stage,
          index: i + 1,
          isCompleted: isCompleted,
          isLocked: isLocked,
          isInProgress: isInProgress,
          isLast: isLast,
        );
      },
    );
  }

  Widget _buildCenteredPathNode({
    required BuildContext context,
    required GameState game,
    required dynamic stage,
    required int index,
    required bool isCompleted,
    required bool isLocked,
    required bool isInProgress,
    required bool isLast,
  }) {
    // 節點樣式
    final Color circleBg;
    final Color circleBorder;
    final Color shadowColor;
    final Color titleColor;
    final Widget nodeChild;

    if (isCompleted) {
      circleBg = const Color(0xFF4CAF50);
      circleBorder = const Color(0xFF388E3C);
      shadowColor = const Color(0xFF4CAF50);
      titleColor = const Color(0xFF2E7D32);
      nodeChild = const Icon(Icons.star_rounded,
          color: Color(0xFFFFD54F), size: 34);
    } else if (isLocked) {
      circleBg = const Color(0xFFEEEEEE);
      circleBorder = const Color(0xFFCECECE);
      shadowColor = Colors.transparent;
      titleColor = const Color(0xFFBDBDBD);
      nodeChild = const Icon(Icons.lock_rounded,
          color: Color(0xFFBDBDBD), size: 28);
    } else {
      // 進行中：寶箱
      circleBg = const Color(0xFFFFF8E1);
      circleBorder = const Color(0xFFFFB300);
      shadowColor = const Color(0xFFFFB300);
      titleColor = const Color(0xFFE65100);
      nodeChild = const Icon(Icons.card_giftcard_rounded,
          color: Color(0xFFFF8F00), size: 32);
    }

    final lineColor = isCompleted
        ? const Color(0xFF4CAF50).withAlpha(100)
        : const Color(0xFFD0D0D0);

    return Column(
      children: [
        // 節點圓圈
        GestureDetector(
          onTap: isLocked
              ? null
              : () {
                  game.navigateToStage(stage.id);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LearnScreen()),
                  );
                },
          child: Column(
            children: [
              // 圓形節點
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleBg,
                  border: Border.all(color: circleBorder, width: 3),
                  boxShadow: shadowColor != Colors.transparent
                      ? [
                          BoxShadow(
                            color: shadowColor.withAlpha(70),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(child: nodeChild),
              ),
              const SizedBox(height: 8),
              // 課程名稱
              Text(
                '$index. ${stage.title}',
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
        // 連線
        if (!isLast)
          Container(
            width: 3,
            height: 28,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

// ─── 背景裝飾小樹 ───
class _BackgroundTrees extends StatelessWidget {
  const _BackgroundTrees();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _TreePainter(),
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);

    final treePositions = [
      Offset(size.width * 0.06, size.height * 0.22),
      Offset(size.width * 0.88, size.height * 0.20),
      Offset(size.width * 0.10, size.height * 0.44),
      Offset(size.width * 0.86, size.height * 0.46),
      Offset(size.width * 0.04, size.height * 0.65),
      Offset(size.width * 0.91, size.height * 0.68),
      Offset(size.width * 0.08, size.height * 0.84),
      Offset(size.width * 0.87, size.height * 0.86),
      Offset(size.width * 0.14, size.height * 0.96),
      Offset(size.width * 0.82, size.height * 0.97),
    ];

    for (final pos in treePositions) {
      final scale = 0.7 + rng.nextDouble() * 0.6;
      final opacity = 0.13 + rng.nextDouble() * 0.08;
      _drawTree(canvas, pos, scale, opacity, rng);
    }
  }

  void _drawTree(
      Canvas canvas, Offset pos, double scale, double opacity, Random rng) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF8D6E63).withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    final crownPaint = Paint()
      ..color = const Color(0xFF81C784).withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    final crownDarkPaint = Paint()
      ..color = const Color(0xFF4CAF50).withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    final trunkW = 7 * scale;
    final trunkH = 16 * scale;
    final crownR = 20 * scale;

    // 樹幹
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + crownR * 0.3),
          width: trunkW,
          height: trunkH),
      const Radius.circular(3),
    );
    canvas.drawRRect(trunkRect, trunkPaint);

    // 樹冠 - 三層圓形疊加
    canvas.drawCircle(
      Offset(pos.dx, pos.dy - crownR * 0.15),
      crownR * 0.75,
      crownDarkPaint,
    );
    canvas.drawCircle(
      Offset(pos.dx - crownR * 0.3, pos.dy + crownR * 0.05),
      crownR * 0.7,
      crownPaint,
    );
    canvas.drawCircle(
      Offset(pos.dx + crownR * 0.35, pos.dy + crownR * 0.1),
      crownR * 0.65,
      crownPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
