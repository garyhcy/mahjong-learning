import 'package:flutter/material.dart';

class MascotWidget extends StatelessWidget {
  final String mascot;
  final double size;
  final VoidCallback? onTap;

  const MascotWidget({
    super.key,
    this.mascot = 'happy',
    this.size = 200,
    this.onTap,
  });

  static const Map<String, String> _assetMap = {
    'happy': 'assets/images/mascot.png',
    'surprised': 'assets/images/mascot_surprised.png',
    'proud': 'assets/images/mascot_proud.png',
    'thinking': 'assets/images/mascot_thinking.png',
    'sad': 'assets/images/mascot_sad.png',
  };

  String get _assetPath => _assetMap[mascot] ?? _assetMap['happy']!;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E0),
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: Icon(Icons.pets, size: size * 0.4, color: Colors.grey[400]),
        );
      },
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: image,
      );
    }
    return image;
  }
}
