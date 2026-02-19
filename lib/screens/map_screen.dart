import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/app_user.dart';
import '../models/territory.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/territory_provider.dart';
import '../widgets/claim_button.dart';
import '../widgets/territory_marker.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Territory? _selectedTerritory;

  // Deterministic colour from user uid
  int _colorFromUid(String uid) {
    final hash = uid.codeUnits.fold(0, (p, c) => p + c);
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1, hue, 0.8, 0.9).toColor().toARGB32();
  }

  Future<void> _onAnchor() async {
    if (_selectedTerritory == null) return;

    // Use Firebase user when available, otherwise a session-scoped offline user.
    final firebaseReady = ref.read(firebaseAvailableProvider);
    final AppUser effectiveUser = firebaseReady
        ? (ref.read(authStateProvider).valueOrNull ??
            const AppUser(
              uid: 'offline_guest',
              displayName: 'Guest',
              isAnonymous: true,
            ))
        : const AppUser(
            uid: 'offline_guest',
            displayName: 'Offline Player',
            isAnonymous: true,
          );

    await ref.read(territoryNotifierProvider.notifier).claim(
          territoryId: _selectedTerritory!.id,
          ownerId: effectiveUser.uid,
          ownerDisplayName: effectiveUser.displayName,
          color: _colorFromUid(effectiveUser.uid),
        );
    if (mounted) {
      setState(() => _selectedTerritory = null);
    }
  }

  Future<void> _onRelease() async {
    if (_selectedTerritory == null) return;
    await ref
        .read(territoryNotifierProvider.notifier)
        .release(_selectedTerritory!.id);
    if (mounted) {
      setState(() => _selectedTerritory = null);
    }
  }

  Future<void> _onContest() async {
    if (_selectedTerritory == null) return;
    final firebaseReady = ref.read(firebaseAvailableProvider);
    final AppUser effectiveUser = firebaseReady
        ? (ref.read(authStateProvider).valueOrNull ??
            const AppUser(
              uid: 'offline_guest',
              displayName: 'Guest',
              isAnonymous: true,
            ))
        : const AppUser(
            uid: 'offline_guest',
            displayName: 'Offline Player',
            isAnonymous: true,
          );

    if (_selectedTerritory!.isContested) {
      // Already contested — show info
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This territory is already being contested.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    await ref.read(territoryNotifierProvider.notifier).startContest(
          territoryId: _selectedTerritory!.id,
          challengerUid: effectiveUser.uid,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Contest started! Stay in range for 30s to claim.'),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
      // Auto-resolve after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          ref.read(territoryNotifierProvider.notifier).resolveContest(
                territoryId: _selectedTerritory?.id ?? '',
                challengerWins: _isInRange(_selectedTerritory!),
                challengerUid: effectiveUser.uid,
                challengerDisplayName: effectiveUser.displayName,
                challengerColor: _colorFromUid(effectiveUser.uid),
              );
        }
      });
    }
  }

  bool _isInRange(Territory t) {
    final pos = ref.read(currentLatLngProvider);
    if (pos == null) return false;
    final dist = const Distance().as(
      LengthUnit.Meter,
      pos,
      LatLng(t.lat, t.lng),
    );
    return dist <= AppConstants.claimRadiusMeters;
  }

  @override
  Widget build(BuildContext context) {
    final territoriesAsync = ref.watch(territoriesProvider);
    final posAsync = ref.watch(positionStreamProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final claimState = ref.watch(territoryNotifierProvider);
    final isOffline = !ref.watch(firebaseAvailableProvider);

    final currentPos = posAsync.whenOrNull(
      data: (p) => LatLng(p.latitude, p.longitude),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ANCHORED'),
        actions: [
          if (isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'OFFLINE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Color(0xFF3A2A00),
                side: BorderSide(color: Colors.orange, width: 1),
              ),
            ),
          if (!isOffline && user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPos ?? const LatLng(40.7128, -74.0060),
              initialZoom: AppConstants.defaultZoom,
              minZoom: AppConstants.minZoom,
              maxZoom: AppConstants.maxZoom,
              onTap: (tapPos, point) => setState(() => _selectedTerritory = null),
            ),
            children: [
              // OSM tile layer
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: 'com.anchored.app',
              ),

              // Territory circles (all in one layer for efficiency)
              if (territoriesAsync.valueOrNull != null)
                TerritoryLayerWidget(territories: territoriesAsync.valueOrNull!),

              // Territory labels (single MarkerLayer)
              if (territoriesAsync.valueOrNull != null)
                TerritoryLabelLayer(
                  territories: territoriesAsync.valueOrNull!,
                  onTap: (t) => setState(() => _selectedTerritory = t),
                ),

              // Player location marker
              if (currentPos != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPos,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(120),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Loading overlay from territories stream ───────────────────
          if (territoriesAsync.isLoading)
            const Center(child: CircularProgressIndicator()),

          // ── Location permission prompt ────────────────────────────────
          if (posAsync.hasError)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Location access denied. Enable GPS to play.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // ── Recenter FAB ──────────────────────────────────────────────
          if (currentPos != null)
            Positioned(
              right: 16,
              bottom: _selectedTerritory != null ? 160 : 24,
              child: FloatingActionButton.small(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.primary,
                onPressed: () =>
                    _mapController.move(currentPos, AppConstants.defaultZoom),
                child: const Icon(Icons.my_location),
              ),
            ),

          // ── Territory info + Claim panel ──────────────────────────────
          if (_selectedTerritory != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _TerritoryPanel(
                territory: _selectedTerritory!,
                isLoading: claimState.isLoading,
                isOwned: _selectedTerritory!.ownerId ==
                    (user?.uid ?? 'offline_guest'),
                canClaim: _isInRange(_selectedTerritory!),
                isContested: _selectedTerritory!.isContested,
                onClaim: _onAnchor,
                onRelease: _onRelease,
                onContest: _onContest,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Territory bottom panel ────────────────────────────────────────────────────

class _TerritoryPanel extends StatelessWidget {
  const _TerritoryPanel({
    required this.territory,
    required this.isLoading,
    required this.isOwned,
    required this.canClaim,
    required this.isContested,
    required this.onClaim,
    required this.onRelease,
    required this.onContest,
  });

  final Territory territory;
  final bool isLoading;
  final bool isOwned;
  final bool canClaim;
  final bool isContested;
  final VoidCallback onClaim;
  final VoidCallback onRelease;
  final VoidCallback onContest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      territory.name,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          territory.level.displayName.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.primary.withAlpha(180),
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${territory.points}pts',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isContested) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '⚔ CONTESTED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (territory.isClaimed)
                Chip(
                  label: Text(
                    territory.ownerDisplayName ?? 'Unknown',
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: territory.color != null
                      ? Color(territory.color!).withAlpha(60)
                      : AppTheme.neutral,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClaimButton(
                  isLoading: isLoading,
                  isOwned: isOwned,
                  canClaim: canClaim,
                  onClaim: onClaim,
                  onRelease: onRelease,
                ),
              ),
              // Contest button: shown when territory is owned by another player
              if (territory.isClaimed && !isOwned && canClaim) ...[
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isContested
                        ? Colors.orange.shade900
                        : Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  icon: const Icon(Icons.warning_amber_rounded, size: 16),
                  label: Text(isContested ? 'CONTESTING' : 'CONTEST'),
                  onPressed: isLoading ? null : onContest,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
