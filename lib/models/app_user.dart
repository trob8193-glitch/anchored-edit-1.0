/// Lightweight representation of a signed-in player.
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    this.isAnonymous = false,
  });

  final String uid;
  final String displayName;
  final bool isAnonymous;

  AppUser copyWith({String? displayName}) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous,
    );
  }
}
