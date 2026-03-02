import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerDisplay extends StatelessWidget {
  final String time;
  final bool isRunning;
  final Color accentColor;
  final Color textSubColor;

  const TimerDisplay({
    super.key,
    required this.time,
    required this.accentColor,
    required this.textSubColor,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: GoogleFonts.mPlusRounded1c(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: isRunning ? accentColor : textSubColor,
        letterSpacing: 3,
      ),
    );
  }
}
