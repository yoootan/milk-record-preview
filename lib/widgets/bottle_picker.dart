import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BottlePicker extends StatefulWidget {
  final int initialAmount;
  final ValueChanged<int> onAmountChanged;

  const BottlePicker({
    super.key,
    this.initialAmount = 100,
    required this.onAmountChanged,
  });

  @override
  State<BottlePicker> createState() => _BottlePickerState();
}

class _BottlePickerState extends State<BottlePicker> {
  late FixedExtentScrollController _controller;
  int _selectedAmount = 100;

  // 0ml ~ 300ml, 10ml刻み
  static const int _maxAmount = 300;
  static const int _step = 10;
  static final int _itemCount = (_maxAmount ~/ _step) + 1;

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.initialAmount;
    _controller = FixedExtentScrollController(
      initialItem: widget.initialAmount ~/ _step,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
    return Column(
      children: [
        // 選択中の量を大きく表示
        Text(
          '${_selectedAmount}ml',
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: colors.accent,
          ),
        ),
        const SizedBox(height: 8),
        // 哺乳瓶風スクロールピッカー
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 選択インジケーター
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              // スクロールホイール
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: 50,
                perspective: 0.003,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAmount = index * _step;
                  });
                  widget.onAmountChanged(_selectedAmount);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _itemCount,
                  builder: (context, index) {
                    final amount = index * _step;
                    final isSelected = amount == _selectedAmount;
                    return Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.mPlusRounded1c(
                          fontSize: isSelected ? 24 : 18,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? colors.accent
                              : colors.textSub.withValues(alpha: 0.5),
                        ),
                        child: Text('${amount}ml'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
