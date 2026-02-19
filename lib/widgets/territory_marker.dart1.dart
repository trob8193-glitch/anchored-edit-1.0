import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/territory.dart';

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
        TerritoryLevel.continent => const Color(0xFFFF6B35),
        TerritoryLevel.country => const Color(0xFF9B59B6),
        TerritoryLevel.state => const Color(0xFF3498DB),
        TerritoryLevel.city => const Color(0xFF2ECC71),
        TerritoryLevel.neighborhood => const Color(0xFF00C2FF),
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
            ? Colors.orange.withAlpha(50)
            : owned
                ? baseColor.withAlpha(70)
                : baseColor.withAlpha(30),
        borderColor: t.isContested ? Colors.orange : baseColor,
        borderStrokeWidth: t.isContested ? 3 : (owned ? 2 : 1),
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
      return Marker(
        point: LatLng(t.lat, t.lng),
        width: 130,
        height: 52,
        child: GestureDetector(
          onTap: onTap != null ? () => onTap!(t) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contested badge
              if (t.isContested)
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
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (t.isClaimed && t.ownerDisplayName != null)
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
