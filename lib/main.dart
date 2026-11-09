import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Release builds must not write framework errors, which can quote widget
  // state, to the system log.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(const ProviderScope(child: LunaApp()));
}
