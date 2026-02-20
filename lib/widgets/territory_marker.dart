import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/territory.dart';
import '../models/npc_agent.dart';

/// Renders circle markers for a list of territory zones.
class TerritoryLayerWidget extends StatelessWidget {
  const TerritoryLayerWidget({
    super.key,
    required this.territories,
    this.onTap,
  });

  final List<Territory> territories;
  final void Function(Territory)? onTap;

  static Color _levelBorderColor(TerritoryLevel level) => switch (level) {
        TerritoryLevel.continent => const Color(0xFFFF6B35),  // hot orange
        TerritoryLevel.country  => const Color(0xFFBF5FFF),  // neon purple
        TerritoryLevel.state    => const Color(0xFF00C2FF),  // cyan
        TerritoryLevel.city     => const Color(0xFF39FF14),  // neon green
        TerritoryLevel.neighborhood => const Color(0xFF00FFD1), // mint
      };

  @override
  Widget build(BuildContext context) {
    final circles = territories.map((t) {
      final owned = t.isClaimed && t.color != null;
      final baseColor = owned
          ? Color(t.color!)
          : _levelBorderColor(t.level);

      return CircleMarker(
        point: LatLng(t.lat, t.lng),
        radius: t.radiusMeters,
        useRadiusInMeter: true,
        color: t.isContested
            ? Colors.orange.withAlpha(90)
            : owned
                ? baseColor.withAlpha(110)
                : baseColor.withAlpha(55),
        borderColor: t.isContested
            ? Colors.orange
            : owned
                ? baseColor
                : baseColor.withAlpha(200),
        borderStrokeWidth: t.isContested ? 4 : (owned ? 3 : 2),
      );
    }).toList();

    return CircleLayer(circles: circles);
  }
}

/// Label markers for territory names and owner tags.
class TerritoryLabelLayer extends StatelessWidget {
  const TerritoryLabelLayer({
    super.key,
    required this.territories,
    this.onTap,
  });

  final List<Territory> territories;
  final void Function(Territory)? onTap;

  @override
  Widget build(BuildContext context) {
    final markers = territories.map((t) {
      final isNpc = t.ownerId?.startsWith('npc_') ?? false;
      final npcColor = (isNpc && t.color != null)
          ? Color(t.color!)
          : null;

      return Marker(
        point: LatLng(t.lat, t.lng),
        width: 140,
        height: 64,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap != null ? () => onTap!(t) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // NPC faction badge
              if (isNpc && t.ownerDisplayName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: npcColor?.withAlpha(200) ?? Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    t.ownerDisplayName!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else if (t.isContested)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚔ CONTESTED',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              // Name tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isNpc
                      ? npcColor?.withAlpha(40) ?? Colors.black.withAlpha(160)
                      : Colors.black.withAlpha(160),
                  border: isNpc
                      ? Border.all(
                          color: npcColor ?? Colors.redAccent, width: 1)
                      : null,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t.name,
                  style: TextStyle(
                    color: isNpc ? (npcColor ?? Colors.white) : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (!isNpc && t.isClaimed && t.ownerDisplayName != null)
                Text(
                  t.ownerDisplayName!,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }).toList();

    return MarkerLayer(markers: markers);
  }
}

// ── Legacy single-territory widgets (kept for backwards compatibility) ─────────

/// Renders a circle marker for a territory zone on the map.
@Deprecated('Use TerritoryLayerWidget instead')
class TerritoryMarker extends StatelessWidget {
  const TerritoryMarker({
    super.key,
    required this.territory,
    this.onTap,
  });

  final Territory territory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = territory.color != null
        ? Color(territory.color!)
        : Colors.blueGrey.withAlpha(180);

    return CircleLayer(
      circles: [
        CircleMarker(
          point: LatLng(territory.lat, territory.lng),
          radius: territory.radiusMeters,
          useRadiusInMeter: true,
          color: color.withAlpha(80),
          borderColor: territory.isContested ? Colors.orange : color,
          borderStrokeWidth: territory.isContested ? 3 : 2,
        ),
      ],
    );
  }
}

/// Label marker for territory name.
@Deprecated('Use TerritoryLabelLayer instead')
class TerritoryLabelMarker extends StatelessWidget {
  const TerritoryLabelMarker({
    super.key,
    required this.territory,
    this.onTap,
  });

  final Territory territory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(territory.lat, territory.lng),
          width: 120,
          height: 40,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    territory.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (territory.isClaimed && territory.ownerDisplayName != null)
                  Text(
                    territory.ownerDisplayName!,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── NPC Agent dot layer ───────────────────────────────────────────────────────

/// Renders faction-colored dots for every active NPC agent on the map.
class NpcAgentLayer extends StatelessWidget {
  const NpcAgentLayer({super.key, required this.agents});
  final List<NpcAgent> agents;

  @override
  Widget build(BuildContext context) {
    final markers = agents.map((a) {
      final fc = a.faction.color;
      return Marker(
        point: a.position,
        width: 44,
        height: 44,
        child: Tooltip(
          message: a.fullTitle,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: fc.withAlpha(80), width: 2),
                  color: fc.withAlpha(20),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fc.withAlpha(220),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    a.faction.emoji,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return MarkerLayer(markers: markers);
  }
}
