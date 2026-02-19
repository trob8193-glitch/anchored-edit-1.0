import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/territory.dart';

/// All Firestore read/write operations for territories.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _territories =>
      _db.collection(AppConstants.territoriesCollection);

  /// Real-time stream of all territory documents.
  Stream<List<Territory>> watchTerritories() {
    return _territories.snapshots().map(
          (snap) =>
              snap.docs.map(Territory.fromFirestore).toList(),
        );
  }

  /// Claim a territory on behalf of a player.
  Future<void> claimTerritory({
    required String territoryId,
    required String ownerId,
    required String ownerDisplayName,
    required int color,
  }) async {
    await _territories.doc(territoryId).update({
      'ownerId': ownerId,
      'ownerDisplayName': ownerDisplayName,
      'claimedAt': FieldValue.serverTimestamp(),
      'color': color,
    });
  }

  /// Release (un-anchor) a territory.
  Future<void> releaseTerritory(String territoryId) async {
    await _territories.doc(territoryId).update({
      'ownerId': null,
      'ownerDisplayName': null,
      'claimedAt': null,
      'color': null,
    });
  }

  /// Seed initial territory data (call once during development).
  Future<void> seedTerritories(List<Territory> territories) async {
    final batch = _db.batch();
    for (final t in territories) {
      batch.set(_territories.doc(t.id), t.toFirestore());
    }
    await batch.commit();
  }
}
