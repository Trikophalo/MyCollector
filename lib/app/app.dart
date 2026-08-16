import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/collection/add_holding_screen.dart';
import '../features/collection/collection_screen.dart';
import '../features/portfolio/portfolio_screen.dart';
import '../features/settings/settings_screen.dart';
import '../ui/theme/app_theme.dart';
import 'providers.dart';

class MyCollectorApp extends ConsumerWidget {
  const MyCollectorApp({this.fontFamily, super.key});

  /// Bleibt im Betrieb leer, damit jede Plattform ihre Systemschrift nutzt.
  /// Bildvergleichstests setzen den Wert, um lesbaren Text statt der
  /// Platzhalterschrift der Testumgebung zu erhalten.
  final String? fontFamily;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'MyCollector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(fontFamily: fontFamily),
      darkTheme: AppTheme.dark(fontFamily: fontFamily),
      themeMode: settings.themeMode,
      home: const AppShell(),
      routes: {'/add': (_) => const AddHoldingScreen()},
    );
  }
}

/// Rahmen der App.
///
/// Auf schmalen Fenstern eine Tab-Leiste, ab Tablet-/Desktopbreite eine
/// Seitenleiste (§5.5) — dieselben Screens, andere Schale.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _destinations = [
    (
      icon: Icons.pie_chart_outline_rounded,
      selected: Icons.pie_chart_rounded,
      label: 'Portfolio',
    ),
    (
      icon: Icons.style_outlined,
      selected: Icons.style_rounded,
      label: 'Sammlung',
    ),
    (
      icon: Icons.settings_outlined,
      selected: Icons.settings_rounded,
      label: 'Einstellungen',
    ),
  ];

  Widget _screenFor(int index) => switch (index) {
    0 => const PortfolioScreen(),
    1 => const CollectionScreen(),
    _ => const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final colors = context.colors;

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      child: KeyedSubtree(key: ValueKey(_index), child: _screenFor(_index)),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              backgroundColor: colors.surface,
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selected),
                    label: Text(destination.label),
                  ),
              ],
            ),
            VerticalDivider(width: 0.5, color: colors.separator),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selected),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
