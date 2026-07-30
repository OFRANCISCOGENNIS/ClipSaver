/// The Search screen (section 10).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/domain/value_objects/media_format.dart';
import '../../../l10n/l10n.dart';
import '../domain/search_query.dart';
import 'search_state.dart';
import 'search_view_model.dart';

/// Global search over the library, with combinable filters.
class SearchView extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
    final viewModel = ref.read(searchViewModelProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSearch)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: kPagePadding,
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: viewModel.textChanged,
                onSubmitted: (_) => viewModel.search(),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.actionClear,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            viewModel.reset();
                          },
                        ),
                ),
              ),
            ),
            if (state.suggestions.isNotEmpty)
              _Suggestions(
                suggestions: state.suggestions,
                onSelected: (suggestion) {
                  _controller.text = suggestion;
                  viewModel.acceptSuggestion(suggestion);
                },
              ),
            _FilterBar(state: state, viewModel: viewModel),
            if (state.showingApproximateResults)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VidoraSpacing.lg,
                ),
                child: Text(
                  l10n.searchApproximate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(child: _Results(state: state)),
          ],
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.suggestions, required this.onSelected});

  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final suggestion in suggestions)
            ListTile(
              dense: true,
              leading: const Icon(Icons.north_west, size: 16),
              title: Text(
                suggestion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onSelected(suggestion),
            ),
        ],
      );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state, required this.viewModel});

  final SearchUiState state;
  final SearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final query = state.query;
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: VidoraSpacing.lg),
      child: Row(
        children: [
          for (final kind in MediaKind.values)
            _Chip(
              label: kind == MediaKind.video
                  ? l10n.searchKindVideo
                  : l10n.searchKindAudio,
              selected: query.kind == kind,
              onTap: () => viewModel.toggleKind(kind),
            ),
          for (final bucket in DurationBucket.values)
            _Chip(
              label: bucket.label(l10n),
              selected: query.durationBucket == bucket,
              onTap: () => viewModel.toggleDuration(bucket),
            ),
          for (final platform in state.platforms)
            _Chip(
              label: platform,
              selected: query.platform == platform,
              onTap: () => viewModel.togglePlatform(platform),
            ),
          for (final tag in state.tags)
            _Chip(
              label: '#$tag',
              selected: query.tags.contains(tag),
              onTap: () => viewModel.toggleTag(tag),
            ),
          if (query.hasFilters)
            Padding(
              padding: const EdgeInsets.only(left: VidoraSpacing.sm),
              child: TextButton.icon(
                onPressed: viewModel.clearFilters,
                icon: const Icon(Icons.filter_alt_off, size: 16),
                label: Text(l10n.searchClearFilters(query.activeFilterCount)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: VidoraSpacing.sm),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final SearchUiState state;

  @override
  Widget build(BuildContext context) {
    if (state.searching && state.hits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: kPagePadding,
          child: Text(
            context.l10n.searchEmpty,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: kPagePadding,
      itemCount: state.hits.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = state.hits[index].entry;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            entry.kind == MediaKind.video
                ? Icons.movie_outlined
                : Icons.audiotrack_outlined,
          ),
          title: Text(
            entry.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              if (entry.author != null) entry.author!,
              entry.size.formatted,
              if (entry.platform != null) entry.platform!,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: monoStyle(context),
          ),
        );
      },
    );
  }
}
