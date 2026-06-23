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
      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── 背景裝飾小樹 ───
            const _BackgroundTrees(),
            Column(
              children: [
                _buildTopBar(game),
                _buildUnitBanner(game, unitProgress),
                const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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

  // ─── 綠色漸變橫幅 ───
  Widget _buildUnitBanner(GameState game, int unitProgress) {
    final stage = game.stages.isNotEmpty ? game.stages.first : null;
    final title = stage?.title ?? '打招呼';
    final subtitle = stage?.subtitle ?? '學會基本問候語';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景裝飾圓點
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '第1單元',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$title 👋',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // 進度條：金黃色
                      Text(
                        '$unitProgress / 7',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: SizedBox(
                          height: 10,
                          child: Row(
                            children: [
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
                              Flexible(
                                flex: 7 - unitProgress,
                                child: Container(
                                  color: Colors.white.withAlpha(50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          color: Colors.white.withAlpha(190),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 打招呼熊貓
                const MascotWidget(
                  expression: MascotExpression.wink,
                  size: 85,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 學習路徑：簡潔節點設計 ───
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      children: List.generate(stages.length, (i) {
        final stage = stages[i];
        final isCompleted = stage.progress >= 1.0;
        final isLocked = !stage.isUnlocked;
        final isInProgress = stage.isUnlocked && !isCompleted;
        final isLast = i == stages.length - 1;

        return _buildSimplePathNode(
          context: context,
          game: game,
          stage: stage,
          index: i + 1,
          isCompleted: isCompleted,
          isLocked: isLocked,
          isInProgress: isInProgress,
          isLast: isLast,
        );
      }),
    );
  }

  Widget _buildSimplePathNode({
    required BuildContext context,
    required GameState game,
    required dynamic stage,
    required int index,
    required bool isCompleted,
    required bool isLocked,
    required bool isInProgress,
    required bool isLast,
  }) {
    // 節點圖標與顏色
    final IconData nodeIcon;
    final Color circleBg;
    final Color circleBorder;
    final Color iconColor;
    final Color titleColor;
    final String subtitleText;

    if (isCompleted) {
      nodeIcon = Icons.star_rounded;
      circleBg = const Color(0xFFE8F5E9);
      circleBorder = const Color(0xFF4CAF50);
      iconColor = const Color(0xFFE8B93E);
      titleColor = const Color(0xFF2E7D32);
      subtitleText = '已完成';
    } else if (isLocked) {
      nodeIcon = Icons.lock_rounded;
      circleBg = const Color(0xFFF5F5F5);
      circleBorder = const Color(0xFFBDBDBD);
      iconColor = const Color(0xFFBDBDBD);
      titleColor = const Color(0xFFBDBDBD);
      subtitleText = '鎖定';
    } else {
      // 進行中：寶箱圖標
      nodeIcon = Icons.card_giftcard_rounded;
      circleBg = const Color(0xFFFFF8E1);
      circleBorder = const Color(0xFFFFB300);
      iconColor = const Color(0xFFFF8F00);
      titleColor = const Color(0xFFE65100);
      subtitleText = '繼續學習';
    }

    // 連線顏色
    final lineColor = isCompleted
        ? const Color(0xFF4CAF50).withAlpha(80)
        : const Color(0xFFE0E0E0);

    final node = SizedBox(
      height: 110,
      child: Row(
        children: [
          // 左側：圓形圖標 + 下方連線
          SizedBox(
            width: 56,
            child: Column(
              children: [
                // 圓形圖標
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                    border: Border.all(color: circleBorder, width: 2.5),
                    boxShadow: (isCompleted || isInProgress)
                        ? [
                            BoxShadow(
                              color: circleBorder.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(nodeIcon, color: iconColor, size: 28),
                ),
                // 連線
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 3,
                        color: lineColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 右側：標題文字
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$index. ${stage.title}',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: isLocked
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFF8D6E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isLocked) return node;

    return GestureDetector(
      onTap: () {
        game.navigateToStage(stage.id);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LearnScreen()),
        );
      },
      child: node,
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
    final rng = Random(42); // 固定種子，保持一致性

    // 繪製多棵裝飾小樹，散佈在背景
    final treePositions = [
      Offset(size.width * 0.08, size.height * 0.18),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.12, size.height * 0.48),
      Offset(size.width * 0.88, size.height * 0.52),
      Offset(size.width * 0.05, size.height * 0.72),
      Offset(size.width * 0.90, size.height * 0.76),
      Offset(size.width * 0.15, size.height * 0.88),
      Offset(size.width * 0.82, size.height * 0.92),
    ];

    for (final pos in treePositions) {
      final scale = 0.6 + rng.nextDouble() * 0.5;
      final opacity = 0.08 + rng.nextDouble() * 0.06;
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
      ..color = const Color(0xFF66BB6A).withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    final trunkW = 6 * scale;
    final trunkH = 14 * scale;
    final crownR = 16 * scale;

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
