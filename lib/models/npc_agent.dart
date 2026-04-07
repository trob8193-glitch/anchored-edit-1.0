import 'package:latlong2/latlong.dart';
import 'faction.dart';

/// A single NPC unit on the map — soldier, captain, beast, or warlord.
class NpcAgent {
  const NpcAgent({
    required this.id,
    required this.name,
    required this.faction,
    required this.type,
    required this.lat,
    required this.lng,
    this.homeTerritoryId,
  });

  final String id;
  final String name;
  final Faction faction;
  final NpcType type;
  final double lat;
  final double lng;

  /// Optional territory this agent starts in and returns to
  final String? homeTerritoryId;

  LatLng get position => LatLng(lat, lng);

  int get power => faction.basePower + type.powerBonus;

  /// ownerId written into Territory when this agent claims it
  String get ownerId => 'npc_$id';

  /// Display name written into Territory.ownerDisplayName
  String get displayName => '${faction.tag} $name';

  String get fullTitle =>
      '${faction.emoji} ${faction.displayName} ${type.title} · ${type.stars}';

  NpcAgent copyWith({double? lat, double? lng, String? homeTerritoryId}) =>
      NpcAgent(
        id: id,
        name: name,
        faction: faction,
        type: type,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        homeTerritoryId: homeTerritoryId ?? this.homeTerritoryId,
      );
}
