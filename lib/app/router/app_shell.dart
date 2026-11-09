import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/sketch/sketch_geometry.dart';
import '../theme/app_theme.dart';
import '../theme/luna_tokens.dart';

class _Tab {
  const _Tab(this.label, this.outlined, this.filled);
  final String label;
  final IconData outlined;
  final IconData filled;
}

const _tabs = [
  _Tab('Home', Icons.spa_outlined, Icons.spa_rounded),
  _Tab('Calendar', Icons.calendar_month_outlined, Icons.calendar_month_rounded),
  _Tab('Log', Icons.add_rounded, Icons.add_rounded),
  _Tab('Insights', Icons.insights_outlined, Icons.insights_rounded),
  _Tab('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(color: t.surface),
        child: CustomPaint(
          painter: _TopPencilLine(t.line),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
              child: Row(
                children: [
                  for (final (i, tab) in _tabs.indexed)
                    Expanded(
                      child: i == 2
                          ? _CentreLogButton(
                              selected: shell.currentIndex == 2,
                              onTap: () => shell.goBranch(
                                2,
                                initialLocation: shell.currentIndex == 2,
                              ),
                            )
                          : _TabButton(
                              tab: tab,
                              selected: shell.currentIndex == i,
                              onTap: () => shell.goBranch(
                                i,
                                initialLocation: shell.currentIndex == i,
                              ),
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

class _TopPencilLine extends CustomPainter {
  _TopPencilLine(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(
      sketchLine(const Offset(0, 1), Offset(size.width, 1), 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TopPencilLine old) => old.color != color;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '${tab.label} tab',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: LunaMotion.of(context, LunaMotion.medium),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected ? t.pastel : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? tab.filled : tab.outlined,
                  size: 23,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? t.ink : t.inkSoft,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CentreLogButton extends StatelessWidget {
  const _CentreLogButton({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Log today',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: t.pastel,
                shape: BoxShape.circle,
                border: Border.all(color: t.blossomEdge, width: 1.6),
              ),
              child: Icon(Icons.add_rounded, size: 28, color: t.ink),
            ),
            const SizedBox(height: 1),
            Text(
              'Log',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? t.ink : t.inkSoft,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
