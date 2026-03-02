import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../theme/app_theme.dart';

class RecordList extends ConsumerWidget {
  const RecordList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(feedingRecordsProvider);

    if (records.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 48,
              color: AppTheme.currentThemeColors.textSub.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'まだ記録がありません',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.currentThemeColors.textSub.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // 日付ごとにグループ化
    final grouped = _groupByDate(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          // 日付ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              _formatDateHeader(entry.key),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.currentThemeColors.textSub,
              ),
            ),
          ),
          // その日の記録
          ...entry.value.map((record) => _buildRecordItem(context, ref, record)),
        ],
      ],
    );
  }

  Map<String, List<FeedingRecord>> _groupByDate(List<FeedingRecord> records) {
    final map = <String, List<FeedingRecord>>{};
    for (final record in records) {
      final key = DateFormat('yyyy-MM-dd').format(record.startedAt);
      map.putIfAbsent(key, () => []).add(record);
    }
    return map;
  }

  String _formatDateHeader(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'きょう';
    if (target == today.subtract(const Duration(days: 1))) return 'きのう';
    return DateFormat('M月d日（E）', 'ja').format(date);
  }

  Widget _buildRecordItem(
      BuildContext context, WidgetRef ref, FeedingRecord record) {
    final colors = AppTheme.currentThemeColors;
    final type = record.feedingType;

    // Determine icon and colors based on type
    IconData icon;
    Color iconColor;
    Color iconBgColor;
    String title;
    String? subtitle;

    switch (type) {
      case FeedingType.breastMilk:
        icon = Icons.favorite_rounded;
        iconColor = colors.accent;
        iconBgColor = colors.iconBreastBg;
        title = '母乳（${record.breastSide == BreastSide.left ? "ひだり" : "みぎ"}）';
        subtitle = record.displayTime;
      case FeedingType.formula:
        icon = Icons.local_drink_rounded;
        iconColor = const Color(0xFFFFB347);
        iconBgColor = colors.iconFormulaBg;
        title = 'ミルク ${record.amountMl}ml';
        subtitle = record.displayTime;
      case FeedingType.spitUp:
        icon = Icons.arrow_upward_rounded;
        iconColor = colors.red;
        iconBgColor = colors.red.withValues(alpha: 0.12);
        title = '吐き戻し（${_spitUpLabel(record.spitUpAmount)}）';
        subtitle = null;
    }

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('削除の確認'),
            content: const Text('この記録を削除しますか？'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: colors.textSub),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  '削除',
                  style: TextStyle(color: colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(feedingRecordsProvider.notifier).removeRecord(record.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // アイコン
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            // 詳細
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSub,
                      ),
                    ),
                ],
              ),
            ),
            // 時刻
            Text(
              record.displayStartTime,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _spitUpLabel(String? amount) {
    switch (amount) {
      case 'small':
        return '少量';
      case 'medium':
        return '中量';
      case 'large':
        return '大量';
      default:
        return '不明';
    }
  }
}
