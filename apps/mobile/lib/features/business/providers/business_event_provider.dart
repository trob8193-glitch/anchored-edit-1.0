import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessEvent {
  const BusinessEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
}

class BusinessEventNotifier extends StateNotifier<List<BusinessEvent>> {
  BusinessEventNotifier() : super(const []);

  void addEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
  }) {
    final event = BusinessEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      location: location,
    );
    state = [event, ...state];
  }
}

final businessEventNotifierProvider = StateNotifierProvider.family<
    BusinessEventNotifier, List<BusinessEvent>, String>((ref, uid) {
  return BusinessEventNotifier();
});

final businessEventsStreamProvider =
    Provider.family<AsyncValue<List<BusinessEvent>>, String>((ref, uid) {
  final events = ref.watch(businessEventNotifierProvider(uid));
  return AsyncValue.data(events);
});
