import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';
import 'luna_tokens.dart';

const kBodyFont = 'NunitoSans';
const kDisplayFont = 'ShipporiMincho';
const kSketchFont = 'Caveat';

/// Motion stays inside the 150-350ms range of the design brief.
abstract final class LunaMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 350);

  static Duration of(BuildContext context, Duration normal) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : normal;
}

ThemeData buildLunaTheme(AppPalette palette, Brightness brightness) {
  final t = LunaTokens.resolve(palette, brightness);
  final isLight = brightness == Brightness.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.periodFill,
    onPrimary: t.onPeriod,
    primaryContainer: t.pastel,
    onPrimaryContainer: t.ink,
    secondary: t.accent,
    onSecondary: isLight ? Colors.white : const Color(0xFF241A33),
    secondaryContainer: t.fertileTint,
    onSecondaryContainer: t.fertileInk,
    tertiary: t.success,
    onTertiary: isLight ? Colors.white : const Color(0xFF10291F),
    error: t.error,
    onError: isLight ? Colors.white : const Color(0xFF3B0A14),
    surface: t.surface,
    onSurface: t.ink,
    onSurfaceVariant: t.inkSoft,
    outline: t.line,
    outlineVariant: t.line,
    surfaceContainerHighest: t.pale,
    surfaceContainerHigh: t.pale,
    surfaceContainer: t.surface,
    surfaceContainerLow: t.surface,
  );

  TextStyle display(double size, FontWeight w, [double h = 1.2]) => TextStyle(
    fontFamily: kDisplayFont,
    fontSize: size,
    fontWeight: w,
    height: h,
    color: t.ink,
  );
  TextStyle body(double size, FontWeight w, [double h = 1.45, Color? c]) =>
      TextStyle(
        fontFamily: kBodyFont,
        fontSize: size,
        fontWeight: w,
        height: h,
        color: c ?? t.ink,
      );

  final text = TextTheme(
    displayLarge: display(46, FontWeight.w700, 1.05),
    displayMedium: display(36, FontWeight.w700, 1.1),
    headlineMedium: display(28, FontWeight.w700),
    headlineSmall: display(24, FontWeight.w700),
    titleLarge: display(20, FontWeight.w700),
    titleMedium: body(17, FontWeight.w800, 1.3),
    titleSmall: body(15, FontWeight.w700, 1.3),
    bodyLarge: body(16.5, FontWeight.w400),
    bodyMedium: body(15, FontWeight.w400),
    bodySmall: body(13, FontWeight.w600, 1.35, t.inkSoft),
    labelLarge: body(16, FontWeight.w800, 1.2),
    labelMedium: body(13.5, FontWeight.w700, 1.2),
    labelSmall: body(12, FontWeight.w700, 1.2, t.inkSoft),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: kBodyFont,
    textTheme: text,
    scaffoldBackgroundColor: t.paper,
    canvasColor: t.surface,
    dividerColor: t.line,
    extensions: [t],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: t.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: text.titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.ink,
      contentTextStyle: body(15, FontWeight.w600, 1.3, t.paper),
      actionTextColor: t.pastel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: TimePickerThemeData(backgroundColor: t.surface),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStatePropertyAll(t.line),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      contentPadding: const EdgeInsets.all(16),
      hintStyle: body(15, FontWeight.w400, 1.3, t.inkSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.line, width: 1.3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.line, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.periodFill, width: 1.8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.periodFill,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
