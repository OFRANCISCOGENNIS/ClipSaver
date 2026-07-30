/// The Analyze screen (section 7).
///
/// Responsibility: render [AnalyzeUiState] and forward intents to the
/// ViewModel. Per section 4.1 the View holds no logic — every branch here
/// is a pure function of the state machine's current node.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/shell.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../l10n/l10n.dart';
import '../../downloads/application/enqueue_download_use_case.dart';
import '../domain/media_item.dart';
import 'analyze_state.dart';
import 'analyze_view_model.dart';
import 'widgets/analysis_result_card.dart';
import 'widgets/analyze_skeleton.dart';
import 'widgets/authorization_badge.dart';
import 'widgets/ineligible_card.dart';

/// Home screen: paste a link, analyze it, act on the verdict.
class AnalyzeView extends ConsumerStatefulWidget {
  /// Creates the screen, optionally pre-filled from a `vidora://` deep
  /// link or the system share sheet.
  const AnalyzeView({this.sharedUrl, super.key});

  /// URL handed over by the deep link, if any.
  final String? sharedUrl;

  @override
  ConsumerState<AnalyzeView> createState() => _AnalyzeViewState();
}

class _AnalyzeViewState extends ConsumerState<AnalyzeView> {
  final TextEditingController _controller = TextEditingController();
  MediaFormat? _selectedFormat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(analyzeViewModelProvider.notifier);
      final shared = widget.sharedUrl;
      if (shared != null && shared.trim().isNotEmpty) {
        _controller.text = shared;
        viewModel.urlChanged(shared);
        // A shared link is an explicit intent to analyze it.
        unawaited(viewModel.analyze());
        unawaited(viewModel.refreshRecents());
      } else {
        unawaited(viewModel.initialize());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download(MediaItem item, MediaFormat format) async {
    final messenger = ScaffoldMessenger.of(context);
    // Captured before the await: after it, this State may be unmounted
    // and `context` unusable.
    final l10n = context.l10n;
    final useCase = EnqueueDownloadUseCase(
      enqueue: ref.read(downloadManagerProvider).enqueue,
      downloadsDirectory: ref.read(downloadsDirectoryProvider),
    );
    final result = await useCase(item, format);
    if (!mounted) return;

    result.fold(
      (task) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.analyzeQueuedSnack(task.title)),
            action: SnackBarAction(
              label: l10n.analyzeSeeQueue,
              onPressed: () => context.go(Routes.downloads),
            ),
          ),
        );
      },
      (failure) => messenger.showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: VidoraColors.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyzeViewModelProvider);
    final viewModel = ref.read(analyzeViewModelProvider.notifier);

    // Keep the field in sync when the ViewModel changes it (paste chip,
    // recents), without fighting the user's cursor while typing.
    if (_controller.text != state.url) {
      _controller.value = TextEditingValue(
        text: state.url,
        selection: TextSelection.collapsed(offset: state.url.length),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appName)),
      body: SafeArea(
        child: ListView(
          padding: kPagePadding,
          children: [
            _UrlField(
              controller: _controller,
              errorText: state.urlError,
              onChanged: viewModel.urlChanged,
              onSubmitted: (_) => viewModel.analyze(),
              onClear: () {
                _controller.clear();
                viewModel.clear();
              },
            ),
            if (state.clipboardSuggestion != null) ...[
              const SizedBox(height: VidoraSpacing.md),
              _ClipboardChip(
                url: state.clipboardSuggestion!,
                onAccept: viewModel.acceptClipboardSuggestion,
                onDismiss: viewModel.dismissClipboardSuggestion,
              ),
            ],
            const SizedBox(height: VidoraSpacing.lg),
            _AnalyzeButton(
              enabled: state.canAnalyze,
              busy: state.isBusy,
              onPressed: viewModel.analyze,
            ),
            const SizedBox(height: VidoraSpacing.xl),
            _Body(
              state: state,
              selectedFormat: _selectedFormat,
              onFormatSelected: (format) =>
                  setState(() => _selectedFormat = format),
              onDownload: _download,
              onRetry: viewModel.retry,
              onOpenRecent: (item) {
                setState(() => _selectedFormat = null);
                viewModel.openRecent(item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Chooses what to show for the current state-machine node.
class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.selectedFormat,
    required this.onFormatSelected,
    required this.onDownload,
    required this.onRetry,
    required this.onOpenRecent,
  });

  final AnalyzeUiState state;
  final MediaFormat? selectedFormat;
  final ValueChanged<MediaFormat> onFormatSelected;
  final void Function(MediaItem item, MediaFormat format) onDownload;
  final VoidCallback onRetry;
  final ValueChanged<MediaItem> onOpenRecent;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: VidoraMotion.standard,
      switchInCurve: VidoraMotion.enter,
      child: switch (state.phase) {
        AnalyzeIdle() || AnalyzeValidating() => _Recents(
            key: const ValueKey('recents'),
            items: state.recents,
            onSelected: onOpenRecent,
          ),
        AnalyzeAnalyzing() => const AnalyzeSkeleton(key: ValueKey('skeleton')),
        AnalyzeResult(:final item) => _EligibleResult(
            key: ValueKey('result-${item.id}'),
            item: item,
            selectedFormat: selectedFormat,
            onFormatSelected: onFormatSelected,
            onDownload: onDownload,
          ),
        AnalyzeIneligible(:final item) => IneligibleCard(
            key: ValueKey('ineligible-${item.id}'),
            item: item,
          ),
        AnalyzeError(:final failure) => _ErrorCard(
            key: const ValueKey('error'),
            message: describeFailure(failure, context.l10n),
            onRetry: onRetry,
          ),
      },
    );
  }
}

class _EligibleResult extends StatelessWidget {
  const _EligibleResult({
    required this.item,
    required this.selectedFormat,
    required this.onFormatSelected,
    required this.onDownload,
    super.key,
  });

  final MediaItem item;
  final MediaFormat? selectedFormat;
  final ValueChanged<MediaFormat> onFormatSelected;
  final void Function(MediaItem item, MediaFormat format) onDownload;

  @override
  Widget build(BuildContext context) {
    final formats = item.eligibility.availableFormats;
    // Default to the first rendition the origin listed; the selection is
    // View state, so it resets whenever a new item arrives.
    final selected =
        formats.contains(selectedFormat) ? selectedFormat! : formats.first;
    return AnalysisResultCard(
      item: item,
      selectedFormat: selected,
      onFormatSelected: onFormatSelected,
      onDownload: () => onDownload(item, selected),
    );
  }
}

class _UrlField extends StatelessWidget {
  const _UrlField({
    required this.controller,
    required this.errorText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autocorrect: false,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.go,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: context.l10n.analyzeUrlHint,
        errorText: errorText,
        prefixIcon: const Icon(Icons.link),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: context.l10n.actionClear,
                onPressed: onClear,
              ),
      ),
    );
  }
}

class _ClipboardChip extends StatelessWidget {
  const _ClipboardChip({
    required this.url,
    required this.onAccept,
    required this.onDismiss,
  });

  final String url;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InputChip(
        avatar: const Icon(Icons.content_paste, size: 16),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            context.l10n.analyzeClipboardPrompt(url),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: onAccept,
        onDeleted: onDismiss,
        deleteButtonTooltipMessage: context.l10n.actionDismiss,
      ),
    );
  }
}

/// Primary CTA; morphs into a spinner while busy (section 6.2).
class _AnalyzeButton extends StatelessWidget {
  const _AnalyzeButton({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: AnimatedSwitcher(
          duration: VidoraMotion.fast,
          child: busy
              ? const SizedBox(
                  key: ValueKey('spinner'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(context.l10n.analyzeAction, key: const ValueKey('label')),
        ),
      ),
    );
  }
}

class _Recents extends StatelessWidget {
  const _Recents({required this.items, required this.onSelected, super.key});

  final List<MediaItem> items;
  final ValueChanged<MediaItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(key: ValueKey('empty'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.analyzeRecents,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: VidoraSpacing.sm),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: VidoraSpacing.md,
            leading: Icon(
              item.isDownloadable
                  ? Icons.check_circle_outline
                  : Icons.block_outlined,
              color: item.isDownloadable
                  ? VidoraColors.success
                  : VidoraColors.error,
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: VidoraSpacing.xs),
                child: AuthorizationBadge(
                  source: item.eligibility.source,
                  license: item.eligibility.license,
                ),
              ),
            ),
            onTap: () => onSelected(item),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VidoraSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: VidoraSpacing.lg),
          Text(
            context.l10n.analyzeEmptyTitle,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: VidoraSpacing.sm),
          Text(
            context.l10n.analyzeEmptyBody,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(VidoraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: VidoraColors.error),
                const SizedBox(width: VidoraSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: VidoraSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.actionRetry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
