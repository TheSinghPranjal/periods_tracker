import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/luna_tokens.dart';

@immutable
class BlossomInk {
  const BlossomInk({
    required this.fill,
    required this.edge,
    required this.core,
  });
  final Color fill;
  final Color edge;
  final Color core;
}

Path _petal(double r) {
  return Path()
    ..moveTo(0, 0)
    ..cubicTo(-0.62 * r, -0.22 * r, -0.66 * r, -0.92 * r, -0.14 * r, -r)
    ..lineTo(0, -0.84 * r)
    ..lineTo(0.14 * r, -r)
    ..cubicTo(0.66 * r, -0.92 * r, 0.62 * r, -0.22 * r, 0, 0)
    ..close();
}

/// One five-petalled cherry blossom with the notched petal tips of sakura.
void drawBlossom(
  Canvas canvas,
  Offset center,
  double radius,
  double rotation,
  BlossomInk ink, {
  bool detailed = true,
}) {
  final fill = Paint()..color = ink.fill;
  final edge = Paint()
    ..color = ink.edge
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = math.max(0.7, radius * 0.06);
  final petal = _petal(radius);

  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotation);
  for (var i = 0; i < 5; i++) {
    canvas.save();
    canvas.rotate(i * 2 * math.pi / 5);
    canvas.drawPath(petal, fill);
    canvas.drawPath(petal, edge);
    if (detailed && radius > 8) {
      // A second, slightly offset pass gives the pencil-sketch double line.
      canvas.save();
      canvas.rotate(0.05);
      canvas.scale(0.97);
      canvas.drawPath(petal, edge..color = ink.edge.withValues(alpha: 0.45));
      canvas.restore();
      edge.color = ink.edge;
    }
    canvas.restore();
  }

  canvas.drawCircle(
    Offset.zero,
    radius * 0.24,
    Paint()..color = ink.core.withValues(alpha: 0.5),
  );
  if (detailed) {
    final stamen = Paint()
      ..color = ink.core
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(0.6, radius * 0.045);
    for (var i = 0; i < 7; i++) {
      final direction = i * 2 * math.pi / 7 + 0.3;
      final tip = Offset.fromDirection(
        direction,
        radius * (i.isEven ? 0.5 : 0.42),
      );
      canvas.drawLine(Offset.zero, tip, stamen);
      canvas.drawCircle(
        tip,
        math.max(0.8, radius * 0.06),
        Paint()..color = ink.core,
      );
    }
  }
  canvas.restore();
}

void drawPetal(
  Canvas canvas,
  Offset at,
  double size,
  double angle,
  BlossomInk ink,
) {
  final path = Path()
    ..moveTo(0, -size)
    ..cubicTo(size * 0.8, -size * 0.6, size * 0.6, size * 0.5, 0, size)
    ..cubicTo(-size * 0.6, size * 0.5, -size * 0.8, -size * 0.6, 0, -size)
    ..close();
  canvas.save();
  canvas.translate(at.dx, at.dy);
  canvas.rotate(angle);
  canvas.drawPath(path, Paint()..color = ink.fill);
  canvas.drawPath(
    path,
    Paint()
      ..color = ink.edge.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8,
  );
  canvas.restore();
}

class _Limb {
  const _Limb(this.p0, this.c1, this.c2, this.p3, this.width);
  final Offset p0, c1, c2, p3;
  final double width;

  Offset at(double t) {
    final u = 1 - t;
    return p0 * (u * u * u) +
        c1 * (3 * u * u * t) +
        c2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }
}

void _drawLimb(Canvas canvas, _Limb limb, Color bark, math.Random random) {
  const steps = 26;
  final left = <Offset>[];
  final right = <Offset>[];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final p = limb.at(t);
    final direction =
        limb.at(math.min(1, t + 0.02)) - limb.at(math.max(0, t - 0.02));
    final normal =
        Offset(-direction.dy, direction.dx) /
        math.max(direction.distance, 0.001);
    final knot = 1 + (random.nextDouble() - 0.5) * 0.28;
    final half = (limb.width * (1 - t * 0.82)) / 2 * knot;
    left.add(p + normal * half);
    right.add(p - normal * half);
  }
  final body = Path()..moveTo(left.first.dx, left.first.dy);
  for (final p in left.skip(1)) {
    body.lineTo(p.dx, p.dy);
  }
  for (final p in right.reversed) {
    body.lineTo(p.dx, p.dy);
  }
  body.close();
  canvas.drawPath(body, Paint()..color = bark.withValues(alpha: 0.82));

  final hatch = Paint()
    ..color = bark
    ..strokeWidth = 0.8
    ..strokeCap = StrokeCap.round;
  for (var i = 1; i < steps; i += 2) {
    if (limb.width * (1 - i / steps * 0.82) < 3.5) continue;
    final from = left[i];
    final to = Offset.lerp(
      left[i],
      right[i + 1],
      0.55 + random.nextDouble() * 0.3,
    )!;
    canvas.drawLine(from, to, hatch);
  }
  // Loose outer pencil line.
  final outline = Paint()
    ..color = bark
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.9;
  canvas.drawPoints(
    ui.PointMode.polygon,
    left.map((p) => p.translate(-0.8, 0.7)).toList(),
    outline,
  );
}

void _blossomsAlong(
  Canvas canvas,
  _Limb limb,
  BlossomInk ink,
  math.Random random,
  double unit, {
  required int count,
  double spread = 21,
}) {
  for (var i = 0; i < count; i++) {
    final t = 0.22 + 0.78 * (i + random.nextDouble() * 0.7) / count;
    final base = limb.at(math.min(t, 1));
    final offset = Offset.fromDirection(
      random.nextDouble() * 2 * math.pi,
      unit * (spread * (0.4 + random.nextDouble() * 0.6)),
    );
    final at = base + offset;
    final roll = random.nextDouble();
    if (roll < 0.14) {
      canvas.drawCircle(at, unit * 3.4, Paint()..color = ink.edge);
      canvas.drawLine(
        at,
        base,
        Paint()
          ..color = ink.edge.withValues(alpha: 0.8)
          ..strokeWidth = 0.8,
      );
    } else {
      drawBlossom(
        canvas,
        at,
        unit * (9 + random.nextDouble() * 9),
        random.nextDouble() * math.pi,
        ink,
      );
    }
  }
}

enum BackdropStyle {
  /// A branch across the top corner, quiet enough to sit behind content.
  header,

  /// The full tree composition for splash and onboarding.
  full,
}

/// The sumi-ink cherry tree behind every screen.
class SakuraBackdrop extends StatelessWidget {
  const SakuraBackdrop({super.key, this.style = BackdropStyle.header});
  final BackdropStyle style;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BackdropPainter(style, LunaTokens.of(context)),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.style, this.tokens);
  final BackdropStyle style;
  final LunaTokens tokens;

  static final Map<(Size, BackdropStyle, Color, Color), ui.Picture> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final key = (size, style, tokens.paper, tokens.blossom);
    final picture = _cache[key] ?? _record(size);
    if (_cache.length > 8) _cache.clear();
    _cache[key] = picture;
    canvas.drawPicture(picture);
  }

  ui.Picture _record(Size size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final random = math.Random(11);
    final w = size.width;
    final h = size.height;
    final strength = style == BackdropStyle.full ? 1.0 : 0.72;
    final ink = BlossomInk(
      fill: tokens.blossom.withValues(alpha: 0.9 * strength),
      edge: tokens.blossomEdge.withValues(alpha: 0.85 * strength),
      core: tokens.blossomCore.withValues(alpha: 0.85 * strength),
    );
    final bark = tokens.branch.withValues(alpha: 0.72 * strength);
    final unit = (w / 390).clamp(0.85, 1.5);

    canvas.drawRect(Offset.zero & size, Paint()..color = tokens.paper);
    _washiFibres(canvas, size, random);

    final limbs = style == BackdropStyle.full
        ? _fullTree(w, h)
        : _headerBranch(w);
    for (final limb in limbs) {
      _drawLimb(canvas, limb, bark, random);
    }
    for (var i = 0; i < limbs.length; i++) {
      _blossomsAlong(
        canvas,
        limbs[i],
        ink,
        random,
        unit.toDouble(),
        spread: style == BackdropStyle.full ? 21 : 13,
        count: i == 0
            ? (style == BackdropStyle.full ? 14 : 7)
            : (style == BackdropStyle.full ? 11 : 6),
      );
    }

    final petals = style == BackdropStyle.full ? 26 : 10;
    for (var i = 0; i < petals; i++) {
      final at = style == BackdropStyle.full
          ? Offset(
              random.nextDouble() * w,
              h * (0.3 + random.nextDouble() * 0.7),
            )
          : Offset(
              w * (0.05 + random.nextDouble() * 0.9),
              h * (0.72 + random.nextDouble() * 0.27),
            );
      drawPetal(
        canvas,
        at,
        unit * (3.5 + random.nextDouble() * 3.5),
        random.nextDouble() * math.pi,
        ink,
      );
    }
    return recorder.endRecording();
  }

  void _washiFibres(Canvas canvas, Size size, math.Random random) {
    final fibre = Paint()
      ..color = tokens.line.withValues(alpha: 0.22)
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 90; i++) {
      final a = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final b =
          a +
          Offset.fromDirection(
            random.nextDouble() * math.pi,
            4 + random.nextDouble() * 12,
          );
      canvas.drawLine(a, b, fibre);
    }
  }

  List<_Limb> _headerBranch(double w) => [
    _Limb(
      Offset(w + 12, 2),
      Offset(w * 0.86, 30),
      Offset(w * 0.72, 8),
      Offset(w * 0.5, 22),
      8,
    ),
    _Limb(
      Offset(w * 0.9, 20),
      Offset(w * 0.96, 60),
      Offset(w * 0.89, 96),
      Offset(w * 0.95, 142),
      4,
    ),
  ];

  List<_Limb> _fullTree(double w, double h) => [
    _Limb(
      Offset(w + 18, h * 0.02),
      Offset(w * 0.78, h * 0.13),
      Offset(w * 0.56, h * 0.08),
      Offset(w * 0.2, h * 0.21),
      17,
    ),
    _Limb(
      Offset(w * 0.72, h * 0.095),
      Offset(w * 0.66, h * 0.2),
      Offset(w * 0.82, h * 0.27),
      Offset(w * 0.72, h * 0.37),
      9,
    ),
    _Limb(
      Offset(w * 0.46, h * 0.125),
      Offset(w * 0.38, h * 0.06),
      Offset(w * 0.24, h * 0.06),
      Offset(w * 0.1, h * 0.05),
      7,
    ),
    _Limb(
      Offset(w * 0.36, h * 0.16),
      Offset(w * 0.3, h * 0.26),
      Offset(w * 0.16, h * 0.28),
      Offset(w * 0.08, h * 0.36),
      6,
    ),
    _Limb(
      Offset(-14, h * 0.99),
      Offset(w * 0.16, h * 0.9),
      Offset(w * 0.24, h * 0.94),
      Offset(w * 0.46, h * 0.85),
      10,
    ),
  ];

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.style != style || old.tokens != tokens;
}
