import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/territory.dart';
import '../services/repository/firestore_territory_repository.dart';
import '../services/repository/local_territory_repository.dart';
import '../services/repository/territory_repository.dart';

// ── Firebase availability flag ────────────────────────────────────────────────

/// Set to true in main() if Firebase.initializeApp() succeeded.
final firebaseAvailableProvider = StateProvider<bool>((_) => false);

// ── Repository selection ──────────────────────────────────────────────────────

/// Picks [FirestoreTerritoryRepository] when Firebase is ready,
/// [LocalTerritoryRepository] otherwise (offline / demo mode).
final territoryRepositoryProvider = Provider<TerritoryRepository>((ref) {
  final firebaseReady = ref.watch(firebaseAvailableProvider);
  if (firebaseReady) {
    return FirestoreTerritoryRepository();
  }
  return LocalTerritoryRepository();
});

// ── Territories stream ────────────────────────────────────────────────────────

/// Live stream of all territories from whichever backend is active.
final territoriesProvider = StreamProvider<List<Territory>>((ref) {
  final repo = ref.watch(territoryRepositoryProvider);
  return repo.watchTerritories();
});

// ── Hierarchy provider ────────────────────────────────────────────────────────

/// Returns a map of parentId → list of direct child territories.
final territoryChildrenProvider =
    Provider<Map<String, List<Territory>>>((ref) {
  final territoriesAsync = ref.watch(territoriesProvider);
  return territoriesAsync.whenData((territories) {
    final Map<String, List<Territory>> map = {};
    for (final t in territories) {
      if (t.parentId != null) {
        map.putIfAbsent(t.parentId!, () => []).add(t);
      }
    }
    return map;
  }).valueOrNull ??
      {};
});

/// Returns the dominant owner of a parent territory based on child ownership.
/// Dominant = the player who owns the most children.
final territoryDominantOwnerProvider =
    Provider.family<String?, String>((ref, parentId) {
  final children = ref.watch(territoryChildrenProvider)[parentId] ?? [];
  if (children.isEmpty) return null;

  final owned = children.where((t) => t.isClaimed);
  if (owned.isEmpty) return null;

  final Map<String, int> counts = {};
  for (final t in owned) {
    counts[t.ownerId!] = (counts[t.ownerId!] ?? 0) + 1;
  }

  var maxCount = 0;
  String? dominant;
  for (final entry in counts.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      dominant = entry.key;
    }
  }
  return dominant;
});

// ── Claim / Release / Contest notifier ───────────────────────────────────────

class TerritoryNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> claim({
    required String territoryId,
    required String ownerId,
    required String ownerDisplayName,
    required int color,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(territoryRepositoryProvider).claimTerritory(
            territoryId: territoryId,
            ownerId: ownerId,
            ownerDisplayName: ownerDisplayName,
            color: color,
          ),
    );
  }

  Future<void> release(String territoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () =>
          ref.read(territoryRepositoryProvider).releaseTerritory(territoryId),
    );
  }

  Future<void> startContest({
    required String territoryId,
    required String challengerUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(territoryRepositoryProvider).contestTerritory(
            territoryId: territoryId,
            challengerUid: challengerUid,
          ),
    );
  }

  Future<void> resolveContest({
    required String territoryId,
    required bool challengerWins,
    String? challengerUid,
    String? challengerDisplayName,
    int? challengerColor,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(territoryRepositoryProvider).resolveContest(
            territoryId: territoryId,
            challengerWins: challengerWins,
            challengerUid: challengerUid,
            challengerDisplayName: challengerDisplayName,
            challengerColor: challengerColor,
          ),
    );
  }
}

final territoryNotifierProvider =
    NotifierProvider<TerritoryNotifier, AsyncValue<void>>(
  TerritoryNotifier.new,
);
