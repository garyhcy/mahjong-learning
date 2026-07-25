/// Daily task definition
class DailyTaskDef {
  final String id;
  final String name;
  final int target;
  final int reward;
  const DailyTaskDef({
    required this.id,
    required this.name,
    required this.target,
    required this.reward,
  });
}

const Map<String, DailyTaskDef> dailyTaskDefs = {
  'complete_lesson': DailyTaskDef(
      id: 'complete_lesson', name: 'Complete 1 Lesson', target: 1, reward: 5),
  'streak_3': DailyTaskDef(
      id: 'streak_3', name: '3 Correct in a Row', target: 3, reward: 10),
  'earn_50xp': DailyTaskDef(
      id: 'earn_50xp', name: 'Earn 50 XP', target: 50, reward: 15),
};
