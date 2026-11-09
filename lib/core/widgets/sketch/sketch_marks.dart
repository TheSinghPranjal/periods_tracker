import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/luna_tokens.dart';
import '../../utils/health_enums.dart';
import 'sakura_art.dart';
import 'sketch_geometry.dart';

/// Crescent moon holding a blossom. Original LunaCycle mark.
class LunaLogo extends StatelessWidget {
  const LunaLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      image: true,
      label: 'LunaCycle logo',
      child: CustomPaint(
        size: Size.square(size),
        painter: LogoPainter(
          moon: t.periodFill,
          ink: BlossomInk(
            fill: t.blossom,
            edge: t.blossomEdge,
            core: t.blossomCore,
          ),
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  LogoPainter({required this.moon, required this.ink});
  final Color moon;
  final BlossomInk ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final outer = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.47, s * 0.5), radius: s * 0.4),
      );
    final cut = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(s * 0.62, s * 0.43), radius: s * 0.335),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, cut),
      Paint()..color = moon,
    );
    drawBlossom(canvas, Offset(s * 0.63, s * 0.47), s * 0.25, 0.2, ink);
    drawBlossom(
      canvas,
      Offset(s * 0.34, s * 0.2),
      s * 0.09,
      1,
      ink,
      detailed: false,
    );
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.moon != moon;
}

/// A small blossom bullet, used for instruction steps and the ovulation mark.
class BlossomIcon extends StatelessWidget {
  const BlossomIcon({super.key, this.size = 18, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _BlossomIconPainter(color, t),
    );
  }
}

class _BlossomIconPainter extends CustomPainter {
  _BlossomIconPainter(this.color, this.t);
  final Color? color;
  final LunaTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    drawBlossom(
      canvas,
      size.center(Offset.zero),
      size.width / 2,
      0,
      BlossomInk(
        fill: color ?? t.blossom,
        edge: color ?? t.blossomEdge,
        core: t.blossomCore,
      ),
      detailed: false,
    );
  }

  @override
  bool shouldRepaint(_BlossomIconPainter old) =>
      old.color != color || old.t != t;
}

/// Hand-sketched expressions, so moods read through shape as well as colour.
class MoodFace extends StatelessWidget {
  const MoodFace({
    super.key,
    required this.mood,
    this.size = 48,
    this.selected = false,
  });
  final MoodKind mood;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _MoodPainter(mood, selected ? t.pastel : t.pale, t.ink),
    );
  }
}

class _MoodPainter extends CustomPainter {
  _MoodPainter(this.mood, this.fill, this.ink);
  final MoodKind mood;
  final Color fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final seed = mood.index + 2;
    final outline = sketchCircle(c, s * 0.44, seed, roughness: s * 0.012);
    canvas.drawPath(outline, Paint()..color = fill);
    final pen = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = s * 0.042;
    canvas.drawPath(outline, pen);

    final left = Offset(s * 0.36, s * 0.42);
    final right = Offset(s * 0.64, s * 0.42);
    void dots([double r = 0.04]) {
      final dot = Paint()..color = ink;
      canvas.drawCircle(left, s * r, dot);
      canvas.drawCircle(right, s * r, dot);
    }

    Path curve(double y, double depth, [double half = 0.15]) => Path()
      ..moveTo(s * (0.5 - half), s * y)
      ..quadraticBezierTo(s * 0.5, s * (y + depth), s * (0.5 + half), s * y);

    switch (mood) {
      case MoodKind.happy:
        dots();
        canvas.drawPath(curve(0.6, 0.2), pen);
      case MoodKind.calm:
        for (final eye in [left, right]) {
          canvas.drawPath(
            Path()
              ..moveTo(eye.dx - s * 0.07, eye.dy)
              ..quadraticBezierTo(
                eye.dx,
                eye.dy + s * 0.07,
                eye.dx + s * 0.07,
                eye.dy,
              ),
            pen,
          );
        }
        canvas.drawPath(curve(0.63, 0.09, 0.1), pen);
      case MoodKind.neutral:
        dots();
        canvas.drawLine(
          Offset(s * 0.38, s * 0.66),
          Offset(s * 0.62, s * 0.66),
          pen,
        );
      case MoodKind.sad:
        dots();
        canvas.drawPath(curve(0.72, -0.15), pen);
        canvas.drawCircle(
          left.translate(-s * 0.02, s * 0.12),
          s * 0.028,
          Paint()..color = ink,
        );
      case MoodKind.anxious:
        dots(0.05);
        final wave = Path()..moveTo(s * 0.32, s * 0.68);
        for (var i = 0; i < 4; i++) {
          final x = 0.32 + i * 0.09;
          wave.quadraticBezierTo(
            s * (x + 0.045),
            s * (i.isEven ? 0.6 : 0.76),
            s * (x + 0.09),
            s * 0.68,
          );
        }
        canvas.drawPath(wave, pen);
      case MoodKind.irritable:
        dots();
        canvas.drawLine(
          left.translate(-s * 0.09, -s * 0.11),
          left.translate(s * 0.08, -s * 0.04),
          pen,
        );
        canvas.drawLine(
          right.translate(s * 0.09, -s * 0.11),
          right.translate(-s * 0.08, -s * 0.04),
          pen,
        );
        canvas.drawPath(curve(0.71, -0.1, 0.12), pen);
      case MoodKind.energetic:
        dots();
        final mouth = Path()
          ..moveTo(s * 0.34, s * 0.58)
          ..quadraticBezierTo(s * 0.5, s * 0.86, s * 0.66, s * 0.58)
          ..close();
        canvas.drawPath(mouth, Paint()..color = ink);
        for (var i = 0; i < 3; i++) {
          final a = -math.pi / 2 + (i - 1) * 0.5;
          canvas.drawLine(
            c + Offset.fromDirection(a, s * 0.46),
            c + Offset.fromDirection(a, s * 0.5),
            pen,
          );
        }
      case MoodKind.tired:
        canvas.drawLine(
          left.translate(-s * 0.07, 0),
          left.translate(s * 0.07, 0),
          pen,
        );
        canvas.drawLine(
          right.translate(-s * 0.07, 0),
          right.translate(s * 0.07, 0),
          pen,
        );
        canvas.drawCircle(Offset(s * 0.5, s * 0.67), s * 0.05, pen);
    }
  }

  @override
  bool shouldRepaint(_MoodPainter old) =>
      old.mood != mood || old.fill != fill || old.ink != ink;
}

/// Droplet scale: more and larger drops mean heavier flow.
class FlowDrops extends StatelessWidget {
  const FlowDrops({super.key, required this.level, this.size = 20, this.color});

  /// 0 spotting, 1 light, 2 medium, 3 heavy, 4 very heavy.
  final int level;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? LunaTokens.of(context).periodFill;
    return CustomPaint(
      size: Size(size * 2.1, size),
      painter: _DropPainter(level, c),
    );
  }
}

class _DropPainter extends CustomPainter {
  _DropPainter(this.level, this.color);
  final int level;
  final Color color;

  void _drop(Canvas canvas, Offset center, double h) {
    final path = Path()
      ..moveTo(center.dx, center.dy - h / 2)
      ..cubicTo(
        center.dx + h * 0.5,
        center.dy + h * 0.02,
        center.dx + h * 0.36,
        center.dy + h / 2,
        center.dx,
        center.dy + h / 2,
      )
      ..cubicTo(
        center.dx - h * 0.36,
        center.dy + h / 2,
        center.dx - h * 0.5,
        center.dy + h * 0.02,
        center.dx,
        center.dy - h / 2,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final mid = size.width / 2;
    if (level == 0) {
      final dot = Paint()..color = color;
      canvas.drawCircle(Offset(mid - h * 0.35, h * 0.6), h * 0.1, dot);
      canvas.drawCircle(Offset(mid, h * 0.38), h * 0.1, dot);
      canvas.drawCircle(Offset(mid + h * 0.35, h * 0.62), h * 0.1, dot);
      return;
    }
    final drops = level.clamp(1, 3);
    final spacing = h * 0.62;
    for (var i = 0; i < drops; i++) {
      final x = mid + (i - (drops - 1) / 2) * spacing;
      _drop(canvas, Offset(x, h / 2), h * (0.6 + level * 0.12));
    }
  }

  @override
  bool shouldRepaint(_DropPainter old) =>
      old.level != level || old.color != color;
}

/// The sketched cycle ring with a blossom marking today's position.
class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 212,
    this.periodFraction,
  });

  final double? progress;
  final double? periodFraction;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 350);
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress ?? 0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => CustomPaint(
          painter: _RingPainter(
            value: value,
            showValue: progress != null,
            periodFraction: periodFraction,
            t: t,
          ),
          child: child,
        ),
        child: Center(
          child: Padding(padding: const EdgeInsets.all(30), child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.showValue,
    required this.periodFraction,
    required this.t,
  });

  final double value;
  final bool showValue;
  final double? periodFraction;
  final LunaTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: c, radius: radius);
    final track = Paint()
      ..color = t.surface.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11;
    canvas.drawCircle(c, radius, track);
    final pencil = Paint()
      ..color = t.blossomEdge.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(sketchCircle(c, radius + 7.5, 4), pencil);
    canvas.drawPath(sketchCircle(c, radius - 7.5, 8), pencil);
    if (!showValue) return;

    const top = -math.pi / 2;
    final arc = Paint()
      ..color = t.blossomEdge
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11;
    canvas.drawArc(rect, top, 2 * math.pi * value, false, arc);
    final fraction = periodFraction;
    if (fraction != null && fraction > 0) {
      canvas.drawArc(
        rect,
        top,
        2 * math.pi * math.min(value, fraction),
        false,
        arc..color = t.periodFill,
      );
    }
    final at = c + Offset.fromDirection(top + 2 * math.pi * value, radius);
    drawBlossom(
      canvas,
      at,
      15,
      value * 6,
      BlossomInk(fill: t.blossom, edge: t.periodFill, core: t.blossomCore),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.t != t || old.periodFraction != periodFraction;
}
