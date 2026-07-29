/// Result card for an eligible analysis (section 7.2 item 4).
///
/// Responsibility: present the media, its authorization badge and only
/// the formats the origin actually offers — the UI must never invent a
/// resolution that was not reported.
library;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/domain/value_objects/media_format.dart';
import '../../domain/media_item.dart';
import 'authorization_badge.dart';

/// Card shown when the analyzed URL is downloadable.
class AnalysisResultCard extends StatelessWidget {
  /// Creates the card for [item].
  const AnalysisResultCard({
    required this.item,
    required this.selectedFormat,
    required this.onFormatSelected,
    required this.onDownload,
    super.key,
  });

  /// The analyzed media.
  final MediaItem item;

  /// Currently chosen rendition.
  final MediaFormat selectedFormat;

  /// Called when the user picks another rendition.
  final ValueChanged<MediaFormat> onFormatSelected;

  /// Called when the user confirms the download.
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eligibility = item.eligibility;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(VidoraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(url: item.thumbnailUrl, duration: item.duration),
                const SizedBox(width: VidoraSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (item.author != null) ...[
                        const SizedBox(height: VidoraSpacing.xs),
                        Text(
                          item.author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: VidoraSpacing.sm),
                      AuthorizationBadge(
                        source: eligibility.source,
                        license: eligibility.license,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: VidoraSpacing.lg),
            Text('Qualidade', style: theme.textTheme.labelLarge),
            const SizedBox(height: VidoraSpacing.sm),
            Wrap(
              spacing: VidoraSpacing.sm,
              runSpacing: VidoraSpacing.sm,
              children: [
                for (final format in eligibility.availableFormats)
                  ChoiceChip(
                    label: Text(_formatLabel(format)),
                    selected: format == selectedFormat,
                    onSelected: (_) => onFormatSelected(format),
                  ),
              ],
            ),
            if (eligibility.restrictions.isNotEmpty) ...[
              const SizedBox(height: VidoraSpacing.lg),
              _Restrictions(restrictions: eligibility.restrictions),
            ],
            const SizedBox(height: VidoraSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: Text('Baixar ${selectedFormat.qualityLabel}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(MediaFormat format) {
    final size = format.estimatedSize;
    final base = '${format.qualityLabel} · ${format.container.toUpperCase()}';
    return size == null ? base : '$base · ${size.formatted}';
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url, this.duration});

  final String? url;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.all(VidoraRadius.card),
      child: SizedBox(
        width: 112,
        height: 72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: scheme.outline.withValues(alpha: 0.35)),
            if (url != null)
              Image.network(
                url!,
                fit: BoxFit.cover,
                // Blur-up: the placeholder stays until the bytes arrive,
                // then the image fades in (section 7.2 item 4).
                frameBuilder: (context, child, frame, wasSyncLoaded) =>
                    AnimatedOpacity(
                  opacity: frame == null && !wasSyncLoaded ? 0 : 1,
                  duration: VidoraMotion.standard,
                  curve: VidoraMotion.enter,
                  child: child,
                ),
                errorBuilder: (context, error, stack) => Icon(
                  Icons.movie_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              Icon(Icons.movie_outlined, color: scheme.onSurfaceVariant),
            if (duration != null)
              Positioned(
                right: VidoraSpacing.xs,
                bottom: VidoraSpacing.xs,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xCC000000),
                    borderRadius: BorderRadius.all(VidoraRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VidoraSpacing.sm,
                      vertical: 2,
                    ),
                    child: Text(
                      formatDuration(duration!),
                      style: monoStyle(context).copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Restrictions extends StatelessWidget {
  const _Restrictions({required this.restrictions});

  final List<String> restrictions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VidoraSpacing.md),
      decoration: BoxDecoration(
        color: VidoraColors.warning.withValues(alpha: 0.10),
        borderRadius: const BorderRadius.all(VidoraRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: VidoraColors.warning),
          const SizedBox(width: VidoraSpacing.sm),
          Expanded(
            child: Text(
              'Condições da licença: ${restrictions.join(', ')}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats [duration] as `m:ss` or `h:mm:ss`.
String formatDuration(Duration duration) {
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60);
  if (duration.inHours > 0) {
    return '${duration.inHours}:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
  return '$minutes:$seconds';
}
