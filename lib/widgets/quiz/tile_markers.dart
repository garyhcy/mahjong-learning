import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mahjong_tile.dart';

/// A question stem split into prose and a trailing run of tiles.
///
/// Mahjong hands are written as a run of markers at the end of the stem. Kept
/// inline they wrap with the prose and the last few tiles drift onto their own
/// line, so the UI pulls the run out and lays it down as a grouped hand.
class PromptParts {
  final String text;
  final List<String> handTiles;

  const PromptParts(this.text, this.handTiles);
}

/// Splits a trailing run of at least three `{{tile_id}}` markers off [raw].
/// Shorter runs (inline references like “waiting on {{p8}}”) stay in the prose.
PromptParts splitTrailingHand(String raw) {
  final trimmed = raw.trimRight();
  final match = RegExp(r'((?:\{\{[a-z0-9_]+\}\}\s*){3,})$').firstMatch(trimmed);
  if (match == null) return PromptParts(raw, const []);

  final tiles = RegExp(
    r'\{\{([a-z0-9_]+)\}\}',
  ).allMatches(match.group(1)!).map((m) => m.group(1)!).toList();
  return PromptParts(trimmed.substring(0, match.start).trimRight(), tiles);
}

/// Splits [text] into inline spans, turning `{{tile_id}}` markers into mahjong
/// tile images. Shared by dialogues, question stems and answer options so a
/// tile renders the same everywhere.
List<InlineSpan> parseTileMarkers(
  String text, {
  double fontSize = 15,
  double height = 1.5,
  Color color = const Color(0xFF2D2D2D),
  FontWeight? fontWeight,
  double tileSize = 32,
}) {
  final exp = RegExp(r'\{\{(.+?)\}\}');
  final spans = <InlineSpan>[];
  var lastEnd = 0;

  TextSpan textSpan(String value) => TextSpan(
    text: value,
    style: GoogleFonts.nunito(
      fontSize: fontSize,
      height: height,
      color: color,
      fontWeight: fontWeight,
    ),
  );

  for (final match in exp.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(textSpan(text.substring(lastEnd, match.start)));
    }
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: MahjongTile(tileId: match.group(1)!, size: tileSize),
      ),
    );
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(textSpan(text.substring(lastEnd)));
  }
  if (spans.isEmpty) spans.add(textSpan(''));
  return spans;
}
