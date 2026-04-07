import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectAccountStatus {
  const ConnectAccountStatus({
    required this.accountId,
    this.detailsSubmitted = false,
    this.payoutsEnabled = false,
  });

  final String accountId;
  final bool detailsSubmitted;
  final bool payoutsEnabled;
}

class PaymentState {
  const PaymentState({
    this.isLoading = false,
    this.error,
    this.connectAccount,
  });

  final bool isLoading;
  final String? error;
  final ConnectAccountStatus? connectAccount;

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    ConnectAccountStatus? connectAccount,
    bool clearConnectAccount = false,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      connectAccount: clearConnectAccount
          ? null
          : (connectAccount ?? this.connectAccount),
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  Future<void> fetchOrCreateConnectAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final existing = state.connectAccount;
      state = state.copyWith(
        isLoading: false,
        connectAccount: existing ??
            const ConnectAccountStatus(
              accountId: 'acct_demo_123',
              detailsSubmitted: false,
              payoutsEnabled: false,
            ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> getOnboardingLink() async {
    if (state.connectAccount == null) {
      await fetchOrCreateConnectAccount();
    }
    return 'https://dashboard.stripe.com/connect/onboarding';
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});
