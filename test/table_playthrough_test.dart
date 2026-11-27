import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/game/table_controller.dart';
import 'package:ludi/game/table_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a hand can be played to a finish without errors', () async {
    for (var seed = 1; seed <= 8; seed++) {
      final controller = TableController(
        seed: seed,
        aiDelay: const Duration(milliseconds: 1),
      );
      controller.startNewHand();
      var steps = 0;
      while (!controller.finished && steps < 300) {
        steps++;
        if (controller.engine.phase == TablePhase.awaitingClaim) {
          final claims = controller.humanClaims;
          final win = claims.where((c) => c.isWin).toList();
          if (win.isNotEmpty) {
            controller.claim(win.first);
          } else {
            controller.passClaim();
          }
        } else if (controller.isHumanTurn) {
          if (controller.canDeclareWin) {
            controller.declareSelfDraw();
          } else if (controller.canDiscard) {
            final tile = controller.engine.players[0].hand.first;
            controller.selectTile(tile);
            controller.discardSelected();
          }
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }
      }
      expect(controller.finished, isTrue,
          reason: 'seed $seed did not finish in $steps steps');
      if (controller.engine.winScore != null) {
        expect(controller.engine.winScore!.faan, greaterThanOrEqualTo(3));
      }
      controller.dispose();
    }
  }, timeout: const Timeout(Duration(seconds: 30)));
}
