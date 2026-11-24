import 'package:flutter/material.dart';

/// ── MahjongTile widget ──
class MahjongTile extends StatelessWidget {
  final String tileId;
  final double size;
  final bool highlighted;
  final bool? isCorrect;
  final bool isDragging;

  const MahjongTile({
    super.key,
    required this.tileId,
    this.size = 64,
    this.highlighted = false,
    this.isCorrect,
    this.isDragging = false,
  });

  Color get _borderColor {
    if (isCorrect == true) return const Color(0xFF2E7D32);
    if (isCorrect == false) return const Color(0xFF4CAF50);
    if (highlighted) return const Color(0xFFE8B93E);
    return const Color(0xFFE0D5C0);
  }

  double get _borderWidth {
    if (isCorrect != null || highlighted) return 2.5;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = isDragging ? size * 1.1 : size;
    final tileWidth = effectiveSize;
    final tileHeight = effectiveSize * 4 / 3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: tileWidth,
      height: tileHeight,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor, width: _borderWidth),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'assets/tiles/$tileId.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFFFF8F0),
            child: Center(
              child: Text(
                tileId,
                style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
