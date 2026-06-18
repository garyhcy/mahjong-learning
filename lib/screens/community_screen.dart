import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mascot_widget.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '社區',
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
            children: [
              const SizedBox(height: 20),
              // Community mascot header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const MascotWidget(
                      expression: MascotExpression.excited,
                      size: 100,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '麻將社區',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '與朋友一起學習，互相切磋',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Leaderboard section
              _SectionHeader(
                icon: Icons.leaderboard_rounded,
                title: '排行榜',
              ),
              const SizedBox(height: 12),
              _LeaderboardCard(rank: 1, name: '麻將大師', xp: 2500),
              _LeaderboardCard(rank: 2, name: '雀聖高手', xp: 2100),
              _LeaderboardCard(rank: 3, name: '牌局達人', xp: 1800),
              _LeaderboardCard(rank: 4, name: '初學新手', xp: 1200),
              _LeaderboardCard(rank: 5, name: '勤奮學徒', xp: 800),

              const SizedBox(height: 24),

              // Friend activity section
              _SectionHeader(
                icon: Icons.groups_rounded,
                title: '好友動態',
              ),
              const SizedBox(height: 12),
              _ActivityCard(
                avatar: '🐼',
                name: '小明',
                action: '完成了「基礎規則」課程',
                time: '5 分鐘前',
              ),
              _ActivityCard(
                avatar: '🀄',
                name: '小華',
                action: '達到 Level 8',
                time: '30 分鐘前',
              ),
              _ActivityCard(
                avatar: '🎯',
                name: '阿強',
                action: '解鎖了「進階策略」成就',
                time: '2 小時前',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;

  const _LeaderboardCard({
    required this.rank,
    required this.name,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFE8B93E),
      const Color(0xFFBDBDBD),
      const Color(0xFFCD7F32),
    ];
    final rankColor = rank <= 3 ? rankColors[rank - 1] : const Color(0xFF9E9E9E);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B93E).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$xp XP',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE8B93E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String avatar;
  final String name;
  final String action;
  final String time;

  const _ActivityCard({
    required this.avatar,
    required this.name,
    required this.action,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF2D2D2D),
                    ),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: ' $action',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
