import 'dart:math';
import 'package:flutter/material.dart';

enum MascotExpression { idle, happy, surprised, thinking, proud, sad }

enum MascotSize { small, medium, large }

extension MascotSizeValue on MascotSize {
  double get value {
    switch (this) {
      case MascotSize.small:
        return 60;
      case MascotSize.medium:
        return 100;
      case MascotSize.large:
        return 150;
    }
  }
}

class MascotWidget extends StatefulWidget {
  final MascotExpression expression;
  final double size;

  const MascotWidget({
    super.key,
    this.expression = MascotExpression.idle,
    this.size = 100.0,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        final scale = 1.0 + (_breathController.value * 0.02);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          'assets/images/mascot_new.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return CustomPaint(
              painter: _MascotPainter(expression: widget.expression),
            );
          },
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotExpression expression;

  _MascotPainter({required this.expression});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = min(w, h) * 0.42;

    final bodyPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    final outlinePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(cx, cy), r, outlinePaint);

    final earR = r * 0.38;
    final earPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - r * 0.65, cy - r * 0.8), earR, earPaint);
    canvas.drawCircle(Offset(cx + r * 0.65, cy - r * 0.8), earR, earPaint);

    final patchW = r * 0.5;
    final patchH = r * 0.32;
    final patchPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - r * 0.32, cy - r * 0.12),
            width: patchW,
            height: patchH),
        patchPaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + r * 0.32, cy - r * 0.12),
            width: patchW,
            height: patchH),
        patchPaint);

    final eyeWhitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF111111);
    final eyeR = r * 0.12;

    switch (expression) {
      case MascotExpression.idle:
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.12), eyeR, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.12), eyeR, eyeWhitePaint);
        _drawBlinkEyes(canvas, cx, cy, r, 0.65);
        break;

      case MascotExpression.happy:
        _drawArchedEyes(canvas, cx, cy, r);
        break;

      case MascotExpression.surprised:
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.12), eyeR * 1.5, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.12), eyeR * 1.5, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.12), eyeR * 0.6, pupilPaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.12), eyeR * 0.6, pupilPaint);
        final mouthPaint = Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.fill;
        final mouthPath = Path()
          ..addOval(Rect.fromCenter(
              center: Offset(cx, cy + r * 0.38),
              width: r * 0.3,
              height: r * 0.22));
        canvas.drawPath(mouthPath, mouthPaint);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + r * 0.44),
                width: r * 0.18,
                height: r * 0.1),
            Paint()..color = const Color(0xFFFF6B6B));
        return;

      case MascotExpression.thinking:
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.1), eyeR, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.1), eyeR, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx - r * 0.28, cy - r * 0.1), eyeR * 0.55, pupilPaint);
        canvas.drawCircle(
            Offset(cx + r * 0.28, cy - r * 0.1), eyeR * 0.55, pupilPaint);
        final handPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(cx + r * 0.7, cy + r * 0.45), r * 0.2, handPaint);
        canvas.drawCircle(
            Offset(cx + r * 0.7, cy + r * 0.45), r * 0.2, outlinePaint);
        final thinkMouthPath = Path()
          ..moveTo(cx - r * 0.08, cy + r * 0.28)
          ..quadraticBezierTo(
              cx + r * 0.05, cy + r * 0.35, cx + r * 0.12, cy + r * 0.28);
        canvas.drawPath(
            thinkMouthPath,
            Paint()
              ..color = const Color(0xFF333333)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
        return;

      case MascotExpression.proud:
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.12), eyeR, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.12), eyeR, eyeWhitePaint);
        _drawStar(canvas, Offset(cx - r * 0.32, cy - r * 0.12), eyeR * 0.7);
        _drawStar(canvas, Offset(cx + r * 0.32, cy - r * 0.12), eyeR * 0.7);
        break;

      case MascotExpression.sad:
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.08), eyeR * 0.8, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.08), eyeR * 0.8, eyeWhitePaint);
        canvas.drawCircle(
            Offset(cx - r * 0.32, cy - r * 0.05), eyeR * 0.4, pupilPaint);
        canvas.drawCircle(
            Offset(cx + r * 0.32, cy - r * 0.05), eyeR * 0.4, pupilPaint);
        final sadMouthPath = Path()
          ..moveTo(cx - r * 0.15, cy + r * 0.35)
          ..quadraticBezierTo(cx, cy + r * 0.2, cx + r * 0.15, cy + r * 0.35);
        canvas.drawPath(
            sadMouthPath,
            Paint()
              ..color = const Color(0xFF333333)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8);
        return;
    }

    if (expression != MascotExpression.surprised &&
        expression != MascotExpression.thinking &&
        expression != MascotExpression.sad) {
      final nosePaint = Paint()..color = const Color(0xFF333333);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, cy + r * 0.08),
              width: r * 0.14,
              height: r * 0.08),
          nosePaint);

      final mouthPath = Path()
        ..moveTo(cx - r * 0.1, cy + r * 0.25)
        ..quadraticBezierTo(cx, cy + r * 0.35, cx + r * 0.1, cy + r * 0.25);
      canvas.drawPath(
          mouthPath,
          Paint()
            ..color = const Color(0xFF333333)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  void _drawBlinkEyes(
      Canvas canvas, double cx, double cy, double r, double blinkAmount) {
    final pupilPaint = Paint()..color = const Color(0xFF111111);
    final pupilR = r * 0.06;
    final leftEyePath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(cx - r * 0.32, cy - r * 0.12),
          width: pupilR * 2,
          height: pupilR * 0.5 * blinkAmount));
    canvas.drawPath(leftEyePath, pupilPaint);

    final rightEyePath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(cx + r * 0.32, cy - r * 0.12),
          width: pupilR * 2,
          height: pupilR * 0.5 * blinkAmount));
    canvas.drawPath(rightEyePath, pupilPaint);
  }

  void _drawArchedEyes(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final leftPath = Path()
      ..moveTo(cx - r * 0.42, cy - r * 0.08)
      ..quadraticBezierTo(
          cx - r * 0.32, cy - r * 0.22, cx - r * 0.22, cy - r * 0.08);
    canvas.drawPath(leftPath, paint);
    final rightPath = Path()
      ..moveTo(cx + r * 0.22, cy - r * 0.08)
      ..quadraticBezierTo(
          cx + r * 0.32, cy - r * 0.22, cx + r * 0.42, cy - r * 0.08);
    canvas.drawPath(rightPath, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFFE8B93E)
      ..style = PaintingStyle.fill;
    final path = Path();
    final outerR = size;
    final innerR = size * 0.4;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * pi / 180;
      final nextAngle = ((i * 72 + 36) - 90) * pi / 180;
      if (i == 0) {
        path.moveTo(
          center.dx + outerR * cos(angle),
          center.dy + outerR * sin(angle),
        );
      } else {
        path.lineTo(
          center.dx + outerR * cos(angle),
          center.dy + outerR * sin(angle),
        );
      }
      path.lineTo(
        center.dx + innerR * cos(nextAngle),
        center.dy + innerR * sin(nextAngle),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) {
    return oldDelegate.expression != expression;
  }
}
