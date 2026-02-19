import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/territory.dart';
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/territory_provider.dart';
import '../screens/auth_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = !ref.watch(firebaseAvailableProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final boardAsync = ref.watch(leaderboardProvider);

    final uid = user?.uid ?? (isOffline ? 'offline_guest' : null);

    final myStats = boardAsync.whenOrNull(
      data: (players) =>
          players.where((p) => p.uid == uid).firstOrNull,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        actions: [
          if (!isOffline && user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.danger),
              tooltip: 'Sign out',
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AvatarCard(
              uid: uid,
              displayName: user?.displayName ??
                  (isOffline ? 'Offline Player' : 'Guest'),
              isOffline: isOffline,
              isAnonymous: user?.isAnonymous ?? true,
            ),
            const SizedBox(height: 24),
            if (myStats != null) ...[
              _StatsGrid(stats: myStats),
              const SizedBox(height: 24),
              _TerritoryList(territories: myStats.territories),
            ] else ...[
              _NoClaimsCard(isOffline: isOffline),
            ],
            if (!isOffline && user == null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('SIGN IN TO SAVE PROGRESS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.uid,
    required this.displayName,
    required this.isOffline,
    required this.isAnonymous,
  });

  final String? uid;
  final String displayName;
  final bool isOffline;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.primary.withAlpha(40),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isOffline)
                      _Tag('OFFLINE', Colors.orange)
                    else if (isAnonymous)
                      _Tag('GUEST', Colors.white38)
                    else
                      _Tag('MEMBER', AppTheme.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(150)),
        color: color.withAlpha(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('POINTS', '${stats.points}', AppTheme.primary),
      _StatItem('TOTAL',
          '${stats.territories.length}', Colors.white70),
      _StatItem(
          'CONTINENTS', '${stats.continentCount}', const Color(0xFFFF6B35)),
      _StatItem(
          'COUNTRIES', '${stats.countryCount}', const Color(0xFF9B59B6)),
      _StatItem('STATES', '${stats.stateCount}', const Color(0xFF3498DB)),
      _StatItem('CITIES', '${stats.cityCount}', const Color(0xFF2ECC71)),
      _StatItem(
          'HOODS', '${stats.neighborhoodCount}', AppTheme.primary),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: items,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.8,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TerritoryList extends StatelessWidget {
  const _TerritoryList({required this.territories});
  final List<Territory> territories;

  @override
  Widget build(BuildContext context) {
    if (territories.isEmpty) return const SizedBox.shrink();

    final sorted = [...territories]
      ..sort((a, b) => b.level.index.compareTo(a.level.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CLAIMED TERRITORIES',
          style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...sorted.map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Text(t.level.displayName,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Text(
                  '+${t.points}pts',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoClaimsCard extends StatelessWidget {
  const _NoClaimsCard({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined,
              size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'No territories claimed yet.',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            isOffline
                ? 'Use the map to walk to a zone and anchor it.'
                : 'Head to the map and start claiming zones!',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
