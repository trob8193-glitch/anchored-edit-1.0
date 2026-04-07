import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_auth_provider.dart';
import '../business/providers/business_event_provider.dart';
import '../delivery/models/delivery_models.dart';
import '../delivery/repositories/delivery_repository.dart';
import '../delivery/repositories/training_repository.dart';

class BusinessHomeScreen extends ConsumerWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthNotifierProvider);
    final uid = auth.userId ?? '';
    final isSignedIn = uid.isNotEmpty;
    final isAuthLoading = auth.status == FirebaseAuthStatus.loading;

    final opportunitiesAsync = ref.watch(deliveryOpportunitiesProvider);
    final progressAsync = isSignedIn
        ? ref.watch(walkerTrainingProgressProvider(uid)).whenData((p) => p)
        : const AsyncValue<WalkerTrainingProgress?>.data(null);
    final eventsAsync = ref.watch(businessEventsStreamProvider(uid));

    final openOrders = opportunitiesAsync.valueOrNull?.length ?? 0;
    final events = eventsAsync.valueOrNull ?? const [];
    final myProgress = progressAsync.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Business Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _BusinessCard(
            title: 'Operations Snapshot',
            lines: [
              opportunitiesAsync.isLoading
                  ? 'Open delivery opportunities: loading...'
                  : opportunitiesAsync.hasError
                      ? 'Open delivery opportunities: unavailable'
                      : 'Open delivery opportunities: $openOrders',
              eventsAsync.isLoading
                  ? 'Business events scheduled: loading...'
                  : eventsAsync.hasError
                      ? 'Business events scheduled: unavailable'
                      : 'Business events scheduled: ${events.length}',
              isAuthLoading
                  ? 'Signed in: connecting...'
                  : isSignedIn
                      ? 'Signed in: yes'
                      : 'Signed in: no',
            ],
          ),
          _BusinessCard(
            title: 'Team',
            lines: [
              !isSignedIn
                  ? 'My modules complete: sign in required'
                  : progressAsync.isLoading
                      ? 'My modules complete: loading...'
                      : progressAsync.hasError
                          ? 'My modules complete: unavailable'
                          : 'My modules complete: ${myProgress?.completedModuleIds.length ?? 0}',
              !isSignedIn
                  ? 'Certified for delivery: sign in required'
                  : progressAsync.isLoading
                      ? 'Certified for delivery: checking...'
                      : progressAsync.hasError
                          ? 'Certified for delivery: unavailable'
                          : 'Certified for delivery: ${myProgress?.certifiedForDelivery == true ? 'yes' : 'no'}',
              !isSignedIn
                  ? 'Final exam unlocked: sign in required'
                  : progressAsync.isLoading
                      ? 'Final exam unlocked: checking...'
                      : progressAsync.hasError
                          ? 'Final exam unlocked: unavailable'
                          : 'Final exam unlocked: ${myProgress?.finalExamUnlocked == true ? 'yes' : 'no'}',
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.title, required this.lines});

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
