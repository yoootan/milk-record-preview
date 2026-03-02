import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../services/local_storage.dart';

final localeProvider =
    NotifierProvider<LocaleNotifier, String>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    return LocalStorage.getLocale();
  }

  void setLocale(String locale) {
    LocalStorage.setLocale(locale);
    state = locale;
  }
}

// Convenience provider for current strings
final stringsProvider = Provider<AppStringBase>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings.forLocale(locale);
});
