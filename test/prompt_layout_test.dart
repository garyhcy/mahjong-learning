import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/widgets/quiz/tile_markers.dart';

void main() {
  group('splitTrailingHand', () {
    test('pulls a trailing hand off the stem', () {
      final parts = splitTrailingHand(
        'This hand is waiting on {{p8}}. Pick the winner. '
        '{{m2}}{{m3}}{{m4}}{{m5}}{{m6}}{{p5}}{{p6}}{{p7}}'
        '{{s3}}{{s4}}{{s5}}{{east}}{{east}}',
      );

      expect(parts.handTiles.length, 13);
      expect(parts.handTiles.first, 'm2');
      expect(parts.handTiles.last, 'east');
      expect(parts.text, 'This hand is waiting on {{p8}}. Pick the winner.');
      expect(parts.text.contains('{{m2}}'), isFalse);
    });

    test('keeps a short run of inline references in the prose', () {
      const stem = 'You hold {{p8}}{{p9}} and wait on one tile.';
      final parts = splitTrailingHand(stem);

      expect(parts.handTiles, isEmpty);
      expect(parts.text, stem);
    });

    test('leaves a stem without markers untouched', () {
      const stem = 'Which of these is a terminal?';
      final parts = splitTrailingHand(stem);

      expect(parts.handTiles, isEmpty);
      expect(parts.text, stem);
    });
  });
}
