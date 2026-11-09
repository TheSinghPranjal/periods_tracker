import 'package:flutter/material.dart';

import '../../../app/theme/luna_tokens.dart';
import 'sketch_geometry.dart';

/// Draws a filled shape with the double pencil outline used across the app.
class SketchBoxPainter extends CustomPainter {
  SketchBoxPainter({
    required this.fill,
    required this.stroke,
    required this.seed,
    this.gradient,
    this.radius = 20,
    this.strokeWidth = 1.3,
  });

  final Color fill;
  final Color stroke;
  final int seed;
  final Gradient? gradient;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    final paint = Paint()..color = fill;
    if (gradient != null) paint.shader = gradient!.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
    final line = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawPath(sketchRoundedRect(rect, radius, seed), line);
    canvas.drawPath(
      sketchRoundedRect(rect.inflate(0.6), radius, seed + 31, roughness: 1.5),
      line
        ..color = stroke.withValues(alpha: 0.42)
        ..strokeWidth = strokeWidth * 0.7,
    );
  }

  @override
  bool shouldRepaint(SketchBoxPainter old) =>
      old.fill != fill ||
      old.stroke != stroke ||
      old.seed != seed ||
      old.gradient != gradient ||
      old.radius != radius;
}

class SketchCard extends StatelessWidget {
  const SketchCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.seed = 3,
    this.fill,
    this.gradient,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsets padding;
  final int seed;
  final Color? fill;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: content,
        ),
      );
    }
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: CustomPaint(
        painter: SketchBoxPainter(
          fill: fill ?? t.surface.withValues(alpha: 0.95),
          stroke: t.line,
          seed: seed,
          gradient: gradient,
        ),
        child: content,
      ),
    );
  }
}

class _SketchButton extends StatefulWidget {
  const _SketchButton({
    required this.label,
    required this.onPressed,
    required this.fill,
    required this.foreground,
    required this.stroke,
    this.icon,
    this.seed = 5,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color fill;
  final Color foreground;
  final Color stroke;
  final IconData? icon;
  final int seed;

  @override
  State<_SketchButton> createState() => _SketchButtonState();
}

class _SketchButtonState extends State<_SketchButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final fg = enabled
        ? widget.foreground
        : widget.foreground.withValues(alpha: 0.45);
    return Semantics(
      button: true,
      enabled: enabled,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        child: CustomPaint(
          painter: SketchBoxPainter(
            fill: enabled ? widget.fill : widget.fill.withValues(alpha: 0.5),
            stroke: widget.stroke,
            seed: widget.seed,
            radius: 18,
            strokeWidth: 1.5,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onPressed,
              onHighlightChanged: (v) => setState(() => _down = v),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 21),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: fg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return _SketchButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      fill: t.pastel,
      foreground: t.ink,
      stroke: t.blossomEdge,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.destructive = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return _SketchButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      seed: 9,
      fill: t.surface,
      foreground: destructive ? t.error : t.ink,
      stroke: destructive ? t.error.withValues(alpha: 0.6) : t.line,
    );
  }
}
