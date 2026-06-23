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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Leaderboard Header ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B9BD5), Color(0xFF3A7BD5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B9BD5).withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const MascotWidget(
                      expression: MascotExpression.happy,
                      size: 72,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '本週排行榜',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '你的排名：第 12 名',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _statChip('850 XP', Icons.bolt_rounded),
                              const SizedBox(width: 12),
                              _statChip('7 天', Icons.local_fire_department_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Top 3 Podium ---
              _sectionHeader('🏆 前三名'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _podiumCard(2, '麻將達人', '2,340 XP', const Color(0xFF9E9E9E))),
                  const SizedBox(width: 10),
                  Expanded(child: _podiumCard(1, '雀神歸位', '3,120 XP', const Color(0xFFE8B93E))),
                  const SizedBox(width: 10),
                  Expanded(child: _podiumCard(3, '新手入門', '1,980 XP', const Color(0xFFCD7F32))),
                ],
              ),
              const SizedBox(height: 28),

              // --- Full Leaderboard ---
              _sectionHeader('全部排名'),
              const SizedBox(height: 12),
              _leaderboardItem(4, '雀友小王', '1,650 XP', false),
              _leaderboardItem(5, '麻將新手', '1,420 XP', false),
              _leaderboardItem(6, '廣東仔', '1,280 XP', false),
              _leaderboardItem(7, '牌技精湛', '1,150 XP', false),
              _leaderboardItem(8, '自摸高手', '1,020 XP', false),
              _leaderboardItem(9, '十三么', '980 XP', false),
              _leaderboardItem(10, '清一色', '910 XP', false),
              _leaderboardItem(11, '大四喜', '880 XP', false),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          _rankBadge(12, const Color(0xFF4CAF50)),
                          const SizedBox(width: 12),
                          const MascotWidget(
                            expression: MascotExpression.content,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '你 · Ludi 學員',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                          ),
                          Text(
                            '850 XP',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // --- Friends Section ---
              _sectionHeader('好友動態'),
              const SizedBox(height: 12),
              _friendActivity('雀友小王', '完成了「碰牌技巧」課程', '10 分鐘前'),
              _friendActivity('麻將新手', '連續學習第 5 天', '1 小時前'),
              _friendActivity('廣東仔', '解鎖了「成就：滿分達人」', '3 小時前'),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF5B9BD5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _podiumCard(int rank, String name, String xp, Color color) {
    final heights = {1: 120.0, 2: 100.0, 3: 85.0};
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Column(
      children: [
        Text(medals[rank]!, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(30),
          ),
          child: Center(
            child: Text('$rank',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                )),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: heights[rank],
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(xp,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: Colors.white70,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _leaderboardItem(int rank, String name, String xp, bool isSelf) {
    final bgColor = isSelf ? const Color(0xFFE8F5E9) : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                _rankBadge(rank, const Color(0xFF757575)),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4CAF50).withAlpha(20),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: const Color(0xFF4CAF50).withAlpha(150), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(name,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                      )),
                ),
                Text(xp,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF757575),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rankBadge(int rank, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(20),
      ),
      child: Center(
        child: Text('$rank',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            )),
      ),
    );
  }

  Widget _friendActivity(String name, String action, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF5B9BD5).withAlpha(20),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: const Color(0xFF5B9BD5), size: 22),
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
                            TextSpan(text: ' $action'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(time,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: const Color(0xFFBDBDBD),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
