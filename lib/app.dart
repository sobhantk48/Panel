import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'core/settings/app_settings.dart';
import 'features/auth/application/auth_notifier.dart';
import 'features/auth/application/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/main/main_screen.dart';

class PanelApp extends ConsumerWidget {
  const PanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'پنل نهان',
      debugShowCheckedModeBanner: false,

      // تم روشن
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),

      // تم تاریک
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // تم فعال از تنظیمات خوانده می‌شود
      themeMode: settings.themeMode,

      // زبان فعال از تنظیمات خوانده می‌شود
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,

      // دلیگیت ترجمه‌های خودمان + دلیگیت‌های داخلی فلاتر
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // نکته: Directionality دستی حذف شد.
      // MaterialApp خودش از روی locale جهت درست (RTL برای fa / LTR برای en) را اعمال می‌کند.
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authNotifierProvider.notifier).checkSavedSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(authNotifierProvider).status;

    switch (status) {
      case AuthStatus.authenticated:
        return const MainScreen();
      case AuthStatus.loading:
      case AuthStatus.initial:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}
