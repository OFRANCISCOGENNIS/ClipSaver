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
import '../../../app/widgets/empty_state.dart';
import '../../../l10n/l10n.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDownloads),
        actions: [
          if (state.hasPausableWork)
            IconButton(
              tooltip: l10n.downloadsPauseAll,
              icon: const Icon(Icons.pause),
              onPressed: viewModel.pauseAll,
            ),
          if (state.hasResumableWork)
            IconButton(
              tooltip: l10n.downloadsResumeAll,
              icon: const Icon(Icons.play_arrow),
              onPressed: viewModel.resumeAll,
            ),
          if (state.hasFinishedWork)
            IconButton(
              tooltip: l10n.downloadsClearFinished,
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
        title: Text(context.l10n.downloadsCancelTitle),
        content: Text(context.l10n.downloadsCancelBody(item.task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.downloadsCancelKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.downloadsCancelConfirm),
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
    final l10n = context.l10n;
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
            // Wrap, não Row: com a fonte do sistema em 2x, bytes + velocidade
            // + ETA numa única linha estouram 156px numa tela de 400. Quem
            // aumenta a fonte é justamente quem não pode perder o texto.
            DefaultTextStyle(
              style: monoStyle(context),
              child: Wrap(
                spacing: VidoraSpacing.md,
                runSpacing: VidoraSpacing.xs,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    total == null
                        ? task.bytesDownloaded.formatted
                        : '${task.bytesDownloaded.formatted} / '
                            '${total.formatted}',
                  ),
                  if (task.state == DownloadState.downloading)
                    Text(
                      '${item.rate?.speedLabel ?? l10n.valueUnavailable}'
                      '   '
                      '${l10n.downloadsEta(
                        item.rate?.etaLabel ?? l10n.valueUnavailable,
                      )}',
                    ),
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
                  _RowAction(
                    semanticLabel: l10n.downloadsRetryItem(task.title),
                    onPressed: onRetry,
                    child: TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.actionRetryShort),
                    ),
                  ),
                if (item.canResume)
                  _RowAction(
                    semanticLabel: l10n.downloadsResumeItem(task.title),
                    onPressed: onResume,
                    child: IconButton(
                      tooltip: l10n.actionResume,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: onResume,
                    ),
                  ),
                if (item.canPause)
                  _RowAction(
                    semanticLabel: l10n.downloadsPauseItem(task.title),
                    onPressed: onPause,
                    child: IconButton(
                      tooltip: l10n.actionPause,
                      icon: const Icon(Icons.pause),
                      onPressed: onPause,
                    ),
                  ),
                if (item.canCancel)
                  _RowAction(
                    semanticLabel: l10n.downloadsCancelItem(task.title),
                    onPressed: onCancel,
                    child: IconButton(
                      tooltip: l10n.actionCancel,
                      icon: const Icon(Icons.close),
                      onPressed: onCancel,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A row action whose spoken label names the item it acts on.
///
/// The tooltip stays short because it is read with the eyes, right next to
/// the row it belongs to. The semantic label carries the title because it is
/// heard out of context: in a five-item queue, five identical "Pause" nodes
/// never say pause *what*.
///
/// The action is re-declared here on purpose. Wrapping a button in
/// `Semantics(excludeSemantics: true)` drops the child's tap action along
/// with its label, which leaves a node a screen reader can read but cannot
/// activate — worse than the ambiguity it was meant to fix.
class _RowAction extends StatelessWidget {
  const _RowAction({
    required this.semanticLabel,
    required this.onPressed,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      onTap: onPressed,
      excludeSemantics: true,
      child: child,
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.item});

  final DownloadItemUiState item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final task = item.task;
    // Without a Content-Length there is no honest percentage, so the bar
    // goes indeterminate rather than inventing one.
    final indeterminate =
        task.totalBytes == null && task.state == DownloadState.downloading;
    final percent = (task.progress * 100).round();

    return Semantics(
      label: l10n.downloadsProgressSemantics(task.state.label(l10n), percent),
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
          // A caixa acompanha a escala de texto do sistema: 44px fixos cabem
          // "100%" no tamanho padrão e cortam a mesma string em 2x.
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(44),
            child: Text(
              indeterminate ? l10n.valueUnavailable : '$percent%',
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
        state.label(context.l10n),
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
  Widget build(BuildContext context) => EmptyState(
        icon: Icons.download_done_outlined,
        title: context.l10n.downloadsEmptyTitle,
        body: context.l10n.downloadsEmptyBody,
      );
}
