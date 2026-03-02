import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/local_storage.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  await LocalStorage.init();
  runApp(const ProviderScope(child: MilkRecordApp()));
}

class MilkRecordApp extends ConsumerWidget {
  const MilkRecordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    return MaterialApp(
      title: '授乳きろく',
      theme: AppTheme.buildTheme(themeState.colors),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
