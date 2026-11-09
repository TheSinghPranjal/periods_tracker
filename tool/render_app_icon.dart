// Renders the app icon and launch image from the same painters the app uses.
// Run with: flutter test tool/render_app_icon.dart
// Then run tool/install_icons.sh to resize and install them.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:periods_tracker/app/theme/luna_tokens.dart';
import 'package:periods_tracker/core/widgets/sketch/sakura_art.dart';
import 'package:periods_tracker/core/widgets/sketch/sketch_marks.dart';
import 'package:periods_tracker/features/settings/domain/app_settings.dart';

Future<void> _save(
  String path,
  int size,
  void Function(Canvas, double) draw,
) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  test('render icons', () async {
    final t = LunaTokens.resolve(AppPalette.blossom, Brightness.light);
    final ink = BlossomInk(
      fill: t.blossom,
      edge: t.blossomEdge,
      core: t.blossomCore,
    );
    await _save('build/icons/icon.png', 1024, (canvas, s) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, s, s),
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(s, s), [
            const Color(0xFFFFF4F7),
            t.pastel,
          ]),
      );
      canvas.save();
      canvas.translate(s * 0.14, s * 0.14);
      LogoPainter(
        moon: t.periodFill,
        ink: ink,
      ).paint(canvas, Size.square(s * 0.72));
      canvas.restore();
    });
    await _save('build/icons/launch.png', 480, (canvas, s) {
      LogoPainter(moon: t.periodFill, ink: ink).paint(canvas, Size.square(s));
    });
  });
}
