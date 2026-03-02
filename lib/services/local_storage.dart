import 'package:hive_flutter/hive_flutter.dart';
import '../models/feeding_record.dart';
import '../theme/app_theme.dart';

class LocalStorage {
  static const String _recordsBoxName = 'feeding_records';
  static const String _settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FeedingRecordAdapter());
    await Hive.openBox<FeedingRecord>(_recordsBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  static Box<FeedingRecord> get recordsBox =>
      Hive.box<FeedingRecord>(_recordsBoxName);

  static Box get settingsBox => Hive.box(_settingsBoxName);

  // 記録の保存
  static Future<void> saveRecord(FeedingRecord record) async {
    await recordsBox.put(record.id, record);
  }

  // 記録の削除
  static Future<void> deleteRecord(String id) async {
    await recordsBox.delete(id);
  }

  // 全記録の取得（新しい順）
  static List<FeedingRecord> getAllRecords() {
    final records = recordsBox.values.toList();
    records.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return records;
  }

  // デフォルトタブの保存・取得
  static Future<void> setDefaultTab(String tab) async {
    await settingsBox.put('defaultTab', tab);
  }

  static String getDefaultTab() {
    return settingsBox.get('defaultTab', defaultValue: 'breastMilk') as String;
  }

  // カラーテーマの保存・取得
  static Future<void> setColorTheme(AppColorTheme theme) async {
    await settingsBox.put('colorTheme', theme.name);
  }

  static AppColorTheme getColorTheme() {
    final name = settingsBox.get('colorTheme', defaultValue: 'pink') as String;
    return AppColorTheme.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppColorTheme.pink,
    );
  }

  // ナイトモードの保存・取得
  static Future<void> setNightMode(bool enabled) async {
    await settingsBox.put('nightMode', enabled);
  }

  static bool getNightMode() {
    return settingsBox.get('nightMode', defaultValue: false) as bool;
  }
}
