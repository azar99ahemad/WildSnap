import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection_container.dart';
import 'app_theme.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initDependencies();
  
  runApp(
    const ProviderScope(
      child: WildSnapProApp(),
    ),
  );
}

/// Main app widget
class WildSnapProApp extends StatelessWidget {
  const WildSnapProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildSnap Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
