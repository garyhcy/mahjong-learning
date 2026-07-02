import 'package:flutter/material.dart';

class TileHand extends StatelessWidget {
  const TileHand({super.key, required this.tiles});

  final List<String> tiles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tiles
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBFBFB), Color(0xFFF2F2F2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                _tileLabel(t),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          )
          .toList(),
    );
  }

  String _tileLabel(String code) {
    if (code.isEmpty) return code;
    if (code.length == 2) {
      final suit = code[0];
      final num = code[1];
      if ('123456789'.contains(num)) {
        if (suit == 'm') return '$num🀇';
        if (suit == 's') return '$num🀐';
        if (suit == 'p') return '$num🀙';
      }
    }
    if (code == 'east') return 'E';
    if (code == 'south') return 'S';
    if (code == 'west') return 'W';
    if (code == 'north') return 'N';
    if (code == 'red') return '中';
    if (code == 'green') return '發';
    if (code == 'white') return '白';
    return code.toUpperCase();
  }
}
