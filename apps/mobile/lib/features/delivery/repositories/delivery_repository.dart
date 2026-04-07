import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/delivery_models.dart';

class DeliveryRepository {
  DeliveryRepository._() {
    if (_orders.isEmpty) {
      _orders.addAll(_seedOrders);
    }
  }

  static final DeliveryRepository instance = DeliveryRepository._();

  static final List<DeliveryOrder> _orders = <DeliveryOrder>[];
  final StreamController<void> _updates = StreamController<void>.broadcast();

  static List<DeliveryOrder> get _seedOrders => <DeliveryOrder>[
        DeliveryOrder(
          id: 'ord_1001',
          customerId: 'demo-user',
          vendorName: 'Paw Pantry',
          status: DeliveryOrderStatus.dispatchPending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
          destinationAddress: '124 Harbor St',
          items: const <DeliveryOrderItem>[
            DeliveryOrderItem(
              itemId: 'itm_food_01',
              title: 'Premium Kibble 10lb',
              quantity: 1,
              unitPriceCents: 4599,
            ),
          ],
          pricing: const DeliveryPricing(
            subtotalCents: 4599,
            deliveryFeeCents: 799,
            taxCents: 368,
            totalCents: 5766,
          ),
        ),
        DeliveryOrder(
          id: 'ord_1002',
          customerId: 'demo-user',
          courierId: 'walker-1',
          vendorName: 'Leash Labs',
          status: DeliveryOrderStatus.courierAssigned,
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          destinationAddress: '881 Grove Ave',
          items: const <DeliveryOrderItem>[
            DeliveryOrderItem(
              itemId: 'itm_treat_02',
              title: 'Training Treat Pack',
              quantity: 2,
              unitPriceCents: 1299,
            ),
          ],
          pricing: const DeliveryPricing(
            subtotalCents: 2598,
            deliveryFeeCents: 699,
            taxCents: 264,
            totalCents: 3561,
          ),
        ),
      ];

  Stream<List<DeliveryOrder>> watchDeliveryOpportunities() async* {
    yield _openOrders();
    yield* _updates.stream.map((_) => _openOrders());
  }

  Stream<List<DeliveryOrder>> watchCustomerOrders(String customerId) async* {
    yield _orders
        .where((o) => o.customerId == customerId)
        .toList(growable: false);
    yield* _updates.stream.map((_) => _orders
        .where((o) => o.customerId == customerId)
        .toList(growable: false));
  }

  Stream<DeliveryOrder?> watchOrderById(String orderId) async* {
    yield _orders.where((o) => o.id == orderId).firstOrNull;
    yield* _updates.stream
        .map((_) => _orders.where((o) => o.id == orderId).firstOrNull);
  }

  Future<void> confirmPickup(String orderId) {
    return _setStatus(orderId, DeliveryOrderStatus.pickupVerified);
  }

  Future<void> startDeliveryRoute(String orderId) {
    return _setStatus(orderId, DeliveryOrderStatus.courierEnRouteToDropoff);
  }

  Future<void> completeDelivery({
    required String orderId,
    required List<String> proofUrls,
  }) {
    return _setStatus(orderId, DeliveryOrderStatus.delivered);
  }

  Future<void> cancelOrder(String orderId, String reason) {
    return _setStatus(orderId, DeliveryOrderStatus.canceled);
  }

  Future<void> _setStatus(String orderId, DeliveryOrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) return;
    final current = _orders[index];
    _orders[index] = DeliveryOrder(
      id: current.id,
      customerId: current.customerId,
      courierId: current.courierId,
      vendorName: current.vendorName,
      status: status,
      createdAt: current.createdAt,
      pricing: current.pricing,
      destinationAddress: current.destinationAddress,
      items: current.items,
    );
    _updates.add(null);
  }

  List<DeliveryOrder> _openOrders() {
    return _orders
        .where((o) =>
            o.status != DeliveryOrderStatus.delivered &&
            o.status != DeliveryOrderStatus.canceled)
        .toList(growable: false);
  }
}

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository.instance;
});

final deliveryOpportunitiesProvider =
    StreamProvider<List<DeliveryOrder>>((ref) {
  return ref.watch(deliveryRepositoryProvider).watchDeliveryOpportunities();
});

final customerDeliveryOrdersProvider =
    StreamProvider.family<List<DeliveryOrder>, String>((ref, customerId) {
  return ref.watch(deliveryRepositoryProvider).watchCustomerOrders(customerId);
});

final deliveryOrderDetailProvider =
    StreamProvider.family<DeliveryOrder?, String>((ref, orderId) {
  return ref.watch(deliveryRepositoryProvider).watchOrderById(orderId);
});

extension _IterableFirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
