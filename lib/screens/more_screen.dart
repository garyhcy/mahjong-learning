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
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Title
              Text(
                'Settings',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card - tap 5 times on mascot to reveal master mode
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _tapCount++;
                        if (_tapCount >= 5 && !_masterUnlocked) {
                          setState(() {
                            _masterUnlocked = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Master Mode unlocked!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const MascotWidget(
                        expression: MascotExpression.happy,
                        size: 56,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.nickname,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Level ${game.userLevel} · ${game.xp} XP',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(game),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Master Mode Section (hidden until unlocked)
              if (_masterUnlocked) ...[
                _sectionTitle('Developer'),
                const SizedBox(height: 8),
                _settingsCard([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Color(0xFFFF9800),
                              size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Master Mode',
                                  style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D2D2D))),
                              Text('Unlock all stages, infinite hearts',
                                  style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: const Color(0xFF9E9E9E))),
                            ],
                          ),
                        ),
                        Switch(
                          value: _masterMode,
                          activeColor: const Color(0xFFFF9800),
                          onChanged: (val) {
                            setState(() => _masterMode = val);
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
                ]),
                const SizedBox(height: 20),
              ],

              // Account section
              _sectionTitle('Account'),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.person_rounded, 'Edit Profile', onTap: () {
                  _showEditNameDialog(game);
                }),
                _settingsDivider(),
                _settingsRow(Icons.lock_rounded, 'Change Password',
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.email_rounded, 'Email',
                    subtitle: 'user@example.com'),
              ]),
              const SizedBox(height: 20),

              // Preferences section
              _sectionTitle('Preferences'),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsToggle(Icons.notifications_rounded, 'Notifications',
                    _notificationsEnabled, (v) {
                  setState(() => _notificationsEnabled = v);
                }),
                _settingsDivider(),
                _settingsToggle(
                    Icons.volume_up_rounded, 'Sound Effects', _soundEnabled,
                    (v) {
                  setState(() => _soundEnabled = v);
                }),
                _settingsDivider(),
                _settingsToggle(Icons.vibration_rounded, 'Haptic Feedback',
                    _hapticEnabled, (v) {
                  setState(() => _hapticEnabled = v);
                }),
                _settingsDivider(),
                _settingsRow(Icons.language_rounded, 'Language',
                    subtitle: _language, onTap: () {
                  _showLanguageDialog();
                }),
              ]),
              const SizedBox(height: 20),

              // Learning section
              _sectionTitle('Learning'),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.schedule_rounded, 'Daily Reminder',
                    subtitle: '9:00 AM', onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.restart_alt_rounded, 'Reset Progress',
                    isDestructive: true, onTap: () {
                  _showResetDialog();
                }),
              ]),
              const SizedBox(height: 20),

              // Subscription
              _sectionTitle('Subscription'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8B93E), Color(0xFFF5D060)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    Text('Upgrade to Pro',
                        style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                        'Unlimited lives, practice, matches, and exclusive avatar frames',
                        style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.white.withAlpha(210)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFE8B93E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: Text('View Plans',
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About section
              _sectionTitle('About'),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.info_rounded, 'Version',
                    subtitle: '1.0.0 (Beta)'),
                _settingsDivider(),
                _settingsRow(Icons.description_rounded, 'Terms of Service',
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.privacy_tip_rounded, 'Privacy Policy',
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.help_rounded, 'Help & Support',
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.feedback_rounded, 'Send Feedback',
                    onTap: () {}),
              ]),
              const SizedBox(height: 20),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Log Out',
                      style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF757575)));
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsRow(IconData icon, String title,
      {String? subtitle, bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (isDestructive
                        ? const Color(0xFFE53935)
                        : const Color(0xFF4CAF50))
                    .withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  size: 18,
                  color: isDestructive
                      ? const Color(0xFFE53935)
                      : const Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFE53935)
                          : const Color(0xFF2D2D2D))),
            ),
            if (subtitle != null)
              Text(subtitle,
                  style: GoogleFonts.nunito(
                      fontSize: 13, color: const Color(0xFF9E9E9E))),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFBDBDBD)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _settingsToggle(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D))),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _settingsDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFF5F5F5)),
    );
  }

  void _showEditNameDialog(GameState game) {
    final controller =
        TextEditingController(text: game.nickname.isNotEmpty ? game.nickname : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Nickname',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          decoration: InputDecoration(
            hintText: 'Enter nickname',
            hintStyle: GoogleFonts.nunito(color: const Color(0xFF9E9E9E)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                game.setNickname(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Save',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Language',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', '繁體中文', '简体中文'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang, style: GoogleFonts.nunito()),
              value: lang,
              groupValue: _language,
              activeColor: const Color(0xFF4CAF50),
              onChanged: (v) {
                setState(() => _language = v!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Progress',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to reset all your learning progress? This action cannot be undone.',
            style: GoogleFonts.nunito(color: const Color(0xFF757575))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Reset',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
