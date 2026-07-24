import 'package:flutter/material.dart';
import '../../widgets/mascot_widget.dart';

// ─── Mascot/Avatar options ───
class AvatarOption {
  final String id;
  final MascotExpression expression;
  final String label;
  final Color frameColor;
  final bool isLocked;

  const AvatarOption({
    required this.id,
    required this.expression,
    required this.label,
    required this.frameColor,
    this.isLocked = false,
  });
}

const List<AvatarOption> avatarOptions = [
  AvatarOption(id: 'happy', expression: MascotExpression.happy, label: 'Happy', frameColor: Color(0xFF4CAF50)),
  AvatarOption(id: 'excited', expression: MascotExpression.excited, label: 'Excited', frameColor: Color(0xFFFF9800)),
  AvatarOption(id: 'wink', expression: MascotExpression.wink, label: 'Wink', frameColor: Color(0xFF9C27B0)),
  AvatarOption(id: 'content', expression: MascotExpression.content, label: 'Chill', frameColor: Color(0xFF2196F3)),
  AvatarOption(id: 'thinking', expression: MascotExpression.thinking, label: 'Thinking', frameColor: Color(0xFF607D8B)),
  AvatarOption(id: 'pro_gold', expression: MascotExpression.happy, label: 'Gold Frame', frameColor: Color(0xFFFFD700), isLocked: true),
  AvatarOption(id: 'pro_diamond', expression: MascotExpression.excited, label: 'Diamond Frame', frameColor: Color(0xFF7C4DFF), isLocked: true),
  AvatarOption(id: 'pro_fire', expression: MascotExpression.wink, label: 'Fire Frame', frameColor: Color(0xFFFF5722), isLocked: true),
];

