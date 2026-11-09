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

class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.onPressed,
    required this.foreground,
    this.gradient,
    this.fill,
    this.border,
    this.shadow,
    this.gloss = false,
    this.icon,
    this.arrow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color foreground;
  final Gradient? gradient;
  final Color? fill;
  final Color? border;
  final Color? shadow;
  final bool gloss;
  final IconData? icon;
  final bool arrow;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  static const _shape = StadiumBorder();
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: _shape,
            gradient: widget.gradient,
            color: widget.fill,
            shadows: widget.shadow == null
                ? null
                : [
                    BoxShadow(
                      color: widget.shadow!,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: widget.border == null
                ? _shape
                : StadiumBorder(
                    side: BorderSide(color: widget.border!, width: 1.4),
                  ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (v) => setState(() => _down = v),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.gloss)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 58),
                    child: Padding(
                      // Equal on both sides so the label stays centred.
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.arrow ? 54 : 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.foreground,
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: widget.foreground,
                                    fontSize: 17,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.arrow)
                    Positioned(
                      right: 22,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: widget.foreground,
                        size: 26,
                      ),
                    ),
                ],
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
    this.arrow = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Shows a forward arrow; for buttons that move on to the next step.
  final bool arrow;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    final enabled = onPressed != null;
    return _PillButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      arrow: arrow,
      foreground: enabled ? Colors.white : t.ink.withValues(alpha: 0.55),
      gloss: enabled,
      gradient: enabled
          ? LinearGradient(colors: [t.buttonStart, t.buttonEnd])
          : null,
      fill: enabled ? null : t.pastel,
      shadow: enabled ? t.buttonEnd.withValues(alpha: 0.32) : null,
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
    final accent = destructive ? t.error : t.periodFill;
    return _PillButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      foreground: onPressed == null ? accent.withValues(alpha: 0.45) : accent,
      fill: t.surface,
      border: accent.withValues(alpha: onPressed == null ? 0.25 : 0.55),
    );
  }
}
