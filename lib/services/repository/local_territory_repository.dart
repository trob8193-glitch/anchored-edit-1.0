import 'dart:async';

import '../../models/territory.dart';
import 'territory_repository.dart';

/// In-memory territory repository — used when Firebase is unavailable.
/// Data is local only; changes do not persist across restarts.
class LocalTerritoryRepository implements TerritoryRepository {
  LocalTerritoryRepository() {
    _territories = _defaultTerritories();
  }

  late List<Territory> _territories;
  final _controller = StreamController<List<Territory>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_territories));

  /// Immediately yields current state, then streams all future updates.
  @override
  Stream<List<Territory>> watchTerritories() async* {
    yield List.unmodifiable(_territories);
    yield* _controller.stream;
  }

  @override
  Future<void> claimTerritory({
    required String territoryId,
    required String ownerId,
    required String ownerDisplayName,
    required int color,
  }) async {
    _territories = _territories.map((t) {
      if (t.id != territoryId) return t;
      return t.copyWith(
        ownerId: ownerId,
        ownerDisplayName: ownerDisplayName,
        claimedAt: DateTime.now(),
        color: color,
        isContested: false,
        contestedByUid: null,
        contestedAt: null,
      );
    }).toList();
    _emit();
  }

  @override
  Future<void> releaseTerritory(String territoryId) async {
    _territories = _territories.map((t) {
      if (t.id != territoryId) return t;
      return Territory(
        id: t.id,
        name: t.name,
        level: t.level,
        lat: t.lat,
        lng: t.lng,
        radiusMeters: t.radiusMeters,
        parentId: t.parentId,
      );
    }).toList();
    _emit();
  }

  @override
  Future<void> contestTerritory({
    required String territoryId,
    required String challengerUid,
  }) async {
    _territories = _territories.map((t) {
      if (t.id != territoryId) return t;
      return t.copyWith(
        isContested: true,
        contestedByUid: challengerUid,
        contestedAt: DateTime.now(),
      );
    }).toList();
    _emit();
  }

  @override
  Future<void> resolveContest({
    required String territoryId,
    required bool challengerWins,
    String? challengerUid,
    String? challengerDisplayName,
    int? challengerColor,
  }) async {
    _territories = _territories.map((t) {
      if (t.id != territoryId) return t;
      if (challengerWins &&
          challengerUid != null &&
          challengerDisplayName != null) {
        return t.copyWith(
          ownerId: challengerUid,
          ownerDisplayName: challengerDisplayName,
          claimedAt: DateTime.now(),
          color: challengerColor ?? t.color,
          isContested: false,
          contestedByUid: null,
          contestedAt: null,
        );
      }
      return t.copyWith(
        isContested: false,
        contestedByUid: null,
        contestedAt: null,
      );
    }).toList();
    _emit();
  }

  void dispose() => _controller.close();

  /// Sample territories for offline / demo mode.
  /// Hierarchy: neighborhood → city → state → country → continent
  static List<Territory> _defaultTerritories() => [
        // ── Continents ─────────────────────────────────────────────────────
        const Territory(
          id: 'demo_north_america',
          name: 'North America',
          level: TerritoryLevel.continent,
          lat: 54.5260,
          lng: -105.2551,
          radiusMeters: 1200,
        ),
        const Territory(
          id: 'demo_europe',
          name: 'Europe',
          level: TerritoryLevel.continent,
          lat: 54.5260,
          lng: 15.2551,
          radiusMeters: 1200,
        ),
        const Territory(
          id: 'demo_asia',
          name: 'Asia',
          level: TerritoryLevel.continent,
          lat: 34.0479,
          lng: 100.6197,
          radiusMeters: 1200,
        ),
        // ── Countries ──────────────────────────────────────────────────────
        const Territory(
          id: 'demo_usa',
          name: 'United States',
          level: TerritoryLevel.country,
          lat: 37.0902,
          lng: -95.7129,
          radiusMeters: 1000,
          parentId: 'demo_north_america',
        ),
        const Territory(
          id: 'demo_canada',
          name: 'Canada',
          level: TerritoryLevel.country,
          lat: 56.1304,
          lng: -106.3468,
          radiusMeters: 1000,
          parentId: 'demo_north_america',
        ),
        const Territory(
          id: 'demo_uk',
          name: 'United Kingdom',
          level: TerritoryLevel.country,
          lat: 55.3781,
          lng: -3.4360,
          radiusMeters: 1000,
          parentId: 'demo_europe',
        ),
        const Territory(
          id: 'demo_france',
          name: 'France',
          level: TerritoryLevel.country,
          lat: 46.2276,
          lng: 2.2137,
          radiusMeters: 1000,
          parentId: 'demo_europe',
        ),
        const Territory(
          id: 'demo_japan',
          name: 'Japan',
          level: TerritoryLevel.country,
          lat: 36.2048,
          lng: 138.2529,
          radiusMeters: 1000,
          parentId: 'demo_asia',
        ),
        // ── States ─────────────────────────────────────────────────────────
        const Territory(
          id: 'demo_new_york_state',
          name: 'New York State',
          level: TerritoryLevel.state,
          lat: 42.1656,
          lng: -74.9481,
          radiusMeters: 800,
          parentId: 'demo_usa',
        ),
        const Territory(
          id: 'demo_california',
          name: 'California',
          level: TerritoryLevel.state,
          lat: 36.7783,
          lng: -119.4179,
          radiusMeters: 800,
          parentId: 'demo_usa',
        ),
        const Territory(
          id: 'demo_texas',
          name: 'Texas',
          level: TerritoryLevel.state,
          lat: 31.9686,
          lng: -99.9018,
          radiusMeters: 800,
          parentId: 'demo_usa',
        ),
        const Territory(
          id: 'demo_florida',
          name: 'Florida',
          level: TerritoryLevel.state,
          lat: 27.9944,
          lng: -81.7603,
          radiusMeters: 800,
          parentId: 'demo_usa',
        ),
        // ── Cities ─────────────────────────────────────────────────────────
        const Territory(
          id: 'demo_new_york',
          name: 'New York City',
          level: TerritoryLevel.city,
          lat: 40.7128,
          lng: -74.0060,
          radiusMeters: 600,
          parentId: 'demo_new_york_state',
        ),
        const Territory(
          id: 'demo_los_angeles',
          name: 'Los Angeles',
          level: TerritoryLevel.city,
          lat: 34.0522,
          lng: -118.2437,
          radiusMeters: 600,
          parentId: 'demo_california',
        ),
        const Territory(
          id: 'demo_chicago',
          name: 'Chicago',
          level: TerritoryLevel.city,
          lat: 41.8781,
          lng: -87.6298,
          radiusMeters: 600,
          parentId: 'demo_usa',
        ),
        const Territory(
          id: 'demo_miami',
          name: 'Miami',
          level: TerritoryLevel.city,
          lat: 25.7617,
          lng: -80.1918,
          radiusMeters: 600,
          parentId: 'demo_florida',
        ),
        const Territory(
          id: 'demo_houston',
          name: 'Houston',
          level: TerritoryLevel.city,
          lat: 29.7604,
          lng: -95.3698,
          radiusMeters: 600,
          parentId: 'demo_texas',
        ),
        const Territory(
          id: 'demo_london',
          name: 'London',
          level: TerritoryLevel.city,
          lat: 51.5074,
          lng: -0.1278,
          radiusMeters: 600,
          parentId: 'demo_uk',
        ),
        const Territory(
          id: 'demo_paris',
          name: 'Paris',
          level: TerritoryLevel.city,
          lat: 48.8566,
          lng: 2.3522,
          radiusMeters: 600,
          parentId: 'demo_france',
        ),
        const Territory(
          id: 'demo_tokyo',
          name: 'Tokyo',
          level: TerritoryLevel.city,
          lat: 35.6762,
          lng: 139.6503,
          radiusMeters: 600,
          parentId: 'demo_japan',
        ),
        const Territory(
          id: 'demo_toronto',
          name: 'Toronto',
          level: TerritoryLevel.city,
          lat: 43.6532,
          lng: -79.3832,
          radiusMeters: 600,
          parentId: 'demo_canada',
        ),
        // ── NYC Neighborhoods ──────────────────────────────────────────────
        const Territory(
          id: 'demo_times_square',
          name: 'Times Square',
          level: TerritoryLevel.neighborhood,
          lat: 40.7580,
          lng: -73.9855,
          radiusMeters: 120,
          parentId: 'demo_new_york',
        ),
        const Territory(
          id: 'demo_central_park',
          name: 'Central Park',
          level: TerritoryLevel.neighborhood,
          lat: 40.7851,
          lng: -73.9683,
          radiusMeters: 200,
          parentId: 'demo_new_york',
        ),
        const Territory(
          id: 'demo_brooklyn_bridge',
          name: 'Brooklyn Bridge',
          level: TerritoryLevel.neighborhood,
          lat: 40.7061,
          lng: -73.9969,
          radiusMeters: 100,
          parentId: 'demo_new_york',
        ),
        const Territory(
          id: 'demo_wall_street',
          name: 'Wall Street',
          level: TerritoryLevel.neighborhood,
          lat: 40.7074,
          lng: -74.0113,
          radiusMeters: 100,
          parentId: 'demo_new_york',
        ),
        const Territory(
          id: 'demo_soho',
          name: 'SoHo',
          level: TerritoryLevel.neighborhood,
          lat: 40.7233,
          lng: -74.0030,
          radiusMeters: 120,
          parentId: 'demo_new_york',
        ),
        // ── London Neighborhoods ───────────────────────────────────────────
        const Territory(
          id: 'demo_westminster',
          name: 'Westminster',
          level: TerritoryLevel.neighborhood,
          lat: 51.4994,
          lng: -0.1245,
          radiusMeters: 150,
          parentId: 'demo_london',
        ),
        const Territory(
          id: 'demo_shoreditch',
          name: 'Shoreditch',
          level: TerritoryLevel.neighborhood,
          lat: 51.5224,
          lng: -0.0798,
          radiusMeters: 120,
          parentId: 'demo_london',
        ),
        const Territory(
          id: 'demo_canary_wharf',
          name: 'Canary Wharf',
          level: TerritoryLevel.neighborhood,
          lat: 51.5054,
          lng: -0.0235,
          radiusMeters: 130,
          parentId: 'demo_london',
        ),
        // ── Tokyo Neighborhoods ────────────────────────────────────────────
        const Territory(
          id: 'demo_shibuya',
          name: 'Shibuya',
          level: TerritoryLevel.neighborhood,
          lat: 35.6598,
          lng: 139.7004,
          radiusMeters: 150,
          parentId: 'demo_tokyo',
        ),
        const Territory(
          id: 'demo_akihabara',
          name: 'Akihabara',
          level: TerritoryLevel.neighborhood,
          lat: 35.7023,
          lng: 139.7750,
          radiusMeters: 120,
          parentId: 'demo_tokyo',
        ),
        // ── Paris Neighborhoods ────────────────────────────────────────────
        const Territory(
          id: 'demo_montmartre',
          name: 'Montmartre',
          level: TerritoryLevel.neighborhood,
          lat: 48.8867,
          lng: 2.3431,
          radiusMeters: 150,
          parentId: 'demo_paris',
        ),
        const Territory(
          id: 'demo_le_marais',
          name: 'Le Marais',
          level: TerritoryLevel.neighborhood,
          lat: 48.8566,
          lng: 2.3600,
          radiusMeters: 130,
          parentId: 'demo_paris',
        ),
      ];
}
