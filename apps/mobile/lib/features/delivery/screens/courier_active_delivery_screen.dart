import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/delivery_models.dart';
import '../repositories/delivery_repository.dart';

class CourierActiveDeliveryScreen extends ConsumerStatefulWidget {
  const CourierActiveDeliveryScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<CourierActiveDeliveryScreen> createState() =>
      _CourierActiveDeliveryScreenState();
}

class _CourierActiveDeliveryScreenState
    extends ConsumerState<CourierActiveDeliveryScreen> {
  static const _bg = Color(0xFF0D1117);
  static const _card = Color(0xFF161B22);
  static const _accent = Color(0xFF00C853);

  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _timeline(DeliveryOrderStatus status) {
    const steps = [
      DeliveryOrderStatus.courierAssigned,
      DeliveryOrderStatus.pickupVerified,
      DeliveryOrderStatus.courierEnRouteToDropoff,
      DeliveryOrderStatus.delivered,
    ];

    final idx = steps.indexOf(status);
    return Column(
      children: List.generate(
        steps.length,
        (i) {
          final done = idx >= i || status == DeliveryOrderStatus.delivered;
          return ListTile(
            dense: true,
            leading: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? _accent : Colors.white30,
            ),
            title: Text(
              steps[i].displayLabel,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(deliveryOrderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Active Delivery', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _accent),
        ),
        error: (e, _) => Center(
          child: Text('Could not load order: $e', style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (order) {
          if (order == null) {
            return const Center(
              child: Text('Order not found.', style: TextStyle(color: Colors.white70)),
            );
          }

          final repo = ref.read(deliveryRepositoryProvider);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                color: _card,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.vendorName ?? 'Vendor',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        order.destinationAddress.isEmpty
                            ? 'Destination set at pickup'
                            : order.destinationAddress,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text('Order ID: ${order.id}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('Items: ${order.items.length}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('Total: ${order.pricing.totalFormatted}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: _card,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _timeline(order.status),
                ),
              ),
              const SizedBox(height: 12),
              if (order.status == DeliveryOrderStatus.courierAssigned)
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => repo.confirmPickup(order.id)),
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  child: const Text('Confirm Pickup'),
                ),
              if (order.status == DeliveryOrderStatus.pickupVerified)
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => repo.startDeliveryRoute(order.id)),
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  child: const Text('Start Delivery Route'),
                ),
              if (order.status == DeliveryOrderStatus.courierEnRouteToDropoff ||
                  order.status == DeliveryOrderStatus.deliveryArrived)
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => repo.completeDelivery(orderId: order.id, proofUrls: const [])),
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  child: const Text('Mark Delivered'),
                ),
              if (order.status != DeliveryOrderStatus.delivered &&
                  order.status != DeliveryOrderStatus.canceled)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => repo.cancelOrder(order.id, 'Canceled by courier')),
                  child: const Text('Cancel Delivery', style: TextStyle(color: Colors.redAccent)),
                ),
            ],
          );
        },
      ),
    );
  }
}
