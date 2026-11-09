import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/luna_tokens.dart';
import '../../features/settings/domain/app_settings.dart';
import '../utils/calendar_date.dart';
import 'sketch/sakura_art.dart';
import 'sketch/sketch_card.dart';
import 'sketch/sketch_marks.dart';

class LunaDates {
  const LunaDates(this.style);
  final DateFormatStyle style;

  String _f(CalendarDate d, String pattern) =>
      DateFormat(pattern).format(d.toLocalDateTime());

  String full(CalendarDate d) => switch (style) {
    DateFormatStyle.dayFirst => _f(d, 'EEEE, d MMMM yyyy'),
    DateFormatStyle.monthFirst => _f(d, 'EEEE, MMMM d, yyyy'),
    DateFormatStyle.yearFirst => _f(d, 'EEEE, yyyy-MM-dd'),
  };

  String medium(CalendarDate d) => switch (style) {
    DateFormatStyle.dayFirst => _f(d, 'd MMM yyyy'),
    DateFormatStyle.monthFirst => _f(d, 'MMM d, yyyy'),
    DateFormatStyle.yearFirst => _f(d, 'yyyy-MM-dd'),
  };

  String short(CalendarDate d) => switch (style) {
    DateFormatStyle.dayFirst => _f(d, 'd MMM'),
    DateFormatStyle.monthFirst => _f(d, 'MMM d'),
    DateFormatStyle.yearFirst => _f(d, 'MM-dd'),
  };

  String longDay(CalendarDate d) => switch (style) {
    DateFormatStyle.monthFirst => _f(d, 'MMMM d'),
    _ => _f(d, 'd MMMM'),
  };

  String range(CalendarDate a, CalendarDate b) => '${short(a)} – ${short(b)}';

  static String time(BuildContext context, int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);
}

final lunaDatesProvider = Provider<LunaDates>(
  (ref) => LunaDates(ref.watch(currentSettingsProvider).dateFormat),
);

@immutable
class GuideContent {
  const GuideContent({
    required this.id,
    required this.title,
    required this.steps,
  });
  final String id;
  final String title;
  final List<String> steps;
}

/// The "how to use this page" note shown at the top of each main screen.
class GuideCard extends ConsumerWidget {
  const GuideCard({super.key, required this.content});
  final GuideContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = LunaTokens.of(context);
    final text = Theme.of(context).textTheme;
    return SketchCard(
      seed: 21,
      fill: t.pale.withValues(alpha: 0.96),
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              content.title,
              style: TextStyle(
                fontFamily: kSketchFont,
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: t.ink,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final (index, step) in content.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 9, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepNumber(index + 1),
                  const SizedBox(width: 10),
                  Expanded(child: Text(step, style: text.bodyMedium)),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => ref
                  .read(dismissedGuidesProvider.notifier)
                  .setDismissed(content.id, true),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber(this.number);
  final int number;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.pastel,
        shape: BoxShape.circle,
        border: Border.all(color: t.blossomEdge),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: t.ink),
      ),
    );
  }
}

/// The standard page: sakura backdrop, heading and scrolling content.
class LunaPage extends ConsumerWidget {
  const LunaPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.actions = const [],
    this.guide,
    this.showBack = false,
    this.bottomBar,
    this.titleWidget,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final GuideContent? guide;
  final bool showBack;
  final Widget? bottomBar;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final guide = this.guide;
    final showGuide =
        guide != null && !ref.watch(dismissedGuidesProvider).contains(guide.id);
    final width = MediaQuery.sizeOf(context).width;
    final gutter = width > 680 ? (width - 640) / 2 : 18.0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: SakuraBackdrop()),
          SafeArea(
            bottom: bottomBar == null,
            child: ListView(
              padding: EdgeInsets.fromLTRB(gutter, 6, gutter, 28),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _HeaderIcons(
                  children: [
                    if (showBack)
                      Semantics(
                        label: 'Go back',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back',
                          onPressed: () => context.pop(),
                        ),
                      ),
                    const Spacer(),
                    if (guide != null)
                      IconButton(
                        tooltip: showGuide
                            ? 'Hide instructions'
                            : 'Show instructions',
                        icon: Icon(
                          showGuide
                              ? Icons.help_rounded
                              : Icons.help_outline_rounded,
                        ),
                        onPressed: () => ref
                            .read(dismissedGuidesProvider.notifier)
                            .setDismissed(guide.id, showGuide),
                      ),
                    ...actions,
                  ],
                ),
                titleWidget ??
                    Semantics(
                      header: true,
                      child: Padding(
                        padding: EdgeInsets.only(right: width > 680 ? 0 : 56),
                        child: Text(title, style: text.headlineMedium),
                      ),
                    ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      subtitle!,
                      style: text.bodyMedium?.copyWith(
                        color: LunaTokens.of(context).inkSoft,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (showGuide) ...[
                  GuideCard(content: guide),
                  const SizedBox(height: 14),
                ],
                ...children,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: bottomBar,
              ),
            ),
    );
  }
}

/// Keeps the header icons readable where they cross the blossom branch.
class _HeaderIcons extends StatelessWidget {
  const _HeaderIcons({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Row(
      children: [
        for (final child in children)
          child is Spacer
              ? child
              : Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.paper.withValues(alpha: 0.86),
                      shape: BoxShape.circle,
                    ),
                    child: child,
                  ),
                ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8, left: 2),
      child: Row(
        children: [
          const BlossomIcon(size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SketchCard(
      seed: 13,
      child: Center(
        child: Column(
          children: [
            const BlossomIcon(size: 44),
            const SizedBox(height: 10),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(message, style: text.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice(
    this.message, {
    super.key,
    this.icon = Icons.lock_outline_rounded,
    this.warning = false,
  });
  final String message;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning ? t.warning.withValues(alpha: 0.1) : t.pale,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warning ? t.warning.withValues(alpha: 0.5) : t.line,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.info_outline_rounded : icon,
            size: 20,
            color: warning ? t.warning : t.periodFill,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// A selectable sketched chip, used for every single- or multi-choice control.
class SketchChip extends StatelessWidget {
  const SketchChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.seed = 1,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: LunaMotion.of(context, LunaMotion.fast),
        decoration: BoxDecoration(
          color: selected ? t.pastel : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.blossomEdge : t.line,
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 46),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected && leading == null) ...[
                      Icon(Icons.check_rounded, size: 17, color: t.ink),
                      const SizedBox(width: 5),
                    ],
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 7),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: t.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      minTileHeight: 56,
      leading: icon == null ? null : Icon(icon, color: t.periodFill),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : Icon(Icons.chevron_right_rounded, color: t.inkSoft)),
      onTap: onTap,
    );
  }
}

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
    );
  }
}

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder});
  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      data: builder,
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const EmptyState(
        title: 'We couldn\'t load this',
        message:
            'Your saved information has not been changed. Please close and reopen the app.',
      ),
    );
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
  String cancelLabel = 'Cancel',
}) async {
  final t = LunaTokens.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: t.ink),
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          style: destructive
              ? TextButton.styleFrom(foregroundColor: t.error)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(
  BuildContext context,
  String message, {
  String? undoLabel,
  VoidCallback? onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        persist: false,
        duration: Duration(seconds: onUndo == null ? 3 : 6),
        action: onUndo == null
            ? null
            : SnackBarAction(label: undoLabel ?? 'Undo', onPressed: onUndo),
      ),
    );
}

/// A calm inline "saved" tick that appears after an autosave.
class SavedTick extends StatelessWidget {
  const SavedTick({super.key, required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final t = LunaTokens.of(context);
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: LunaMotion.of(context, LunaMotion.medium),
      child: Semantics(
        liveRegion: true,
        label: visible ? 'Saved' : '',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: t.success),
            const SizedBox(width: 4),
            Text(
              'Saved',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: t.success),
            ),
          ],
        ),
      ),
    );
  }
}

String intensityWord(int value) =>
    const ['None', 'Mild', 'Moderate', 'Severe'][value.clamp(0, 3)];
