import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feeding_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/breast_milk_view.dart';
import '../widgets/feeding_tab_bar.dart';
import '../widgets/formula_view.dart';
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
    if (timer.isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('計測中はタブを切り替えられません'),
          backgroundColor: AppTheme.currentThemeColors.accent,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SettingsSheet(
        currentDefault: _selectedTabIndex == 0 ? 'breastMilk' : 'formula',
        currentTheme: themeState.selectedTheme,
        nightModeEnabled: themeState.nightModeEnabled,
        onDefaultChanged: (value) {
          ref.read(defaultTabProvider.notifier).setDefaultTab(value);
        },
        onThemeChanged: (theme) {
          ref.read(themeProvider.notifier).setTheme(theme);
        },
        onNightModeChanged: (enabled) {
          ref.read(themeProvider.notifier).setNightMode(enabled);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme to rebuild on changes
    ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('授乳きろく'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _showSettings,
            color: AppTheme.currentThemeColors.textSub,
          ),
        ],
      ),
      body: Column(
        children: [
          // リアルタイム集計バナー
          const LiveBanner(),
          // タブバー
          FeedingTabBar(
            selectedIndex: _selectedTabIndex,
            onTabChanged: _onTabChanged,
          ),
          // メインコンテンツ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedTabIndex == 0
                ? const BreastMilkView(key: ValueKey('breast'))
                : const FormulaView(key: ValueKey('formula')),
          ),
          const SizedBox(height: 8),
          // 吐き戻しボタン
          const SpitUpButton(),
          const SizedBox(height: 8),
          // 区切り線
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              color: AppTheme.currentThemeColors.textSub.withValues(alpha: 0.15),
            ),
          ),
          // 記録一覧
          const Expanded(
            child: SingleChildScrollView(
              child: RecordList(),
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
  final ValueChanged<String> onDefaultChanged;
  final ValueChanged<AppColorTheme> onThemeChanged;
  final ValueChanged<bool> onNightModeChanged;

  const _SettingsSheet({
    required this.currentDefault,
    required this.currentTheme,
    required this.nightModeEnabled,
    required this.onDefaultChanged,
    required this.onThemeChanged,
    required this.onNightModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentThemeColors;
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
            'カラーテーマ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeDot(context, AppColorTheme.pink, const Color(0xFFE8729A), 'ピンク'),
              const SizedBox(width: 16),
              _buildThemeDot(context, AppColorTheme.orange, const Color(0xFFF4845F), 'オレンジ'),
              const SizedBox(width: 16),
              _buildThemeDot(context, AppColorTheme.blue, const Color(0xFF5B9BD5), 'ブルー'),
              const SizedBox(width: 16),
              _buildThemeDot(context, AppColorTheme.dark, const Color(0xFF1A1A2E), 'ダーク'),
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
                    'ナイトモード',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '20:00〜6:00 自動ダーク',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSub,
                    ),
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
          // デフォルトタブ
          Text(
            'デフォルトのタブ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'アプリ起動時に表示するタブ',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSub,
            ),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            label: '母乳',
            icon: Icons.favorite_rounded,
            value: 'breastMilk',
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            label: 'ミルク',
            icon: Icons.local_drink_rounded,
            value: 'formula',
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildThemeDot(
    BuildContext context,
    AppColorTheme theme,
    Color color,
    String label,
  ) {
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
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.currentThemeColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = currentDefault == value;
    final colors = AppTheme.currentThemeColors;
    return GestureDetector(
      onTap: () {
        onDefaultChanged(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.12)
              : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colors.accent, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? colors.accent : colors.textSub),
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
              Icon(Icons.check_circle_rounded,
                  color: colors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
