import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_auth_provider.dart';
import '../delivery/models/delivery_models.dart';
import '../delivery/repositories/delivery_repository.dart';
import '../jobs/job_provider.dart';
import '../verification/verification_provider.dart';

class OwnerActivityHubScreen extends ConsumerWidget {
  const OwnerActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final uid = auth.userId ?? '';
    final isSignedIn = uid.isNotEmpty;
    final isAuthLoading = auth.status == FirebaseAuthStatus.loading;

    final ordersAsync = !isSignedIn
        ? const AsyncValue<List<DeliveryOrder>>.data([])
        : ref.watch(customerDeliveryOrdersProvider(uid));
    final jobs = ref.watch(jobsProvider).jobs;
    final orders = ordersAsync.valueOrNull ?? const <DeliveryOrder>[];
    final active = orders
        .where((o) =>
            o.status != DeliveryOrderStatus.delivered &&
            o.status != DeliveryOrderStatus.canceled)
        .length;

    return _HubScaffold(
      title: 'Owner Activity',
      summary: 'Track walks, check-ins, and service updates.',
      metrics: [
        isAuthLoading
            ? 'Orders today: connecting account...'
            : !isSignedIn
                ? 'Orders today: sign in required'
                : ordersAsync.isLoading
                    ? 'Orders today: loading...'
                    : ordersAsync.hasError
                        ? 'Orders today: unavailable'
                        : 'Orders today: ${orders.length}',
        isAuthLoading
            ? 'Active orders: connecting account...'
            : !isSignedIn
                ? 'Active orders: sign in required'
                : ordersAsync.isLoading
                    ? 'Active orders: loading...'
                    : ordersAsync.hasError
                        ? 'Active orders: unavailable'
                        : 'Active orders: $active',
        'Pending jobs: ${jobs.where((j) => j['status'] == 'pending').length}',
      ],
    );
  }
}

class OwnerDogsHubScreen extends ConsumerWidget {
  const OwnerDogsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final isSignedIn = (auth.userId ?? '').isNotEmpty;
    final verif = ref.watch(verifProvider);
    final dogTypes = const [
      VerifType.vaccination,
      VerifType.microchip,
      VerifType.breedRegistration,
      VerifType.dogLicense,
    ];
    final approved = dogTypes
        .where((t) => verif.itemOf(t).status == VerifStatus.approved)
        .length;
    final pending = dogTypes
        .where((t) => verif.itemOf(t).status == VerifStatus.pending)
        .length;

    return _HubScaffold(
      title: 'Owner Dogs',
      summary: 'Manage pet profiles, records, and routines.',
      metrics: [
        'Dog records approved: $approved/${dogTypes.length}',
        'Dog records pending: $pending',
        isSignedIn
            ? 'Verification coverage: ${(approved * 100 / dogTypes.length).toStringAsFixed(0)}%'
            : 'Verification coverage: local only (sign in to sync)',
      ],
    );
  }
}

class OwnerExploreHubScreen extends ConsumerWidget {
  const OwnerExploreHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(deliveryOpportunitiesProvider);
    final opportunities =
        opportunitiesAsync.valueOrNull ?? const <DeliveryOrder>[];
    return _HubScaffold(
      title: 'Owner Explore',
      summary: 'Discover walkers, trainers, and local pet services.',
      metrics: [
        opportunitiesAsync.isLoading
            ? 'Open nearby delivery slots: loading...'
            : opportunitiesAsync.hasError
                ? 'Open nearby delivery slots: unavailable'
                : 'Open nearby delivery slots: ${opportunities.length}',
        opportunitiesAsync.isLoading
            ? 'Fresh vendor opportunities: loading...'
            : opportunitiesAsync.hasError
                ? 'Fresh vendor opportunities: unavailable'
                : 'Fresh vendor opportunities: ${opportunities.take(3).length}',
        'Explore feed status: live',
      ],
    );
  }
}

class OwnerGrowHubScreen extends ConsumerWidget {
  const OwnerGrowHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final isSignedIn = (auth.userId ?? '').isNotEmpty;
    final verif = ref.watch(verifProvider);
    final approved = verif.items.values
        .where((v) => v.status == VerifStatus.approved)
        .length;
    final pending =
        verif.items.values.where((v) => v.status == VerifStatus.pending).length;
    return _HubScaffold(
      title: 'Owner Grow',
      summary: 'Training plans and wellness goals for your dogs.',
      metrics: [
        'Verification milestones complete: $approved',
        'Milestones pending review: $pending',
        !isSignedIn
            ? 'Goal completion: local only (sign in to sync)'
            : approved + pending == 0
                ? 'Goal completion: 0%'
                : 'Goal completion: ${(approved * 100 / (approved + pending)).toStringAsFixed(0)}%',
      ],
    );
  }
}

class OwnerSocialHubScreen extends ConsumerWidget {
  const OwnerSocialHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final isSignedIn = (auth.userId ?? '').isNotEmpty;
    final jobs = ref.watch(jobsProvider).jobs;
    final completed = jobs.where((j) => j['status'] == 'completed').length;
    final accepted = jobs.where((j) => j['status'] == 'accepted').length;
    return _HubScaffold(
      title: 'Owner Social',
      summary: 'Community posts, groups, and event planning.',
      metrics: [
        'Completed jobs shared: $completed',
        'Accepted jobs in progress: $accepted',
        isSignedIn
            ? 'Community health: stable'
            : 'Community health: local view (sign in to sync)',
      ],
    );
  }
}

class _HubScaffold extends StatelessWidget {
  const _HubScaffold({
    required this.title,
    required this.summary,
    required this.metrics,
  });

  final String title;
  final String summary;
  final List<String> metrics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: const Color(0xFF212121),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child:
                  Text(summary, style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 8),
          ...metrics.map(
            (m) => Card(
              color: const Color(0xFF212121),
              child: ListTile(
                leading:
                    const Icon(Icons.insights_outlined, color: Colors.white60),
                title: Text(m, style: const TextStyle(color: Colors.white70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
