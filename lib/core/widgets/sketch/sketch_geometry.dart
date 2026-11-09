import 'dart:math' as math;
import 'dart:ui';

/// Hand-drawn geometry. All jitter comes from a seed, so a given shape looks
/// the same on every frame instead of shimmering.
List<Offset> sampleRoundedRect(Rect rect, double radius, double step) {
  final r = math.min(radius, rect.shortestSide / 2);
  final points = <Offset>[];
  void edge(Offset a, Offset b) {
    final length = (b - a).distance;
    final count = math.max(1, (length / step).floor());
    for (var i = 0; i < count; i++) {
      points.add(Offset.lerp(a, b, i / count)!);
    }
  }

  void corner(Offset center, double from) {
    const count = 4;
    for (var i = 0; i < count; i++) {
      final angle = from + (math.pi / 2) * (i / count);
      points.add(center + Offset(math.cos(angle), math.sin(angle)) * r);
    }
  }

  edge(Offset(rect.left + r, rect.top), Offset(rect.right - r, rect.top));
  corner(Offset(rect.right - r, rect.top + r), -math.pi / 2);
  edge(Offset(rect.right, rect.top + r), Offset(rect.right, rect.bottom - r));
  corner(Offset(rect.right - r, rect.bottom - r), 0);
  edge(Offset(rect.right - r, rect.bottom), Offset(rect.left + r, rect.bottom));
  corner(Offset(rect.left + r, rect.bottom - r), math.pi / 2);
  edge(Offset(rect.left, rect.bottom - r), Offset(rect.left, rect.top + r));
  corner(Offset(rect.left + r, rect.top + r), math.pi);
  return points;
}

/// Closed Catmull-Rom curve through the points.
Path smoothClosedPath(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  final n = pts.length;
  for (var i = 0; i < n; i++) {
    final p0 = pts[(i - 1 + n) % n];
    final p1 = pts[i];
    final p2 = pts[(i + 1) % n];
    final p3 = pts[(i + 2) % n];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

Path sketchRoundedRect(
  Rect rect,
  double radius,
  int seed, {
  double roughness = 1.1,
}) {
  final random = math.Random(seed);
  final points = sampleRoundedRect(rect, radius, 34)
      .map(
        (p) => p.translate(
          (random.nextDouble() - 0.5) * roughness * 2,
          (random.nextDouble() - 0.5) * roughness * 2,
        ),
      )
      .toList();
  return smoothClosedPath(points);
}

Path sketchLine(Offset a, Offset b, int seed, {double roughness = 1.2}) {
  final random = math.Random(seed);
  final length = (b - a).distance;
  final segments = math.max(2, (length / 40).ceil());
  final path = Path()..moveTo(a.dx, a.dy);
  var previous = a;
  for (var i = 1; i <= segments; i++) {
    final target = Offset.lerp(a, b, i / segments)!;
    final jitter = i == segments
        ? Offset.zero
        : Offset(
            (random.nextDouble() - 0.5) * roughness * 2,
            (random.nextDouble() - 0.5) * roughness * 2,
          );
    final end = target + jitter;
    final mid = Offset.lerp(previous, end, 0.5)!;
    path.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    previous = end;
  }
  return path;
}

Path sketchCircle(
  Offset center,
  double radius,
  int seed, {
  double roughness = 1,
}) {
  final random = math.Random(seed);
  const count = 14;
  final pts = [
    for (var i = 0; i < count; i++)
      center +
          Offset.fromDirection(
            2 * math.pi * i / count,
            radius + (random.nextDouble() - 0.5) * roughness * 2,
          ),
  ];
  return smoothClosedPath(pts);
}

/// Cuts a path into dashes, giving predicted days a pencilled look.
Path dashed(Path source, {double dash = 5, double gap = 4}) {
  final result = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      result.addPath(
        metric.extractPath(distance, math.min(distance + dash, metric.length)),
        Offset.zero,
      );
      distance += dash + gap;
    }
  }
  return result;
}
