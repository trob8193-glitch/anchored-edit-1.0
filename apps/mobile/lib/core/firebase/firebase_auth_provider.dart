import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FirebaseAuthStatus { idle, loading, authenticated, error }

class FirebaseAuthState {
  const FirebaseAuthState({
    this.userId,
    this.displayName,
    this.email,
    this.role = 'owner',
    this.status = FirebaseAuthStatus.idle,
  });

  final String? userId;
  final String? displayName;
  final String? email;
  final String role;
  final FirebaseAuthStatus status;

  bool get isAuthenticated => (userId ?? '').isNotEmpty;

  FirebaseAuthState copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? role,
    FirebaseAuthStatus? status,
  }) {
    return FirebaseAuthState(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}

class FirebaseAuthNotifier extends StateNotifier<FirebaseAuthState> {
  FirebaseAuthNotifier() : super(const FirebaseAuthState());

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: FirebaseAuthStatus.loading);
    state = state.copyWith(
      userId: state.userId ?? 'demo-user',
      email: email,
      displayName: state.displayName ?? email.split('@').first,
      status: FirebaseAuthStatus.authenticated,
    );
    return null;
  }

  Future<String?> signInWithBackendOnly({
    required String email,
    required String password,
  }) {
    return signIn(email: email, password: password);
  }

  Future<String?> signUp({
    required String email,
    required String password,
    String? displayName,
    String? role,
  }) async {
    state = state.copyWith(status: FirebaseAuthStatus.loading);
    state = state.copyWith(
      userId: state.userId ?? 'demo-user',
      email: email,
      displayName: displayName ?? email.split('@').first,
      role: role ?? state.role,
      status: FirebaseAuthStatus.authenticated,
    );
    return null;
  }

  Future<void> signOut() async {
    state = const FirebaseAuthState(status: FirebaseAuthStatus.idle);
  }
}

final firebaseAuthNotifierProvider =
    StateNotifierProvider<FirebaseAuthNotifier, FirebaseAuthState>((ref) {
  return FirebaseAuthNotifier();
});
