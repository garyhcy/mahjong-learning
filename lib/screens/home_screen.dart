import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../screens/learn_screen.dart';
import '../services/audio_service.dart';
import '../services/app_i18n.dart';
import '../models/mahjong_data.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/stage_map.dart';

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
    final title = stage?.localizedTitle ?? AppI18n.t('home.mahjongBasics');
    final stageNum = stageIndex + 1;
    final stageProgress = stage != null && stage.lessonCount > 0
        ? stage.completedLessons
        : 0;
    final stageTotal = stage?.lessonCount ?? 7;
    // 王冠邏輯：每個完成 stage（progress >= 1.0）= 1 王冠，與 stage node 一致
    final crownsEarned = game.stages.where((s) => s.progress >= 1.0).length;
    final crownsTotal = game.stages.length;

    final stageColor = stage?.color ?? const Color(0xFF56A85C);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Color.lerp(stageColor, Colors.white, 0.12)!,
            Color.lerp(stageColor, Colors.black, 0.20)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: stageColor.withAlpha(80),
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
              child: MascotWidget(expression: MascotExpression.wink, size: 110),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${AppI18n.t('home.stage')} $stageNum',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withAlpha(70),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFD54F).withAlpha(120),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/crown.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$crownsEarned / $crownsTotal',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  // ─── 學習路徑（Table Trail）───
  Widget _buildLearningPath(BuildContext context, GameState game) {
    final stages = game.stages;
    if (stages.isEmpty) {
      return Center(
        child: Text(
          AppI18n.t('home.noStages'),
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final currentIndex = stages.indexWhere(
      (s) => s.isUnlocked && s.progress < 1.0,
    );

    final goalStage = currentIndex >= 0 ? stages[currentIndex] : stages.last;

    return ListView(
      padding: const EdgeInsets.only(top: 6, bottom: 40),
      children: [
        DailyGoalCard(
          game: game,
          onStartLesson: () => _openStage(context, game, goalStage),
        ),
        StageMap(
          stages: stages,
          currentIndex: currentIndex,
          onStageTap: (stage) => _openStage(context, game, stage),
          onLockedTap: (stage) => _showLockedStage(context, stage),
        ),
      ],
    );
  }

  void _openStage(BuildContext context, GameState game, LearningStage stage) {
    AudioService().playTileClick();
    game.navigateToStage(stage.id);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LearnScreen()));
  }

  void _showLockedStage(BuildContext context, LearningStage stage) {
    AudioService().playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppI18n.t('home.lockedStage'),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF5D4037),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

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
