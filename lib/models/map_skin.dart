import 'package:flutter/material.dart';

enum MapSkin {
  tactical,
  satellite,
  ghost,
}

extension MapSkinX on MapSkin {
  String get label => switch (this) {
        MapSkin.tactical  => 'TACTICAL',
        MapSkin.satellite => 'SATELLITE',
        MapSkin.ghost     => 'GHOST',
      };

  String get subtitle => switch (this) {
        MapSkin.tactical  => 'Dark military',
        MapSkin.satellite => 'Real imagery',
        MapSkin.ghost     => 'No labels',
      };

  IconData get icon => switch (this) {
        MapSkin.tactical  => Icons.map_outlined,
        MapSkin.satellite => Icons.satellite_alt,
        MapSkin.ghost     => Icons.visibility_off_outlined,
      };

  Color get accentColor => switch (this) {
        MapSkin.tactical  => const Color(0xFF00FFD1),
        MapSkin.satellite => const Color(0xFF39FF14),
        MapSkin.ghost     => const Color(0xFFBF5FFF),
      };

  /// Tile URL template for flutter_map TileLayer.
  String get tileUrl => switch (this) {
        MapSkin.tactical =>
          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
        MapSkin.satellite =>
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        MapSkin.ghost =>
          'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png',
      };

  /// Subdomain list — empty for ESRI (no {s} in URL).
  List<String> get subdomains => switch (this) {
        MapSkin.tactical  => const ['a', 'b', 'c', 'd'],
        MapSkin.satellite => const [],
        MapSkin.ghost     => const ['a', 'b', 'c', 'd'],
      };

  /// Max native zoom supported by the tile provider.
  int get maxNativeZoom => switch (this) {
        MapSkin.tactical  => 19,
        MapSkin.satellite => 18,
        MapSkin.ghost     => 19,
      };
}
