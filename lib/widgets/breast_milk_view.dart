import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
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
    final s = ref.read(stringsProvider);
    final colors = ref.read(colorsProvider);

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

      final sideName = _activeSide == BreastSide.left ? s.left : s.right;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.breastRecorded(sideName, record.displayTime)),
          backgroundColor: colors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() => _activeSide = null);
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final colors = ref.watch(colorsProvider);
    final s = ref.watch(stringsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          TimerDisplay(
            time: timer.isRunning ? timer.displayTime : '00:00',
            isRunning: timer.isRunning,
            accentColor: colors.accent,
            textSubColor: colors.textSub,
          ),
          const SizedBox(height: 6),
          // Status label
          SizedBox(
            height: 20,
            child: timer.isRunning
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulseDot(color: colors.red),
                      const SizedBox(width: 6),
                      Text(
                        s.feedingLeft(_activeSide == BreastSide.left ? s.left : s.right),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSub),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          if (!timer.isRunning) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSideButton(s.left, BreastSide.left, colors),
                const SizedBox(width: 24),
                _buildSideButton(s.right, BreastSide.right, colors),
              ],
            ),
          ] else ...[
            _buildStopButton(colors, s),
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
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 28, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLeft ? '←' : '→',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700, height: 1),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton(ThemeColors colors, dynamic s) {
    return GestureDetector(
      onTap: _stopFeeding,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.btnStopGradient,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: colors.btnStopShadow, blurRadius: 32, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('■', style: TextStyle(color: Colors.white, fontSize: 48, height: 1)),
            const SizedBox(height: 2),
            Text(
              s.stop,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 1400), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Opacity(
        opacity: 0.3 + _ctrl.value * 0.7,
        child: Container(width: 7, height: 7, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
      ),
    );
  }
}
