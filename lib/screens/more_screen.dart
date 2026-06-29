import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/mascot_widget.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _masterMode = false;
  int _tapCount = 0;
  bool _masterUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'More',
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
              const SizedBox(height: 12),
              // Profile Card - tap 5 times to reveal master mode
              GestureDetector(
                onTap: () {
                  _tapCount++;
                  if (_tapCount >= 5 && !_masterUnlocked) {
                    setState(() {
                      _masterUnlocked = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔓 Master Mode unlocked!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                        expression: MascotExpression.happy,
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        game.nickname.isNotEmpty ? game.nickname : 'Ludi Learner',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${game.userLevel} · ${game.xp} XP',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Master Mode Section (hidden until unlocked)
              if (_masterUnlocked) ...[
                _SectionHeader(title: 'Developer'),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _masterMode ? const Color(0xFFFFF3E0) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _masterMode ? const Color(0xFFFF9800) : const Color(0xFFF0F0F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFFF9800), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Master Mode',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2D2D),
                              ),
                            ),
                            Text(
                              'Unlock all stages, infinite hearts',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _masterMode,
                        activeColor: const Color(0xFFFF9800),
                        onChanged: (val) {
                          setState(() {
                            _masterMode = val;
                          });
                          if (val) {
                            game.activateMasterMode();
                          } else {
                            game.deactivateMasterMode();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Settings Section
              _SectionHeader(title: 'Settings'),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.person_rounded,
                title: 'Profile',
                color: const Color(0xFF4CAF50),
              ),
              _MenuItem(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                color: const Color(0xFFE8B93E),
              ),
              _MenuItem(
                icon: Icons.volume_up_rounded,
                title: 'Sound',
                color: const Color(0xFF4CAF50),
              ),
              _MenuItem(
                icon: Icons.palette_rounded,
                title: 'Theme',
                color: const Color(0xFF9C27B0),
              ),

              const SizedBox(height: 24),

              // Support Section
              _SectionHeader(title: 'Support'),
              const SizedBox(height: 12),
              _MenuItem(
                icon: Icons.help_rounded,
                title: 'Help Center',
                color: const Color(0xFF2196F3),
              ),
              _MenuItem(
                icon: Icons.feedback_rounded,
                title: 'Feedback',
                color: const Color(0xFF4CAF50),
              ),
              _MenuItem(
                icon: Icons.info_rounded,
                title: 'About Ludi',
                color: const Color(0xFF9E9E9E),
              ),

              const SizedBox(height: 24),

              // Sign Out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
  final String title;

  const _SectionHeader({required this.title});

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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
