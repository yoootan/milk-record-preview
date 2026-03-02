import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../theme/app_theme.dart';
import 'bottle_picker.dart';

class FormulaView extends ConsumerWidget {
  const FormulaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 8),
          _FormulaBottle(),
        ],
      ),
    );
  }
}

class _FormulaBottle extends ConsumerStatefulWidget {
  const _FormulaBottle();

  @override
  ConsumerState<_FormulaBottle> createState() => _FormulaBottleState();
}

class _FormulaBottleState extends ConsumerState<_FormulaBottle> {
  int _currentMl = 0;
  int _lastRecordedMl = -1;
  String _hintState = 'idle'; // 'idle', 'touching', 'saved'

  void _onAmountChanged(int ml) {
    setState(() {
      _currentMl = ml;
    });
  }

  void _onTouchStart() {
    setState(() => _hintState = 'touching');
  }

  void _onTouchEnd() {
    if (_currentMl > 0 && _currentMl != _lastRecordedMl) {
      // 記録保存
      final now = DateTime.now();
      final record = FeedingRecord(
        id: const Uuid().v4(),
        type: 'formula',
        durationSeconds: 0,
        amountMl: _currentMl,
        startedAt: now,
        endedAt: now,
      );
      ref.read(feedingRecordsProvider.notifier).addRecord(record);
      _lastRecordedMl = _currentMl;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ミルク ${_currentMl}ml 記録しました'),
          backgroundColor: AppTheme.currentThemeColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() => _hintState = 'saved');
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _hintState = 'idle');
      });
    } else {
      setState(() => _hintState = 'idle');
    }
  }

  void _onTouchCancel() {
    setState(() {
      _currentMl = 0;
      _hintState = 'idle';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
    return Column(
      children: [
        BottlePicker(
          initialAmount: _currentMl,
          onAmountChanged: _onAmountChanged,
          onTouchStart: _onTouchStart,
          onTouchEnd: _onTouchEnd,
          onTouchCancel: _onTouchCancel,
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _hintState == 'touching'
              ? Text(
                  '指をはなすと記録',
                  key: const ValueKey('touching'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.accent,
                  ),
                )
              : _hintState == 'saved'
                  ? Text(
                      '✓ 記録しました！',
                      key: const ValueKey('saved'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.accent,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('idle')),
        ),
      ],
    );
  }
}
