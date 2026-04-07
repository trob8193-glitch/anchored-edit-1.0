import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_auth_provider.dart';
import '../business/providers/business_event_provider.dart';
import '../delivery/models/delivery_models.dart';
import '../delivery/repositories/delivery_repository.dart';
import '../delivery/repositories/training_repository.dart';
import '../jobs/job_provider.dart';
import '../verification/verification_provider.dart';

class BusinessOpsHubScreen extends ConsumerWidget {
  const BusinessOpsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final uid = auth.userId ?? '';
    final isSignedIn = uid.isNotEmpty;
    final isAuthLoading = auth.status == FirebaseAuthStatus.loading;

    final opportunitiesAsync = ref.watch(deliveryOpportunitiesProvider);
    final opportunities =
        opportunitiesAsync.valueOrNull ?? const <DeliveryOrder>[];
    final jobs = ref.watch(jobsProvider).jobs;
    final eventsAsync = ref.watch(businessEventsStreamProvider(uid));
    final events = eventsAsync.valueOrNull ?? const [];
    return _HubScaffold(
      title: 'Business Ops',
      summary: 'Order queue, assignment health, and operational throughput.',
      metrics: [
        opportunitiesAsync.isLoading
            ? 'Open opportunities: loading...'
            : opportunitiesAsync.hasError
                ? 'Open opportunities: unavailable'
                : 'Open opportunities: ${opportunities.length}',
        'Pending assignments: ${jobs.where((j) => j['status'] == 'pending').length}',
        isAuthLoading
            ? 'Scheduled events: connecting account...'
            : !isSignedIn
                ? 'Scheduled events: sign in required'
                : eventsAsync.isLoading
                    ? 'Scheduled events: loading...'
                    : eventsAsync.hasError
                        ? 'Scheduled events: unavailable'
                        : 'Scheduled events: ${events.length}',
      ],
    );
  }
}

class BusinessLiveHubScreen extends ConsumerWidget {
  const BusinessLiveHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(deliveryOpportunitiesProvider);
    final opportunities =
        opportunitiesAsync.valueOrNull ?? const <DeliveryOrder>[];
    final active = opportunities
        .where((o) =>
            o.status != DeliveryOrderStatus.delivered &&
            o.status != DeliveryOrderStatus.canceled)
        .length;
    final delayed = opportunities
        .where((o) => o.status == DeliveryOrderStatus.dispatchPending)
        .length;
    return _HubScaffold(
      title: 'Business Live',
      summary: 'Monitor active routes and high-priority service events.',
      metrics: [
        opportunitiesAsync.isLoading
            ? 'Live deliveries: loading...'
            : opportunitiesAsync.hasError
                ? 'Live deliveries: unavailable'
                : 'Live deliveries: $active',
        opportunitiesAsync.isLoading
            ? 'Dispatched tasks: loading...'
            : opportunitiesAsync.hasError
                ? 'Dispatched tasks: unavailable'
                : 'Dispatched tasks: $delayed',
        'Incident reports: 0',
      ],
    );
  }
}

class BusinessConnectHubScreen extends ConsumerWidget {
  const BusinessConnectHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final uid = auth.userId ?? '';
    final isSignedIn = uid.isNotEmpty;
    final opportunitiesAsync = ref.watch(deliveryOpportunitiesProvider);
    final opportunities =
        opportunitiesAsync.valueOrNull ?? const <DeliveryOrder>[];
    final eventsAsync = ref.watch(businessEventsStreamProvider(uid));
    final events = eventsAsync.valueOrNull ?? const [];
    return _HubScaffold(
      title: 'Business Connect',
      summary: 'Partnerships, lead pipeline, and network collaboration.',
      metrics: [
        opportunitiesAsync.isLoading
            ? 'New leads: loading...'
            : opportunitiesAsync.hasError
                ? 'New leads: unavailable'
                : 'New leads: ${opportunities.take(10).length}',
        !isSignedIn
            ? 'Partner events: sign in required'
            : eventsAsync.isLoading
                ? 'Partner events: loading...'
                : eventsAsync.hasError
                    ? 'Partner events: unavailable'
                    : 'Partner events: ${events.length}',
        'Referrals this month: ${events.where((e) => e.date.month == DateTime.now().month).length}',
      ],
    );
  }
}

class BusinessProfileHubScreen extends ConsumerWidget {
  const BusinessProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final uid = auth.userId ?? '';
    final isSignedIn = uid.isNotEmpty;
    final verif = ref.watch(verifProvider);
    final progressAsync = isSignedIn
        ? ref.watch(walkerTrainingProgressProvider(uid)).whenData((p) => p)
        : const AsyncValue<WalkerTrainingProgress?>.data(null);
    final progress = progressAsync.valueOrNull;
    final approved = verif.items.values
        .where((v) => v.status == VerifStatus.approved)
        .length;
    return _HubScaffold(
      title: 'Business Profile',
      summary: 'Brand profile quality, trust posture, and listing strength.',
      metrics: [
        !isSignedIn
            ? 'Profile completion: sign in required'
            : progressAsync.isLoading
                ? 'Profile completion: loading...'
                : progressAsync.hasError
                    ? 'Profile completion: unavailable'
                    : 'Profile completion: ${progress?.completedModuleIds.isNotEmpty == true ? 'in progress' : 'started'}',
        'Trust checks approved: $approved',
        !isSignedIn
            ? 'Delivery certification: sign in required'
            : progressAsync.isLoading
                ? 'Delivery certification: checking...'
                : progressAsync.hasError
                    ? 'Delivery certification: unavailable'
                    : 'Delivery certification: ${progress?.certifiedForDelivery == true ? 'active' : 'pending'}',
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
