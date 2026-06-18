import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mahjong_tiles.dart';

class TileHandDisplay extends StatelessWidget {
  const TileHandDisplay({
    super.key,
    required this.tileCodes,
    this.highlightWaiting = true,
  });

  final List<String> tileCodes;
  final bool highlightWaiting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E7D32).withAlpha(60)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: tileCodes
                .map((code) => _TileChip(code: code))
                .toList(),
          ),
          if (highlightWaiting) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE8B93E),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '?',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE8B93E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Waiting for 1 tile',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TileChip extends StatelessWidget {
  const _TileChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          MahjongTile.emoji(code),
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }
}

class TileOptionButton extends StatelessWidget {
  const TileOptionButton({
    super.key,
    required this.tileCode,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.enabled = true,
  });

  final String tileCode;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE0E0E0);
    Color? bgColor = const Color(0xFFFFF8F0);

    if (isCorrect) {
      borderColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFF2E7D32).withAlpha(25);
    } else if (isWrong) {
      borderColor = const Color(0xFF4CAF50);
      bgColor = const Color(0xFF4CAF50).withAlpha(25);
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              MahjongTile.emoji(tileCode),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              MahjongTile.name(tileCode).split(' ').first,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
