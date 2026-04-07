import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/delivery_models.dart';
import '../repositories/delivery_repository.dart';
import 'courier_active_delivery_screen.dart';

class CourierOpportunitiesScreen extends ConsumerWidget {
  const CourierOpportunitiesScreen({super.key});

  static const _bg = Color(0xFF0D1117);
  static const _card = Color(0xFF161B22);
  static const _accent = Color(0xFF00C853);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(deliveryOpportunitiesProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Courier Opportunities',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: opportunitiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Could not load opportunities: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No open opportunities right now.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final order = orders[i];
              return Card(
                color: _card,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    order.vendorName ?? 'Vendor',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${order.status.displayLabel} � ${order.pricing.totalFormatted}',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CourierActiveDeliveryScreen(orderId: order.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
