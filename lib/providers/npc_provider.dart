import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/faction.dart';
import '../models/npc_agent.dart';
import '../models/territory.dart';
import 'territory_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Battle result
// ─────────────────────────────────────────────────────────────────────────────

class BattleResult {
  const BattleResult({
    required this.playerWon,
    required this.playerRoll,
    required this.npcRoll,
    required this.npc,
    required this.territoryName,
  });

  final bool playerWon;
  final int playerRoll;
  final int npcRoll;
  final NpcAgent npc;
  final String territoryName;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final npcProvider =
    StateNotifierProvider<NpcNotifier, List<NpcAgent>>((ref) => NpcNotifier(ref));

// ─────────────────────────────────────────────────────────────────────────────
// NPC Notifier — AI tick engine
// ─────────────────────────────────────────────────────────────────────────────

class NpcNotifier extends StateNotifier<List<NpcAgent>> {
  NpcNotifier(this._ref) : super(_buildAgents()) {
    // Wait for territories to load, then seed + start AI loop
    _ref.listen<AsyncValue<List<Territory>>>(territoriesProvider,
        (_, next) {
      next.whenData((territories) {
        if (!_seeded && territories.isNotEmpty) {
          _seeded = true;
          _seedTerritories(territories);
          _startAiLoop();
        }
      });
    });
  }

  final Ref _ref;
  final _rng = Random();
  Timer? _aiTimer;
  bool _seeded = false;

  // ── Seed home territories on first load ──────────────────────────────────

  void _seedTerritories(List<Territory> territories) {
    for (final agent in state) {
      final targetId = agent.homeTerritoryId;
      if (targetId == null) continue;
      final exists = territories.any((t) => t.id == targetId);
      if (!exists) continue;
      _claim(agent, targetId);
    }
  }

  void _claim(NpcAgent agent, String territoryId) {
    _ref.read(territoryNotifierProvider.notifier).claim(
          territoryId: territoryId,
          ownerId: agent.ownerId,
          ownerDisplayName: agent.displayName,
          color: agent.faction.color32,
        );
  }

  // ── AI tick every 55 seconds ──────────────────────────────────────────────

  void _startAiLoop() {
    // First tick after 8s so player sees action quickly
    Future.delayed(const Duration(seconds: 8), _tick);
    _aiTimer = Timer.periodic(const Duration(seconds: 55), (_) => _tick());
  }

  void _tick() {
    final territories =
        _ref.read(territoriesProvider).valueOrNull ?? [];
    if (territories.isEmpty) return;

    for (final agent in state) {
      if (_rng.nextDouble() > 0.65) continue; // 65% chance each tick

      // Prioritise: unowned → rival-faction-owned → player-owned
      final unowned = _nearbyTerritories(agent, territories)
          .where((t) => !t.isClaimed)
          .toList();
      final rivalOwned = _nearbyTerritories(agent, territories)
          .where((t) =>
              t.isClaimed &&
              t.ownerId != agent.ownerId &&
              (t.ownerId?.startsWith('npc_') ?? false))
          .toList();

      Territory? target;
      if (unowned.isNotEmpty) {
        target = unowned[_rng.nextInt(unowned.length.clamp(1, 3))];
      } else if (rivalOwned.isNotEmpty) {
        target = rivalOwned[_rng.nextInt(rivalOwned.length.clamp(1, 2))];
      } else {
        // Occasionally pressure player territories
        if (_rng.nextDouble() < 0.25) {
          final playerOwned = _nearbyTerritories(agent, territories)
              .where((t) =>
                  t.isClaimed && !(t.ownerId?.startsWith('npc_') ?? false))
              .toList();
          if (playerOwned.isNotEmpty) {
            target = playerOwned[_rng.nextInt(playerOwned.length)];
          }
        }
      }

      if (target == null) continue;

      // Warlords always claim; others battle if enemy-owned
      final isEnemyOwned =
          target.isClaimed && target.ownerId != agent.ownerId;
      if (!isEnemyOwned || agent.type == NpcType.warlord) {
        _claim(agent, target.id);
      } else {
        // NPC vs NPC battle — higher power wins with a small random factor
        final attPower = agent.power + _rng.nextInt(4);
        final defPower = (target.color != null ? 4 : 3) + _rng.nextInt(4);
        if (attPower > defPower) {
          _claim(agent, target.id);
        }
      }
    }
  }

  // ── Battle: player vs NPC ─────────────────────────────────────────────────

  /// Call this when the player tries to claim an NPC-owned territory.
  /// Returns a BattleResult — the caller handles the claim if playerWon.
  BattleResult battle({
    required Territory territory,
    int playerPower = 5,
  }) {
    // Find the NPC that owns this territory
    final ownerAgent = state.firstWhere(
      (a) => a.ownerId == territory.ownerId,
      orElse: () => _defaultEnemy(territory),
    );

    final playerRoll = playerPower + _rng.nextInt(8) + 1;
    final npcRoll = ownerAgent.power + _rng.nextInt(6) + 1;

    return BattleResult(
      playerWon: playerRoll > npcRoll,
      playerRoll: playerRoll,
      npcRoll: npcRoll,
      npc: ownerAgent,
      territoryName: territory.name,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Up to 5 nearest territories within 80 km of an agent
  List<Territory> _nearbyTerritories(
      NpcAgent agent, List<Territory> all) {
    const dist = Distance();
    final withDist = all
        .map((t) => (
              t,
              dist.as(
                  LengthUnit.Kilometer,
                  agent.position,
                  LatLng(t.lat, t.lng))
            ))
        .where((pair) => pair.$2 < 80)
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    return withDist.take(5).map((p) => p.$1).toList();
  }

  NpcAgent _defaultEnemy(Territory t) {
    // Build a generic NPC from the territory owner id so battle still works
    final factionGuess = Faction.values[
        t.ownerId.hashCode.abs() % Faction.values.length];
    return NpcAgent(
      id: t.ownerId ?? 'unknown',
      name: 'Agent',
      faction: factionGuess,
      type: NpcType.soldier,
      lat: t.lat,
      lng: t.lng,
    );
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    super.dispose();
  }

  // ── Static world of NPC agents ────────────────────────────────────────────

  static List<NpcAgent> _buildAgents() => const [
        // ── THE SYNDICATE (red) ── Urban crime cells ────────────────────────
        NpcAgent(
          id: 'syn_boss_ny',
          name: 'Voss',
          faction: Faction.syndicate,
          type: NpcType.warlord,
          lat: 40.7128,
          lng: -74.0060,
          homeTerritoryId: 'demo_new_york',
        ),
        NpcAgent(
          id: 'syn_chi',
          name: 'Mara',
          faction: Faction.syndicate,
          type: NpcType.captain,
          lat: 41.8781,
          lng: -87.6298,
          homeTerritoryId: 'demo_chicago',
        ),
        NpcAgent(
          id: 'syn_la',
          name: 'Drake',
          faction: Faction.syndicate,
          type: NpcType.soldier,
          lat: 34.0522,
          lng: -118.2437,
          homeTerritoryId: 'demo_los_angeles',
        ),
        NpcAgent(
          id: 'syn_london',
          name: 'Cipher',
          faction: Faction.syndicate,
          type: NpcType.captain,
          lat: 51.5074,
          lng: -0.1278,
          homeTerritoryId: 'demo_london',
        ),
        NpcAgent(
          id: 'syn_sa_jefe',
          name: 'El Jefe',
          faction: Faction.syndicate,
          type: NpcType.captain,
          lat: 29.4241,
          lng: -98.4936,
          homeTerritoryId: 'demo_river_walk_sa',
        ),

        // ── IRON VEIL (blue) ── Military occupation force ────────────────────
        NpcAgent(
          id: 'ivl_warlord_moscow',
          name: 'Koval',
          faction: Faction.ironVeil,
          type: NpcType.warlord,
          lat: 55.7558,
          lng: 37.6173,
          homeTerritoryId: 'demo_russia',
        ),
        NpcAgent(
          id: 'ivl_berlin',
          name: 'Steele',
          faction: Faction.ironVeil,
          type: NpcType.captain,
          lat: 52.5200,
          lng: 13.4050,
          homeTerritoryId: 'demo_germany',
        ),
        NpcAgent(
          id: 'ivl_beijing',
          name: 'Gen. Rho',
          faction: Faction.ironVeil,
          type: NpcType.captain,
          lat: 39.9042,
          lng: 116.4074,
          homeTerritoryId: 'demo_china',
        ),
        NpcAgent(
          id: 'ivl_sa_stone_oak',
          name: 'Iron-9',
          faction: Faction.ironVeil,
          type: NpcType.soldier,
          lat: 29.5941,
          lng: -98.4914,
          homeTerritoryId: 'demo_stone_oak_sa',
        ),

        // ── WILDBORN (green) ── Primal beasts ────────────────────────────────
        NpcAgent(
          id: 'wld_amazon',
          name: 'Serpentis',
          faction: Faction.wildborn,
          type: NpcType.beast,
          lat: -3.4653,
          lng: -62.2159,
          homeTerritoryId: 'demo_brazil',
        ),
        NpcAgent(
          id: 'wld_sahara',
          name: 'Dune Stalker',
          faction: Faction.wildborn,
          type: NpcType.beast,
          lat: 23.4162,
          lng: 25.6628,
          homeTerritoryId: 'demo_egypt',
        ),
        NpcAgent(
          id: 'wld_siberia',
          name: 'Permafrost',
          faction: Faction.wildborn,
          type: NpcType.warlord,
          lat: 63.0,
          lng: 97.0,
          homeTerritoryId: 'demo_russia',
        ),
        NpcAgent(
          id: 'wld_outback',
          name: 'Razorback',
          faction: Faction.wildborn,
          type: NpcType.beast,
          lat: -25.2744,
          lng: 133.7751,
          homeTerritoryId: 'demo_australia',
        ),
        NpcAgent(
          id: 'wld_sa_beast',
          name: 'Coyote',
          faction: Faction.wildborn,
          type: NpcType.beast,
          lat: 29.4960,
          lng: -98.6059,
          homeTerritoryId: 'demo_leon_valley_tx',
        ),
        NpcAgent(
          id: 'wld_helotes_beast',
          name: 'Brush Wolf',
          faction: Faction.wildborn,
          type: NpcType.beast,
          lat: 29.5757,
          lng: -98.6873,
          homeTerritoryId: 'demo_helotes_tx',
        ),

        // ── GHOST PROTOCOL (purple) ── Shadow hackers ─────────────────────────
        NpcAgent(
          id: 'ghx_tokyo',
          name: 'Nyx',
          faction: Faction.ghostProtocol,
          type: NpcType.warlord,
          lat: 35.6762,
          lng: 139.6503,
          homeTerritoryId: 'demo_japan',
        ),
        NpcAgent(
          id: 'ghx_sg',
          name: 'Zero.exe',
          faction: Faction.ghostProtocol,
          type: NpcType.captain,
          lat: 1.3521,
          lng: 103.8198,
          homeTerritoryId: 'demo_singapore',
        ),
        NpcAgent(
          id: 'ghx_sf',
          name: 'Specter',
          faction: Faction.ghostProtocol,
          type: NpcType.captain,
          lat: 37.7749,
          lng: -122.4194,
          homeTerritoryId: 'demo_usa',
        ),
        NpcAgent(
          id: 'ghx_sa_pearl',
          name: 'Phantom',
          faction: Faction.ghostProtocol,
          type: NpcType.soldier,
          lat: 29.4440,
          lng: -98.4853,
          homeTerritoryId: 'demo_pearl_district_sa',
        ),

        // ── THE CARTEL (orange) ── Street-level enforcers ─────────────────────
        NpcAgent(
          id: 'ctl_warlord_mx',
          name: 'La Sombra',
          faction: Faction.cartel,
          type: NpcType.warlord,
          lat: 19.4326,
          lng: -99.1332,
          homeTerritoryId: 'demo_mexico',
        ),
        NpcAgent(
          id: 'ctl_buenos_aires',
          name: 'Furia',
          faction: Faction.cartel,
          type: NpcType.captain,
          lat: -34.6037,
          lng: -58.3816,
          homeTerritoryId: 'demo_argentina',
        ),
        NpcAgent(
          id: 'ctl_nairobi',
          name: 'Blade',
          faction: Faction.cartel,
          type: NpcType.captain,
          lat: -1.286389,
          lng: 36.817223,
          homeTerritoryId: 'demo_kenya',
        ),
        NpcAgent(
          id: 'ctl_sa_south',
          name: 'Lobo',
          faction: Faction.cartel,
          type: NpcType.captain,
          lat: 29.4093,
          lng: -98.4892,
          homeTerritoryId: 'demo_southtown_sa',
        ),
        NpcAgent(
          id: 'ctl_sa_midtown',
          name: 'Viper',
          faction: Faction.cartel,
          type: NpcType.soldier,
          lat: 29.4390,
          lng: -98.4960,
          homeTerritoryId: 'demo_midtown_sa',
        ),
      ];
}
