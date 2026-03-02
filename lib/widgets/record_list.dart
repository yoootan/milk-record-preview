import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class RecordList extends ConsumerWidget {
  const RecordList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(feedingRecordsProvider);
    final s = ref.watch(stringsProvider);
    final colors = ref.watch(colorsProvider);

    if (records.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.edit_note_rounded,
              size: 48,
              color: colors.textSub.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              s.noRecords,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSub.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDate(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Text(
                  _formatDateHeader(entry.key, s),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textSub,
                  ),
                ),
                const Spacer(),
                ..._buildDailySummary(entry.value, s, colors),
              ],
            ),
          ),
          ...entry.value.map((record) => _buildRecordItem(context, ref, record, s)),
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

  String _formatDateHeader(String dateStr, dynamic s) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return s.today;
    if (target == today.subtract(const Duration(days: 1))) return s.yesterday;
    return DateFormat('M月d日（E）', 'ja').format(date);
  }

  Widget _buildRecordItem(
      BuildContext context, WidgetRef ref, FeedingRecord record, dynamic s) {
    final colors = ref.watch(colorsProvider);
    final type = record.feedingType;

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
        final side = record.breastSide == BreastSide.left ? s.left : s.right;
        title = '${s.breastMilk}（$side）';
        subtitle = record.displayTime;
      case FeedingType.formula:
        icon = Icons.local_drink_rounded;
        iconColor = const Color(0xFFFFB347);
        iconBgColor = colors.iconFormulaBg;
        title = '${s.formula} ${record.amountMl}ml';
        subtitle = null;
      case FeedingType.spitUp:
        icon = Icons.arrow_upward_rounded;
        iconColor = colors.red;
        iconBgColor = colors.red.withValues(alpha: 0.12);
        title = '${s.spitUp}（${_spitUpLabel(record.spitUpAmount, s)}）';
        subtitle = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(subtitle, style: TextStyle(fontSize: 11, color: colors.textSub)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              record.displayStartTime,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSub),
            ),
          ),
          GestureDetector(
            onTap: () => _showDeleteConfirm(context, ref, record, colors, s),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.close_rounded, size: 14, color: colors.textSub.withValues(alpha: 0.4)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    WidgetRef ref,
    FeedingRecord record,
    ThemeColors colors,
    dynamic s,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colors.bg,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.deleteTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 6),
              Text(
                s.deleteMessage,
                style: TextStyle(fontSize: 13, color: colors.textSub, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: colors.gray,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            s.cancel,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.text),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(feedingRecordsProvider.notifier).removeRecord(record.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: colors.red,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            s.delete,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDailySummary(List<FeedingRecord> records, dynamic s, ThemeColors colors) {
    final widgets = <Widget>[];

    // 母乳合計時間
    final breastSeconds = records
        .where((r) => r.feedingType == FeedingType.breastMilk)
        .fold<int>(0, (sum, r) => sum + r.durationSeconds);

    // ミルク合計ml
    final formulaMl = records
        .where((r) => r.feedingType == FeedingType.formula)
        .fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));

    if (breastSeconds > 0) {
      final min = breastSeconds ~/ 60;
      final sec = breastSeconds % 60;
      final duration = min > 0
          ? (sec > 0 ? '${min}m${sec}s' : '${min}m')
          : '${sec}s';
      widgets.add(
        Text(
          s.dailyBreastTotal(duration),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.accent),
        ),
      );
    }

    if (formulaMl > 0) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(width: 8));
      }
      widgets.add(
        Text(
          s.dailyFormulaTotal(formulaMl),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFFFB347)),
        ),
      );
    }

    return widgets;
  }

  String _spitUpLabel(String? amount, dynamic s) {
    switch (amount) {
      case 'small': return s.spitUpSmall;
      case 'medium': return s.spitUpMedium;
      case 'large': return s.spitUpLarge;
      default: return '?';
    }
  }
}
