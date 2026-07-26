import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../users/presentation/users_screen.dart';
import '../logs/presentation/logs_screen.dart';
import '../settings/presentation/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _index = 0;

  static const _titles = <String>['داشبورد', 'کاربران', 'لاگ‌ها', 'تنظیمات'];

  static const _pages = <Widget>[
    DashboardScreen(),
    UsersScreen(),
    LogsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: _buildActions(),
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'داشبورد',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'کاربران',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'لاگ‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    switch (_index) {
      case 0:
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'به‌روزرسانی',
            onPressed: () => ref.read(statsNotifierProvider.notifier).refresh(),
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'به‌روزرسانی',
            onPressed: () => ref.read(usersNotifierProvider.notifier).refresh(),
          ),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'به‌روزرسانی',
            onPressed: () => ref.read(logsNotifierProvider.notifier).refresh(),
          ),
        ];
      default:
        return const [];
    }
  }
}
