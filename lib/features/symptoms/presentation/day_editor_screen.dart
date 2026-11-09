import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/calendar_date.dart';
import '../../../core/widgets/common.dart';
import 'day_editor.dart';

export 'day_editor.dart' show DayFocus;

class DayEditorScreen extends ConsumerWidget {
  const DayEditorScreen({super.key, required this.date, required this.focus});
  final CalendarDate date;
  final DayFocus focus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = switch (focus) {
      DayFocus.all => 'Daily log',
      DayFocus.symptoms => 'Log symptoms',
      DayFocus.mood => 'Log mood',
      DayFocus.note => 'Add a note',
    };
    return LunaPage(
      title: title,
      subtitle: ref.watch(lunaDatesProvider).full(date),
      showBack: true,
      children: [DayEditor(date: date, focus: focus)],
    );
  }
}
