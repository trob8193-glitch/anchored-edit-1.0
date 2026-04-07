# Permissions Matrix

Last updated: 2026-04-06

This document maps declared permissions to app behavior and user-facing rationale.

## Android Permissions

- INTERNET
  - Purpose: API and backend communication.
  - User impact: required for online features.

- ACCESS_FINE_LOCATION
  - Purpose: territory gameplay and map interactions.
  - User impact: enables nearby zone detection and map placement.

- ACCESS_COARSE_LOCATION
  - Purpose: fallback location accuracy when precise location is unavailable.
  - User impact: enables approximate location features.

- ACCESS_BACKGROUND_LOCATION
  - Purpose: background territory and contest notifications.
  - User impact: only needed for background location experiences.
  - Store note: requires explicit disclosure and strong feature justification.

## iOS Usage Descriptions

- NSLocationWhenInUseUsageDescription
  - Purpose: claim territory zones and map-based gameplay while app is active.

- NSLocationAlwaysAndWhenInUseUsageDescription
  - Purpose: notify users about nearby contested zones in background.

- NSLocationAlwaysUsageDescription
  - Purpose: maintain ownership tracking while app is not foregrounded.

## Compliance Checklist

- Ensure in-app permission prompts match these purposes.
- Ensure store listing privacy text matches real data handling.
- Remove any unused permissions before release.
- Re-verify declarations before each production submission.
