import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// タイマーの状態
class TimerState {
  final bool isRunning;
  final int elapsedSeconds;
  final DateTime? startedAt;

  const TimerState({
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.startedAt,
  });

  TimerState copyWith({
    bool? isRunning,
    int? elapsedSeconds,
    DateTime? startedAt,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  String get displayTime {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

final timerProvider =
    NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const TimerState();
  }

  void start() {
    _timer?.cancel();
    state = TimerState(
      isRunning: true,
      elapsedSeconds: 0,
      startedAt: DateTime.now(),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  TimerState stop() {
    _timer?.cancel();
    final finalState = state.copyWith(isRunning: false);
    state = const TimerState();
    return finalState;
  }

  void reset() {
    _timer?.cancel();
    state = const TimerState();
  }
}
