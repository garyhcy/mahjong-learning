import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/practice_state.dart';
import '../services/app_i18n.dart';
import 'practice/tile_recognition_screen.dart';
import 'practice/tile_matching_screen.dart';
import 'learn_screen.dart';
import 'practice/sequence_sorting_screen.dart';
import 'practice/rules_quiz_screen.dart';
import 'practice/speed_challenge_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final game = context.read<GameState>();
        final state = PracticeState();
        state.load(isPremium: game.isPremium);
        return state;
      },
      child: const _PracticeContent(),
    );
  }
}

class _PracticeContent extends StatelessWidget {
  const _PracticeContent();

  @override
  Widget build(BuildContext context) {
    final practiceState = context.watch<PracticeState>();
    final game = context.watch<GameState>();

    // Keep PracticeState's premium flag in sync with GameState so that a
    // subscription purchased mid-session immediately unlocks unlimited practice.
    if (practiceState.isLoaded && practiceState.isPremiumFlag != game.isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        practiceState.updatePremium(game.isPremium);
      });
    }

    if (!practiceState.isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F9F3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppI18n.t('practice.title'),
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppI18n.t('practice.subtitle'),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daily attempts card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _DailyAttemptsCard(
                  attemptsRemaining: practiceState.attemptsRemaining,
                  isPremium: game.isPremium,
                ),
              ),
            ),

            // Weakness recommendation
            if (practiceState.results.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _WeaknessCard(practiceState: practiceState),
                ),
              ),

            // Wrong-answer review practice (from GameState)
            if (game.wrongAnswerCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _WrongAnswerPracticeCard(
                    count: game.wrongAnswerCount,
                    onTap: () {
                      game.startWrongAnswerReview();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const LearnScreen(),
                      ));
                    },
                  ),
                ),
              ),

            // Practice modes header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text(
                  AppI18n.t('practice.modes'),
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),

            // Practice mode cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _PracticeModeCard(
                      title: AppI18n.t('practice.tileRecognition'),
                      subtitle: AppI18n.t('practice.tileRecognitionDesc'),
                      icon: Icons.visibility_rounded,
                      color: const Color(0xFF4CAF50),
                      accuracy: practiceState.getAccuracy('recognition'),
                      canPlay: practiceState.canPractice,
                      onTap: () => _startPractice(
                        context,
                        const TileRecognitionScreen(),
                        practiceState,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PracticeModeCard(
                      title: AppI18n.t('practice.tileMatching'),
                      subtitle: AppI18n.t('practice.tileMatchingDesc'),
                      icon: Icons.category_rounded,
                      color: const Color(0xFF5B9BD5),
                      accuracy: practiceState.getAccuracy('matching'),
                      canPlay: practiceState.canPractice,
                      onTap: () => _startPractice(
                        context,
                        const TileMatchingScreen(),
                        practiceState,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PracticeModeCard(
                      title: AppI18n.t('practice.sequenceSorting'),
                      subtitle: AppI18n.t('practice.sequenceSortingDesc'),
                      icon: Icons.sort_rounded,
                      color: const Color(0xFFE8B93E),
                      accuracy: practiceState.getAccuracy('sorting'),
                      canPlay: practiceState.canPractice,
                      onTap: () => _startPractice(
                        context,
                        const SequenceSortingScreen(),
                        practiceState,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PracticeModeCard(
                      title: AppI18n.t('practice.rulesQuiz'),
                      subtitle: AppI18n.t('practice.rulesQuizDesc'),
                      icon: Icons.quiz_rounded,
                      color: const Color(0xFF9C27B0),
                      accuracy: practiceState.getAccuracy('rules'),
                      canPlay: practiceState.canPractice,
                      onTap: () => _startPractice(
                        context,
                        const RulesQuizScreen(),
                        practiceState,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PracticeModeCard(
                      title: AppI18n.t('practice.speedChallenge'),
                      subtitle: AppI18n.t('practice.speedChallengeDesc'),
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFFFF6B35),
                      accuracy: null,
                      speedBest: practiceState.speedBest,
                      canPlay: practiceState.canPractice,
                      onTap: () => _startPractice(
                        context,
                        const SpeedChallengeScreen(),
                        practiceState,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent activity
            if (practiceState.results.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    AppI18n.t('practice.recentActivity'),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _RecentActivityList(
                    results: practiceState.results.reversed.take(5).toList(),
                  ),
                ),
              ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  static void _startPractice(
    BuildContext context,
    Widget screen,
    PracticeState practiceState,
  ) {
    if (!practiceState.canPractice) {
      _showUpgradeDialog(context);
      return;
    }
    if (!practiceState.useAttempt()) {
      _showUpgradeDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: practiceState,
          child: screen,
        ),
      ),
    );
  }

  static void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Color(0xFFE8B93E), size: 24),
            const SizedBox(width: 8),
            Text(
              AppI18n.t('practice.dailyLimitReached'),
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          AppI18n.t('practice.dailyLimitDesc').replaceAll(
              '{n}', PracticeState.freeAttemptsPerDay.toString()),
          style:
              GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF757575)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppI18n.t('practice.maybeLater'),
              style: GoogleFonts.nunito(color: const Color(0xFF9E9E9E)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppI18n.t('settings.upgradeToPro'),
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyAttemptsCard extends StatelessWidget {
  final int attemptsRemaining;
  final bool isPremium;

  const _DailyAttemptsCard({
    required this.attemptsRemaining,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                colors: [Color(0xFFE8B93E), Color(0xFFF5D060)],
              )
            : const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPremium ? Icons.all_inclusive : Icons.local_fire_department,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium
                      ? AppI18n.t('practice.unlimitedPractice')
                      : AppI18n.t('practice.dailyPractice'),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isPremium
                      ? AppI18n.t('practice.proUnlimitedDesc')
                      : AppI18n.t('practice.sessionsRemaining')
                          .replaceAll('{remaining}', attemptsRemaining.toString())
                          .replaceAll(
                              '{total}', PracticeState.freeAttemptsPerDay.toString()),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            ...List.generate(PracticeState.freeAttemptsPerDay, (i) {
              final isUsed = i >= attemptsRemaining;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  isUsed ? Icons.circle_outlined : Icons.circle,
                  size: 14,
                  color: Colors.white.withAlpha(isUsed ? 100 : 255),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _WeaknessCard extends StatelessWidget {
  final PracticeState practiceState;

  const _WeaknessCard({required this.practiceState});

  @override
  Widget build(BuildContext context) {
    final report = practiceState.weaknessReport;
    if (report.weakestTiles.isEmpty && report.weakestCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: Color(0xFFE65100), size: 20),
              const SizedBox(width: 8),
              Text(
                AppI18n.t('practice.recommended'),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (report.weakestTiles.isNotEmpty)
            Row(
              children: [
                Text(
                  AppI18n.t('practice.weakTiles'),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF795548),
                  ),
                ),
                ...report.weakestTiles.take(3).map((tile) => Container(
                      width: 28,
                      height: 37,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFE65100), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.asset(
                          'assets/tiles/$tile.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    )),
              ],
            ),
          if (report.weakestCategories.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              AppI18n.t('practice.focusOn').replaceAll(
                  '{categories}', report.weakestCategories.take(2).join(', ')),
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF795548),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? accuracy;
  final int? speedBest;
  final bool canPlay;
  final VoidCallback onTap;

  const _PracticeModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.accuracy,
    this.speedBest,
    required this.canPlay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            if (accuracy != null && accuracy! > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(accuracy! * 100).round()}%',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              )
            else if (speedBest != null && speedBest! > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '$speedBest',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              canPlay ? Icons.chevron_right : Icons.lock_outline,
              color:
                  canPlay ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final List<dynamic> results;

  const _RecentActivityList({required this.results});

  String _drillLabel(String type) {
    switch (type) {
      case 'recognition':
        return AppI18n.t('practice.tileRecognition');
      case 'matching':
        return AppI18n.t('practice.tileMatching');
      case 'sorting':
        return AppI18n.t('practice.sequenceSorting');
      case 'rules':
        return AppI18n.t('practice.rulesQuiz');
      case 'speed':
        return AppI18n.t('practice.speedChallenge');
      default:
        return type;
    }
  }

  IconData _drillIcon(String type) {
    switch (type) {
      case 'recognition':
        return Icons.visibility_rounded;
      case 'matching':
        return Icons.category_rounded;
      case 'sorting':
        return Icons.sort_rounded;
      case 'rules':
        return Icons.quiz_rounded;
      case 'speed':
        return Icons.bolt_rounded;
      default:
        return Icons.play_arrow;
    }
  }

  Color _drillColor(String type) {
    switch (type) {
      case 'recognition':
        return const Color(0xFF4CAF50);
      case 'matching':
        return const Color(0xFF5B9BD5);
      case 'sorting':
        return const Color(0xFFE8B93E);
      case 'rules':
        return const Color(0xFF9C27B0);
      case 'speed':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF757575);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppI18n.t('practice.justNow');
    if (diff.inMinutes < 60)
      return AppI18n.t('practice.minutesAgo')
          .replaceAll('{n}', diff.inMinutes.toString());
    if (diff.inHours < 24)
      return AppI18n.t('practice.hoursAgo')
          .replaceAll('{n}', diff.inHours.toString());
    return AppI18n.t('practice.daysAgo')
        .replaceAll('{n}', diff.inDays.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: results.asMap().entries.map((entry) {
          final index = entry.key;
          final r = entry.value;
          final isLast = index == results.length - 1;
          final color = _drillColor(r.drillType);
          final percentage = (r.accuracy * 100).round();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_drillIcon(r.drillType),
                          color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _drillLabel(r.drillType),
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          Text(
                            _timeAgo(r.timestamp),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      r.drillType == 'speed'
                          ? AppI18n.t('practice.tilesCount')
                              .replaceAll('{count}', r.correctAnswers.toString())
                          : '$percentage%',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}


// ── Wrong Answer Practice Card ──
class _WrongAnswerPracticeCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _WrongAnswerPracticeCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEF9A9A)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.error_outline,
                  color: Color(0xFFC62828), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppI18n.t('practice.reviewMistakes'),
                      style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC62828))),
                  const SizedBox(height: 2),
                  Text(
                      AppI18n.t('practice.reviewMistakesDesc')
                          .replaceAll('{count}', count.toString()),
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFFE57373))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFC62828), size: 24),
          ],
        ),
      ),
    );
  }
}
