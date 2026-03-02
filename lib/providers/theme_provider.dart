import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage.dart';
import '../theme/app_theme.dart';

class ThemeState {
  final AppColorTheme selectedTheme;
  final bool nightModeEnabled;
  final bool isNightTime;

  const ThemeState({
    this.selectedTheme = AppColorTheme.pink,
    this.nightModeEnabled = false,
    this.isNightTime = false,
  });

  ThemeState copyWith({
    AppColorTheme? selectedTheme,
    bool? nightModeEnabled,
    bool? isNightTime,
  }) {
    return ThemeState(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      nightModeEnabled: nightModeEnabled ?? this.nightModeEnabled,
      isNightTime: isNightTime ?? this.isNightTime,
    );
  }

  /// Returns the effective theme considering night mode
  AppColorTheme get effectiveTheme {
    if (nightModeEnabled && isNightTime) {
      return AppColorTheme.dark;
    }
    return selectedTheme;
  }

  ThemeColors get colors => AppTheme.colorsForTheme(effectiveTheme);
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeState> {
  Timer? _nightCheckTimer;

  @override
  ThemeState build() {
    ref.onDispose(() {
      _nightCheckTimer?.cancel();
    });

    final savedTheme = LocalStorage.getColorTheme();
    final nightMode = LocalStorage.getNightMode();
    final isNight = _checkNightTime();

    final initialState = ThemeState(
      selectedTheme: savedTheme,
      nightModeEnabled: nightMode,
      isNightTime: isNight,
    );

    // Update AppTheme static reference
    AppTheme.setCurrentColors(initialState.colors);

    // Start periodic night time check
    _startNightTimeCheck();

    return initialState;
  }

  void setTheme(AppColorTheme theme) {
    LocalStorage.setColorTheme(theme);
    state = state.copyWith(selectedTheme: theme);
    AppTheme.setCurrentColors(state.colors);
  }

  void setNightMode(bool enabled) {
    LocalStorage.setNightMode(enabled);
    state = state.copyWith(
      nightModeEnabled: enabled,
      isNightTime: _checkNightTime(),
    );
    AppTheme.setCurrentColors(state.colors);
  }

  void _startNightTimeCheck() {
    _nightCheckTimer?.cancel();
    _nightCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final isNight = _checkNightTime();
      if (isNight != state.isNightTime) {
        state = state.copyWith(isNightTime: isNight);
        AppTheme.setCurrentColors(state.colors);
      }
    });
  }

  /// Night time: 20:00 - 06:00
  static bool _checkNightTime() {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }
}
