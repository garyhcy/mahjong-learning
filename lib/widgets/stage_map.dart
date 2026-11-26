import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mahjong_data.dart';
import 'mascot_widget.dart';

/// The learning path, drawn as tiles laid along a winding table trail.
///
/// Each stage is a face-up mahjong tile: ivory when available, stage-coloured
/// when it is the one to play, gold when cleared, face-down when still locked.
/// The route between tiles is a pale felt ribbon, solid once travelled and
/// dashed while it waits.
class StageMap extends StatefulWidget {
  final List<LearningStage> stages;
  final int currentIndex;
  final void Function(LearningStage stage) onStageTap;
  final void Function(LearningStage stage) onLockedTap;
  final int numberOffset;

  const StageMap({
    super.key,
    required this.stages,
    required this.currentIndex,
    required this.onStageTap,
    required this.onLockedTap,
    this.numberOffset = 0,
  });

  @override
  State<StageMap> createState() => _StageMapState();
}

class _StageMapState extends State<StageMap>
    with SingleTickerProviderStateMixin {
  static const double _pitch = 150;
  static const double _tileW = 68;
  static const double _tileH = 94;
  static const double _topPad = 12;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _intro.value = 1;
      } else {
        _intro.forward();
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  double _offsetFor(int i, double width) {
    const pattern = [0.0, 0.45, 0.7, 0.45, 0.0, -0.45, -0.7, -0.45];
    final scale = math.min(width * 0.16, 96.0);
    return pattern[i % pattern.length] * scale;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stages.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 620.0);
        final height = widget.stages.length * _pitch + 56;
        final centers = <Offset>[
          for (var i = 0; i < widget.stages.length; i++)
            Offset(
              width / 2 + _offsetFor(i, width),
              i * _pitch + _topPad + _tileH / 2,
            ),
        ];

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrailPainter(
                      stages: widget.stages,
                      centers: centers,
                    ),
                  ),
                ),
                for (var i = 0; i < widget.stages.length; i++)
                  _node(i, width, centers[i]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _node(int i, double width, Offset center) {
    final stage = widget.stages[i];
    final n = widget.stages.length;
    final start = (i / (n + 3)).clamp(0.0, 0.85);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    final completed = stage.progress >= 1.0;
    final locked = !stage.isUnlocked;
    final current = i == widget.currentIndex;

    final labelWidth = math.min(210.0, width - 16);
    final labelLeft = (center.dx - labelWidth / 2).clamp(
      8.0,
      width - labelWidth - 8,
    );

    return Positioned(
      left: 0,
      right: 0,
      top: i * _pitch,
      child: AnimatedBuilder(
        animation: curve,
        builder: (context, child) => Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - curve.value)),
            child: child,
          ),
        ),
        child: SizedBox(
          height: _pitch,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: center.dx - _tileW / 2,
                top: _topPad,
                child: _StageTile(
                  stage: stage,
                  number: i + 1 + widget.numberOffset,
                  completed: completed,
                  locked: locked,
                  current: current,
                  onTap: () => locked
                      ? widget.onLockedTap(stage)
                      : widget.onStageTap(stage),
                ),
              ),
              if (current)
                Positioned(
                  left: center.dx + 38,
                  top: _topPad - 12,
                  child: const IgnorePointer(
                    child: MascotWidget(
                      expression: MascotExpression.wink,
                      size: 46,
                    ),
                  ),
                ),
              Positioned(
                left: labelLeft,
                top: _topPad + _tileH + 8,
                width: labelWidth,
                child: _StageLabel(
                  stage: stage,
                  completed: completed,
                  locked: locked,
                  current: current,
                  showUnlockHint: i == widget.currentIndex + 1,
                  previousTitle: i > 0
                      ? widget.stages[i - 1].localizedTitle
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageTile extends StatefulWidget {
  final LearningStage stage;
  final int number;
  final bool completed;
  final bool locked;
  final bool current;
  final VoidCallback onTap;

  const _StageTile({
    required this.stage,
    required this.number,
    required this.completed,
    required this.locked,
    required this.current,
    required this.onTap,
  });

  @override
  State<_StageTile> createState() => _StageTileState();
}

class _StageTileState extends State<_StageTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final face = widget.completed
        ? const Color(0xFFFFF6DC)
        : widget.current
        ? stage.color
        : widget.locked
        ? const Color(0xFFECE7DA)
        : const Color(0xFFFFFDF7);
    final border = widget.completed
        ? const Color(0xFFE0A526)
        : widget.locked
        ? const Color(0xFFD3CCBB)
        : stage.color;
    final fg = widget.current
        ? Colors.white
        : widget.locked
        ? const Color(0xFFA79F8E)
        : stage.color;

    return Semantics(
      button: true,
      enabled: !widget.locked,
      label: '${widget.number}. ${stage.localizedTitle}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: SizedBox(
            width: StageMapGeometry.tileW,
            height: StageMapGeometry.tileH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: StageMapGeometry.tileW,
                  height: StageMapGeometry.tileH,
                  decoration: BoxDecoration(
                    color: face,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: border, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: widget.locked
                            ? Colors.black.withAlpha(10)
                            : stage.color.withAlpha(widget.current ? 90 : 45),
                        blurRadius: widget.current ? 18 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      children: [
                        if (widget.locked)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _FaceDownPainter(
                                color: const Color(0xFFD8D0BE),
                              ),
                            ),
                          ),
                        Center(
                          child: widget.completed
                              ? Image.asset(
                                  'assets/images/crown.png',
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.contain,
                                )
                              : Icon(
                                  widget.locked
                                      ? Icons.lock_rounded
                                      : stage.icon,
                                  size: widget.locked ? 24 : 30,
                                  color: fg,
                                ),
                        ),
                        if (widget.current)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 9,
                            child: _TileProgress(progress: stage.progress),
                          ),
                        if (widget.completed)
                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: const Color(0xFFE0A526).withAlpha(230),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: -7,
                  top: -7,
                  child: Container(
                    width: 23,
                    height: 23,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.completed
                          ? const Color(0xFFE0A526)
                          : widget.locked
                          ? const Color(0xFFB5AD9B)
                          : stage.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFFBF0),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${widget.number}',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileProgress extends StatelessWidget {
  final double progress;

  const _TileProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: Colors.white.withAlpha(70),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

class _StageLabel extends StatelessWidget {
  final LearningStage stage;
  final bool completed;
  final bool locked;
  final bool current;
  final bool showUnlockHint;
  final String? previousTitle;

  const _StageLabel({
    required this.stage,
    required this.completed,
    required this.locked,
    required this.current,
    required this.showUnlockHint,
    required this.previousTitle,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = locked
        ? const Color(0xFFA79F8E)
        : const Color(0xFF25322B);
    final String status;
    if (completed) {
      status = 'Cleared';
    } else if (locked) {
      status = showUnlockHint && previousTitle != null
          ? 'Clear $previousTitle first'
          : 'Locked';
    } else {
      status = '${stage.completedLessons} / ${stage.lessonCount} lessons';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stage.localizedTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: 14,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (completed) ...[
              const Icon(
                Icons.workspace_premium_rounded,
                size: 13,
                color: Color(0xFFE0A526),
              ),
              const SizedBox(width: 3),
            ],
            if (current) ...[
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: stage.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Flexible(
              child: Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: locked
                      ? const Color(0xFFB3AB99)
                      : completed
                      ? const Color(0xFFB07E12)
                      : current
                      ? stage.color
                      : const Color(0xFF7C8578),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Trail ribbon behind the tiles: a wide pale band, then a solid or dashed line.
class _TrailPainter extends CustomPainter {
  final List<LearningStage> stages;
  final List<Offset> centers;

  _TrailPainter({required this.stages, required this.centers});

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    for (var i = 0; i < centers.length - 1; i++) {
      final a = centers[i];
      final b = centers[i + 1];
      final midY = (a.dy + b.dy) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy + StageMapGeometry.tileH / 2 - 4)
        ..cubicTo(
          a.dx,
          midY,
          b.dx,
          midY,
          b.dx,
          b.dy - StageMapGeometry.tileH / 2 + 4,
        );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFEFE5CF),
      );

      final cleared = stages[i].progress >= 1.0;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = cleared ? const Color(0xFF6FA36B) : const Color(0xFFC9C2AE);

      if (cleared) {
        canvas.drawPath(path, paint);
      } else {
        for (final metric in path.computeMetrics()) {
          var distance = 0.0;
          while (distance < metric.length) {
            final next = math.min(distance + 9, metric.length);
            canvas.drawPath(metric.extractPath(distance, next), paint);
            distance += 16;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.centers != centers || oldDelegate.stages != stages;
}

class _FaceDownPainter extends CustomPainter {
  final Color color;

  _FaceDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = -2; i < 8; i++) {
      final x = i * 14.0;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FaceDownPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Shared geometry so the canvas and the widgets agree on tile size.
class StageMapGeometry {
  static const double tileW = 68;
  static const double tileH = 94;
}
