import 'package:flutter/material.dart';
import 'mascot_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentMascot = 'happy';

  final int _streakDays = 7;
  final int _tilesLearned = 24;
  final int _lessonsCompleted = 12;

  void _onMascotTap() {
    setState(() {
      const cycle = ['happy', 'surprised', 'proud', 'thinking', 'sad'];
      final idx = cycle.indexOf(_currentMascot);
      _currentMascot = cycle[(idx + 1) % cycle.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 24),
              _buildStatRow(),
              const SizedBox(height: 20),
              _buildDailyChallenge(),
              const SizedBox(height: 24),
              _buildStartLearningButton(),
              const SizedBox(height: 28),
              _buildLearningPath(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Banner ──────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC21807), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC21807).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ludi',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your Mahjong Journey\nStarts Here',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MascotWidget(
            mascot: _currentMascot,
            size: 130,
            onTap: _onMascotTap,
          ),
        ],
      ),
    );
  }

  // ── Stat Row ─────────────────────────────────────────────────
  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Streak', '$_streakDays days', Icons.local_fire_department, const Color(0xFFFF6D00))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Tiles', '$_tilesLearned', Icons.grid_view_rounded, const Color(0xFF1565C0))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Lessons', '$_lessonsCompleted', Icons.menu_book_rounded, const Color(0xFF2E7D32))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ── Daily Challenge ──────────────────────────────────────────
  Widget _buildDailyChallenge() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFF8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6D00).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFF6D00), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Challenge',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF3E2723)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Identify 5 tile patterns in 60s',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6D00),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Play', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Start Learning Button ────────────────────────────────────
  Widget _buildStartLearningButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFC21807)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD32F2F).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
            SizedBox(width: 4),
            Text(
              'Start Learning',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // ── Learning Path ────────────────────────────────────────────
  Widget _buildLearningPath() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Learning Path',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF3E2723)),
        ),
        const SizedBox(height: 14),
        _buildStageCard(
          stage: 1,
          title: 'Tile Recognition',
          subtitle: 'Learn all 34 tile types',
          state: StageState.completed,
        ),
        _buildStageCard(
          stage: 2,
          title: 'Basic Hands',
          subtitle: 'Master common winning hands',
          state: StageState.active,
          progress: 0.6,
        ),
        _buildStageCard(
          stage: 3,
          title: 'Scoring & Strategy',
          subtitle: 'Advanced scoring rules',
          state: StageState.locked,
        ),
      ],
    );
  }

  Widget _buildStageCard({
    required int stage,
    required String title,
    required String subtitle,
    required StageState state,
    double progress = 0.0,
  }) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData? leadingIcon;

    switch (state) {
      case StageState.completed:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF81C784);
        textColor = const Color(0xFF2E7D32);
        leadingIcon = Icons.check_circle;
        break;
      case StageState.active:
        bgColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFFFB74D);
        textColor = const Color(0xFFE65100);
        leadingIcon = Icons.play_circle_fill;
        break;
      case StageState.locked:
        bgColor = const Color(0xFFF5F5F5);
        borderColor = const Color(0xFFBDBDBD);
        textColor = const Color(0xFF9E9E9E);
        leadingIcon = Icons.lock;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: textColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Stage $stage',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7)),
                    ),
                    const SizedBox(width: 8),
                    if (state == StageState.completed)
                      const Text('Done', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
                if (state == StageState.active) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: borderColor.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE65100)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(progress * 100).toInt()}% complete', style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.6))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum StageState { completed, active, locked }
