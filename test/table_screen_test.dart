import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/screens/table_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders a table on a narrow phone without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TableScreen(seed: 1)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Practice table'), findsOneWidget);
    expect(find.byType(TableScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a table on a desktop viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TableScreen(seed: 2)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Practice table'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
