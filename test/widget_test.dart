import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ludi/main.dart';
import 'package:ludi/providers/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    final gameState = GameState();
    await gameState.loadFromStorage();
    await tester.pumpWidget(MahjongApp(gameState: gameState));
    await tester.pump();

    expect(find.byType(MahjongApp), findsOneWidget);
  });
}
