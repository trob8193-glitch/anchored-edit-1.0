import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/delivery_models.dart';

class TrainingRepository {
  const TrainingRepository._();

  static const TrainingRepository instance = TrainingRepository._();

  Future<List<DeliveryTrainingModule>> getModules() async {
    return const <DeliveryTrainingModule>[
      DeliveryTrainingModule(
        id: 'mod_safety_01',
        title: 'Safety First',
        subtitle: 'Core handling and incident prevention',
        description:
            'Learn pre-trip checks, safe handoffs, and emergency basics.',
        category: 'Safety',
        isRequiredForCert: true,
        durationMinutes: 18,
      ),
      DeliveryTrainingModule(
        id: 'mod_route_02',
        title: 'Route Discipline',
        subtitle: 'Efficient pickup/dropoff flow',
        description:
            'Optimize route order, traffic decisions, and ETA communication.',
        category: 'Operations',
        isRequiredForCert: true,
        durationMinutes: 15,
      ),
      DeliveryTrainingModule(
        id: 'mod_cx_03',
        title: 'Customer Experience',
        subtitle: 'High-trust communication habits',
        description:
            'Use clear updates, issue escalation, and proof-of-delivery best practices.',
        category: 'CX',
        isRequiredForCert: false,
        durationMinutes: 12,
      ),
    ];
  }

  Stream<WalkerTrainingProgress> watchWalkerProgress(String walkerId) async* {
    final modules = await getModules();
    final completedIds = modules
        .where((m) => m.isRequiredForCert)
        .map((m) => m.id)
        .toList(growable: false);

    yield WalkerTrainingProgress(
      walkerId: walkerId,
      completedModuleIds: completedIds,
      finalExamUnlocked: true,
      certifiedForDelivery: true,
      deliveryModeUnlocked: true,
      licenseNumber: 'DLV-${walkerId.toUpperCase()}-A1',
      certificationScore: 93,
    );
  }
}

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  return TrainingRepository.instance;
});

final deliveryModulesProvider =
    FutureProvider<List<DeliveryTrainingModule>>((ref) {
  return ref.watch(trainingRepositoryProvider).getModules();
});

final walkerTrainingProgressProvider =
    StreamProvider.family<WalkerTrainingProgress, String>((ref, walkerId) {
  return ref.watch(trainingRepositoryProvider).watchWalkerProgress(walkerId);
});
