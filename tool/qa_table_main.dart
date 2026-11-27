import 'package:flutter/material.dart';

import 'package:ludi/game/table_controller.dart';
import 'package:ludi/game/table_engine.dart';
import 'package:ludi/screens/table_screen.dart';

/// Local-only QA entry point; never used by the production app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final scenario = Uri.base.queryParameters['scenario'] ?? 'selfdraw';
  final controller = switch (scenario) {
    'kong' => _kongScenario(),
    'draw' => _drawScenario(),
    _ => _selfDrawScenario(),
  };

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TableScreen(controller: controller),
    ),
  );
}

TableController _selfDrawScenario() {
  final controller = TableController(seed: 7)..startNewHand();
  controller.engine.setHandForTesting(0, [
    'm1',
    'm2',
    'm3',
    'm4',
    'm5',
    'm6',
    'p2',
    'p3',
    'p4',
    's7',
    's8',
    's9',
    'east',
    'east',
  ]);
  return controller;
}

TableController _kongScenario() {
  final controller = TableController(seed: 8)..startNewHand();
  controller.engine.setHandForTesting(0, [
    'm1',
    'm1',
    'm1',
    'p2',
    'p3',
    'p4',
    's2',
    's3',
    's4',
    'east',
    'east',
  ]);
  controller.engine.setHandForTesting(1, ['m1']);
  controller.engine.currentPlayer = 1;
  controller.engine.discardTile(1, 'm1');
  return controller;
}

TableController _drawScenario() {
  final controller = TableController(seed: 9)..startNewHand();
  controller.engine
    ..phase = TablePhase.finished
    ..isDraw = true
    ..winnerIndex = null;
  return controller;
}
