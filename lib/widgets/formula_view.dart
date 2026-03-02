import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import 'bottle_picker.dart';
import 'timer_display.dart';

class FormulaView extends ConsumerStatefulWidget {
  const FormulaView({super.key});

  @override
  ConsumerState<FormulaView> createState() => _FormulaViewState();
}

class _FormulaViewState extends ConsumerState<FormulaView> {
  int _selectedAmount = 100;

  void _startFeeding() {
    ref.read(timerProvider.notifier).start();
  }

  void _stopFeeding() {
    final timerState = ref.read(timerProvider.notifier).stop();

    if (timerState.startedAt != null && timerState.elapsedSeconds > 0) {
      final record = FeedingRecord(
        id: const Uuid().v4(),
        type: 'formula',
        durationSeconds: timerState.elapsedSeconds,
        amountMl: _selectedAmount,
        startedAt: timerState.startedAt!,
        endedAt: DateTime.now(),
      );
      ref.read(feedingRecordsProvider.notifier).addRecord(record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final colors = AppTheme.currentThemeColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          TimerDisplay(
            time: timer.isRunning ? timer.displayTime : '00:00',
            isRunning: timer.isRunning,
          ),
          const SizedBox(height: 24),

          if (!timer.isRunning) ...[
            _buildStartButton(colors),
          ] else ...[
            BottlePicker(
              initialAmount: _selectedAmount,
              onAmountChanged: (amount) {
                _selectedAmount = amount;
              },
            ),
            const SizedBox(height: 16),
            _buildStopButton(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildStartButton(ThemeColors colors) {
    return GestureDetector(
      onTap: _startFeeding,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.btnRightGradient,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.btnRightShadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 48,
            ),
            Text(
              'スタート',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton(ThemeColors colors) {
    return GestureDetector(
      onTap: _stopFeeding,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.btnStopGradient,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.btnStopShadow,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stop_rounded,
              color: Colors.white,
              size: 40,
            ),
            Text(
              'ストップ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
