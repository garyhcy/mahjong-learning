/// Achievement definition
class AchievementDef {
  final String id;
  final String name;
  final String emoji;
  final String desc;
  const AchievementDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.desc,
  });
}

/// All achievements (24) - IDs aligned with community_screen.dart _allAchievements
const Map<String, AchievementDef> achievementDefs = {
  'first_lesson': AchievementDef(
      id: 'first_lesson', name: 'Beginner', emoji: '🎓', desc: 'Complete 1 lesson'),
  'early_bird': AchievementDef(
      id: 'early_bird', name: 'Early Bird', emoji: '🐦', desc: 'Complete a lesson between 06:00-09:00'),
  'streak_3': AchievementDef(
      id: 'streak_3', name: '3-Day Streak', emoji: '🔥', desc: '3-day learning streak'),
  'streak_7': AchievementDef(
      id: 'streak_7', name: '7-Day Streak', emoji: '💪', desc: '7-day learning streak'),
  'perfect_quiz': AchievementDef(
      id: 'perfect_quiz', name: 'Perfect Score', emoji: '💯', desc: '100% correct in a single quiz'),
  'five_lessons': AchievementDef(
      id: 'five_lessons', name: 'Bookworm', emoji: '📚', desc: 'Complete 5 lessons'),
  'first_stage': AchievementDef(
      id: 'first_stage', name: 'Stage Clear', emoji: '🏅', desc: 'Complete Stage 1'),
  'quick_learner': AchievementDef(
      id: 'quick_learner', name: 'Quick Learner', emoji: '⚡', desc: 'Complete 3 lessons within 30 minutes'),
  'comeback': AchievementDef(
      id: 'comeback', name: 'Comeback', emoji: '🔄', desc: 'Complete a lesson after 7+ days inactive'),
  'night_owl': AchievementDef(
      id: 'night_owl', name: 'Night Owl', emoji: '🦉', desc: 'Complete a lesson between 23:00-02:00'),
  'streak_14': AchievementDef(
      id: 'streak_14', name: '14-Day Streak', emoji: '🌟', desc: '14-day learning streak'),
  'streak_30': AchievementDef(
      id: 'streak_30', name: '30-Day Streak', emoji: '🏆', desc: '30-day learning streak'),
  'ten_lessons': AchievementDef(
      id: 'ten_lessons', name: 'Scholar', emoji: '📖', desc: 'Complete 10 lessons'),
  'twenty_lessons': AchievementDef(
      id: 'twenty_lessons', name: 'Dedicated', emoji: '🎯', desc: 'Complete 20 lessons'),
  'all_stages': AchievementDef(
      id: 'all_stages', name: 'Master', emoji: '👑', desc: 'Complete all stages'),
  'social_3': AchievementDef(
      id: 'social_3', name: 'Social', emoji: '🤝', desc: 'Add 3 friends'),
  'social_10': AchievementDef(
      id: 'social_10', name: 'Popular', emoji: '🎉', desc: 'Add 10 friends'),
  'first_match': AchievementDef(
      id: 'first_match', name: 'First Match', emoji: '🀄', desc: 'Play your first match (locked)'),
  'match_5': AchievementDef(
      id: 'match_5', name: 'Regular', emoji: '🎲', desc: 'Play 5 matches (locked)'),
  'match_win': AchievementDef(
      id: 'match_win', name: 'Winner', emoji: '🏅', desc: 'Win a match (locked)'),
  'speed_demon': AchievementDef(
      id: 'speed_demon', name: 'Speed Demon', emoji: '💨', desc: 'Win speed challenge 10 times'),
  'explorer': AchievementDef(
      id: 'explorer', name: 'Explorer', emoji: '🗺️', desc: 'Complete all 17 course types'),
  'gold_league': AchievementDef(
      id: 'gold_league', name: 'Gold Member', emoji: '🥇', desc: 'Reach Gold league (1200+ XP)'),
  'diamond_league': AchievementDef(
      id: 'diamond_league', name: 'Diamond', emoji: '💎', desc: 'Reach Diamond league (4000+ XP)'),
};

/// League tier thresholds (XP-based) - used by achievement checks
const int leagueGoldXp = 1200;
const int leagueDiamondXp = 4000;
