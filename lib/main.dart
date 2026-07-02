import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/game_state.dart';
import 'providers/match_state.dart';
import 'models/match_data.dart';
import 'services/purchases_service.dart';
import 'services/app_i18n.dart';
import 'widgets/mascot_widget.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/community_screen.dart';
import 'screens/practice_screen.dart';
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
  await PurchasesService.init();
  // Load display language preference
  final sp = await SharedPreferences.getInstance();
  final langKey = sp.getString('app_display_lang') ?? 'en';
  AppI18n.set(langKey == 'zh' ? DisplayLang.zh : DisplayLang.en);
  final gameState = GameState();
  await gameState.loadFromStorage();
  final matchState = MatchState();
  await matchState.load();
  await matchState.loadRooms();
  final i18n = AppI18n();
  runApp(MahjongApp(gameState: gameState, matchState: matchState, i18n: i18n));
}

bool firebaseAvailable = false;

class MahjongApp extends StatelessWidget {
  const MahjongApp({super.key, required this.gameState, required this.matchState, required this.i18n});

  final GameState gameState;
  final MatchState matchState;
  final AppI18n i18n;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameState),
        ChangeNotifierProvider.value(value: matchState),
        ChangeNotifierProvider.value(value: i18n),
      ],
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
    final gameState = context.read<GameState>();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        gameState.loadCloudProgress();
        PurchasesService.login(user.uid);
        PurchasesService.syncToGameState(gameState);
      } else {
        PurchasesService.logout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _LanguageGate(child: _AuthFlow());
  }
}

class _AuthFlow extends StatelessWidget {
  const _AuthFlow();

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

class _LanguageGate extends StatefulWidget {
  const _LanguageGate({required this.child});
  final Widget child;
  @override
  State<_LanguageGate> createState() => _LanguageGateState();
}

class _LanguageGateState extends State<_LanguageGate> {
  bool? _hasChosen;
  @override
  void initState() {
    super.initState();
    _checkChosen();
  }
  Future<void> _checkChosen() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _hasChosen = p.getString('app_display_lang') != null);
  }
  @override
  Widget build(BuildContext context) {
    if (_hasChosen == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }
    if (!_hasChosen!) return const _LanguageSelectScreen();
    return widget.child;
  }
}

class _LanguageSelectScreen extends StatelessWidget {
  const _LanguageSelectScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              Text('Choose your language',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D))),
              const SizedBox(height: 8),
              Text('You can change this later in Settings',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 14, color: const Color(0xFF757575))),
              const SizedBox(height: 32),
              // ── 中文 ──
              ElevatedButton(
                onPressed: () async {
                  final p = await SharedPreferences.getInstance();
                  await p.setString('app_display_lang', 'zh');
                  AppI18n.set(DisplayLang.zh);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D2D2D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                ),
                child: Text('中文',
                    style: GoogleFonts.nunito(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              // ── English ──
              ElevatedButton(
                onPressed: () async {
                  final p = await SharedPreferences.getInstance();
                  await p.setString('app_display_lang', 'en');
                  AppI18n.set(DisplayLang.en);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D2D2D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                ),
                child: Text('English',
                    style: GoogleFonts.nunito(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
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
    CommunityScreen(),
    PracticeScreen(),
    MoreScreen(),
  ];

  void switchToTab(int index) {
    if (mounted && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.read<GameState>().isPremium;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchState>().updatePremium(isPremium);
    });
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
                    _navItem(0, Icons.home_rounded, 'Home'),
                    _navItem(1, Icons.people_rounded, 'Community'),
                    _navItem(2, Icons.school_rounded, 'Practice'),
                    _navItem(3, Icons.more_horiz_rounded, 'More'),
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
