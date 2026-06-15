import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_controller.dart';
import 'models/curriculum_data.dart';
import 'services/progress_storage.dart';
import 'widgets/tile_hand.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = GameController(ProgressStorage());
  await game.load();
  runApp(MahjongMasterNewApp(game: game));
}

class MahjongMasterNewApp extends StatelessWidget {
  const MahjongMasterNewApp({super.key, required this.game});

  final GameController game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahjong Master New',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFD94040),
        useMaterial3: true,
      ),
      home: game.onboardingSeen ? CurriculumHomeScreen(game: game) : OnboardingScreen(game: game),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CurriculumHomeScreen extends StatefulWidget {
  const CurriculumHomeScreen({super.key, required this.game});

  final GameController game;

  @override
  State<CurriculumHomeScreen> createState() => _CurriculumHomeScreenState();
}

class _CurriculumHomeScreenState extends State<CurriculumHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _onlyIncomplete = false;
  int _tabIndex = 0;
  static const _releaseVersion = '0.2.0';

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_onGameUpdate);
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.game.removeListener(_onGameUpdate);
    super.dispose();
  }

  void _onGameUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final seen = widget.game.seenReleaseNoteVersion;
      if (seen == _releaseVersion) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('What\'s New (v0.2.0)'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('- New tabbed home: Learn / Profile / Analytics'),
              Text('- Lesson result screen with stars + next CTA'),
              Text('- Search and incomplete filters'),
              Text('- Local analytics event log'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                widget.game.markReleaseNoteSeen(_releaseVersion);
                Navigator.pop(context);
              },
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    if (!game.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = <Widget>[
      _buildLearnTab(game),
      ProfileScreen(game: game, embedded: true),
      AnalyticsLogScreen(game: game, embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mahjong Master New'),
      ),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (value) => setState(() => _tabIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildLearnTab(GameController game) {
    return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _StatChip(label: 'XP', value: '${game.xp}'),
              const SizedBox(width: 8),
              _StatChip(label: 'Hearts', value: '${game.hearts}'),
              const SizedBox(width: 8),
              _StatChip(label: 'Streak', value: '${game.streak}'),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search lesson id/title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _onlyIncomplete,
                onChanged: (v) => setState(() => _onlyIncomplete = v == true),
              ),
              const Text('Only show incomplete lessons'),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Global Progress', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          value: game.lessonCompleted.values.where((v) => v).length / cursorLessons.length,
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${game.lessonCompleted.values.where((v) => v).length} / ${cursorLessons.length} completed',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Goal', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: game.dailyProgress),
                  const SizedBox(height: 6),
                  Text('${game.dailyDoneCount} / ${game.dailyGoal} lessons completed today'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (game.hasActiveLesson && game.currentLesson != null) ...[
            _ContinueLessonCard(
              game: game,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LessonScreen(game: game)),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          ...cursorStages.map((stage) {
            final query = _searchController.text.trim().toLowerCase();
            final stageLessons = cursorLessons.where((l) => l.stageId == stage.id).where((lesson) {
              final done = game.lessonCompleted[lesson.id] == true;
              if (_onlyIncomplete && done) return false;
              if (query.isEmpty) return true;
              final hay = '${lesson.id} ${lesson.title} ${lesson.subtitle}'.toLowerCase();
              return hay.contains(query);
            }).toList();
            final count = stageLessons.length;
            if (count == 0) {
              return const SizedBox.shrink();
            }
            final stageProgress = game.stageProgress(stage.id);
            return Card(
              child: ExpansionTile(
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        value: stageProgress,
                        strokeWidth: 3,
                        color: stage.color,
                        backgroundColor: Colors.black12,
                      ),
                    ),
                    Icon(stage.icon, color: stage.color, size: 18),
                  ],
                ),
                title: Text(stage.title),
                subtitle: Text('${stage.subtitle}  •  $count lessons  •  ${(stageProgress * 100).round()}%'),
                children: [
                  ...stageLessons.map((lesson) {
                    final unlocked = game.isLessonUnlocked(lesson);
                    final done = game.lessonCompleted[lesson.id] == true;
                    final lessonProgress = game.lessonProgress(lesson.id);
                    return ListTile(
                      enabled: unlocked,
                      leading: Icon(
                        done ? Icons.check_circle : (unlocked ? Icons.play_circle_fill : Icons.lock),
                        color: done ? Colors.green : (unlocked ? stage.color : Colors.grey),
                      ),
                      title: Text('${lesson.id}  ${lesson.title}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson.subtitle),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: done ? 1 : lessonProgress,
                            minHeight: 4,
                            color: done ? Colors.green : stage.color,
                            backgroundColor: Colors.black12,
                          ),
                        ],
                      ),
                      trailing: done
                          ? const _LessonBadge(label: 'Done', color: Colors.green)
                          : (unlocked ? const _LessonBadge(label: 'Open', color: Colors.blue) : const _LessonBadge(label: 'Locked', color: Colors.grey)),
                      onTap: !unlocked
                          ? null
                          : () {
                              game.startLesson(lesson.id);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LessonScreen(game: game),
                                ),
                              );
                            },
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Total lessons: ${cursorLessons.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      );
  }
}

class _LessonBadge extends StatelessWidget {
  const _LessonBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.game});
  final GameController game;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String? _feedback;
  bool _showExplanation = false;
  bool _pulseQuestion = false;
  int _startXp = 0;
  int _startHearts = 0;
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _startXp = widget.game.xp;
    _startHearts = widget.game.hearts;
    widget.game.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.game.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _pulse() async {
    setState(() => _pulseQuestion = true);
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) setState(() => _pulseQuestion = false);
  }

  void _refresh() {
    final lesson = widget.game.currentLesson;
    if (!_navigatedToResult && lesson != null && widget.game.lessonCompleted[lesson.id] == true) {
      _navigatedToResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LessonResultScreen(
              game: widget.game,
              lesson: lesson,
              gainedXp: widget.game.xp - _startXp,
              heartsUsed: (_startHearts - widget.game.hearts).clamp(0, 5),
            ),
          ),
        );
      });
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.game.currentLesson;
    if (lesson == null) {
      return const Scaffold(body: Center(child: Text('No active lesson.')));
    }

    final inDialogue = !widget.game.isDialogueDone;
    final q = widget.game.currentQuestion;
    final completed = widget.game.lessonCompleted[lesson.id] == true;
    final qCount = widget.game.questionCount;
    final qIndex = widget.game.questionIndex;
    final progressValue = qCount == 0 ? 0.0 : (qIndex / qCount).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('${lesson.id} ${lesson.title}'),
        leading: IconButton(
          onPressed: () {
            widget.game.leaveLesson();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (!inDialogue && !completed) ...[
              LinearProgressIndicator(value: progressValue),
              const SizedBox(height: 6),
              Text('Question ${qIndex + 1} / $qCount'),
              const SizedBox(height: 12),
            ],
            if (inDialogue) ...[
              Text(
                lesson.dialogue[widget.game.dialogueIndex],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: widget.game.advanceDialogue,
                child: const Text('Next'),
              ),
            ] else if (completed) ...[
              const SizedBox.shrink(),
            ] else if (q != null) ...[
              AnimatedScale(
                scale: _pulseQuestion ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 140),
                child: Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              if (widget.game.outOfHearts) ...[
                _NoHeartsBanner(game: widget.game),
                const SizedBox(height: 10),
              ],
              if (q.type == CursorQuizType.tileSelection && q.tiles != null) ...[
                TileHand(tiles: q.tiles!),
                const SizedBox(height: 10),
              ],
              ...List.generate(q.options.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: widget.game.outOfHearts
                        ? null
                        : () {
                      final ok = widget.game.answer(i);
                      if (ok) {
                        HapticFeedback.selectionClick();
                      } else {
                        HapticFeedback.heavyImpact();
                      }
                      _pulse();
                      setState(() {
                        _feedback = ok ? 'Correct! +10 XP' : 'Wrong. -1 heart';
                        _showExplanation = true;
                      });
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(q.options[i]),
                    ),
                  ),
                );
              }),
              if (_feedback != null && _showExplanation) ...[
                const SizedBox(height: 8),
                Text(
                  _feedback!,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _feedback!.startsWith('Correct') ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(q.explanation),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ContinueLessonCard extends StatelessWidget {
  const _ContinueLessonCard({required this.game, required this.onTap});

  final GameController game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lesson = game.currentLesson;
    if (lesson == null) return const SizedBox.shrink();
    final progress = game.lessonProgress(lesson.id);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue Lesson',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('${lesson.id}  ${lesson.title}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 4),
              Text('${(progress * 100).round()}%'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoHeartsBanner extends StatelessWidget {
  const _NoHeartsBanner({required this.game});

  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No hearts left',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red),
          ),
          SizedBox(height: 4),
          Text('Hearts refill to full after midnight.'),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.game, this.embedded = false});
  final GameController game;
  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _importController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.game.addListener(_refresh);
  }

  @override
  void dispose() {
    _importController.dispose();
    widget.game.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.game.lessonCompleted.values.where((v) => v).length;
    final body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('XP'),
              trailing: Text('${widget.game.xp}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Hearts'),
              subtitle: const Text('Refill to full after midnight'),
              trailing: Text('${widget.game.hearts}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Streak'),
              trailing: Text('${widget.game.streak}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Completed Lessons'),
              trailing: Text('$completed / ${cursorLessons.length}'),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Demo Mode'),
              subtitle: const Text('Unlock all lessons for showcase'),
              value: widget.game.demoModeEnabled,
              onChanged: (v) => widget.game.setDemoMode(v),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset all progress?'),
                  content: const Text('This will clear XP, hearts state, streak, and lesson progress.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                  ],
                ),
              );
              if (yes == true) {
                await widget.game.resetProgress();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress reset completed.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset Progress'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final json = widget.game.exportProgressJson();
              _importController.text = json;
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Export Progress JSON'),
                  content: SizedBox(
                    width: 540,
                    child: TextField(
                      controller: _importController,
                      maxLines: 10,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Copy this JSON',
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Export Progress JSON'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _importController.clear();
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Import Progress JSON'),
                  content: SizedBox(
                    width: 540,
                    child: TextField(
                      controller: _importController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Paste JSON here',
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        final ok = widget.game.importProgressJson(_importController.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? 'Import success' : 'Import failed: invalid JSON')),
                        );
                      },
                      child: const Text('Import'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Import Progress JSON'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Version 0.1.0 MVP',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile / Settings')),
      body: body,
    );
  }
}

class LessonResultScreen extends StatelessWidget {
  const LessonResultScreen({
    super.key,
    required this.game,
    required this.lesson,
    required this.gainedXp,
    required this.heartsUsed,
  });

  final GameController game;
  final CursorLesson lesson;
  final int gainedXp;
  final int heartsUsed;

  int _stars() {
    if (heartsUsed == 0) return 3;
    if (heartsUsed <= 2) return 2;
    return 1;
  }

  CursorLesson? _nextLesson() {
    final idx = cursorLessons.indexWhere((l) => l.id == lesson.id);
    if (idx < 0 || idx + 1 >= cursorLessons.length) return null;
    return cursorLessons[idx + 1];
  }

  @override
  Widget build(BuildContext context) {
    final stars = _stars();
    final next = _nextLesson();
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lesson.id} ${lesson.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Text('Star rating: ${'⭐' * stars}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Text('XP gained: $gainedXp'),
            Text('Hearts used: $heartsUsed'),
            const SizedBox(height: 16),
            if (next != null)
              FilledButton(
                onPressed: () {
                  game.startLesson(next.id);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => LessonScreen(game: game)),
                  );
                },
                child: Text('Next Lesson: ${next.id}'),
              ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                game.leaveLesson();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => CurriculumHomeScreen(game: game)),
                  (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsLogScreen extends StatelessWidget {
  const AnalyticsLogScreen({super.key, required this.game, this.embedded = false});
  final GameController game;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final events = game.analyticsEvents.reversed.toList();
    final body = events.isEmpty
        ? const Center(child: Text('No events yet.'))
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) => Text(events[i], style: const TextStyle(fontFamily: 'monospace')),
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemCount: events.length,
          );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Local Analytics Log')),
      body: body,
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Welcome to Mahjong Master New',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text('Learn Hong Kong Mahjong step by step with 36 lessons.'),
              const SizedBox(height: 6),
              const Text('Complete lessons, earn XP, and keep your daily streak alive.'),
              const SizedBox(height: 6),
              const Text('Wrong answers cost hearts. Hearts refill to full after midnight.'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    game.markOnboardingSeen();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => CurriculumHomeScreen(game: game)),
                    );
                  },
                  child: const Text('Start Learning'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
