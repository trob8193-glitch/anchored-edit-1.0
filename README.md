# Anchored

Anchored is a Flutter app focused on location-based territory gameplay with role-based surfaces and delivery/training modules.

## Project Status

- Branch: `main`
- CI: GitHub Actions workflow at `.github/workflows/flutter-ci.yml`
- Local quality gate: `flutter analyze` and `flutter test --no-pub`

## Local Development

1. Install Flutter stable.
2. Run dependency install:

```bash
flutter pub get
```

3. Run static checks:

```bash
flutter analyze
flutter test --no-pub
```

4. Launch app:

```bash
flutter run
```

## Production and Compliance Docs

- Privacy policy: `docs/PRIVACY_POLICY.md`
- Terms of service: `docs/TERMS_OF_SERVICE.md`
- Permissions rationale: `docs/PERMISSIONS_MATRIX.md`

## Release Notes

- Ensure production Firebase keys/config are set for your target environment.
- Re-validate permissions and disclosure text before each store submission.
