class SavedCredentials {
  const SavedCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class SavedCredentialsService {
  static SavedCredentials? _user;
  static SavedCredentials? _admin;

  Future<SavedCredentials?> loadUserCredentials() async {
    return _user;
  }

  Future<void> saveUserCredentials(String email, String password) async {
    _user = SavedCredentials(email: email, password: password);
  }

  Future<void> clearUserCredentials() async {
    _user = null;
  }

  Future<SavedCredentials?> loadAdminCredentials() async {
    return _admin;
  }

  Future<void> saveAdminCredentials(String email, String password) async {
    _admin = SavedCredentials(email: email, password: password);
  }

  Future<void> clearAdminCredentials() async {
    _admin = null;
  }
}
