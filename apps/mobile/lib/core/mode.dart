enum AppMode {
  owner,
  walker,
  business,
  admin,
}

String modeLabel(AppMode mode) {
  switch (mode) {
    case AppMode.owner:
      return 'Owner';
    case AppMode.walker:
      return 'Walker';
    case AppMode.business:
      return 'Business';
    case AppMode.admin:
      return 'Admin';
  }
}
