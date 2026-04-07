import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_auth_provider.dart';
import '../delivery/models/delivery_models.dart';
import '../delivery/repositories/delivery_repository.dart';
import '../jobs/job_provider.dart';
import '../verification/verification_provider.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

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
    final verif = ref.watch(verifProvider);

    final orders = ordersAsync.valueOrNull ?? const <DeliveryOrder>[];
    final activeOrders = orders
        .where((o) =>
            o.status != DeliveryOrderStatus.delivered &&
            o.status != DeliveryOrderStatus.canceled)
        .length;
    final pendingJobs = jobs.where((j) => j['status'] == 'pending').length;
    final approvedVerifs = verif.items.values
        .where((v) => v.status == VerifStatus.approved)
        .length;
    final pendingVerifs =
        verif.items.values.where((v) => v.status == VerifStatus.pending).length;

    final orderSyncLabel = isAuthLoading
        ? 'Sync: connecting account...'
        : !isSignedIn
            ? 'Sync: sign in to load live orders'
            : ordersAsync.isLoading
                ? 'Sync: loading live orders...'
                : ordersAsync.hasError
                    ? 'Sync: orders temporarily unavailable'
                    : 'Sync: live';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Owner Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _InfoCard(
            title: 'Today',
            lines: [
              !isSignedIn
                  ? 'Orders: sign in required'
                  : ordersAsync.isLoading
                      ? 'Orders: loading...'
                      : ordersAsync.hasError
                          ? 'Orders: unavailable'
                          : 'Orders: ${orders.length}',
              !isSignedIn
                  ? 'Active orders: sign in required'
                  : ordersAsync.isLoading
                      ? 'Active orders: loading...'
                      : ordersAsync.hasError
                          ? 'Active orders: unavailable'
                          : 'Active orders: $activeOrders',
              'Pending jobs: $pendingJobs',
            ],
          ),
          _InfoCard(
            title: 'Trust and Verification',
            lines: [
              'Approved checks: $approvedVerifs',
              'Pending checks: $pendingVerifs',
              isAuthLoading
                  ? 'Account connected: connecting...'
                  : !isSignedIn
                      ? 'Account connected: no'
                      : 'Account connected: yes',
              orderSyncLabel,
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF212121),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child:
                    Text(line, style: const TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
