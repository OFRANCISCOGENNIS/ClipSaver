/// Educational card for a refused analysis (section 2.3 and 7.2 item 5).
///
/// Responsibility: explain *why* a download is not authorized and point at
/// the legitimate path, instead of showing a bare refusal. The technical
/// detail is available but collapsed, so the plain-language explanation
/// leads.
library;

import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/media_item.dart';
import 'authorization_badge.dart';

/// Card shown when the analyzed URL cannot be downloaded.
class IneligibleCard extends StatelessWidget {
  /// Creates the card for [item].
  const IneligibleCard({required this.item, super.key});

  /// The analyzed media, carrying the refusal reason.
  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(VidoraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: VidoraColors.error,
                  size: 20,
                ),
                const SizedBox(width: VidoraSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.ineligibleTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: VidoraSpacing.md),
            Text(item.eligibility.reason, style: theme.textTheme.bodyLarge),
            const SizedBox(height: VidoraSpacing.lg),
            AuthorizationBadge(source: item.eligibility.source),
            const SizedBox(height: VidoraSpacing.sm),
            Theme(
              // The default divider lines fight the card's own border.
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(
                  bottom: VidoraSpacing.sm,
                ),
                title: Text(
                  l10n.ineligibleTechnicalDetails,
                  style: theme.textTheme.labelLarge,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.ineligibleDetailBody(
                        item.url.host,
                        item.eligibility.source.label(l10n),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
