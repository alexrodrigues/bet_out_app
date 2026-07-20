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
        ],
      ),
    );
  }
}
