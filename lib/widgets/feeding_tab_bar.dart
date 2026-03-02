import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class FeedingTabBar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const FeedingTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);
    final s = ref.watch(stringsProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.gray,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTab(0, s.breastMilk, Icons.favorite_rounded, colors),
          _buildTab(1, s.formula, Icons.local_drink_rounded, colors),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon, ThemeColors colors) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [BoxShadow(color: colors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? colors.accent : colors.textSub),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colors.accent : colors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
