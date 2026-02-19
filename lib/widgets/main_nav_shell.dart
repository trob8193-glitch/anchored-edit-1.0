import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';

/// Main navigation shell with a bottom nav bar linking Map, Leaderboard, Profile.
class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    MapScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withAlpha(50),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primary),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon:
                Icon(Icons.emoji_events, color: AppTheme.primary),
            label: 'Rankings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
