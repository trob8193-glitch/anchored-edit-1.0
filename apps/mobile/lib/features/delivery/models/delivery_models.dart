import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryOrderStatus {
  orderConfirmed,
  dispatchPending,
  courierAssigned,
  courierEnRouteToPickup,
  pickupReady,
  pickupVerified,
  courierEnRouteToDropoff,
  deliveryArrived,
  delivered,
  canceled,
}

extension DeliveryOrderStatusLabel on DeliveryOrderStatus {
  String get displayLabel {
    switch (this) {
      case DeliveryOrderStatus.orderConfirmed:
        return 'Order Confirmed';
      case DeliveryOrderStatus.dispatchPending:
        return 'Dispatch Pending';
      case DeliveryOrderStatus.courierAssigned:
        return 'Courier Assigned';
      case DeliveryOrderStatus.courierEnRouteToPickup:
        return 'En Route To Pickup';
      case DeliveryOrderStatus.pickupReady:
        return 'Pickup Ready';
      case DeliveryOrderStatus.pickupVerified:
        return 'Pickup Verified';
      case DeliveryOrderStatus.courierEnRouteToDropoff:
        return 'En Route To Dropoff';
      case DeliveryOrderStatus.deliveryArrived:
        return 'Arrived';
      case DeliveryOrderStatus.delivered:
        return 'Delivered';
      case DeliveryOrderStatus.canceled:
        return 'Canceled';
    }
  }
}

DateTime _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.status,
    required this.createdAt,
    this.pricing = const DeliveryPricing(),
    this.destinationAddress = '',
    this.items = const [],
    this.customerId,
    this.courierId,
    this.vendorName,
  });

  final String id;
  final String? customerId;
  final String? courierId;
  final String? vendorName;
  final DeliveryOrderStatus status;
  final DateTime createdAt;
  final DeliveryPricing pricing;
  final String destinationAddress;
  final List<DeliveryOrderItem> items;

  factory DeliveryOrder.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final statusRaw = (data['status'] as String?) ?? DeliveryOrderStatus.orderConfirmed.name;
    final status = DeliveryOrderStatus.values.firstWhere(
      (s) => s.name == statusRaw,
      orElse: () => DeliveryOrderStatus.orderConfirmed,
    );
    return DeliveryOrder(
      id: doc.id,
      customerId: data['customerId'] as String?,
      courierId: data['courierId'] as String?,
      vendorName: data['vendorName'] as String?,
      status: status,
      createdAt: _toDate(data['createdAt']),
      pricing: DeliveryPricing.fromMap(
          (data['pricing'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{}),
      destinationAddress: (data['destinationAddress'] as String?) ?? '',
      items: ((data['items'] as List?) ?? const [])
          .map((e) => DeliveryOrderItem.fromMap(
              (e as Map?)?.cast<String, dynamic>() ??
                  const <String, dynamic>{}))
          .toList(),
    );
  }
}

class VendorCatalogItem {
  const VendorCatalogItem({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.priceCents,
    this.isActive = true,
  });

  final String id;
  final String vendorId;
  final String title;
  final int priceCents;
  final bool isActive;

  factory VendorCatalogItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return VendorCatalogItem(
      id: doc.id,
      vendorId: (data['vendorId'] as String?) ?? '',
      title: (data['title'] as String?) ?? 'Item',
      priceCents: (data['priceCents'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] == true,
    );
  }
}

enum DeliveryDestinationType { customerAddress, pickupSpot }

class DeliveryCartEntry {
  const DeliveryCartEntry({required this.item, required this.quantity});

  final VendorCatalogItem item;
  final int quantity;
}

class DeliveryCart {
  const DeliveryCart({
    this.vendorId,
    this.vendorName,
    this.destinationType = DeliveryDestinationType.customerAddress,
    this.destinationAddress,
    this.entries = const [],
  });

  final String? vendorId;
  final String? vendorName;
  final DeliveryDestinationType destinationType;
  final String? destinationAddress;
  final List<DeliveryCartEntry> entries;

  bool get isEmpty => entries.isEmpty;
}

class DeliveryPricing {
  const DeliveryPricing({
    this.subtotalCents = 0,
    this.deliveryFeeCents = 0,
    this.taxCents = 0,
    this.totalCents = 0,
  });

  final int subtotalCents;
  final int deliveryFeeCents;
  final int taxCents;
  final int totalCents;

  String get totalFormatted => '\$${(totalCents / 100).toStringAsFixed(2)}';

  factory DeliveryPricing.fromMap(Map<String, dynamic> map) {
    return DeliveryPricing(
      subtotalCents: (map['subtotalCents'] as num?)?.toInt() ?? 0,
      deliveryFeeCents: (map['deliveryFeeCents'] as num?)?.toInt() ?? 0,
      taxCents: (map['taxCents'] as num?)?.toInt() ?? 0,
      totalCents: (map['totalCents'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subtotalCents': subtotalCents,
      'deliveryFeeCents': deliveryFeeCents,
      'taxCents': taxCents,
      'totalCents': totalCents,
    };
  }
}

class DeliveryOrderItem {
  const DeliveryOrderItem({
    required this.itemId,
    required this.title,
    required this.quantity,
    required this.unitPriceCents,
  });

  final String itemId;
  final String title;
  final int quantity;
  final int unitPriceCents;

  factory DeliveryOrderItem.fromMap(Map<String, dynamic> map) {
    return DeliveryOrderItem(
      itemId: (map['itemId'] as String?) ?? '',
      title: (map['title'] as String?) ?? 'Item',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPriceCents: (map['unitPriceCents'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'title': title,
      'quantity': quantity,
      'unitPriceCents': unitPriceCents,
    };
  }
}

class DeliveryTrainingModule {
  const DeliveryTrainingModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.isRequiredForCert,
    required this.durationMinutes,
    this.quizId,
    this.safetyNotes = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final bool isRequiredForCert;
  final int durationMinutes;
  final String? quizId;
  final List<String> safetyNotes;

  String get durationLabel => '${durationMinutes} min';

  factory DeliveryTrainingModule.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return DeliveryTrainingModule(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Module',
      subtitle: (data['subtitle'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'General',
      isRequiredForCert: data['isRequiredForCert'] == true,
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 10,
      quizId: data['quizId'] as String?,
      safetyNotes: ((data['safetyNotes'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class WalkerTrainingProgress {
  const WalkerTrainingProgress({
    required this.walkerId,
    this.completedModuleIds = const [],
    this.finalExamUnlocked = false,
    this.certifiedForDelivery = false,
    this.deliveryModeUnlocked = false,
    this.licenseNumber,
    this.certificationScore,
  });

  final String walkerId;
  final List<String> completedModuleIds;
  final bool finalExamUnlocked;
  final bool certifiedForDelivery;
  final bool deliveryModeUnlocked;
  final String? licenseNumber;
  final double? certificationScore;

  factory WalkerTrainingProgress.empty(String walkerId) {
    return WalkerTrainingProgress(walkerId: walkerId);
  }

  factory WalkerTrainingProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return WalkerTrainingProgress(
      walkerId: (data['walkerId'] as String?) ?? doc.id,
      completedModuleIds: ((data['completedModuleIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      finalExamUnlocked: data['finalExamUnlocked'] == true,
      certifiedForDelivery: data['certifiedForDelivery'] == true,
      deliveryModeUnlocked: data['deliveryModeUnlocked'] == true,
      licenseNumber: data['licenseNumber'] as String?,
      certificationScore: (data['certificationScore'] as num?)?.toDouble(),
    );
  }
}

enum QuestionType { singleChoice, multiChoice }

class DeliveryQuizOption {
  const DeliveryQuizOption({required this.id, required this.text});

  final String id;
  final String text;

  factory DeliveryQuizOption.fromMap(Map<String, dynamic> map) {
    return DeliveryQuizOption(
      id: (map['id'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
    );
  }
}

class DeliveryQuizQuestion {
  const DeliveryQuizQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    required this.options,
    required this.correctOptionIds,
    this.explanation = '',
  });

  final String id;
  final String prompt;
  final QuestionType type;
  final List<DeliveryQuizOption> options;
  final List<String> correctOptionIds;
  final String explanation;

  bool isCorrect(List<String> selected) {
    final a = selected.toSet();
    final b = correctOptionIds.toSet();
    return a.length == b.length && a.containsAll(b);
  }

  factory DeliveryQuizQuestion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final typeRaw = (data['type'] as String?) ?? 'singleChoice';
    final type = typeRaw == 'multiChoice'
        ? QuestionType.multiChoice
        : QuestionType.singleChoice;
    final optionsRaw = (data['options'] as List?) ?? const [];
    return DeliveryQuizQuestion(
      id: doc.id,
      prompt: (data['prompt'] as String?) ?? '',
      type: type,
      options: optionsRaw
          .map((e) => DeliveryQuizOption.fromMap(
              (e as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{}))
          .toList(),
      correctOptionIds: ((data['correctOptionIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      explanation: (data['explanation'] as String?) ?? '',
    );
  }
}

class DeliveryQuiz {
  const DeliveryQuiz({required this.id, required this.title, this.description = ''});

  final String id;
  final String title;
  final String description;

  factory DeliveryQuiz.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return DeliveryQuiz(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Quiz',
      description: (data['description'] as String?) ?? '',
    );
  }
}

class WalkerQuizAttempt {
  const WalkerQuizAttempt({
    required this.id,
    required this.walkerId,
    required this.quizId,
    required this.selectedAnswers,
    required this.scorePercent,
    required this.passed,
    required this.createdAt,
  });

  final String id;
  final String walkerId;
  final String quizId;
  final Map<String, List<String>> selectedAnswers;
  final double scorePercent;
  final bool passed;
  final DateTime createdAt;
}
