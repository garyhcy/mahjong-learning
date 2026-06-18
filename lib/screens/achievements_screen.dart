import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mascot_widget.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '成就',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8B93E), Color(0xFFF9A825)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8B93E).withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const MascotWidget(
                      expression: MascotExpression.content,
                      size: 80,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '成就進度',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '已解鎖 8 / 24 個成就',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: 0.33,
                              backgroundColor: Colors.white.withAlpha(40),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section Header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '已解鎖成就',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Achievement Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _AchievementBadge(
                    icon: Icons.school_rounded,
                    color: const Color(0xFF4CAF50),
                    title: '初學者',
                    subtitle: '完成第一個課程',
                  ),
                  _AchievementBadge(
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFE8B93E),
                    title: '連續七天',
                    subtitle: '連續學習 7 天',
                  ),
                  _AchievementBadge(
                    icon: Icons.stars_rounded,
                    color: const Color(0xFFE8B93E),
                    title: '滿分達人',
                    subtitle: '測驗獲得滿分',
                  ),
                  _AchievementBadge(
                    icon: Icons.auto_awesome_rounded,
                    color: const Color(0xFF4CAF50),
                    title: '基礎精通',
                    subtitle: '完成基礎規則全部課程',
                  ),
                  _AchievementBadge(
                    icon: Icons.psychology_rounded,
                    color: const Color(0xFF9C27B0),
                    title: '策略家',
                    subtitle: '完成進階策略課程',
                  ),
                  _AchievementBadge(
                    icon: Icons.speed_rounded,
                    color: const Color(0xFF2196F3),
                    title: '快速答題',
                    subtitle: '5 秒內答對題目',
                  ),
                  _AchievementBadge(
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFE8B93E),
                    title: 'Level 5',
                    subtitle: '達到等級 5',
                  ),
                  _AchievementBadge(
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF4CAF50),
                    title: '勤奮好學',
                    subtitle: '完成 20 堂課',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Locked Section
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDBDBD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '尚未解鎖',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(6, (i) {
                  return _AchievementBadge(
                    icon: Icons.lock_rounded,
                    color: const Color(0xFFE0E0E0),
                    title: '???',
                    subtitle: '繼續學習來解鎖',
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _AchievementBadge({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = icon == Icons.lock_rounded;
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? const Color(0xFFEEEEEE) : const Color(0xFFF0F0F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFF5F5F5) : color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isLocked ? const Color(0xFFE0E0E0) : color,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLocked ? const Color(0xFFBDBDBD) : const Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: isLocked ? const Color(0xFFE0E0E0) : const Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
