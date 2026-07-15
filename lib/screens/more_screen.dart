import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/mascot_widget.dart';
import '../services/app_i18n.dart';
import '../services/audio_service.dart';
import 'paywall_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// League calculation (same as community_screen)
String _getLeagueName(int xp) {
  if (xp >= 4000) return 'Diamond League';
  if (xp >= 2500) return 'Emerald League';
  if (xp >= 1200) return 'Gold League';
  if (xp >= 500) return 'Silver League';
  return 'Bronze League';
}

String _getLeagueEmoji(int xp) {
  if (xp >= 4000) return '👑';
  if (xp >= 2500) return '💎';
  if (xp >= 1200) return '🥇';
  if (xp >= 500) return '🥈';
  return '🥉';
}

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
  bool _bgmEnabled = true;
  MascotExpression _selectedExpression = MascotExpression.happy;

  @override
  void initState() {
    super.initState();
    _loadAudioPrefs();
  }

  Future<void> _loadAudioPrefs() async {
    final audio = AudioService();
    await audio.init();
    if (mounted) {
      setState(() {
        _soundEnabled = audio.sfxEnabled;
        _hapticEnabled = audio.hapticEnabled;
        _bgmEnabled = audio.bgmEnabled;
      });
    }
  }

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
                AppI18n.t('settings.title'),
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
                        if (!kDebugMode) return;
                        _tapCount++;
                        if (_tapCount >= 5 && !_masterUnlocked) {
                          setState(() {
                            _masterUnlocked = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppI18n.t('settings.masterModeUnlocked')),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: MascotWidget(
                        expression: _selectedExpression,
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
                            '${_getLeagueEmoji(game.xp)} ${_getLeagueName(game.xp)}',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAvatarSelector(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.palette_rounded,
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
                              Text(AppI18n.t('settings.masterMode'),
                                  style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D2D2D))),
                              Text(AppI18n.t('settings.masterModeDesc'),
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
              _sectionTitle(AppI18n.t('settings.account')),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.badge_rounded, AppI18n.t('settings.playerName'),
                    subtitle: game.nickname, onTap: () {
                  _showEditNameDialog(game);
                }),
                _settingsDivider(),
                _settingsRow(Icons.lock_rounded, AppI18n.t('settings.changePassword'),
                    onTap: _showChangePasswordDialog),
                _settingsDivider(),
                _settingsRow(Icons.email_rounded, AppI18n.t('settings.email'),
                    subtitle: FirebaseAuth.instance.currentUser?.email ?? AppI18n.t('settings.notSignedIn')),
              ]),
              const SizedBox(height: 20),

              // Preferences section
              _sectionTitle(AppI18n.t('settings.preferences')),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsToggle(Icons.notifications_rounded, AppI18n.t('settings.notifications'),
                    _notificationsEnabled, (v) {
                  setState(() => _notificationsEnabled = v);
                }),
                _settingsDivider(),
                _settingsToggle(
                    Icons.volume_up_rounded, AppI18n.t('settings.soundEffects'), _soundEnabled,
                    (v) {
                  setState(() {
                    _soundEnabled = v;
                    AudioService().setSfxEnabled(v);
                  });
                }),
                _settingsDivider(),
                _settingsToggle(
                    Icons.music_note_rounded, AppI18n.t('settings.bgm'), _bgmEnabled,
                    (v) {
                  setState(() {
                    _bgmEnabled = v;
                    AudioService().setBgmEnabled(v);
                  });
                }),
                _settingsDivider(),
                _settingsToggle(Icons.vibration_rounded, AppI18n.t('settings.hapticFeedback'),
                    _hapticEnabled, (v) {
                  setState(() {
                    _hapticEnabled = v;
                    AudioService().setHapticEnabled(v);
                  });
                }),
                _settingsDivider(),
                _settingsRow(Icons.language_rounded, AppI18n.t('settings.language'),
                    subtitle: AppI18n.current == DisplayLang.zh ? '中文' : 'English',
                    onTap: _showLanguageSheet),
              ]),
              const SizedBox(height: 20),

              // Learning section
              _sectionTitle(AppI18n.t('settings.learning')),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.schedule_rounded, AppI18n.t('settings.dailyReminder'),
                    subtitle: '9:00 AM', onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.restart_alt_rounded, AppI18n.t('settings.resetProgress'),
                    isDestructive: true, onTap: () {
                  _showResetDialog();
                }),
              ]),
              const SizedBox(height: 20),

              // Subscription
              _sectionTitle(AppI18n.t('settings.subscription')),
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
                    Text(AppI18n.t('settings.upgradeToPro'),
                        style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                        AppI18n.t('settings.upgradeDesc'),
                        style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.white.withAlpha(210)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const PaywallScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFE8B93E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: Text(AppI18n.t('settings.viewPlans'),
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About section
              _sectionTitle(AppI18n.t('settings.about')),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.info_rounded, AppI18n.t('settings.version'),
                    subtitle: '1.0.0 (Beta)'),
                _settingsDivider(),
                _settingsRow(Icons.description_rounded, AppI18n.t('settings.termsOfService'),
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.privacy_tip_rounded, AppI18n.t('settings.privacyPolicy'),
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.help_rounded, AppI18n.t('settings.helpSupport'),
                    onTap: () {}),
                _settingsDivider(),
                _settingsRow(Icons.feedback_rounded, AppI18n.t('settings.sendFeedback'),
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
                  child: Text(AppI18n.t('settings.signOut'),
                      style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),

              // Delete Account - placed at the very bottom, isolated (Apple requires it)
              _sectionTitle(AppI18n.t('settings.accountManagement')),
              const SizedBox(height: 8),
              _settingsCard([
                _settingsRow(Icons.delete_forever_rounded, AppI18n.t('settings.deleteAccount'),
                    isDestructive: true, onTap: _showDeleteAccountDialog),
              ]),
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
        title: Text(AppI18n.t('settings.editNickname'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          decoration: InputDecoration(
            hintText: AppI18n.t('settings.enterNickname'),
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
            child: Text(AppI18n.t('common.cancel'),
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
            child: Text(AppI18n.t('common.save'),
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelector() {
    final expressions = [
      {'expr': MascotExpression.happy, 'label': AppI18n.t('mascot.happy')},
      {'expr': MascotExpression.thinking, 'label': AppI18n.t('mascot.thinking')},
      {'expr': MascotExpression.excited, 'label': AppI18n.t('mascot.excited')},
      {'expr': MascotExpression.content, 'label': AppI18n.t('mascot.content')},
      {'expr': MascotExpression.sad, 'label': AppI18n.t('mascot.sad')},
      {'expr': MascotExpression.wink, 'label': AppI18n.t('mascot.wink')},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppI18n.t('settings.chooseMascot'),
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: expressions.length,
              itemBuilder: (context, index) {
                final item = expressions[index];
                final expr = item['expr'] as MascotExpression;
                final label = item['label'] as String;
                final isSelected = _selectedExpression == expr;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedExpression = expr);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CAF50).withAlpha(20)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MascotWidget(expression: expr, size: 48),
                        const SizedBox(height: 6),
                        Text(label,
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF757575))),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DisplayLang pendingLang = AppI18n.current; // 暫存選擇，確認後才套用
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(AppI18n.t('more.language'),
                      style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  // ── App language: only 中文 / English (暫存，確認後套用) ──
                  Row(
                    children: [
                      _langOption('中文', pendingLang == DisplayLang.zh, () {
                        pendingLang = DisplayLang.zh;
                        setSheetState(() {});
                      }),
                      const SizedBox(width: 12),
                      _langOption('English', pendingLang == DisplayLang.en, () {
                        pendingLang = DisplayLang.en;
                        setSheetState(() {});
                      }),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // ── Done 按鈕：套用暫存的語言選擇 ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        AppI18n.set(pendingLang);
                        final p = await SharedPreferences.getInstance();
                        await p.setString(
                            'app_display_lang',
                            pendingLang == DisplayLang.zh ? 'zh' : 'en');
                        if (!ctx.mounted) return;
                        ctx.read<AppI18n>().renotify();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                          pendingLang == DisplayLang.zh ? '完成' : 'Done',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _langOption(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4CAF50).withAlpha(20) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color(0xFF4CAF50) : const Color(0xFF757575))),
        ),
      ),
    );
  }


  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppI18n.t('settings.changePassword'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppI18n.t('settings.currentPassword'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppI18n.t('settings.newPassword'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppI18n.t('settings.confirmPassword'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppI18n.t('common.cancel'),
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppI18n.t('settings.passwordsNoMatch'))),
                );
                return;
              }
              if (newController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppI18n.t('auth.weakPassword'))),
                );
                return;
              }
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.email != null) {
                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentController.text,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newController.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppI18n.t('settings.passwordUpdated'))),
                    );
                  }
                }
              } on FirebaseAuthException catch (e) {
                String msg = AppI18n.t('settings.passwordChangeFailed');
                if (e.code == 'wrong-password') msg = AppI18n.t('settings.currentPasswordWrong');
                if (e.code == 'requires-recent-login') msg = AppI18n.t('settings.reloginRequired');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppI18n.t('settings.passwordChangeFailed'))),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppI18n.t('common.update'),
                style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    int step = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final messages = [
            AppI18n.t('delete.warning1'),
            AppI18n.t('delete.warning2'),
            AppI18n.t('delete.typeDeletePrompt'),
          ];
          if (step < 2) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(step == 0 ? AppI18n.t('delete.title') : AppI18n.t('delete.finalWarning'),
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: const Color(0xFFD32F2F))),
              content: Text(messages[step],
                  style: GoogleFonts.nunito(color: const Color(0xFF616161))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppI18n.t('common.cancel'),
                      style: GoogleFonts.nunito(color: const Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => step++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(AppI18n.t('common.continue'),
                      style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          }
          // Step 2: type DELETE
          final confirmController = TextEditingController();
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppI18n.t('delete.typeDeleteTitle'),
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: const Color(0xFFD32F2F))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(messages[2], style: GoogleFonts.nunito(color: const Color(0xFF616161))),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppI18n.t('common.cancel'),
                    style: GoogleFonts.nunito(color: const Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (confirmController.text.trim().toUpperCase() != 'DELETE') return;
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // Delete Firestore user document first, then Auth account
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                      await user.delete();
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    // Reset local state
                    final game = context.read<GameState>();
                    game.loadFromStorage(); // reload fresh state after account deletion
                  } on FirebaseAuthException catch (e) {
                    String msg = AppI18n.t('delete.failed');
                    if (e.code == 'requires-recent-login') {
                      msg = AppI18n.t('settings.reloginRequired');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppI18n.t('delete.failed'))),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(AppI18n.t('delete.confirm'),
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppI18n.t('settings.resetProgress'),
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
            AppI18n.t('settings.resetConfirm'),
            style: GoogleFonts.nunito(color: const Color(0xFF757575))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppI18n.t('common.cancel'),
                style: GoogleFonts.nunito(color: const Color(0xFF757575))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final game = context.read<GameState>();
              game.resetProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppI18n.t('common.reset'),
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
