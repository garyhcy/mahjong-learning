
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/game_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/more_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
  } catch (_) {
    // Firebase optional in local/dev until config is added.
  }
  final gameState = GameState();
  await gameState.loadFromStorage();
  runApp(MahjongApp(gameState: gameState));
}

bool firebaseAvailable = false;

class MahjongApp extends StatelessWidget {
  const MahjongApp({super.key, required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameState,
      child: MaterialApp(
        title: 'Ludi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            primary: const Color(0xFF4CAF50),
            secondary: const Color(0xFFE8B93E),
            surface: const Color(0xFFFFF8F0),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF8F0),
          textTheme: GoogleFonts.nunitoTextTheme().apply(
            bodyColor: const Color(0xFF2D2D2D),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: Color(0xFF2D2D2D),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    if (!firebaseAvailable) return;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        context.read<GameState>().loadCloudProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!firebaseAvailable) return const MainShell();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8F0),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        return const AuthScreen();
      },
    );
  }
}

class MainShell extends StatefulWidget {
  static final mainShellKey = GlobalKey<_MainShellState>();

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    ShopScreen(),
    AchievementsScreen(),
    SettingsScreen(),
    MoreScreen(),
  ];

  void switchToTab(int index) {
    if (mounted && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(0, Icons.home_rounded, '首頁'),
                    _navItem(1, Icons.people_rounded, '社區'),
                    _navItem(2, Icons.school_rounded, '練習'),
                    _navItem(3, Icons.emoji_events_rounded, '成就'),
                    _navItem(4, Icons.more_horiz_rounded, '更多'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: active ? -2.0 : 0.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: active
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFBDBDBD),
                  size: 24),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFBDBDBD),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('設置',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('帳號設定', [
            _buildTile(Icons.person_rounded, '個人資料', '修改頭像與暱稱'),
            _buildTile(Icons.lock_rounded, '隱私設定', '管理個人資料可見性'),
          ]),
          const SizedBox(height: 16),
          _buildSection('學習設定', [
            _buildTile(Icons.volume_up_rounded, '音效', '開啟/關閉音效與背景音樂'),
            _buildTile(Icons.notifications_rounded, '通知', '設定學習提醒時間'),
            _buildTile(Icons.language_rounded, '語言', '繁體中文'),
          ]),
          const SizedBox(height: 16),
          _buildSection('其他', [
            _buildTile(Icons.info_rounded, '關於', '版本 1.0.0'),
            _buildTile(Icons.help_rounded, '幫助中心', '常見問題與使用說明'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF757575),
              )),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Colors.grey),
      onTap: () {},
    );
  }
}
