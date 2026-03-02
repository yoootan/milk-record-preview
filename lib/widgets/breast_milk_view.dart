import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import 'timer_display.dart';

class BreastMilkView extends ConsumerStatefulWidget {
  const BreastMilkView({super.key});

  @override
  ConsumerState<BreastMilkView> createState() => _BreastMilkViewState();
}

class _BreastMilkViewState extends ConsumerState<BreastMilkView> {
  BreastSide? _activeSide;

  void _startFeeding(BreastSide side) {
    setState(() => _activeSide = side);
    ref.read(timerProvider.notifier).start();
  }

  void _stopFeeding() {
    final timerState = ref.read(timerProvider.notifier).stop();

    if (timerState.startedAt != null && timerState.elapsedSeconds > 0) {
      final record = FeedingRecord(
        id: const Uuid().v4(),
        type: 'breastMilk',
        side: _activeSide == BreastSide.left ? 'left' : 'right',
        durationSeconds: timerState.elapsedSeconds,
        startedAt: timerState.startedAt!,
        endedAt: DateTime.now(),
      );
      ref.read(feedingRecordsProvider.notifier).addRecord(record);
    }

    setState(() => _activeSide = null);
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
          const SizedBox(height: 32),

          if (!timer.isRunning) ...[
            Text(
              'どちら側ですか？',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSub,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSideButton('ひだり', BreastSide.left, colors),
                const SizedBox(width: 24),
                _buildSideButton('みぎ', BreastSide.right, colors),
              ],
            ),
          ] else ...[
            Text(
              '${_activeSide == BreastSide.left ? "ひだり" : "みぎ"}で授乳中...',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSub,
              ),
            ),
            const SizedBox(height: 16),
            _buildStopButton(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildSideButton(String label, BreastSide side, ThemeColors colors) {
    final isLeft = side == BreastSide.left;
    final gradient = isLeft ? colors.btnLeftGradient : colors.btnRightGradient;
    final shadow = isLeft ? colors.btnLeftShadow : colors.btnRightShadow;
    return GestureDetector(
      onTap: () => _startFeeding(side),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLeft ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
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
        width: 140,
        height: 140,
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
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stop_rounded,
              color: Colors.white,
              size: 48,
            ),
            Text(
              'ストップ',
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
}
