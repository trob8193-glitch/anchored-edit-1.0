import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_auth_provider.dart';
import '../delivery/models/delivery_models.dart';
import '../delivery/repositories/delivery_repository.dart';
import '../delivery/repositories/training_repository.dart';
import '../jobs/job_provider.dart';
import '../payments/providers/payment_provider.dart';
import '../verification/verification_provider.dart';

class WalkerHomeHubScreen extends ConsumerWidget {
  const WalkerHomeHubScreen({super.key});

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
    final payment = ref.watch(paymentProvider).connectAccount;
    return _HubScaffold(
      title: 'Walker Home',
      summary: 'Your queue, schedule, and active service workload.',
      metrics: [
        opportunitiesAsync.isLoading
            ? 'Open opportunities: loading...'
            : opportunitiesAsync.hasError
                ? 'Open opportunities: unavailable'
                : 'Open opportunities: ${opportunities.length}',
        'Accepted jobs: ${jobs.where((j) => j['status'] == 'accepted').length}',
        isAuthLoading
            ? 'Payout setup: connecting account...'
            : !isSignedIn
                ? 'Payout setup: not connected'
                : 'Payout setup: ${payment?.payoutsEnabled == true ? 'enabled' : 'pending'}',
      ],
    );
  }
}

class WalkerLiveHubScreen extends ConsumerWidget {
  const WalkerLiveHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider).jobs;
    final active = jobs.where((j) => j['status'] == 'accepted').length;
    final completed = jobs.where((j) => j['status'] == 'completed').length;
    return _HubScaffold(
      title: 'Walker Live',
      summary: 'Track live routes, check-ins, and timing accuracy.',
      metrics: [
        'Live sessions: $active',
        'Completed sessions today: $completed',
        active == 0 ? 'ETA variance: n/a' : 'ETA variance: on track',
      ],
    );
  }
}

class WalkerPawMediaHubScreen extends ConsumerWidget {
  const WalkerPawMediaHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider).jobs;
    final completed = jobs.where((j) => j['status'] == 'completed').length;
    final accepted = jobs.where((j) => j['status'] == 'accepted').length;
    return _HubScaffold(
      title: 'Walker PawMedia',
      summary: 'Manage walk photos and owner-ready updates.',
      metrics: [
        'Photo-ready sessions: $completed',
        'Draft updates needed: $accepted',
        'Shared updates: ${completed > 0 ? completed : 0}',
      ],
    );
  }
}

class WalkerTrainingHubScreen extends ConsumerWidget {
  const WalkerTrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final uid = auth.userId ?? '';
    final isSignedIn = uid.isNotEmpty;
    final progressAsync = isSignedIn
        ? ref.watch(walkerTrainingProgressProvider(uid)).whenData((p) => p)
        : const AsyncValue<WalkerTrainingProgress?>.data(null);
    final progress = progressAsync.valueOrNull;
    return _HubScaffold(
      title: 'Walker Training',
      summary: 'Certification progress and skill development modules.',
      metrics: [
        !isSignedIn
            ? 'Modules complete: sign in required'
            : progressAsync.isLoading
                ? 'Modules complete: loading...'
                : progressAsync.hasError
                    ? 'Modules complete: unavailable'
                    : 'Modules complete: ${progress?.completedModuleIds.length ?? 0}',
        !isSignedIn
            ? 'Final exam unlocked: sign in required'
            : progressAsync.isLoading
                ? 'Final exam unlocked: checking...'
                : progressAsync.hasError
                    ? 'Final exam unlocked: unavailable'
                    : 'Final exam unlocked: ${progress?.finalExamUnlocked == true ? 'yes' : 'no'}',
        !isSignedIn
            ? 'Certified for delivery: sign in required'
            : progressAsync.isLoading
                ? 'Certified for delivery: checking...'
                : progressAsync.hasError
                    ? 'Certified for delivery: unavailable'
                    : 'Certified for delivery: ${progress?.certifiedForDelivery == true ? 'yes' : 'no'}',
      ],
    );
  }
}

class WalkerProfileHubScreen extends ConsumerWidget {
  const WalkerProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final isSignedIn = (auth.userId ?? '').isNotEmpty;
    final verif = ref.watch(verifProvider);
    final approved = verif.items.values
        .where((v) => v.status == VerifStatus.approved)
        .length;
    final payment = ref.watch(paymentProvider).connectAccount;
    return _HubScaffold(
      title: 'Walker Profile',
      summary: 'Public profile quality, trust, and conversion metrics.',
      metrics: [
        'Trust checks approved: $approved',
        !isSignedIn
            ? 'Connect details submitted: sign in required'
            : 'Connect details submitted: ${payment?.detailsSubmitted == true ? 'yes' : 'no'}',
        !isSignedIn
            ? 'Payouts enabled: sign in required'
            : 'Payouts enabled: ${payment?.payoutsEnabled == true ? 'yes' : 'no'}',
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
