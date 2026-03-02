import 'package:hive/hive.dart';

part 'feeding_record.g.dart';

enum FeedingType { breastMilk, formula, spitUp }

enum BreastSide { left, right }

@HiveType(typeId: 0)
class FeedingRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'breastMilk', 'formula', or 'spitUp'

  @HiveField(2)
  final String? side; // 'left' or 'right'

  @HiveField(3)
  final int durationSeconds;

  @HiveField(4)
  final int? amountMl;

  @HiveField(5)
  final DateTime startedAt;

  @HiveField(6)
  final DateTime endedAt;

  @HiveField(7)
  final String? spitUpAmount; // 'small', 'medium', 'large'

  FeedingRecord({
    required this.id,
    required this.type,
    this.side,
    required this.durationSeconds,
    this.amountMl,
    required this.startedAt,
    required this.endedAt,
    this.spitUpAmount,
  });

  FeedingType get feedingType {
    switch (type) {
      case 'breastMilk':
        return FeedingType.breastMilk;
      case 'spitUp':
        return FeedingType.spitUp;
      default:
        return FeedingType.formula;
    }
  }

  BreastSide? get breastSide {
    if (side == null) return null;
    return side == 'left' ? BreastSide.left : BreastSide.right;
  }

  String get displayTime {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0) {
      return seconds > 0 ? '$minutes分$seconds秒' : '$minutes分';
    }
    return '$seconds秒';
  }

  String get displayStartTime {
    final h = startedAt.hour.toString().padLeft(2, '0');
    final m = startedAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
