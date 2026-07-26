import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../dashboard/application/stats_state.dart';
import '../users/presentation/users_screen.dart';
import '../users/presentation/user_form_screen.dart';
import '../settings/presentation/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _index = 0;

  static const _pages = <Widget>[
    DashboardScreen(),
    UsersScreen(),
    SettingsScreen(),
  ];

  Future<void> _refreshDashboard() async {
    await ref.read(statsNotifierProvider.notifier).refresh();
    if (!mounted) return;
    final st = ref.read(statsNotifierProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          st.status == StatsStatus.error
              ? 'خطا در به‌روزرسانی'
              : 'به‌روزرسانی شد',
        ),
        duration: const Duration(milliseconds: 900),
        backgroundColor:
            st.status == StatsStatus.error ? Colors.red : Colors.green,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_index) {
      case 0:
        final state = ref.watch(statsNotifierProvider);
        final isRefreshing =
            state.status == StatsStatus.loading && state.stats != null;
        return AppBar(
          title: const Text('داشبورد'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: isRefreshing ? null : _refreshDashboard,
            ),
          ],
        );
      case 1:
        return AppBar(title: const Text('کاربران'));
      default:
        return AppBar(title: const Text('تنظیمات'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _index == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserFormScreen()),
              ),
              child: const Icon(Icons.person_add),
            )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: _pages,
        ),
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
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}
