import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Anchor/Claim button shown when the player is within range of a territory.
class ClaimButton extends StatelessWidget {
  const ClaimButton({
    super.key,
    required this.isLoading,
    required this.isOwned,
    required this.canClaim,
    required this.onClaim,
    required this.onRelease,
  });

  final bool isLoading;

  /// True if the current user already owns the selected territory.
  final bool isOwned;

  /// True if the player is close enough to claim.
  final bool canClaim;

  final VoidCallback onClaim;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (isOwned) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.danger,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onRelease,
        icon: const Icon(Icons.link_off),
        label: const Text('Release'),
      );
    }

    return ElevatedButton.icon(
      onPressed: canClaim ? onClaim : null,
      icon: const Icon(Icons.anchor),
      label: Text(canClaim ? 'Anchor' : 'Too Far Away'),
    );
  }
}
