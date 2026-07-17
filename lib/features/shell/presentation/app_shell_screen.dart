import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../design_system/widget/bo_theme.dart';
import '../../home/presentation/home_screen.dart';
import '../../simulator/presentation/simulator_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  static const routeName = '/shell';

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 1; // Simulator tab (matches mock)

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: BoColors.scaffoldGray,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          SimulatorScreen(),
          _StubTab(icon: Icons.health_and_safety_outlined),
          _StubTab(icon: Icons.person_outline),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: BoColors.navIndicator,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navSimulator,
          ),
          NavigationDestination(
            icon: const Icon(Icons.health_and_safety_outlined),
            selectedIcon: const Icon(Icons.health_and_safety),
            label: l10n.navSupport,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

class _StubTab extends StatelessWidget {
  const _StubTab({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: BoColors.navy.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              l10n.comingSoon,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BoColors.navy,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
