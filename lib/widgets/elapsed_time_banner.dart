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

    // Find last breast milk or formula record (not spit up)
    final feedRecords = records.where(
      (r) => r.feedingType == FeedingType.breastMilk || r.feedingType == FeedingType.formula,
    );

    if (feedRecords.isEmpty) return const SizedBox.shrink();

    final last = feedRecords.first; // records are sorted newest first
    final elapsed = DateTime.now().difference(last.endedAt);

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    String timeStr;
    if (hours > 0) {
      timeStr = '${hours}h${minutes.toString().padLeft(2, '0')}m';
    } else {
      timeStr = '${minutes}m';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_rounded, size: 14, color: colors.accent),
          const SizedBox(width: 6),
          Text(
            s.elapsedSinceLastFeed(timeStr),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
