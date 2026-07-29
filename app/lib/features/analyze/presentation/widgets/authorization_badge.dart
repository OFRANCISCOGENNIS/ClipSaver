/// The authorization-source badge (section 2.3).
///
/// Responsibility: make the legal basis of every analysis visible at a
/// glance — this badge is the product's core transparency promise, so it
/// is never optional and never abbreviated away.
library;

import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../core/domain/value_objects/license.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/authorization_source.dart';

/// Shows why a download is (or is not) authorized.
class AuthorizationBadge extends StatelessWidget {
  /// Creates the badge for [source], naming [license] when it is the basis.
  const AuthorizationBadge({required this.source, this.license, super.key});

  /// The legal basis of the verdict.
  final AuthorizationSource source;

  /// Detected license, shown instead of the generic label when present.
  final License? license;

  IconData get _icon => switch (source) {
        AuthorizationSource.officialApi => Icons.verified_outlined,
        AuthorizationSource.openLicense => Icons.public_outlined,
        AuthorizationSource.userOwned => Icons.person_outline,
        AuthorizationSource.directFile => Icons.link_outlined,
        AuthorizationSource.none => Icons.block_outlined,
      };

  /// Open-license badges name the actual license (e.g. "Licença CC-BY"),
  /// which is more informative than the generic source label.
  String _label(AppLocalizations l10n) =>
      source == AuthorizationSource.openLicense && license != null
          ? license!.label(l10n)
          : source.label(l10n);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final label = _label(l10n);
    final denied = source == AuthorizationSource.none;
    final color = denied ? VidoraColors.error : VidoraColors.success;

    return Semantics(
      label: denied
          ? l10n.badgeUnauthorized(label)
          : l10n.badgeAuthorization(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VidoraSpacing.md,
          vertical: VidoraSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.all(VidoraRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 14, color: color),
            const SizedBox(width: VidoraSpacing.xs + 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
