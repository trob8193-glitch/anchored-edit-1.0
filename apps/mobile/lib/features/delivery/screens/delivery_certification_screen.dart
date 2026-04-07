import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_auth_provider.dart';
import '../repositories/training_repository.dart';
import 'delivery_license_screen.dart';

class DeliveryCertificationScreen extends ConsumerWidget {
  const DeliveryCertificationScreen({super.key});

  static const _bg = Color(0xFF0D1117);
  static const _card = Color(0xFF161B22);
  static const _accent = Color(0xFF00C853);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseAuthNotifierProvider).userId ?? '';
    if (uid.isEmpty) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Text(
            'Sign in to view your delivery certification path.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final modulesAsync = ref.watch(deliveryModulesProvider);
    final progressAsync = ref.watch(walkerTrainingProgressProvider(uid));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Delivery Certification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: modulesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Could not load modules: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (modules) => progressAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _accent),
          ),
          error: (e, _) => Center(
            child: Text(
              'Could not load progress: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (progress) {
            final total = modules.length;
            final completed = modules
                .where((m) => progress.completedModuleIds.contains(m.id))
                .length;
            final ratio = total == 0 ? 0.0 : completed / total;

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completed / $total modules complete',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation(_accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...modules.map(
                  (m) {
                    final done = progress.completedModuleIds.contains(m.id);
                    return Card(
                      color: _card,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          done ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: done ? _accent : Colors.white38,
                        ),
                        title: Text(m.title, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          m.subtitle.isEmpty ? m.durationLabel : '${m.subtitle} • ${m.durationLabel}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        trailing: m.isRequiredForCert
                            ? const Chip(
                                label: Text('Required'),
                                visualDensity: VisualDensity.compact,
                              )
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (progress.certifiedForDelivery)
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeliveryLicenseScreen.forUid(uid: uid),
                      ),
                    ),
                    icon: const Icon(Icons.badge_outlined),
                    label: const Text('View License'),
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                  )
                else
                  FilledButton.icon(
                    onPressed: progress.finalExamUnlocked
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Final exam flow is being wired up next.'),
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.quiz_outlined),
                    label: Text(
                      progress.finalExamUnlocked
                          ? 'Final Exam Unlocked'
                          : 'Complete Required Modules First',
                    ),
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
