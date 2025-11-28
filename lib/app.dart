import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';

import 'core/providers/startup_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

class StudyCompanionApp extends ConsumerWidget {
  const StudyCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch startup provider
    final startupAsync = ref.watch(startupProvider);

    return startupAsync.when(
      data: (_) {
        final router = ref.watch(routerProvider);
        final themeModeAsync = ref.watch(themeNotifierProvider);

        return MaterialApp.router(
          title: 'Study Companion OS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeModeAsync.value ?? ThemeMode.system,
          routerConfig: router,
        );
      },
      loading: () => const MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $error'),
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
