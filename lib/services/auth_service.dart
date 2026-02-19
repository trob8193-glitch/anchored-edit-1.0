import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// Wraps Firebase Auth for anonymous and email/password sign-in.
class AuthService {
  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AppUser? get appUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      displayName: user.displayName ??
          user.email?.split('@').first ??
          'Player_${user.uid.substring(0, 5)}',
      isAnonymous: user.isAnonymous,
    );
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> registerWithEmail(String email, String password,
      String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
