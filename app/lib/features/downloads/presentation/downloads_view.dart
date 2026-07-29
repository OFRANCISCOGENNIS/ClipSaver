/// The Downloads screen (section 8.2).
///
/// Responsibility: render the queue and expose per-item and bulk actions.
/// All scheduling decisions belong to the manager; this file only shows
/// state and forwards intents.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../domain/download_state.dart';
import 'downloads_state.dart';
import 'downloads_view_model.dart';

/// Queue screen with progress, speed and ETA per item.
class DownloadsView extends ConsumerStatefulWidget {
  /// Creates the screen.
  const DownloadsView({super.key});

  @override
  ConsumerState<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends ConsumerState<DownloadsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Picks up transfers interrupted by a previous app session.
      ref.read(downloadsViewModelProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadsViewModelProvider);
    final viewModel = ref.read(downloadsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (state.hasPausableWork)
            IconButton(
              tooltip: 'Pausar tudo',
              icon: const Icon(Icons.pause),
              onPressed: viewModel.pauseAll,
            ),
          if (state.hasResumableWork)
            IconButton(
              tooltip: 'Retomar tudo',
              icon: const Icon(Icons.play_arrow),
              onPressed: viewModel.resumeAll,
            ),
          if (state.hasFinishedWork)
            IconButton(
              tooltip: 'Limpar concluídos',
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
                    child: DownloadTile(
                      item: item,
                      onPause: () => viewModel.pause(item.id),
                      onResume: () => viewModel.resume(item.id),
                      onRetry: () => viewModel.retry(item.id),
                      onCancel: () => _confirmCancel(context, viewModel, item),
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Cancelling discards partial bytes, so it always asks first
  /// (section 8.2: "cancelar (com confirmação)").
  Future<void> _confirmCancel(
    BuildContext context,
    DownloadsViewModel viewModel,
    DownloadItemUiState item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar download?'),
        content: Text(
          'O progresso de “${item.task.title}” será descartado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Manter'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar download'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await viewModel.cancel(item.id);
  }
}

/// One queue row.
class DownloadTile extends StatelessWidget {
  /// Creates the row for [item].
  const DownloadTile({
    required this.item,
    required this.onPause,
    required this.onResume,
    required this.onRetry,
    required this.onCancel,
    super.key,
  });

  /// The row's state.
  final DownloadItemUiState item;

  /// Pause intent.
  final VoidCallback onPause;

  /// Resume intent.
  final VoidCallback onResume;

  /// Retry intent.
  final VoidCallback onRetry;

  /// Cancel intent.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = item.task;
    final total = task.totalBytes;

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
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: VidoraSpacing.sm),
                _StateChip(state: task.state),
              ],
            ),
            const SizedBox(height: VidoraSpacing.md),
            _Progress(item: item),
            const SizedBox(height: VidoraSpacing.sm),
            DefaultTextStyle(
              style: monoStyle(context),
              child: Row(
                children: [
                  Text(
                    total == null
                        ? task.bytesDownloaded.formatted
                        : '${task.bytesDownloaded.formatted} / '
                            '${total.formatted}',
                  ),
                  const Spacer(),
                  if (task.state == DownloadState.downloading) ...[
                    Text(item.rate?.speedLabel ?? '—'),
                    const SizedBox(width: VidoraSpacing.md),
                    Text('ETA ${item.rate?.etaLabel ?? '—'}'),
                  ],
                ],
              ),
            ),
            if (task.failureReason != null) ...[
              const SizedBox(height: VidoraSpacing.sm),
              Text(
                task.failureReason!,
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
                if (item.canResume)
                  IconButton(
                    tooltip: 'Continuar',
                    icon: const Icon(Icons.play_arrow),
                    onPressed: onResume,
                  ),
                if (item.canPause)
                  IconButton(
                    tooltip: 'Pausar',
                    icon: const Icon(Icons.pause),
                    onPressed: onPause,
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

class _Progress extends StatelessWidget {
  const _Progress({required this.item});

  final DownloadItemUiState item;

  @override
  Widget build(BuildContext context) {
    final task = item.task;
    // Without a Content-Length there is no honest percentage, so the bar
    // goes indeterminate rather than inventing one.
    final indeterminate =
        task.totalBytes == null && task.state == DownloadState.downloading;
    final percent = (task.progress * 100).round();

    return Semantics(
      label: '${describeDownloadState(task.state)}, $percent por cento',
      value: '$percent%',
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(VidoraRadius.pill),
              child: LinearProgressIndicator(
                value: indeterminate ? null : task.progress,
              ),
            ),
          ),
          const SizedBox(width: VidoraSpacing.md),
          SizedBox(
            width: 44,
            child: Text(
              indeterminate ? '—' : '$percent%',
              textAlign: TextAlign.right,
              style: monoStyle(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final DownloadState state;

  Color get _color => switch (state) {
        DownloadState.done => VidoraColors.success,
        DownloadState.failed => VidoraColors.error,
        DownloadState.paused || DownloadState.canceled => VidoraColors.warning,
        _ => VidoraColors.primaryEnd,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VidoraSpacing.sm,
        vertical: VidoraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(VidoraRadius.pill),
      ),
      child: Text(
        describeDownloadState(state),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
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
              Icons.download_done_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: VidoraSpacing.lg),
            Text('Nenhum download na fila', style: theme.textTheme.titleLarge),
            const SizedBox(height: VidoraSpacing.sm),
            Text(
              'Analise um link autorizado para começar.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
