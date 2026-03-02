import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BottlePicker extends StatefulWidget {
  final int initialAmount;
  final ValueChanged<int> onAmountChanged;
  final VoidCallback? onTouchStart;
  final VoidCallback? onTouchEnd;
  final VoidCallback? onTouchCancel;

  const BottlePicker({
    super.key,
    this.initialAmount = 0,
    required this.onAmountChanged,
    this.onTouchStart,
    this.onTouchEnd,
    this.onTouchCancel,
  });

  @override
  State<BottlePicker> createState() => _BottlePickerState();
}

class _BottlePickerState extends State<BottlePicker>
    with SingleTickerProviderStateMixin {
  int _selectedAmount = 0;
  bool _isTouching = false;
  late AnimationController _bubbleController;

  static const int _maxAmount = 300;
  static const int _step = 10;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.initialAmount;
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  void _updateAmount(double localY, double height) {
    // Bottle fill area mapped to SVG coordinates
    final fillTop = height * 0.28;
    final fillBottom = height * 0.93;
    final fillHeight = fillBottom - fillTop;

    final clamped = localY.clamp(fillTop, fillBottom);
    final ratio = 1.0 - (clamped - fillTop) / fillHeight;
    final raw = (ratio * _maxAmount).round();
    final snapped = (raw / _step).round() * _step;
    final amount = snapped.clamp(0, _maxAmount);

    if (amount != _selectedAmount) {
      setState(() => _selectedAmount = amount);
      widget.onAmountChanged(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
    return Column(
      children: [
        // Amount display
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: colors.accent,
          ),
          child: Text('${_selectedAmount}ml'),
        ),
        const SizedBox(height: 4),
        // Bottle
        SizedBox(
          width: 180,
          height: 260,
          child: GestureDetector(
            onPanStart: (details) {
              _isTouching = true;
              _updateAmount(details.localPosition.dy, 260);
              widget.onTouchStart?.call();
            },
            onPanUpdate: (details) {
              // Cancel if dragged outside bottle bounds
              final pos = details.localPosition;
              if (pos.dx < 0 || pos.dx > 180 || pos.dy < 0 || pos.dy > 260) {
                if (_isTouching) {
                  _isTouching = false;
                  setState(() => _selectedAmount = 0);
                  widget.onAmountChanged(0);
                  widget.onTouchCancel?.call();
                }
                return;
              }
              _updateAmount(pos.dy, 260);
            },
            onPanEnd: (_) {
              if (_isTouching) {
                _isTouching = false;
                widget.onTouchEnd?.call();
              }
            },
            onTapDown: (details) {
              _isTouching = true;
              _updateAmount(details.localPosition.dy, 260);
              widget.onTouchStart?.call();
            },
            onTapUp: (_) {
              if (_isTouching) {
                _isTouching = false;
                widget.onTouchEnd?.call();
              }
            },
            child: AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(180, 260),
                  painter: _BottlePainter(
                    fillRatio: _selectedAmount / _maxAmount,
                    accentColor: colors.accent,
                    textSubColor: colors.textSub,
                    bubblePhase: _bubbleController.value,
                    isTouching: _isTouching,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (!_isTouching)
          Text(
            'タッチして量を調整',
            style: TextStyle(
              fontSize: 11,
              color: colors.textSub.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }
}

class _BottlePainter extends CustomPainter {
  final double fillRatio;
  final Color accentColor;
  final Color textSubColor;
  final double bubblePhase;
  final bool isTouching;

  _BottlePainter({
    required this.fillRatio,
    required this.accentColor,
    required this.textSubColor,
    required this.bubblePhase,
    required this.isTouching,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / 220;
    final sy = h / 320;

    _drawCap(canvas, sx, sy);
    _drawRing(canvas, sx, sy);
    _drawNeck(canvas, sx, sy);
    _drawBody(canvas, sx, sy);
    _drawMilk(canvas, sx, sy);
    _drawBubbles(canvas, sx, sy);
    _drawScales(canvas, sx, sy);
    _drawHighlight(canvas, sx, sy);
  }

  void _drawCap(Canvas canvas, double sx, double sy) {
    final paint = Paint()..color = const Color(0xFFC8DFF0);
    final strokePaint = Paint()
      ..color = const Color(0xFFA0C4DD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(75 * sx, 42 * sy)
      ..cubicTo(75 * sx, 30 * sy, 85 * sx, 22 * sy, 110 * sx, 22 * sy)
      ..cubicTo(135 * sx, 22 * sy, 145 * sx, 30 * sy, 145 * sx, 42 * sy)
      ..lineTo(145 * sx, 58 * sy)
      ..lineTo(75 * sx, 58 * sy)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final hlPath = Path()
      ..moveTo(85 * sx, 34 * sy)
      ..cubicTo(88 * sx, 30 * sy, 95 * sx, 27 * sy, 105 * sx, 27 * sy);
    canvas.drawPath(hlPath, hlPaint);
  }

  void _drawRing(Canvas canvas, double sx, double sy) {
    final rect = Rect.fromLTWH(70 * sx, 56 * sy, 80 * sx, 16 * sy);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(4 * sx));
    canvas.drawRRect(rRect, Paint()..color = const Color(0xFFB8D4E8));
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = const Color(0xFF9CBDD6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF9CBDD6).withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(76 * sx, 62 * sy), Offset(144 * sx, 62 * sy), linePaint);
    canvas.drawLine(
      Offset(76 * sx, 66 * sy),
      Offset(144 * sx, 66 * sy),
      linePaint..color = const Color(0xFF9CBDD6).withValues(alpha: 0.25),
    );
  }

  void _drawNeck(Canvas canvas, double sx, double sy) {
    final path = Path()
      ..moveTo(70 * sx, 72 * sy)
      ..lineTo(52 * sx, 88 * sy)
      ..lineTo(168 * sx, 88 * sy)
      ..lineTo(150 * sx, 72 * sy)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.95));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD0D0D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  Path _bodyPath(double sx, double sy) {
    return Path()
      ..moveTo(52 * sx, 88 * sy)
      ..cubicTo(42 * sx, 95 * sy, 35 * sx, 115 * sy, 35 * sx, 135 * sy)
      ..lineTo(35 * sx, 275 * sy)
      ..cubicTo(35 * sx, 292 * sy, 55 * sx, 305 * sy, 110 * sx, 305 * sy)
      ..cubicTo(165 * sx, 305 * sy, 185 * sx, 292 * sy, 185 * sx, 275 * sy)
      ..lineTo(185 * sx, 135 * sy)
      ..cubicTo(185 * sx, 115 * sy, 178 * sx, 95 * sy, 168 * sx, 88 * sy)
      ..close();
  }

  void _drawBody(Canvas canvas, double sx, double sy) {
    final path = _bodyPath(sx, sy);
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.94));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD0D0D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawMilk(Canvas canvas, double sx, double sy) {
    if (fillRatio <= 0) return;

    const bottleTop = 95.0;
    const bottleBot = 303.0;
    const bottleH = bottleBot - bottleTop;

    final milkTop = bottleBot - fillRatio * bottleH;

    canvas.save();
    canvas.clipPath(_bodyPath(sx, sy));

    // Milk gradient
    final milkRect = Rect.fromLTWH(
      35 * sx, milkTop * sy, 150 * sx, (bottleBot - milkTop) * sy,
    );
    final milkPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF8E8), Color(0xFFFFE4B5)],
      ).createShader(milkRect);
    canvas.drawRect(milkRect, milkPaint);

    // Wave at top
    final wavePaint = Paint()..color = const Color(0xFFFFF8E8).withValues(alpha: 0.45);
    final wavePath = Path();
    final waveY = milkTop * sy;
    wavePath.moveTo(35 * sx, waveY);
    for (double x = 35; x <= 185; x += 1) {
      final wave = sin((x / 20 + bubblePhase * 2 * pi) * 1) * 2;
      wavePath.lineTo(x * sx, waveY + wave * sy);
    }
    wavePath.lineTo(185 * sx, waveY + 10 * sy);
    wavePath.lineTo(35 * sx, waveY + 10 * sy);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);

    canvas.restore();
  }

  void _drawBubbles(Canvas canvas, double sx, double sy) {
    if (fillRatio <= 0.05) return;

    const bottleBot = 303.0;
    const bottleH = 208.0;
    final milkTop = bottleBot - fillRatio * bottleH;

    final bubbles = [
      (cx: 75.0, startY: 260.0, r: 3.0, delay: 0.0),
      (cx: 130.0, startY: 270.0, r: 2.5, delay: 0.3),
      (cx: 100.0, startY: 280.0, r: 2.0, delay: 0.55),
      (cx: 90.0, startY: 250.0, r: 1.8, delay: 0.75),
    ];

    for (final b in bubbles) {
      final phase = (bubblePhase + b.delay) % 1.0;
      if (b.startY < milkTop) continue;
      final y = b.startY - phase * 40;
      if (y < milkTop) continue;

      final opacity = phase < 0.2
          ? phase / 0.2 * 0.6
          : 0.6 * (1.0 - (phase - 0.2) / 0.8);

      canvas.drawCircle(
        Offset(b.cx * sx, y * sy),
        b.r * sx,
        Paint()..color = Colors.white.withValues(alpha: opacity.clamp(0.0, 0.6)),
      );
    }
  }

  void _drawScales(Canvas canvas, double sx, double sy) {
    const bottleTop = 95.0;
    const bottleBot = 303.0;
    const bottleH = bottleBot - bottleTop;
    const bodyR = 184.0;

    final scalePaint = Paint()..color = const Color(0xFFC05050);

    final textStyle = TextStyle(
      fontSize: 9 * sx,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFC05050),
    );

    for (int v = 10; v <= 290; v += 10) {
      final pct = v / 300;
      final y = bottleBot - pct * bottleH;
      final isMajor = v % 50 == 0;
      final lineW = isMajor ? 20.0 : 10.0;

      canvas.drawLine(
        Offset((bodyR - 6 - lineW) * sx, y * sy),
        Offset((bodyR - 6) * sx, y * sy),
        scalePaint
          ..strokeWidth = (isMajor ? 1.0 : 0.5)
          ..color = const Color(0xFFC05050).withValues(alpha: isMajor ? 0.7 : 0.4),
      );

      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(text: '$v', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset((bodyR - 6 - lineW - 5) * sx - tp.width, y * sy - tp.height / 2),
        );
      }
    }
  }

  void _drawHighlight(Canvas canvas, double sx, double sy) {
    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * sx
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(54 * sx, 100 * sy)
      ..cubicTo(50 * sx, 110 * sy, 46 * sx, 140 * sy, 46 * sx, 160 * sy)
      ..lineTo(46 * sx, 260 * sy)
      ..cubicTo(46 * sx, 270 * sy, 48 * sx, 275 * sy, 50 * sx, 278 * sy);
    canvas.drawPath(path, hlPaint);

    final hl2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx
      ..strokeCap = StrokeCap.round;
    final path2 = Path()
      ..moveTo(60 * sx, 105 * sy)
      ..cubicTo(58 * sx, 112 * sy, 55 * sx, 130 * sy, 55 * sx, 145 * sy)
      ..lineTo(55 * sx, 220 * sy);
    canvas.drawPath(path2, hl2);
  }

  @override
  bool shouldRepaint(covariant _BottlePainter old) =>
      old.fillRatio != fillRatio ||
      old.accentColor != accentColor ||
      old.bubblePhase != bubblePhase ||
      old.isTouching != isTouching;
}
