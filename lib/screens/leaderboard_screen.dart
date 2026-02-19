import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/territory.dart';
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/territory_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(leaderboardProvider);
    final isOffline = !ref.watch(firebaseAvailableProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        actions: [
          if (isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'OFFLINE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Color(0xFF3A2A00),
                side: BorderSide(color: Colors.orange, width: 1),
              ),
            ),
        ],
      ),
      body: boardAsync.when(
        data: (players) => players.isEmpty
            ? _EmptyBoard(isOffline: isOffline)
            : _BoardList(
                players: players,
                currentUid:
                    currentUser?.uid ?? (isOffline ? 'offline_guest' : null),
              ),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppTheme.danger)),
        ),
      ),
    );
  }
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_outlined,
              size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No territories claimed yet.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isOffline
                ? 'Walk to a zone and tap Anchor to claim it.'
                : 'Be the first to anchor a territory!',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BoardList extends StatelessWidget {
  const _BoardList({required this.players, required this.currentUid});
  final List<PlayerStats> players;
  final String? currentUid;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: players.length,
      itemBuilder: (ctx, i) {
        final p = players[i];
        final isMe = p.uid == currentUid;
        final rank = i + 1;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isMe
                ? AppTheme.primary.withAlpha(30)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMe ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: ListTile(
            leading: _RankBadge(rank: rank),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    p.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isMe ? AppTheme.primary : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMe)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Chip(
                      label: Text('YOU',
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.bold)),
                      backgroundColor: AppTheme.primary,
                      labelStyle: TextStyle(color: Colors.black),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            subtitle: _TerritoryBreakdown(stats: p),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${p.points}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const Text('pts',
                    style: TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (rank) {
      1 => (const Color(0xFFFFD700), Icons.emoji_events),
      2 => (const Color(0xFFC0C0C0), Icons.emoji_events),
      3 => (const Color(0xFFCD7F32), Icons.emoji_events),
      _ => (Colors.white30, Icons.person_outline),
    };
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withAlpha(30),
      child: rank <= 3
          ? Icon(icon, color: color, size: 18)
          : Text(
              '$rank',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
    );
  }
}

class _TerritoryBreakdown extends StatelessWidget {
  const _TerritoryBreakdown({required this.stats});
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final parts = <_LevelChip>[];
    if (stats.continentCount > 0) {
      parts.add(_LevelChip('×${stats.continentCount} Continent',
          TerritoryLevel.continent));
    }
    if (stats.countryCount > 0) {
      parts.add(
          _LevelChip('×${stats.countryCount} Country', TerritoryLevel.country));
    }
    if (stats.stateCount > 0) {
      parts.add(
          _LevelChip('×${stats.stateCount} State', TerritoryLevel.state));
    }
    if (stats.cityCount > 0) {
      parts.add(_LevelChip('×${stats.cityCount} City', TerritoryLevel.city));
    }
    if (stats.neighborhoodCount > 0) {
      parts.add(_LevelChip('×${stats.neighborhoodCount} Hood',
          TerritoryLevel.neighborhood));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 4, runSpacing: 2, children: parts),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip(this.label, this.level);
  final String label;
  final TerritoryLevel level;

  static Color _colorFor(TerritoryLevel l) => switch (l) {
        TerritoryLevel.continent => const Color(0xFFFF6B35),
        TerritoryLevel.country => const Color(0xFF9B59B6),
        TerritoryLevel.state => const Color(0xFF3498DB),
        TerritoryLevel.city => const Color(0xFF2ECC71),
        TerritoryLevel.neighborhood => AppTheme.primary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}
