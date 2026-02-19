import 'package:cloud_firestore/cloud_firestore.dart';

/// Geographic hierarchy level of a territory zone.
enum TerritoryLevel {
  neighborhood,
  city,
  state,
  country,
  continent;

  String get displayName => switch (this) {
        TerritoryLevel.neighborhood => 'Neighborhood',
        TerritoryLevel.city => 'City',
        TerritoryLevel.state => 'State',
        TerritoryLevel.country => 'Country',
        TerritoryLevel.continent => 'Continent',
      };

  int get points => switch (this) {
        TerritoryLevel.neighborhood => 1,
        TerritoryLevel.city => 5,
        TerritoryLevel.state => 20,
        TerritoryLevel.country => 100,
        TerritoryLevel.continent => 500,
      };
}

/// Represents a claimable territory zone on the map.
class Territory {
  const Territory({
    required this.id,
    required this.name,
    required this.level,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    this.parentId,
    this.ownerId,
    this.ownerDisplayName,
    this.claimedAt,
    this.color,
    this.isContested = false,
    this.contestedByUid,
    this.contestedAt,
  });

  final String id;
  final String name;
  final TerritoryLevel level;
  final double lat;
  final double lng;
  final double radiusMeters;

  /// ID of the parent territory in the hierarchy (e.g. neighborhood → city).
  final String? parentId;

  final String? ownerId;
  final String? ownerDisplayName;
  final DateTime? claimedAt;
  final int? color; // stored as ARGB int

  /// True when another player is actively challenging this territory.
  final bool isContested;
  final String? contestedByUid;
  final DateTime? contestedAt;

  bool get isClaimed => ownerId != null;

  /// Points value for this territory.
  int get points => level.points;

  Territory copyWith({
    String? id,
    String? name,
    TerritoryLevel? level,
    double? lat,
    double? lng,
    double? radiusMeters,
    String? parentId,
    Object? ownerId = _sentinel,
    Object? ownerDisplayName = _sentinel,
    Object? claimedAt = _sentinel,
    Object? color = _sentinel,
    bool? isContested,
    Object? contestedByUid = _sentinel,
    Object? contestedAt = _sentinel,
  }) {
    return Territory(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      parentId: parentId ?? this.parentId,
      ownerId: ownerId == _sentinel ? this.ownerId : ownerId as String?,
      ownerDisplayName: ownerDisplayName == _sentinel
          ? this.ownerDisplayName
          : ownerDisplayName as String?,
      claimedAt:
          claimedAt == _sentinel ? this.claimedAt : claimedAt as DateTime?,
      color: color == _sentinel ? this.color : color as int?,
      isContested: isContested ?? this.isContested,
      contestedByUid: contestedByUid == _sentinel
          ? this.contestedByUid
          : contestedByUid as String?,
      contestedAt: contestedAt == _sentinel
          ? this.contestedAt
          : contestedAt as DateTime?,
    );
  }

  factory Territory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Territory(
      id: doc.id,
      name: data['name'] as String,
      level: TerritoryLevel.values.firstWhere(
        (e) => e.name == (data['level'] as String),
        orElse: () => TerritoryLevel.neighborhood,
      ),
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      radiusMeters: (data['radiusMeters'] as num).toDouble(),
      parentId: data['parentId'] as String?,
      ownerId: data['ownerId'] as String?,
      ownerDisplayName: data['ownerDisplayName'] as String?,
      claimedAt: data['claimedAt'] != null
          ? (data['claimedAt'] as Timestamp).toDate()
          : null,
      color: data['color'] as int?,
      isContested: data['isContested'] as bool? ?? false,
      contestedByUid: data['contestedByUid'] as String?,
      contestedAt: data['contestedAt'] != null
          ? (data['contestedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'level': level.name,
        'lat': lat,
        'lng': lng,
        'radiusMeters': radiusMeters,
        'parentId': parentId,
        'ownerId': ownerId,
        'ownerDisplayName': ownerDisplayName,
        'claimedAt':
            claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
        'color': color,
        'isContested': isContested,
        'contestedByUid': contestedByUid,
        'contestedAt':
            contestedAt != null ? Timestamp.fromDate(contestedAt!) : null,
      };
}

// Sentinel for optional nullable copyWith params
const Object _sentinel = Object();
