/// The Library screen (section 9).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../analyze/presentation/widgets/analysis_result_card.dart';
import '../domain/library_entry.dart';
import '../domain/library_repository.dart';
import 'library_state.dart';
import 'library_view_model.dart';

/// Library of downloaded media, with tabs, sorting and per-item actions.
class LibraryView extends ConsumerStatefulWidget {
  /// Creates the screen.
  const LibraryView({super.key});

  @override
  ConsumerState<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends ConsumerState<LibraryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(libraryViewModelProvider.notifier);
      // Files can disappear between sessions; check before showing a list
      // that promises they are all playable.
      viewModel.reconcileFiles();
      viewModel.purgeExpiredTrash();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryViewModelProvider);
    final viewModel = ref.read(libraryViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            tooltip: state.viewMode == LibraryViewMode.grid
                ? 'Ver em lista'
                : 'Ver em grade',
            icon: Icon(
              state.viewMode == LibraryViewMode.grid
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
            onPressed: viewModel.toggleViewMode,
          ),
          PopupMenuButton<LibrarySort>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            onSelected: viewModel.sortBy,
            itemBuilder: (context) => [
              for (final sort in LibrarySort.values)
                PopupMenuItem(
                  value: sort,
                  child: Row(
                    children: [
                      Expanded(child: Text(_sortLabel(sort))),
                      if (sort == state.sort)
                        Icon(
                          state.descending
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 16,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: VidoraSpacing.lg),
            child: Row(
              children: [
                for (final tab in LibraryTab.values)
                  Padding(
                    padding: const EdgeInsets.only(right: VidoraSpacing.sm),
                    child: ChoiceChip(
                      label: Text('${tab.label} (${_countFor(state, tab)})'),
                      selected: state.tab == tab,
                      onSelected: (_) => viewModel.selectTab(tab),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: state.isEmpty
            ? const _EmptyLibrary()
            : state.viewMode == LibraryViewMode.grid
                ? _Grid(entries: state.entries, viewModel: viewModel)
                : _List(entries: state.entries, viewModel: viewModel),
      ),
    );
  }

  int _countFor(LibraryUiState state, LibraryTab tab) => switch (tab) {
        LibraryTab.videos => state.counts.videos,
        LibraryTab.audios => state.counts.audios,
        LibraryTab.favorites => state.counts.favorites,
        LibraryTab.recents => state.counts.total,
      };

  String _sortLabel(LibrarySort sort) => switch (sort) {
        LibrarySort.downloadedAt => 'Data do download',
        LibrarySort.name => 'Nome',
        LibrarySort.size => 'Tamanho',
        LibrarySort.duration => 'Duração',
        LibrarySort.platform => 'Plataforma',
      };
}

class _Grid extends StatelessWidget {
  const _Grid({required this.entries, required this.viewModel});

  final List<LibraryEntry> entries;
  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: kPagePadding,
        // Virtualized by construction: only visible tiles are built,
        // which is what keeps 10.000 items at 60/120 FPS (section 12).
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 0.78,
          mainAxisSpacing: VidoraSpacing.md,
          crossAxisSpacing: VidoraSpacing.md,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) => RepaintBoundary(
          key: ValueKey(entries[index].id),
          child: LibraryCard(entry: entries[index], viewModel: viewModel),
        ),
      );
}

class _List extends StatelessWidget {
  const _List({required this.entries, required this.viewModel});

  final List<LibraryEntry> entries;
  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: kPagePadding,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => RepaintBoundary(
          key: ValueKey(entries[index].id),
          child: LibraryRow(entry: entries[index], viewModel: viewModel),
        ),
      );
}

/// Grid tile for one library entry.
class LibraryCard extends StatelessWidget {
  /// Creates the tile.
  const LibraryCard({required this.entry, required this.viewModel, super.key});

  /// The entry to render.
  final LibraryEntry entry;

  /// Receives the tile's actions.
  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: theme.colorScheme.outline.withValues(alpha: 0.30),
                  child: Icon(
                    entry.status == LibraryFileStatus.missing
                        ? Icons.report_gmailerrorred_outlined
                        : Icons.play_circle_outline,
                    color: entry.status == LibraryFileStatus.missing
                        ? VidoraColors.warning
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Positioned(
                  top: VidoraSpacing.xs,
                  right: VidoraSpacing.xs,
                  child: _FavoriteButton(entry: entry, viewModel: viewModel),
                ),
                if (entry.duration != null)
                  Positioned(
                    right: VidoraSpacing.xs,
                    bottom: VidoraSpacing.xs,
                    child: _DurationBadge(duration: entry.duration!),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(VidoraSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: VidoraSpacing.xs),
                _EntryMeta(entry: entry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dense list row for one library entry.
class LibraryRow extends StatelessWidget {
  /// Creates the row.
  const LibraryRow({required this.entry, required this.viewModel, super.key});

  /// The entry to render.
  final LibraryEntry entry;

  /// Receives the row's actions.
  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          entry.status == LibraryFileStatus.missing
              ? Icons.report_gmailerrorred_outlined
              : (entry.kind.name == 'video'
                  ? Icons.movie_outlined
                  : Icons.audiotrack_outlined),
          color: entry.status == LibraryFileStatus.missing
              ? VidoraColors.warning
              : null,
        ),
        title: Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _EntryMeta(entry: entry),
        trailing: _FavoriteButton(entry: entry, viewModel: viewModel),
      );
}

class _EntryMeta extends StatelessWidget {
  const _EntryMeta({required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.status == LibraryFileStatus.missing) {
      return Text(
        'Arquivo não encontrado',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: VidoraColors.warning),
      );
    }
    final parts = <String>[
      entry.size.formatted,
      if (entry.platform != null) entry.platform!,
      if (entry.license != null) entry.license!.displayName,
    ];
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: monoStyle(context),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.entry, required this.viewModel});

  final LibraryEntry entry;
  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: entry.favorite
            ? 'Remover dos favoritos'
            : 'Adicionar aos favoritos',
        iconSize: 20,
        icon: Icon(
          entry.favorite ? Icons.favorite : Icons.favorite_border,
          color: entry.favorite ? VidoraColors.error : null,
        ),
        onPressed: () => viewModel.toggleFavorite(entry.id),
      );
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
            formatDuration(duration),
            style: monoStyle(context).copyWith(color: Colors.white),
          ),
        ),
      );
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

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
              Icons.video_library_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: VidoraSpacing.lg),
            Text('Nada por aqui ainda', style: theme.textTheme.titleLarge),
            const SizedBox(height: VidoraSpacing.sm),
            Text(
              'Downloads concluídos aparecem nesta aba.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
