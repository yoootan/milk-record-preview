import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppColorTheme { pink, orange, blue, dark }

class ThemeColors {
  final Color bg;
  final Color card;
  final Color accent;
  final Color accentLight;
  final List<Color> btnLeftGradient;
  final Color btnLeftShadow;
  final List<Color> btnRightGradient;
  final Color btnRightShadow;
  final List<Color> btnStopGradient;
  final Color btnStopShadow;
  final Color text;
  final Color textSub;
  final Color gray;
  final Color iconBreastBg;
  final Color iconFormulaBg;
  final Color green;
  final Color red;
  final Color liveBg;
  final Color liveBorder;
  final Brightness brightness;

  const ThemeColors({
    required this.bg,
    required this.card,
    required this.accent,
    required this.accentLight,
    required this.btnLeftGradient,
    required this.btnLeftShadow,
    required this.btnRightGradient,
    required this.btnRightShadow,
    required this.btnStopGradient,
    required this.btnStopShadow,
    required this.text,
    required this.textSub,
    required this.gray,
    required this.iconBreastBg,
    required this.iconFormulaBg,
    required this.green,
    required this.red,
    required this.liveBg,
    required this.liveBorder,
    this.brightness = Brightness.light,
  });
}

class AppTheme {
  // ===== Pink Theme =====
  static const pinkColors = ThemeColors(
    bg: Color(0xFFFFF5F7),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFFE8729A),
    accentLight: Color(0xFFFFE0EB),
    btnLeftGradient: [Color(0xFFF78DA7), Color(0xFFE8729A)],
    btnLeftShadow: Color(0x59F78DA7),
    btnRightGradient: [Color(0xFFFFAAC4), Color(0xFFE8729A)],
    btnRightShadow: Color(0x59FFAAC4),
    btnStopGradient: [Color(0xFFFF8A80), Color(0xFFEF5350)],
    btnStopShadow: Color(0x4DEF5350),
    text: Color(0xFF5D3A4A),
    textSub: Color(0xFFA07888),
    gray: Color(0xFFF5ECF0),
    iconBreastBg: Color(0x2EF78DA7),
    iconFormulaBg: Color(0x2EFFB347),
    green: Color(0xFF66BB6A),
    red: Color(0xFFEF5350),
    liveBg: Color(0x14E8729A),
    liveBorder: Color(0x26E8729A),
  );

  // ===== Orange Theme =====
  static const orangeColors = ThemeColors(
    bg: Color(0xFFFFF9F2),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFFF4845F),
    accentLight: Color(0xFFFFE8DF),
    btnLeftGradient: [Color(0xFFF78DA7), Color(0xFFF4845F)],
    btnLeftShadow: Color(0x59F78DA7),
    btnRightGradient: [Color(0xFFFFB347), Color(0xFFF4845F)],
    btnRightShadow: Color(0x59FFB347),
    btnStopGradient: [Color(0xFFFF8A80), Color(0xFFEF5350)],
    btnStopShadow: Color(0x4DEF5350),
    text: Color(0xFF5D4037),
    textSub: Color(0xFFA1887F),
    gray: Color(0xFFF0EBE5),
    iconBreastBg: Color(0x2EF78DA7),
    iconFormulaBg: Color(0x2EFFB347),
    green: Color(0xFF66BB6A),
    red: Color(0xFFEF5350),
    liveBg: Color(0x14F4845F),
    liveBorder: Color(0x26F4845F),
  );

  // ===== Blue Theme =====
  static const blueColors = ThemeColors(
    bg: Color(0xFFF2F7FF),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFF5B9BD5),
    accentLight: Color(0xFFDEEAF6),
    btnLeftGradient: [Color(0xFF7BAFD4), Color(0xFF5B9BD5)],
    btnLeftShadow: Color(0x595B9BD5),
    btnRightGradient: [Color(0xFFA3CBE8), Color(0xFF5B9BD5)],
    btnRightShadow: Color(0x59A3CBE8),
    btnStopGradient: [Color(0xFFFF8A80), Color(0xFFEF5350)],
    btnStopShadow: Color(0x4DEF5350),
    text: Color(0xFF2E4057),
    textSub: Color(0xFF7A8EA3),
    gray: Color(0xFFE8EEF5),
    iconBreastBg: Color(0x2E7BAFD4),
    iconFormulaBg: Color(0x2EA3CBE8),
    green: Color(0xFF66BB6A),
    red: Color(0xFFEF5350),
    liveBg: Color(0x145B9BD5),
    liveBorder: Color(0x265B9BD5),
  );

  // ===== Dark Theme =====
  static const darkColors = ThemeColors(
    bg: Color(0xFF1A1A2E),
    card: Color(0xFF25253D),
    accent: Color(0xFFE8729A),
    accentLight: Color(0x2EE8729A),
    btnLeftGradient: [Color(0xFFC7608A), Color(0xFFE8729A)],
    btnLeftShadow: Color(0x4DE8729A),
    btnRightGradient: [Color(0xFFD4A054), Color(0xFFE8729A)],
    btnRightShadow: Color(0x4DD4A054),
    btnStopGradient: [Color(0xFFFF8A80), Color(0xFFEF5350)],
    btnStopShadow: Color(0x40EF5350),
    text: Color(0xFFE8E0E4),
    textSub: Color(0xFF8A7F84),
    gray: Color(0xFF2A2A42),
    iconBreastBg: Color(0x26E8729A),
    iconFormulaBg: Color(0x26D4A054),
    green: Color(0xFF66BB6A),
    red: Color(0xFFEF5350),
    liveBg: Color(0x14E8729A),
    liveBorder: Color(0x1FE8729A),
    brightness: Brightness.dark,
  );

  static ThemeColors colorsForTheme(AppColorTheme theme) {
    switch (theme) {
      case AppColorTheme.pink:
        return pinkColors;
      case AppColorTheme.orange:
        return orangeColors;
      case AppColorTheme.blue:
        return blueColors;
      case AppColorTheme.dark:
        return darkColors;
    }
  }

  static ThemeData buildTheme(ThemeColors colors) {
    final isDark = colors.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: colors.brightness,
        surface: colors.bg,
      ),
      scaffoldBackgroundColor: colors.bg,
      textTheme: GoogleFonts.mPlusRounded1cTextTheme().apply(
        bodyColor: colors.text,
        displayColor: colors.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.text,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.accent,
        contentTextStyle: TextStyle(color: isDark ? colors.text : Colors.white),
      ),
    );
  }
}
