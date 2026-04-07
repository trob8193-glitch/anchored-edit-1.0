import 'package:flutter/material.dart';
import '../../core/mode.dart';
import '../screens/owner_home_screen.dart';
// ── Hub screens (one file per mode) ──
import 'walker_hub_screens.dart';
import 'owner_hub_screens.dart';
import 'business_hub_screens.dart';
import '../delivery/screens/courier_opportunities_screen.dart';

// Minimal ModeTab class definition
// Helper feature widget used by mode tabs and feature hubs
Widget feature(
  String title,
  String subtitle, {
  List<String> actions = const [],
  Map<String, VoidCallback> actionHandlers = const {},
  List<String> chips = const [],
  List<FeatureItem> items = const [],
  IconData? icon,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    color: Colors.grey[50],
    elevation: 1.5,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 28, color: Colors.grey[700]),
              if (icon != null) const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(fontSize: 15, color: Colors.black54)),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.map((a) {
                final handler = actionHandlers[a];
                if (handler == null) {
                  return Chip(
                    label: Text(a),
                    backgroundColor: Colors.grey[200],
                  );
                }
                return OutlinedButton(onPressed: handler, child: Text(a));
              }).toList(),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: chips
                  .map((c) =>
                      Chip(label: Text(c), backgroundColor: Colors.grey[200]))
                  .toList(),
            ),
          ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text("Details",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              children: items,
            ),
          ],
        ],
      ),
    ),
  );
}

class FeatureItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const FeatureItem(
      {required this.title,
      required this.subtitle,
      required this.icon,
      super.key});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class ModeTab {
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
  const ModeTab(this.label, this.icon, this.builder);
}

List<ModeTab> getModeTabs(AppMode mode, dynamic appState, dynamic flags) {
  switch (mode) {
    // ──────────────────────────────────────────────────────────────────────
    //  OWNER  (8 bottom-nav tabs — down from ~30)
    // ──────────────────────────────────────────────────────────────────────
    case AppMode.owner:
      return [
        ModeTab("Home", Icons.home, (context) => const OwnerHomeScreen()),
        ModeTab("Activity", Icons.dashboard_outlined,
            (context) => const OwnerActivityHubScreen()),
        ModeTab("My Dogs", Icons.pets, (context) => const OwnerDogsHubScreen()),
        ModeTab("Explore", Icons.explore_outlined,
            (context) => const OwnerExploreHubScreen()),
        ModeTab(
            "Grow", Icons.trending_up, (context) => const OwnerGrowHubScreen()),
        ModeTab("Social", Icons.camera_alt_outlined,
            (context) => const OwnerSocialHubScreen()),
        ModeTab("Premium", Icons.workspace_premium,
          (context) => const _ComingSoonScreen(title: 'Owner Premium')),
        ModeTab("Profile", Icons.person_outlined,
          (context) => const _ComingSoonScreen(title: 'Owner Profile')),
      ];

    // ──────────────────────────────────────────────────────────────────────
    //  WALKER  (7 bottom-nav tabs — down from 12)
    // ──────────────────────────────────────────────────────────────────────
    case AppMode.walker:
      return [
        ModeTab("Home", Icons.home, (context) => const WalkerHomeHubScreen()),
        ModeTab(
            "Live", Icons.gps_fixed, (context) => const WalkerLiveHubScreen()),
        ModeTab("PawMedia", Icons.camera_alt,
            (context) => const WalkerPawMediaHubScreen()),
        ModeTab("Training", Icons.school,
            (context) => const WalkerTrainingHubScreen()),
        ModeTab("Delivery", Icons.local_shipping_outlined,
          (context) => const CourierOpportunitiesScreen()),
        ModeTab("Premium", Icons.workspace_premium,
          (context) => const _ComingSoonScreen(title: 'Walker Premium')),
        ModeTab("Profile", Icons.person_outlined,
            (context) => const WalkerProfileHubScreen()),
      ];

    // ──────────────────────────────────────────────────────────────────────
    //  BUSINESS  (4 bottom-nav tabs — down from ~10)
    // ──────────────────────────────────────────────────────────────────────
    case AppMode.business:
      return [
        ModeTab("Ops", Icons.business_center_outlined,
            (context) => const BusinessOpsHubScreen()),
        ModeTab("Live", Icons.gps_fixed,
            (context) => const BusinessLiveHubScreen()),
        ModeTab("Connect", Icons.hub_outlined,
            (context) => const BusinessConnectHubScreen()),
        ModeTab("Profile", Icons.person_outlined,
            (context) => const BusinessProfileHubScreen()),
      ];

    // ──────────────────────────────────────────────────────────────────────
    //  ADMIN  (2 bottom-nav tabs — down from 8)
    // ──────────────────────────────────────────────────────────────────────
    case AppMode.admin:
      return [
        ModeTab("Manage", Icons.admin_panel_settings_outlined,
            (context) => const _ComingSoonScreen(title: 'Admin Manage Hub')),
        ModeTab("Dev", Icons.terminal,
            (context) => const _ComingSoonScreen(title: 'Admin Dev Hub')),
      ];
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title coming soon',
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
