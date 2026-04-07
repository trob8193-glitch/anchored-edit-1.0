import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/training_repository.dart';

class DeliveryLicenseScreen extends ConsumerWidget {
  const DeliveryLicenseScreen({
    super.key,
    required this.uid,
  });

  final String uid;

  const DeliveryLicenseScreen.forUid({
    super.key,
    required this.uid,
  });

  static const _bg = Color(0xFF0D1117);
  static const _card = Color(0xFF161B22);
  static const _accent = Color(0xFF00C853);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(walkerTrainingProgressProvider(uid));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Delivery License', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: progressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _accent),
        ),
        error: (e, _) => Center(
          child: Text('Could not load license: $e', style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (progress) {
          final certified = progress.certifiedForDelivery;
          final license = progress.licenseNumber ?? 'Not issued yet';
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: _card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            certified ? Icons.verified : Icons.hourglass_empty,
                            color: certified ? _accent : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            certified ? 'Delivery Certified' : 'Certification In Progress',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Walker ID: $uid', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text('License Number: $license', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        'Training Score: ${progress.certificationScore?.toStringAsFixed(0) ?? 'N/A'}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: _card,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This screen confirms delivery eligibility and can be used by operations teams for quick status checks.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
