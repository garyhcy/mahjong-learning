import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_state.dart';
import '../services/app_i18n.dart';

/// Compact "today" card for Home: streak, the three daily tasks and a single
/// start button. Mirrors the claim rules used on the Community tab; the game
/// state stays the single owner of progress and rewards.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.game,
    required this.onStartLesson,
  });

  final GameState game;
  final VoidCallback onStartLesson;

  static const _green = Color(0xFF4CAF50);
  static const _greenDark = Color(0xFF2E7D32);
  static const _gold = Color(0xFFE8B93E);
  static const _ink = Color(0xFF2D2D2D);
  static const _muted = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    final tasks = <_GoalTask>[
      _GoalTask(
        id: 'complete_lesson',
        icon: Icons.menu_book_rounded,
        label: AppI18n.t('social.taskCompleteLesson'),
        progress: game.lessonCompletedToday.clamp(0, 1),
        target: 1,
        reward: 5,
        claimed: game.dailyTasks['complete_lesson_claimed'] == 1,
      ),
      _GoalTask(
        id: 'streak_3',
        icon: Icons.bolt_rounded,
        label: AppI18n.t('social.taskStreak3'),
        progress: game.consecutiveCorrect.clamp(0, 3),
        target: 3,
        reward: 10,
        claimed: game.dailyTasks['streak_3_claimed'] == 1,
      ),
      _GoalTask(
        id: 'earn_50xp',
        icon: Icons.stars_rounded,
        label: AppI18n.t('social.taskEarn50xp'),
        progress: game.dailyXpEarned.clamp(0, 50),
        target: 50,
        reward: 15,
        claimed: game.dailyTasks['earn_50xp_claimed'] == 1,
      ),
    ];
    final doneCount = tasks.where((task) => task.done).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7EAE3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D4A2F).withAlpha(12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFF7043),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppI18n.t(
                              'home.dayStreak',
                            ).replaceAll('{n}', '${game.streak}'),
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                          ),
                          Text(
                            AppI18n.t('home.todayGoal'),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$doneCount / ${tasks.length}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: doneCount == tasks.length ? _greenDark : _muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...tasks.map((task) => _taskRow(context, task)),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onStartLesson,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      AppI18n.t('home.startLesson'),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: _greenDark,
                      backgroundColor: const Color(0xFFEFF7ED),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taskRow(BuildContext context, _GoalTask task) {
    final fraction = (task.progress / task.target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            task.icon,
            size: 18,
            color: task.done ? _greenDark : const Color(0xFF9E9E9E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.label,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFF1F3EE),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      task.done ? _greenDark : _green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerRight,
              child: task.claimed
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: _greenDark,
                      size: 20,
                    )
                  : task.done
                  ? _claimChip(context, task)
                  : Text(
                      '${task.progress}/${task.target}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: _muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _claimChip(BuildContext context, _GoalTask task) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        game.claimDailyTaskReward(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '+${task.reward} XP',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _greenDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '+${task.reward} XP',
          style: GoogleFonts.nunito(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GoalTask {
  const _GoalTask({
    required this.id,
    required this.icon,
    required this.label,
    required this.progress,
    required this.target,
    required this.reward,
    required this.claimed,
  });

  final String id;
  final IconData icon;
  final String label;
  final int progress;
  final int target;
  final int reward;
  final bool claimed;

  bool get done => progress >= target;
}
