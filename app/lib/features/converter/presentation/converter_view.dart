/// The Converter screen (section 11).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../domain/conversion_job.dart';
import 'converter_state.dart';
import 'converter_view_model.dart';

/// Conversion queue, independent of the download queue.
class ConverterView extends ConsumerWidget {
  /// Creates the screen.
  const ConverterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(converterViewModelProvider);
    final viewModel = ref.read(converterViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor'),
        actions: [
          if (state.hasFinishedWork)
            IconButton(
              tooltip: 'Limpar concluídas',
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: viewModel.clearFinished,
            ),
        ],
      ),
      body: SafeArea(
        child: state.items.isEmpty
            ? const _EmptyQueue()
            : ListView.separated(
                padding: kPagePadding,
                itemCount: state.items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: VidoraSpacing.md),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return RepaintBoundary(
                    key: ValueKey(item.id),
                    child: ConversionTile(
                      item: item,
                      onCancel: () => viewModel.cancel(item.id),
                      onRetry: () => viewModel.retry(item.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// One conversion row.
class ConversionTile extends StatelessWidget {
  /// Creates the row.
  const ConversionTile({
    required this.item,
    required this.onCancel,
    required this.onRetry,
    super.key,
  });

  /// The row's state.
  final ConversionItemUiState item;

  /// Cancel intent.
  final VoidCallback onCancel;

  /// Retry intent.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = item.job;
    final percent = (job.progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(VidoraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.outputPath.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: VidoraSpacing.sm),
                Text(
                  describeConversionState(job.state),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: VidoraSpacing.md),
            Semantics(
              label:
                  '${describeConversionState(job.state)}, $percent por cento',
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(VidoraRadius.pill),
                      child: LinearProgressIndicator(
                        // Without the source duration FFmpeg's processed
                        // time cannot become a percentage (section 11).
                        value: item.hasDeterminateProgress
                            ? job.progress
                            : (job.state == ConversionState.converting
                                ? null
                                : job.progress),
                      ),
                    ),
                  ),
                  const SizedBox(width: VidoraSpacing.md),
                  SizedBox(
                    width: 44,
                    child: Text(
                      item.hasDeterminateProgress ||
                              job.state != ConversionState.converting
                          ? '$percent%'
                          : '—',
                      textAlign: TextAlign.right,
                      style: monoStyle(context),
                    ),
                  ),
                ],
              ),
            ),
            if (job.failureReason != null) ...[
              const SizedBox(height: VidoraSpacing.sm),
              Text(
                job.failureReason!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: VidoraColors.error),
              ),
            ],
            const SizedBox(height: VidoraSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (item.canRetry)
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar de novo'),
                  ),
                if (item.canCancel)
                  IconButton(
                    tooltip: 'Cancelar',
                    icon: const Icon(Icons.close),
                    onPressed: onCancel,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: kPagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: VidoraSpacing.lg),
            Text('Nenhuma conversão', style: theme.textTheme.titleLarge),
            const SizedBox(height: VidoraSpacing.sm),
            Text(
              'Escolha um item da biblioteca para converter. '
              'O arquivo original é preservado.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
