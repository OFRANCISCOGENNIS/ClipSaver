/// Shared empty-state block: icon, title, explanation.
///
/// Extracted from three near-identical copies (Downloads, Library,
/// Converter) after the Converter's copy overflowed 165px at 3x system
/// font — a `Column` inside a `Center` has nowhere to go when the text
/// outgrows the viewport. Centering and scrolling are combined here so the
/// fix applies to every screen at once: centered while it fits, scrollable
/// once it does not. Duplicated layout is how the same bug ships three
/// times.
library;

import 'package:flutter/material.dart';

import '../shell.dart';
import '../theme/tokens.dart';

/// Icon + title + body, centered when short, scrollable when tall.
class EmptyState extends StatelessWidget {
  /// Creates the block.
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  /// Leading pictogram.
  final IconData icon;

  /// One-line headline.
  final String title;

  /// Explanation under the headline.
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: kPagePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: VidoraSpacing.lg),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: VidoraSpacing.sm),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
