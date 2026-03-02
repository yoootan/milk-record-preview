import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feeding_record.dart';
import '../services/local_storage.dart';

// 記録一覧のプロバイダー
final feedingRecordsProvider =
    NotifierProvider<FeedingRecordsNotifier, List<FeedingRecord>>(
        FeedingRecordsNotifier.new);

class FeedingRecordsNotifier extends Notifier<List<FeedingRecord>> {
  @override
  List<FeedingRecord> build() {
    return LocalStorage.getAllRecords();
  }

  Future<void> addRecord(FeedingRecord record) async {
    await LocalStorage.saveRecord(record);
    state = LocalStorage.getAllRecords();
  }

  Future<void> removeRecord(String id) async {
    await LocalStorage.deleteRecord(id);
    state = LocalStorage.getAllRecords();
  }
}

// デフォルトタブのプロバイダー
final defaultTabProvider =
    NotifierProvider<DefaultTabNotifier, String>(DefaultTabNotifier.new);

class DefaultTabNotifier extends Notifier<String> {
  @override
  String build() {
    return LocalStorage.getDefaultTab();
  }

  Future<void> setDefaultTab(String tab) async {
    await LocalStorage.setDefaultTab(tab);
    state = tab;
  }
}
