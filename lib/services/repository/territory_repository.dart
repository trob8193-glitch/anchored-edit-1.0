import '../../models/territory.dart';

/// Abstract repository interface for territory data.
/// Concrete implementations: [FirestoreTerritoryRepository], [LocalTerritoryRepository].
abstract class TerritoryRepository {
  Stream<List<Territory>> watchTerritories();

  Future<void> claimTerritory({
    required String territoryId,
    required String ownerId,
    required String ownerDisplayName,
    required int color,
  });

  Future<void> releaseTerritory(String territoryId);

  /// Mark a territory as contested by [challengerUid].
  Future<void> contestTerritory({
    required String territoryId,
    required String challengerUid,
  });

  /// Resolve a contest — challenger takes ownership or contest is cancelled.
  Future<void> resolveContest({
    required String territoryId,
    required bool challengerWins,
    String? challengerUid,
    String? challengerDisplayName,
    int? challengerColor,
  });
}
