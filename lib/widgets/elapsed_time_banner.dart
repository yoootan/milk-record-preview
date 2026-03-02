import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feeding_record.dart';
import '../providers/feeding_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class ElapsedTimeBanner extends ConsumerStatefulWidget {
  const ElapsedTimeBanner({super.key});

  @override
  ConsumerState<ElapsedTimeBanner> createState() => _ElapsedTimeBannerState();
}

class _ElapsedTimeBannerState extends ConsumerState<ElapsedTimeBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(feedingRecordsProvider);
    final colors = ref.watch(colorsProvider);
    final s = ref.watch(stringsProvider);

    final feedRecords = records.where(
      (r) => r.feedingType == FeedingType.breastMilk || r.feedingType == FeedingType.formula,
    );

    if (feedRecords.isEmpty) return const SizedBox.shrink();

    final last = feedRecords.first;
    final elapsed = DateTime.now().difference(last.endedAt);

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    String timeStr;
    if (hours > 0) {
      timeStr = '${hours}h${minutes.toString().padLeft(2, '0')}m';
    } else {
      timeStr = '${minutes}m';
    }

    // Build last feed detail
    String lastDetail;
    if (last.feedingType == FeedingType.breastMilk) {
      final side = last.breastSide == BreastSide.left ? s.left : s.right;
      lastDetail = s.lastFeedBreast(side, last.displayTime);
    } else {
      lastDetail = s.lastFeedFormula(last.amountMl ?? 0);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: colors.textSub.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(
            s.elapsedSinceLastFeed(timeStr),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textSub.withValues(alpha: 0.7),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: colors.textSub.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            lastDetail,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.textSub.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
