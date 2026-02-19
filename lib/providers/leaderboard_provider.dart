import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/territory.dart';
import 'territory_provider.dart';

/// Stats computed for a single player.
class PlayerStats {
  const PlayerStats({
    required this.uid,
    required this.displayName,
    required this.color,
    required this.territories,
    required this.points,
  });

  final String uid;
  final String displayName;
  final int color;
  final List<Territory> territories;
  final int points;

  int get neighborhoodCount =>
      territories.where((t) => t.level == TerritoryLevel.neighborhood).length;
  int get cityCount =>
      territories.where((t) => t.level == TerritoryLevel.city).length;
  int get stateCount =>
      territories.where((t) => t.level == TerritoryLevel.state).length;
  int get countryCount =>
      territories.where((t) => t.level == TerritoryLevel.country).length;
  int get continentCount =>
      territories.where((t) => t.level == TerritoryLevel.continent).length;
}

/// Derives a ranked leaderboard from live territory data.
final leaderboardProvider = Provider<AsyncValue<List<PlayerStats>>>((ref) {
  final territoriesAsync = ref.watch(territoriesProvider);

  return territoriesAsync.whenData((territories) {
    final claimed = territories.where((t) => t.isClaimed);

    // Group by owner
    final Map<String, List<Territory>> byPlayer = {};
    for (final t in claimed) {
      byPlayer.putIfAbsent(t.ownerId!, () => []).add(t);
    }

    final stats = byPlayer.entries.map((entry) {
      final list = entry.value;
      final first = list.first;
      final points = list.fold(0, (sum, t) => sum + t.points);
      return PlayerStats(
        uid: entry.key,
        displayName: first.ownerDisplayName ?? 'Unknown',
        color: first.color ?? 0xFF00C2FF,
        territories: list,
        points: points,
      );
    }).toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    return stats;
  });
});
