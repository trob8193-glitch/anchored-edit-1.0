import 'package:flutter/material.dart';

/// The five factions competing for territory dominance globally.
enum Faction { syndicate, ironVeil, wildborn, ghostProtocol, cartel }

/// NPC unit rank within a faction.
enum NpcType { soldier, captain, beast, warlord }

extension FactionX on Faction {
  String get displayName => switch (this) {
        Faction.syndicate => 'Syndicate',
        Faction.ironVeil => 'Iron Veil',
        Faction.wildborn => 'Wildborn',
        Faction.ghostProtocol => 'Ghost Protocol',
        Faction.cartel => 'The Cartel',
      };

  /// Short tag shown on labels
  String get tag => switch (this) {
        Faction.syndicate => '[SYN]',
        Faction.ironVeil => '[IVL]',
        Faction.wildborn => '[WLD]',
        Faction.ghostProtocol => '[GHX]',
        Faction.cartel => '[CTL]',
      };

  Color get color => switch (this) {
        Faction.syndicate => const Color(0xFFFF3B3B),
        Faction.ironVeil => const Color(0xFF4A9EFF),
        Faction.wildborn => const Color(0xFF39FF14),
        Faction.ghostProtocol => const Color(0xFFBF5FFF),
        Faction.cartel => const Color(0xFFFF9F00),
      };

  int get color32 => switch (this) {
        Faction.syndicate => 0xFFFF3B3B,
        Faction.ironVeil => 0xFF4A9EFF,
        Faction.wildborn => 0xFF39FF14,
        Faction.ghostProtocol => 0xFFBF5FFF,
        Faction.cartel => 0xFFFF9F00,
      };

  int get basePower => switch (this) {
        Faction.syndicate => 6,
        Faction.ironVeil => 7,
        Faction.wildborn => 5,
        Faction.ghostProtocol => 6,
        Faction.cartel => 5,
      };

  String get description => switch (this) {
        Faction.syndicate => 'Criminal empire expanding through city cores',
        Faction.ironVeil => 'Military force seizing strategic high ground',
        Faction.wildborn => 'Ancient beasts reclaiming the untamed wild',
        Faction.ghostProtocol => 'Shadow hackers infiltrating tech hubs',
        Faction.cartel => 'Street-level cartel controlling neighborhoods',
      };

  static const String _fire = '🔥';
  static const String _shield = '🛡';
  static const String _beast = '🐾';
  static const String _ghost = '👾';
  static const String _bolt = '⚡';

  String get emoji => switch (this) {
        Faction.syndicate => _fire,
        Faction.ironVeil => _shield,
        Faction.wildborn => _beast,
        Faction.ghostProtocol => _ghost,
        Faction.cartel => _bolt,
      };
}

extension NpcTypeX on NpcType {
  String get title => switch (this) {
        NpcType.soldier => 'Soldier',
        NpcType.captain => 'Captain',
        NpcType.beast => 'Beast',
        NpcType.warlord => 'Warlord',
      };

  int get powerBonus => switch (this) {
        NpcType.soldier => 0,
        NpcType.captain => 2,
        NpcType.beast => 1,
        NpcType.warlord => 4,
      };

  String get stars => switch (this) {
        NpcType.soldier => '★',
        NpcType.captain => '★★★',
        NpcType.beast => '★★',
        NpcType.warlord => '★★★★★',
      };
}
