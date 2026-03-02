import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TimerDisplay extends StatelessWidget {
  final String time;
  final bool isRunning;

  const TimerDisplay({
    super.key,
    required this.time,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: isRunning
            ? colors.accent.withValues(alpha: 0.15)
            : colors.gray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        time,
        style: GoogleFonts.mPlusRounded1c(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: isRunning ? colors.accent : colors.textSub,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
