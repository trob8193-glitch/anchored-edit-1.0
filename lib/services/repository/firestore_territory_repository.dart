import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/territory.dart';
import 'territory_repository.dart';

/// Live Firestore-backed territory repository.
class FirestoreTerritoryRepository implements TerritoryRepository {
  FirestoreTerritoryRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.territoriesCollection);

  @override
  Stream<List<Territory>> watchTerritories() {
    return _col.snapshots().map(
          (snap) => snap.docs.map(Territory.fromFirestore).toList(),
        );
  }

  @override
  Future<void> claimTerritory({
    required String territoryId,
    required String ownerId,
    required String ownerDisplayName,
    required int color,
  }) async {
    await _col.doc(territoryId).update({
      'ownerId': ownerId,
      'ownerDisplayName': ownerDisplayName,
      'claimedAt': FieldValue.serverTimestamp(),
      'color': color,
    });
  }

  @override
  Future<void> releaseTerritory(String territoryId) async {
    await _col.doc(territoryId).update({
      'ownerId': null,
      'ownerDisplayName': null,
      'claimedAt': null,
      'color': null,
      'isContested': false,
      'contestedByUid': null,
      'contestedAt': null,
    });
  }

  @override
  Future<void> contestTerritory({
    required String territoryId,
    required String challengerUid,
  }) async {
    await _col.doc(territoryId).update({
      'isContested': true,
      'contestedByUid': challengerUid,
      'contestedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> resolveContest({
    required String territoryId,
    required bool challengerWins,
    String? challengerUid,
    String? challengerDisplayName,
    int? challengerColor,
  }) async {
    if (challengerWins &&
        challengerUid != null &&
        challengerDisplayName != null) {
      await _col.doc(territoryId).update({
        'ownerId': challengerUid,
        'ownerDisplayName': challengerDisplayName,
        'claimedAt': FieldValue.serverTimestamp(),
        'color': challengerColor,
        'isContested': false,
        'contestedByUid': null,
        'contestedAt': null,
      });
    } else {
      await _col.doc(territoryId).update({
        'isContested': false,
        'contestedByUid': null,
        'contestedAt': null,
      });
    }
  }

  /// One-time seed: write initial territory documents to Firestore.
  Future<void> seed(List<Territory> territories) async {
    final batch = _db.batch();
    for (final t in territories) {
      batch.set(_col.doc(t.id), t.toFirestore());
    }
    await batch.commit();
  }
}
