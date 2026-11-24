import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mahjong_tile.dart';

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
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: MahjongTile(tileId: match.group(1)!, size: tileSize),
    ));
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(textSpan(text.substring(lastEnd)));
  }
  if (spans.isEmpty) spans.add(textSpan(''));
  return spans;
}
