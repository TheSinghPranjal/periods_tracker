import 'package:flutter/material.dart';

import '../../features/settings/domain/app_settings.dart';

/// Semantic colours. Widgets read these roles rather than raw colour values.
@immutable
class LunaTokens extends ThemeExtension<LunaTokens> {
  const LunaTokens({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.line,
    required this.branch,
    required this.blossom,
    required this.blossomEdge,
    required this.blossomCore,
    required this.pastel,
    required this.pale,
    required this.accent,
    required this.periodFill,
    required this.onPeriod,
    required this.predicted,
    required this.fertileTint,
    required this.fertileInk,
    required this.ovulation,
    required this.selected,
    required this.today,
    required this.success,
    required this.warning,
    required this.error,
    required this.heroStart,
    required this.heroEnd,
  });

  final Color paper;
  final Color surface;
  final Color ink;
  final Color inkSoft;
  final Color line;
  final Color branch;
  final Color blossom;
  final Color blossomEdge;
  final Color blossomCore;

  /// Soft fill for primary buttons; [ink] text stays readable on it.
  final Color pastel;
  final Color pale;
  final Color accent;
  final Color periodFill;
  final Color onPeriod;
  final Color predicted;
  final Color fertileTint;
  final Color fertileInk;
  final Color ovulation;
  final Color selected;
  final Color today;
  final Color success;
  final Color warning;
  final Color error;
  final Color heroStart;
  final Color heroEnd;

  static LunaTokens of(BuildContext context) =>
      Theme.of(context).extension<LunaTokens>()!;

  factory LunaTokens.resolve(AppPalette palette, Brightness brightness) {
    final hue = _hues[palette]!;
    if (brightness == Brightness.light) {
      return LunaTokens(
        paper: hue.paper,
        surface: const Color(0xFFFFFFFF),
        ink: const Color(0xFF3B3036),
        inkSoft: const Color(0xFF6B5E66),
        line: hue.line,
        branch: const Color(0xFF6A5550),
        blossom: hue.blossom,
        blossomEdge: hue.edge,
        blossomCore: hue.deep,
        pastel: hue.pastel,
        pale: hue.pale,
        accent: const Color(0xFF7D62AE),
        periodFill: hue.deep,
        onPeriod: const Color(0xFFFFFFFF),
        predicted: hue.deep,
        fertileTint: const Color(0xFFE9E0F6),
        fertileInk: const Color(0xFF5E4590),
        ovulation: const Color(0xFF5E4590),
        selected: const Color(0xFF3B3036),
        today: const Color(0xFF6B5E66),
        success: const Color(0xFF2F7A5B),
        warning: const Color(0xFF9A5B13),
        error: const Color(0xFFB3283F),
        heroStart: hue.pastel,
        heroEnd: hue.pale,
      );
    }
    return LunaTokens(
      paper: const Color(0xFF1E191F),
      surface: const Color(0xFF2A232B),
      ink: const Color(0xFFF6EDF1),
      inkSoft: const Color(0xFFC4B6BF),
      line: const Color(0xFF5B4B56),
      branch: const Color(0xFF8F7D78),
      blossom: hue.pastel.withValues(alpha: 0.82),
      blossomEdge: hue.edge,
      blossomCore: hue.deep,
      pastel: Color.lerp(hue.deep, const Color(0xFF2A232B), 0.35)!,
      pale: Color.lerp(hue.deep, const Color(0xFF2A232B), 0.78)!,
      accent: const Color(0xFFBBA4E6),
      periodFill: hue.pastel,
      onPeriod: const Color(0xFF2B1820),
      predicted: hue.pastel,
      fertileTint: const Color(0xFF41365A),
      fertileInk: const Color(0xFFD7C8F4),
      ovulation: const Color(0xFFD7C8F4),
      selected: const Color(0xFFF6EDF1),
      today: const Color(0xFFC4B6BF),
      success: const Color(0xFF86D0B1),
      warning: const Color(0xFFEBBE85),
      error: const Color(0xFFFF9AA9),
      heroStart: Color.lerp(hue.deep, const Color(0xFF2A232B), 0.45)!,
      heroEnd: const Color(0xFF332A35),
    );
  }

  @override
  LunaTokens copyWith() => this;

  @override
  LunaTokens lerp(LunaTokens? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

class _Hue {
  const _Hue({
    required this.paper,
    required this.line,
    required this.blossom,
    required this.edge,
    required this.deep,
    required this.pastel,
    required this.pale,
  });
  final Color paper, line, blossom, edge, deep, pastel, pale;
}

const _hues = <AppPalette, _Hue>{
  AppPalette.blossom: _Hue(
    paper: Color(0xFFFFF8F9),
    line: Color(0xFFDDC4CE),
    blossom: Color(0xFFFAD4E0),
    edge: Color(0xFFE79CB6),
    deep: Color(0xFFB84A72),
    pastel: Color(0xFFF8C6D6),
    pale: Color(0xFFFDEBF1),
  ),
  AppPalette.lavender: _Hue(
    paper: Color(0xFFFBF8FE),
    line: Color(0xFFD5C9E4),
    blossom: Color(0xFFE5D9F5),
    edge: Color(0xFFB79CDD),
    deep: Color(0xFF7354A6),
    pastel: Color(0xFFDCCDF2),
    pale: Color(0xFFF2ECFA),
  ),
  AppPalette.sage: _Hue(
    paper: Color(0xFFF8FBF8),
    line: Color(0xFFC6D9CD),
    blossom: Color(0xFFD5EADD),
    edge: Color(0xFF93C2A8),
    deep: Color(0xFF3F7A5C),
    pastel: Color(0xFFC6E2D2),
    pale: Color(0xFFEAF4EE),
  ),
  AppPalette.momiji: _Hue(
    paper: Color(0xFFFFF9F5),
    line: Color(0xFFE3CBBB),
    blossom: Color(0xFFF9D5BF),
    edge: Color(0xFFE5A07C),
    deep: Color(0xFFA94A26),
    pastel: Color(0xFFF7CDB4),
    pale: Color(0xFFFDEEE4),
  ),
  AppPalette.plum: _Hue(
    paper: Color(0xFFFCF7FA),
    line: Color(0xFFDAC6D3),
    blossom: Color(0xFFEBD1E2),
    edge: Color(0xFFC88FB2),
    deep: Color(0xFF8A3F6B),
    pastel: Color(0xFFE7C7DB),
    pale: Color(0xFFF7EBF2),
  ),
};
