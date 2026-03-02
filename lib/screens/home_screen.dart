import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../providers/feeding_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/breast_milk_view.dart';
import '../widgets/feeding_tab_bar.dart';
import '../widgets/formula_view.dart';
import '../widgets/elapsed_time_banner.dart';
import '../widgets/live_banner.dart';
import '../widgets/record_list.dart';
import '../widgets/spit_up_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    final defaultTab = ref.read(defaultTabProvider);
    _selectedTabIndex = defaultTab == 'formula' ? 1 : 0;
  }

  void _onTabChanged(int index) {
    final timer = ref.read(timerProvider);
    final s = ref.read(stringsProvider);
    if (timer.isRunning) {
      final colors = ref.read(colorsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.cannotSwitchTab),
          backgroundColor: colors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _selectedTabIndex = index);
  }

  void _showSettings() {
    final themeState = ref.read(themeProvider);
    final locale = ref.read(localeProvider);
    final colors = ref.read(colorsProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SettingsSheet(
        currentDefault: _selectedTabIndex == 0 ? 'breastMilk' : 'formula',
        currentTheme: themeState.selectedTheme,
        nightModeEnabled: themeState.nightModeEnabled,
        currentLocale: locale,
        colors: colors,
        onDefaultChanged: (value) {
          ref.read(defaultTabProvider.notifier).setDefaultTab(value);
        },
        onThemeChanged: (theme) {
          ref.read(themeProvider.notifier).setTheme(theme);
        },
        onNightModeChanged: (enabled) {
          ref.read(themeProvider.notifier).setNightMode(enabled);
        },
        onLocaleChanged: (locale) {
          ref.read(localeProvider.notifier).setLocale(locale);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(colorsProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _showSettings,
            color: colors.textSub,
          ),
        ],
      ),
      body: Column(
        children: [
          const LiveBanner(),
          const ElapsedTimeBanner(),
          FeedingTabBar(
            selectedIndex: _selectedTabIndex,
            onTabChanged: _onTabChanged,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: _selectedTabIndex == 0
                        ? const BreastMilkView(key: ValueKey('breast'))
                        : const FormulaView(key: ValueKey('formula')),
                  ),
                  const SizedBox(height: 8),
                  const SpitUpButton(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(
                      color: colors.textSub.withValues(alpha: 0.15),
                    ),
                  ),
                  const RecordList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  final String currentDefault;
  final AppColorTheme currentTheme;
  final bool nightModeEnabled;
  final String currentLocale;
  final ThemeColors colors;
  final ValueChanged<String> onDefaultChanged;
  final ValueChanged<AppColorTheme> onThemeChanged;
  final ValueChanged<bool> onNightModeChanged;
  final ValueChanged<String> onLocaleChanged;

  const _SettingsSheet({
    required this.currentDefault,
    required this.currentTheme,
    required this.nightModeEnabled,
    required this.currentLocale,
    required this.colors,
    required this.onDefaultChanged,
    required this.onThemeChanged,
    required this.onNightModeChanged,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.forLocale(currentLocale);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSub.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // カラーテーマ
          Text(
            s.settingsColorTheme,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeDot(context, AppColorTheme.pink, const Color(0xFFE8729A), s.themePink),
              const SizedBox(width: 16),
              _buildThemeDot(context, AppColorTheme.orange, const Color(0xFFF4845F), s.themeOrange),
              const SizedBox(width: 16),
              _buildThemeDot(context, AppColorTheme.blue, const Color(0xFF5B9BD5), s.themeBlue),
              const SizedBox(width: 16),
              _buildThemeDot(context, AppColorTheme.dark, const Color(0xFF1A1A2E), s.themeDark),
            ],
          ),
          const SizedBox(height: 24),
          // ナイトモード
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.settingsNightMode,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.settingsNightModeSub,
                    style: TextStyle(fontSize: 12, color: colors.textSub),
                  ),
                ],
              ),
              Switch(
                value: nightModeEnabled,
                onChanged: (value) {
                  onNightModeChanged(value);
                  Navigator.pop(context);
                },
                activeTrackColor: colors.accent.withValues(alpha: 0.5),
                activeThumbColor: colors.accent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 言語
          Text(
            s.settingsLanguage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          _buildLangOption(context, 'ja', s.langJapanese, colors),
          const SizedBox(height: 8),
          _buildLangOption(context, 'en', s.langEnglish, colors),
          const SizedBox(height: 24),
          // デフォルトタブ
          Text(
            s.settingsDefaultTab,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.settingsDefaultTabSub,
            style: TextStyle(fontSize: 13, color: colors.textSub),
          ),
          const SizedBox(height: 16),
          _buildTabOption(context, label: s.breastMilk, icon: Icons.favorite_rounded, value: 'breastMilk'),
          const SizedBox(height: 8),
          _buildTabOption(context, label: s.formula, icon: Icons.local_drink_rounded, value: 'formula'),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, String locale, String label, ThemeColors colors) {
    final isSelected = currentLocale == locale;
    return GestureDetector(
      onTap: () {
        onLocaleChanged(locale);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.12) : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: colors.accent, width: 2) : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.accent : colors.text,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.accent, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDot(BuildContext context, AppColorTheme theme, Color color, String label) {
    final isSelected = currentTheme == theme;
    return GestureDetector(
      onTap: () {
        onThemeChanged(theme);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                  : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: colors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption(BuildContext context, {required String label, required IconData icon, required String value}) {
    final isSelected = currentDefault == value;
    return GestureDetector(
      onTap: () {
        onDefaultChanged(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent.withValues(alpha: 0.12) : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: colors.accent, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colors.accent : colors.textSub),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.accent : colors.text,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
