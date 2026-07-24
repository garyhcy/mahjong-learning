// ─── Achievement display model (expanded to 24) ───
class AchievementDisplay {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;

  const AchievementDisplay({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

const List<AchievementDisplay> allAchievements = [
  // Unlocked (10)
  AchievementDisplay(id: 'first_lesson', emoji: '🎓', title: 'achievement.first_lesson.title', subtitle: 'achievement.first_lesson.subtitle'),
  AchievementDisplay(id: 'early_bird', emoji: '🐦', title: 'achievement.early_bird.title', subtitle: 'achievement.early_bird.subtitle'),
  AchievementDisplay(id: 'streak_3', emoji: '🔥', title: 'achievement.streak_3.title', subtitle: 'achievement.streak_3.subtitle'),
  AchievementDisplay(id: 'streak_7', emoji: '💪', title: 'achievement.streak_7.title', subtitle: 'achievement.streak_7.subtitle'),
  AchievementDisplay(id: 'perfect_quiz', emoji: '💯', title: 'achievement.perfect_quiz.title', subtitle: 'achievement.perfect_quiz.subtitle'),
  AchievementDisplay(id: 'five_lessons', emoji: '📚', title: 'achievement.five_lessons.title', subtitle: 'achievement.five_lessons.subtitle'),
  AchievementDisplay(id: 'first_stage', emoji: '🏅', title: 'achievement.first_stage.title', subtitle: 'achievement.first_stage.subtitle'),
  AchievementDisplay(id: 'quick_learner', emoji: '⚡', title: 'achievement.quick_learner.title', subtitle: 'achievement.quick_learner.subtitle'),
  AchievementDisplay(id: 'comeback', emoji: '🔄', title: 'achievement.comeback.title', subtitle: 'achievement.comeback.subtitle'),
  AchievementDisplay(id: 'night_owl', emoji: '🦉', title: 'achievement.night_owl.title', subtitle: 'achievement.night_owl.subtitle'),
  // Locked (14)
  AchievementDisplay(id: 'streak_14', emoji: '🌟', title: 'achievement.streak_14.title', subtitle: 'achievement.streak_14.subtitle'),
  AchievementDisplay(id: 'streak_30', emoji: '🏆', title: 'achievement.streak_30.title', subtitle: 'achievement.streak_30.subtitle'),
  AchievementDisplay(id: 'ten_lessons', emoji: '📖', title: 'achievement.ten_lessons.title', subtitle: 'achievement.ten_lessons.subtitle'),
  AchievementDisplay(id: 'twenty_lessons', emoji: '🎯', title: 'achievement.twenty_lessons.title', subtitle: 'achievement.twenty_lessons.subtitle'),
  AchievementDisplay(id: 'all_stages', emoji: '👑', title: 'achievement.all_stages.title', subtitle: 'achievement.all_stages.subtitle'),
  AchievementDisplay(id: 'social_3', emoji: '🤝', title: 'achievement.social_3.title', subtitle: 'achievement.social_3.subtitle'),
  AchievementDisplay(id: 'social_10', emoji: '🎉', title: 'achievement.social_10.title', subtitle: 'achievement.social_10.subtitle'),
  AchievementDisplay(id: 'first_match', emoji: '🀄', title: 'achievement.first_match.title', subtitle: 'achievement.first_match.subtitle'),
  AchievementDisplay(id: 'match_5', emoji: '🎲', title: 'achievement.match_5.title', subtitle: 'achievement.match_5.subtitle'),
  AchievementDisplay(id: 'match_win', emoji: '🏅', title: 'achievement.match_win.title', subtitle: 'achievement.match_win.subtitle'),
  AchievementDisplay(id: 'speed_demon', emoji: '💨', title: 'achievement.speed_demon.title', subtitle: 'achievement.speed_demon.subtitle'),
  AchievementDisplay(id: 'explorer', emoji: '🗺️', title: 'achievement.explorer.title', subtitle: 'achievement.explorer.subtitle'),
  AchievementDisplay(id: 'gold_league', emoji: '🥇', title: 'achievement.gold_league.title', subtitle: 'achievement.gold_league.subtitle'),
  AchievementDisplay(id: 'diamond_league', emoji: '💎', title: 'achievement.diamond_league.title', subtitle: 'achievement.diamond_league.subtitle'),
];

