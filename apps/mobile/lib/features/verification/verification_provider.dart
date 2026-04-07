import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VerifType {
  govtId,
  phone,
  email,
  address,
  backgroundCheck,
  insurance,
  walkerCert,
  businessLicense,
  businessInsurance,
  taxId,
  healthCert,
  vaccination,
  microchip,
  breedRegistration,
  dogLicense,
}

enum VerifStatus { notSubmitted, pending, approved, rejected }

class VerifItem {
  const VerifItem({
    required this.type,
    this.status = VerifStatus.notSubmitted,
    this.submittedValue,
    this.submittedAt,
    this.adminNote,
  });

  final VerifType type;
  final VerifStatus status;
  final String? submittedValue;
  final DateTime? submittedAt;
  final String? adminNote;

  VerifItem copyWith({
    VerifStatus? status,
    String? submittedValue,
    DateTime? submittedAt,
    String? adminNote,
    bool clearAdminNote = false,
  }) {
    return VerifItem(
      type: type,
      status: status ?? this.status,
      submittedValue: submittedValue ?? this.submittedValue,
      submittedAt: submittedAt ?? this.submittedAt,
      adminNote: clearAdminNote ? null : (adminNote ?? this.adminNote),
    );
  }
}

class VerifState {
  const VerifState({this.items = const {}});

  final Map<VerifType, VerifItem> items;

  VerifItem itemOf(VerifType type) {
    return items[type] ?? VerifItem(type: type);
  }

  VerifState copyWith({Map<VerifType, VerifItem>? items}) {
    return VerifState(items: items ?? this.items);
  }
}

class VerifNotifier extends StateNotifier<VerifState> {
  VerifNotifier() : super(const VerifState());

  Future<void> submit(VerifType type, String value) async {
    final next = Map<VerifType, VerifItem>.from(state.items);
    next[type] = VerifItem(
      type: type,
      status: VerifStatus.pending,
      submittedValue: value,
      submittedAt: DateTime.now(),
    );
    state = state.copyWith(items: next);
  }
}

final verifProvider = StateNotifierProvider<VerifNotifier, VerifState>((ref) {
  return VerifNotifier();
});
