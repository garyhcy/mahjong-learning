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
    final totalLessons = game.stages.fold(0, (sum, s) => sum + s.lessonCount);
    final unitProgress = totalLessons > 0
        ? (game.completedLessons / totalLessons * 7).round().clamp(0, 7)
        : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(game),
            _buildUnitBanner(game, unitProgress),
            const SizedBox(height: 8),
            Expanded(child: _buildLearningPath(context, game)),
          ],
        ),
      ),
    );
  }

  // ─── 頂部狀態列 + 熊貓頭像 + 右側圖標 ───
  Widget _buildTopBar(GameState game) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: const MascotWidget(
                expression: MascotExpression.happy,
                size: 44,
              ),
            ),
          ),
          const Spacer(),
          _buildStatIcon(
            icon: Icons.star_rounded,
            value: '${game.userLevel}',
            color: const Color(0xFFE8B93E),
          ),
          const SizedBox(width: 20),
          _buildStatIcon(
            icon: Icons.diamond_rounded,
            value: '${game.xp}',
            color: const Color(0xFF5B9BD5),
          ),
          const SizedBox(width: 20),
          _buildStatIcon(
            icon: Icons.favorite_rounded,
            value: '${game.streak}',
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildStatIcon({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5D4037),
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '第1單元',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '進度 $unitProgress / 7',
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 8,
                          child: Row(
                            children: [
                              Flexible(
                                flex: unitProgress,
                                child: Container(
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              Flexible(
                                flex: 7 - unitProgress,
                                child: Container(
                                  color: Colors.white.withAlpha(77),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withAlpha(200),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const MascotWidget(
              expression: MascotExpression.wink,
              size: 80,
            ),
          ],
        ),
      ),
    );
  }

  // ─── 垂直節點學習路徑 ───
  Widget _buildLearningPath(BuildContext context, GameState game) {
    final stages = game.stages;
    if (stages.isEmpty) {
      return const Center(
        child: Text('尚無學習單元',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: List.generate(stages.length, (i) {
        final stage = stages[i];
        final isCompleted = stage.progress >= 1.0;
        final isLocked = !stage.isUnlocked;
        final isInProgress = stage.isUnlocked && !isCompleted;
        final isLast = i == stages.length - 1;

        final node = _buildPathNode(
          index: i + 1,
          title: stage.title,
          subtitle: stage.subtitle,
          icon: isCompleted
              ? Icons.star_rounded
              : isLocked
                  ? Icons.lock_rounded
                  : Icons.play_circle_rounded,
          iconColor: isCompleted
              ? const Color(0xFFE8B93E)
              : isLocked
                  ? Colors.grey.shade400
                  : stage.color ?? const Color(0xFF4CAF50),
          isCompleted: isCompleted,
          isLocked: isLocked,
          isInProgress: isInProgress,
          isLast: isLast,
          progress: stage.progress,
          stageColor: stage.color ?? const Color(0xFF4CAF50),
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
      }),
    );
  }

  Widget _buildPathNode({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isCompleted,
    required bool isLocked,
    required bool isInProgress,
    required bool isLast,
    required double progress,
    required Color stageColor,
  }) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.white
                        : isLocked
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFFE8F5E9),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF4CAF50)
                          : isLocked
                              ? Colors.grey.shade300
                              : const Color(0xFF4CAF50),
                      width: 2,
                    ),
                    boxShadow: isCompleted || isInProgress
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withAlpha(51),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: isCompleted
                            ? const Color(0xFF4CAF50).withAlpha(102)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF4CAF50).withAlpha(77)
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$index. $title',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? const Color(0xFF2E7D32)
                                : isLocked
                                    ? Colors.grey.shade500
                                    : const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        if (isInProgress) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    stageColor),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '已完成',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '鎖定',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const double dashWidth = 5;
    const double dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, (startY + dashWidth).clamp(0, size.height)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
