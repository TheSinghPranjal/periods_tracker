import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/theme/luna_tokens.dart';
import '../../../core/widgets/sketch/sakura_art.dart'
    show BlossomInk, drawBlossom, drawLeaf;

enum GoalArtKind {
  calendar,
  moods,
  feet,
  dropCalendar,
  regular,
  sometimesIrregular,
  veryIrregular,
  unsure,
}

/// Original illustrations for the onboarding goal cards. They are decorative:
/// each card's text already says what it means.
class GoalArt extends StatelessWidget {
  const GoalArt({super.key, required this.kind, this.width = 104});
  final GoalArtKind kind;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, width * 0.8),
        painter: _GoalPainter(kind, LunaTokens.of(context).pastel),
      ),
    );
  }
}

const _rose = Color(0xFFE2577F);
const _roseDeep = Color(0xFFC93A68);
const _rosePale = Color(0xFFF9D3DF);
const _coral = Color(0xFFF2708A);
const _ink = Color(0xFF6B2A45);

Paint _fill(Color c) => Paint()..color = c;

Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..strokeWidth = w;

Paint _shade(Rect r, Color a, Color b) => Paint()
  ..shader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [a, b],
  ).createShader(r);

class _GoalPainter extends CustomPainter {
  _GoalPainter(this.kind, this.blob);
  final GoalArtKind kind;
  final Color blob;

  @override
  void paint(Canvas canvas, Size size) {
    // Everything is drawn on a 100 x 80 grid.
    canvas.save();
    canvas.scale(size.width / 100);
    final isRegularity = kind.index >= GoalArtKind.regular.index;
    if (isRegularity) {
      _regularityBase(canvas);
    } else {
      _blob(canvas);
    }
    switch (kind) {
      case GoalArtKind.calendar:
        _sprig(canvas, const Offset(13, 72), -1.25);
        _sparks(canvas, const Offset(17, 18));
        _calendar(canvas, const Rect.fromLTWH(26, 9, 60, 60), 0.09, _Mark.drop);
        _heart(canvas, const Offset(82, 7), 4, _coral);
      case GoalArtKind.moods:
        _sparks(canvas, const Offset(11, 24));
        _moods(canvas);
        _heart(canvas, const Offset(89, 13), 4.5, _coral);
      case GoalArtKind.feet:
        _sprig(canvas, const Offset(13, 76), -0.95);
        _sparks(canvas, const Offset(16, 18));
        _foot(
          canvas,
          const Offset(77, 51),
          0.68,
          const Color(0xFFFDEAF0),
          null,
        );
        _foot(canvas, const Offset(47, 44), 1, _rose, Colors.white);
        _heart(canvas, const Offset(88, 10), 4.5, _coral);
      case GoalArtKind.dropCalendar:
        _sparks(canvas, const Offset(15, 16));
        _calendar(
          canvas,
          const Rect.fromLTWH(45, 8, 46, 56),
          0.08,
          _Mark.check,
        );
        _drop(canvas, const Offset(38, 50), 26);
      case GoalArtKind.regular:
        canvas.drawCircle(_centre, 13, _fill(_rose));
        canvas.drawPath(
          Path()
            ..moveTo(_centre.dx - 6, _centre.dy)
            ..lineTo(_centre.dx - 1.5, _centre.dy + 4.5)
            ..lineTo(_centre.dx + 7, _centre.dy - 5),
          _stroke(Colors.white, 2.6),
        );
      case GoalArtKind.sometimesIrregular:
        final pen = _stroke(_roseDeep, 2.2);
        canvas.drawCircle(_centre.translate(-20, 0), 4, _fill(_rose));
        canvas.drawCircle(_centre.translate(20, 0), 4, _fill(_rose));
        canvas.drawLine(
          _centre.translate(-12, 0),
          _centre.translate(12, 0),
          pen,
        );
        for (final dir in const [-1.0, 1.0]) {
          final tip = _centre.translate(dir * 12, 0);
          canvas.drawLine(tip, tip.translate(-dir * 5, -4), pen);
          canvas.drawLine(tip, tip.translate(-dir * 5, 4), pen);
        }
      case GoalArtKind.veryIrregular:
        final wave = Path()..moveTo(_centre.dx - 22, _centre.dy + 2);
        for (var i = 0; i < 4; i++) {
          final x = _centre.dx - 22 + i * 11;
          wave.quadraticBezierTo(
            x + 5.5,
            _centre.dy + (i.isEven ? -12 : 14),
            x + 11,
            _centre.dy + 1,
          );
        }
        canvas.drawPath(wave, _stroke(_rose, 2.4));
      case GoalArtKind.unsure:
        final mark = TextPainter(
          text: const TextSpan(
            text: '?',
            style: TextStyle(
              fontFamily: kBodyFont,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: _roseDeep,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        mark.paint(canvas, _centre - Offset(mark.width / 2, mark.height / 2));
    }
    canvas.restore();
  }

  static const _centre = Offset(52, 48);

  void _regularityBase(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 73), width: 86, height: 9),
      _fill(blob.withValues(alpha: 0.5)),
    );
    const left = Color(0xFF9DB577);
    const right = Color(0xFF8FA968);
    drawLeaf(canvas, const Offset(24, 70), 21, -2.75, left);
    drawLeaf(canvas, const Offset(24, 70), 22, -2.2, right);
    drawLeaf(canvas, const Offset(80, 70), 21, -0.4, left);
    drawLeaf(canvas, const Offset(80, 70), 22, -0.95, right);
    _sparks(canvas, const Offset(22, 22));
    _calendar(canvas, const Rect.fromLTWH(23, 12, 60, 60), 0.05, _Mark.none);
  }

  void _blob(Canvas canvas) {
    final path = Path()
      ..moveTo(16, 58)
      ..cubicTo(4, 40, 22, 18, 44, 14)
      ..cubicTo(66, 8, 96, 16, 98, 44)
      ..cubicTo(100, 68, 76, 78, 52, 77)
      ..cubicTo(36, 77, 24, 72, 16, 58)
      ..close();
    canvas.drawPath(path, _fill(blob.withValues(alpha: 0.45)));
  }

  void _sparks(Canvas canvas, Offset at) {
    final pen = _stroke(_coral, 1.8);
    for (final a in const [-2.6, -2.05, -1.5]) {
      canvas.drawLine(
        at + Offset.fromDirection(a, 3.5),
        at + Offset.fromDirection(a, 9),
        pen,
      );
    }
  }

  void _sprig(Canvas canvas, Offset base, double angle) {
    final tip = base + Offset.fromDirection(angle, 36);
    canvas.drawLine(base, tip, _stroke(const Color(0xFF7D8F58), 1.3));
    for (var i = 1; i <= 3; i++) {
      final at = Offset.lerp(base, tip, i / 3.4)!;
      drawLeaf(canvas, at, 9.5, angle - 0.75, const Color(0xFF8FA968));
      drawLeaf(canvas, at, 9.5, angle + 0.75, const Color(0xFF9DB577));
    }
    drawLeaf(canvas, tip, 9, angle, const Color(0xFF8FA968));
  }

  void _heart(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawPath(_heartPath(c, r), _fill(color));
  }

  Path _heartPath(Offset c, double r) => Path()
    ..moveTo(c.dx, c.dy + r)
    ..cubicTo(
      c.dx - r * 2,
      c.dy - r * 0.3,
      c.dx - r * 0.9,
      c.dy - r * 1.5,
      c.dx,
      c.dy - r * 0.4,
    )
    ..cubicTo(
      c.dx + r * 0.9,
      c.dy - r * 1.5,
      c.dx + r * 2,
      c.dy - r * 0.3,
      c.dx,
      c.dy + r,
    )
    ..close();

  void _calendar(Canvas canvas, Rect r, double tilt, _Mark mark) {
    canvas.save();
    canvas.translate(r.center.dx, r.center.dy);
    canvas.rotate(tilt);
    final box = Rect.fromCenter(
      center: Offset.zero,
      width: r.width,
      height: r.height,
    );
    final body = RRect.fromRectAndRadius(box, const Radius.circular(6));
    canvas.drawRRect(body, _fill(Colors.white));
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTWH(box.left, box.top, box.width, box.height * 0.2),
      _shade(box, _coral, _rose),
    );
    canvas.restore();
    canvas.drawRRect(body, _stroke(_roseDeep, 1.5));

    final rows = 4;
    final cols = mark == _Mark.drop ? 5 : 4;
    final gridLeft = box.left + 5;
    final gridTop = box.top + box.height * 0.27;
    final cellW = (box.width - 10) / cols;
    final cellH = (box.height * 0.73 - 5) / rows;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final cell = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            gridLeft + x * cellW + 1,
            gridTop + y * cellH + 1,
            cellW - 2,
            cellH - 2,
          ),
          const Radius.circular(1.5),
        );
        final highlighted = mark == _Mark.drop && y == 1 && x == 2;
        canvas.drawRRect(cell, _fill(highlighted ? _rose : _rosePale));
        if (highlighted) {
          _smallDrop(canvas, cell.center, cellH * 0.62, _roseDeep);
        }
      }
    }
    if (mark == _Mark.check) {
      final c = Offset(0, box.height * 0.14);
      canvas.drawCircle(c, 10, _fill(Colors.white));
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - 8, c.dy)
          ..lineTo(c.dx - 2, c.dy + 6)
          ..lineTo(c.dx + 9, c.dy - 6),
        _stroke(_roseDeep, 3),
      );
    }
    for (final dx in [-0.27, 0.0, 0.27]) {
      final x = box.width * dx;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, box.top + 1), width: 4, height: 11),
          const Radius.circular(2),
        ),
        _fill(Colors.white),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, box.top + 1), width: 4, height: 11),
          const Radius.circular(2),
        ),
        _stroke(const Color(0xFF8A6A76), 1),
      );
    }
    canvas.restore();
  }

  void _smallDrop(Canvas canvas, Offset c, double h, Color color) {
    canvas.drawPath(_dropPath(c, h), _fill(color));
  }

  Path _dropPath(Offset c, double h) => Path()
    ..moveTo(c.dx, c.dy - h / 2)
    ..cubicTo(
      c.dx + h * 0.55,
      c.dy,
      c.dx + h * 0.42,
      c.dy + h / 2,
      c.dx,
      c.dy + h / 2,
    )
    ..cubicTo(
      c.dx - h * 0.42,
      c.dy + h / 2,
      c.dx - h * 0.55,
      c.dy,
      c.dx,
      c.dy - h / 2,
    )
    ..close();

  void _drop(Canvas canvas, Offset c, double half) {
    final h = half * 2;
    final path = _dropPath(c, h);
    final bounds = path.getBounds();
    canvas.drawPath(path, _shade(bounds, const Color(0xFFF58AA3), _rose));
    canvas.drawPath(path, _stroke(_roseDeep.withValues(alpha: 0.45), 1));
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - h * 0.2, c.dy + h * 0.02)
        ..quadraticBezierTo(
          c.dx - h * 0.24,
          c.dy + h * 0.24,
          c.dx - h * 0.06,
          c.dy + h * 0.33,
        ),
      _stroke(Colors.white.withValues(alpha: 0.7), 2.4),
    );
  }

  void _moods(Canvas canvas) {
    const faceInk = _ink;
    final pen = _stroke(faceInk, 1.5);

    // Heart.
    const hc = Offset(52, 27);
    final heart = _heartPath(hc, 16);
    canvas.drawPath(
      heart,
      _shade(heart.getBounds(), const Color(0xFFF58AA3), _rose),
    );
    canvas.drawCircle(hc.translate(-6, -3), 1.5, _fill(faceInk));
    canvas.drawCircle(hc.translate(6, -3), 1.5, _fill(faceInk));
    canvas.drawArc(
      Rect.fromCenter(center: hc.translate(0, 0), width: 9, height: 7),
      0.25,
      math.pi - 0.5,
      false,
      pen,
    );

    // Content yellow face.
    const yc = Offset(31, 56);
    final yr = Rect.fromCircle(center: yc, radius: 14);
    canvas.drawOval(
      yr,
      _shade(yr, const Color(0xFFFFD27F), const Color(0xFFF7AE4F)),
    );
    for (final dx in [-5.5, 5.5]) {
      canvas.drawArc(
        Rect.fromCenter(center: yc.translate(dx, -3), width: 7, height: 5),
        0.2,
        math.pi - 0.4,
        false,
        pen,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(center: yc.translate(0, 3.5), width: 8, height: 6),
      0.25,
      math.pi - 0.5,
      false,
      pen,
    );

    // Low purple face.
    const pc = Offset(72, 56);
    final pr = Rect.fromCircle(center: pc, radius: 14);
    canvas.drawOval(
      pr,
      _shade(pr, const Color(0xFFC6AEEA), const Color(0xFF9D80D2)),
    );
    canvas.drawCircle(pc.translate(-5.5, -2), 1.5, _fill(faceInk));
    canvas.drawCircle(pc.translate(5.5, -2), 1.5, _fill(faceInk));
    canvas.drawLine(pc.translate(-9, -6.5), pc.translate(-3.5, -8.5), pen);
    canvas.drawLine(pc.translate(9, -6.5), pc.translate(3.5, -8.5), pen);
    canvas.drawArc(
      Rect.fromCenter(center: pc.translate(0, 8), width: 9, height: 7),
      math.pi + 0.3,
      math.pi - 0.6,
      false,
      pen,
    );
  }

  void _foot(Canvas canvas, Offset c, double s, Color color, Color? heart) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.2);
    canvas.scale(s);
    final sole = Path()
      ..moveTo(-17, -14)
      ..cubicTo(-12, -24, 14, -24, 18, -12)
      ..cubicTo(21, -2, 11, 4, 12, 13)
      ..cubicTo(13, 25, -9, 30, -13, 15)
      ..cubicTo(-15, 7, -21, -5, -17, -14)
      ..close();
    final fill = heart == null
        ? _fill(color)
        : _shade(sole.getBounds(), const Color(0xFFF58AA3), color);
    canvas.drawPath(sole, fill);
    if (heart == null) canvas.drawPath(sole, _stroke(_rosePale, 1.2));
    const toes = [
      (Offset(-17, -28), 6.2),
      (Offset(-5, -33), 5.2),
      (Offset(5, -33), 4.6),
      (Offset(14, -30), 4.0),
      (Offset(21, -24), 3.4),
    ];
    for (final (at, r) in toes) {
      canvas.drawCircle(at, r, _fill(heart == null ? color : _coral));
      if (heart == null) canvas.drawCircle(at, r, _stroke(_rosePale, 1.2));
    }
    if (heart != null) _heart(canvas, const Offset(0, -2), 9, heart);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GoalPainter old) => old.kind != kind || old.blob != blob;
}

enum _Mark { none, drop, check }

/// The standing calendar shown on the date and period-length steps.
class HeroCalendarArt extends StatelessWidget {
  const HeroCalendarArt({super.key, this.width = 240, this.cycle = false});
  final double width;

  /// Shows repeating arrows instead of a single marked day.
  final bool cycle;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, width * 140 / 240),
        painter: _HeroCalendarPainter(LunaTokens.of(context).pastel, cycle),
      ),
    );
  }
}

class _HeroCalendarPainter extends CustomPainter {
  _HeroCalendarPainter(this.cloud, this.cycle);
  final Color cloud;
  final bool cycle;

  static const _olive = Color(0xFF8E9A5B);
  static const _oliveLight = Color(0xFFA6B176);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 240);

    final puff = Path()
      ..addOval(Rect.fromCircle(center: const Offset(58, 78), radius: 38))
      ..addOval(Rect.fromCircle(center: const Offset(92, 46), radius: 36))
      ..addOval(Rect.fromCircle(center: const Offset(150, 42), radius: 38))
      ..addOval(Rect.fromCircle(center: const Offset(190, 80), radius: 36))
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(40, 62, 170, 56),
          const Radius.circular(28),
        ),
      );
    canvas.drawPath(puff, _fill(cloud.withValues(alpha: 0.32)));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 127), width: 176, height: 20),
      _fill(cloud.withValues(alpha: 0.6)),
    );

    _broadLeaf(canvas, const Offset(66, 122), 44, -2.75, _oliveLight);
    _broadLeaf(canvas, const Offset(68, 120), 52, -2.05, _olive);
    _broadLeaf(canvas, const Offset(74, 118), 42, -1.6, _oliveLight);
    _broadLeaf(canvas, const Offset(176, 122), 42, -0.12, _oliveLight);
    _broadLeaf(canvas, const Offset(174, 120), 48, -0.68, _olive);

    canvas.save();
    canvas.translate(120, 68);
    canvas.rotate(0.09);
    const box = Rect.fromLTWH(-64, -56, 128, 112);

    // The stand folding away behind the page.
    final stand = Path()
      ..moveTo(box.right - 6, box.top + 12)
      ..lineTo(box.right + 13, box.bottom - 4)
      ..lineTo(box.right - 8, box.bottom + 2)
      ..close();
    canvas.drawPath(stand, _fill(const Color(0xFFF6B3C6)));
    canvas.drawPath(stand, _stroke(_roseDeep, 1.6));

    final page = RRect.fromRectAndRadius(box, const Radius.circular(10));
    canvas.drawRRect(page, _fill(Colors.white));
    canvas.save();
    canvas.clipRRect(page);
    final band = Rect.fromLTWH(box.left, box.top, box.width, 26);
    canvas.drawRect(band, _shade(band, const Color(0xFFF58AA3), _rose));
    canvas.restore();
    canvas.drawRRect(page, _stroke(_roseDeep, 1.8));

    const cols = 5, rows = 3;
    const cell = Size(18, 19);
    const gap = 3.0;
    final gridW = cols * cell.width + (cols - 1) * gap;
    final left = -gridW / 2;
    const top = -20.0;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + x * (cell.width + gap),
            top + y * (cell.height + gap),
            cell.width,
            cell.height,
          ),
          const Radius.circular(3),
        );
        final today = !cycle && y == 1 && x == 2;
        canvas.drawRRect(
          rect,
          _fill(today ? const Color(0xFFF58AA3) : _rosePale),
        );
      }
    }
    if (cycle) {
      _cycleArrows(
        canvas,
        Offset(0, top + cell.height + gap + cell.height / 2),
      );
    } else {
      final dropCentre = Offset(0, top + cell.height + gap + cell.height / 2);
      final drop = Path()
        ..moveTo(dropCentre.dx, dropCentre.dy - 11)
        ..cubicTo(
          dropCentre.dx + 10,
          dropCentre.dy,
          dropCentre.dx + 7,
          dropCentre.dy + 10,
          dropCentre.dx,
          dropCentre.dy + 10,
        )
        ..cubicTo(
          dropCentre.dx - 7,
          dropCentre.dy + 10,
          dropCentre.dx - 10,
          dropCentre.dy,
          dropCentre.dx,
          dropCentre.dy - 11,
        )
        ..close();
      canvas.drawPath(drop, _fill(_roseDeep));
    }

    final ring = _stroke(_ink, 2.6);
    for (final x in const [-34.0, 34.0]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, box.top + 2), width: 11, height: 22),
        math.pi * 0.95,
        math.pi * 1.3,
        false,
        ring,
      );
    }
    canvas.restore();

    final spark = _stroke(_coral, 3);
    const origin = Offset(186, 42);
    for (final a in const [-1.25, -0.72, -0.15]) {
      canvas.drawLine(
        origin + Offset.fromDirection(a, 14),
        origin + Offset.fromDirection(a, 27),
        spark,
      );
    }
    canvas.restore();
  }

  void _cycleArrows(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 30, _fill(Colors.white.withValues(alpha: 0.9)));
    const r = 21.0;
    final pen = _stroke(_roseDeep, 4.2);
    for (final start in const [-2.75, 0.39]) {
      const sweep = 2.2;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
        pen,
      );
      final end = start + sweep;
      final tip = c + Offset.fromDirection(end, r);
      final back = end - math.pi / 2;
      canvas.drawLine(tip, tip + Offset.fromDirection(back + 0.65, 10), pen);
      canvas.drawLine(tip, tip + Offset.fromDirection(back - 0.65, 10), pen);
    }
  }

  @override
  bool shouldRepaint(_HeroCalendarPainter old) =>
      old.cloud != cloud || old.cycle != cycle;
}

enum ReminderArtKind { calendar, bell, pills, blossom }

/// The soft rounded tile at the start of each reminder card.
class ReminderArt extends StatelessWidget {
  const ReminderArt({super.key, required this.kind});
  final ReminderArtKind kind;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return ExcludeSemantics(
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: t.pastel.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(18),
        ),
        child: CustomPaint(painter: _ReminderPainter(kind, t)),
      ),
    );
  }
}

class _ReminderPainter extends CustomPainter {
  _ReminderPainter(this.kind, this.t);
  final ReminderArtKind kind;
  final LunaTokens t;

  void _sparks(Canvas canvas, Offset at) {
    final pen = _stroke(_coral, 2);
    for (final a in const [-1.3, -0.75, -0.2]) {
      canvas.drawLine(
        at + Offset.fromDirection(a, 3),
        at + Offset.fromDirection(a, 8),
        pen,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 62);
    switch (kind) {
      case ReminderArtKind.calendar:
        final page = RRect.fromRectAndRadius(
          const Rect.fromLTWH(13, 15, 36, 33),
          const Radius.circular(7),
        );
        canvas.drawRRect(page, _fill(Colors.white));
        canvas.save();
        canvas.clipRRect(page);
        canvas.drawRect(const Rect.fromLTWH(13, 15, 36, 9), _fill(_coral));
        canvas.restore();
        canvas.drawRRect(page, _stroke(_roseDeep, 1.9));
        for (final x in const [23.0, 39.0]) {
          canvas.drawLine(
            Offset(x, 11),
            Offset(x, 19),
            _stroke(_roseDeep, 2.2),
          );
        }
        for (var y = 0; y < 2; y++) {
          for (var x = 0; x < 3; x++) {
            if (y == 1 && x == 1) continue;
            canvas.drawCircle(
              Offset(21.5 + x * 9.5, 30.5 + y * 8.5),
              2.6,
              _fill(_rosePale),
            );
          }
        }
        final c = const Offset(31, 38.5);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - 5.5)
            ..cubicTo(c.dx + 5, c.dy, c.dx + 3.6, c.dy + 4.5, c.dx, c.dy + 4.5)
            ..cubicTo(c.dx - 3.6, c.dy + 4.5, c.dx - 5, c.dy, c.dx, c.dy - 5.5)
            ..close(),
          _fill(_roseDeep),
        );
      case ReminderArtKind.bell:
        final bell = Path()
          ..moveTo(29, 13)
          ..cubicTo(19, 13, 18, 23, 18, 31)
          ..cubicTo(18, 37, 14, 40, 13, 43)
          ..lineTo(45, 43)
          ..cubicTo(44, 40, 40, 37, 40, 31)
          ..cubicTo(40, 23, 39, 13, 29, 13)
          ..close();
        canvas.drawCircle(const Offset(29, 45.5), 4.5, _fill(_roseDeep));
        canvas.drawPath(
          bell,
          _shade(bell.getBounds(), const Color(0xFFF9A3B9), _rose),
        );
        canvas.drawCircle(const Offset(29, 12), 2.6, _fill(_rose));
        _sparks(canvas, const Offset(44, 18));
      case ReminderArtKind.pills:
        canvas.save();
        canvas.translate(26, 32);
        canvas.rotate(-0.8);
        const capsule = Rect.fromLTWH(-19, -8.5, 38, 17);
        final shape = RRect.fromRectAndRadius(
          capsule,
          const Radius.circular(8.5),
        );
        canvas.drawRRect(shape, _fill(Colors.white));
        canvas.save();
        canvas.clipRect(const Rect.fromLTWH(0, -10, 21, 20));
        canvas.drawRRect(shape, _fill(_rose));
        canvas.restore();
        canvas.drawRRect(shape, _stroke(_roseDeep, 1.5));
        canvas.restore();
        final tablet = Rect.fromCenter(
          center: const Offset(44, 44),
          width: 21,
          height: 13,
        );
        canvas.drawOval(
          tablet.translate(0, 2.5),
          _fill(_roseDeep.withValues(alpha: 0.65)),
        );
        canvas.drawOval(tablet, _fill(const Color(0xFFF9B9CA)));
        canvas.drawLine(
          const Offset(36, 44),
          const Offset(52, 44),
          _stroke(_rose, 1.2),
        );
        _sparks(canvas, const Offset(40, 15));
      case ReminderArtKind.blossom:
        drawBlossom(
          canvas,
          const Offset(31, 31),
          21,
          0.2,
          BlossomInk(fill: t.blossom, edge: t.blossomEdge, core: t.blossomCore),
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReminderPainter old) => old.kind != kind || old.t != t;
}

void _broadLeaf(
  Canvas canvas,
  Offset at,
  double length,
  double angle,
  Color color,
) {
  final w = length * 0.24;
  final blade = Path()
    ..moveTo(0, 0)
    ..cubicTo(length * 0.25, -w, length * 0.7, -w, length, 0)
    ..cubicTo(length * 0.7, w, length * 0.25, w, 0, 0)
    ..close();
  canvas.save();
  canvas.translate(at.dx, at.dy);
  canvas.rotate(angle);
  canvas.drawPath(blade, _fill(color));
  canvas.drawLine(
    Offset.zero,
    Offset(length * 0.92, 0),
    _stroke(const Color(0xFF6F7C45), 0.9),
  );
  canvas.restore();
}

/// The shield with a padlock at the top of the privacy step.
class ShieldArt extends StatelessWidget {
  const ShieldArt({super.key, this.width = 124});
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, width * 76 / 120),
        painter: _ShieldPainter(t),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter(this.t);
  final LunaTokens t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120);
    const pale = Color(0xFFC3CB98);
    const paler = Color(0xFFD3D9B0);
    _broadLeaf(canvas, const Offset(40, 44), 36, math.pi + 0.5, pale);
    _broadLeaf(canvas, const Offset(42, 52), 32, math.pi - 0.3, paler);
    _broadLeaf(canvas, const Offset(80, 46), 36, -0.35, pale);
    _broadLeaf(canvas, const Offset(78, 54), 28, 0.2, paler);

    final shield = Path()
      ..moveTo(60, 3)
      ..cubicTo(50, 11, 42, 13, 33, 13)
      ..lineTo(33, 38)
      ..cubicTo(33, 56, 48, 67, 60, 74)
      ..cubicTo(72, 67, 87, 56, 87, 38)
      ..lineTo(87, 13)
      ..cubicTo(78, 13, 70, 11, 60, 3)
      ..close();
    canvas.drawPath(
      shield,
      _shade(shield.getBounds(), Colors.white, _rosePale),
    );
    canvas.drawPath(shield, _stroke(_roseDeep, 2.6));

    canvas.drawArc(
      Rect.fromCircle(center: const Offset(60, 32), radius: 7.5),
      math.pi,
      math.pi,
      false,
      _stroke(_rose, 3.2),
    );
    canvas.drawLine(
      const Offset(52.5, 32),
      const Offset(52.5, 36),
      _stroke(_rose, 3.2),
    );
    canvas.drawLine(
      const Offset(67.5, 32),
      const Offset(67.5, 36),
      _stroke(_rose, 3.2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 35, 24, 18),
        const Radius.circular(4.5),
      ),
      _fill(_rose),
    );
    canvas.drawCircle(const Offset(60, 42.5), 2.6, _fill(Colors.white));
    canvas.drawLine(
      const Offset(60, 43),
      const Offset(60, 48),
      _stroke(Colors.white, 2),
    );

    drawBlossom(
      canvas,
      const Offset(80, 63),
      12.5,
      0.3,
      BlossomInk(fill: const Color(0xFFF9B8CC), edge: _rose, core: _roseDeep),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.t != t;
}
