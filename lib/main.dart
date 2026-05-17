import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:techladder/core/router/app_router.dart';
import 'package:techladder/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();
  await Hive.openBox('guest_progress');
  await Hive.openBox('yt_cache');
  await Hive.openBox('gh_cache');
  await Hive.openBox('lc_cache');

  runApp(
    const ProviderScope(child: TechLadderApp()),
  );
}

class TechLadderApp extends StatelessWidget {
  const TechLadderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TechLadder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
