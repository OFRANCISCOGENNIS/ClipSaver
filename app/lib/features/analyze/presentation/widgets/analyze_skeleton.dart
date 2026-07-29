/// Skeleton placeholder shown while an analysis is in flight.
///
/// Responsibility: section 6.2 forbids spinners for structured content —
/// the skeleton mirrors the result card's layout so the transition to real
/// data does not shift anything on screen.
library;

import 'package:flutter/material.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../l10n/l10n.dart';

/// Shimmering placeholder in the shape of the result card.
class AnalyzeSkeleton extends StatefulWidget {
  /// Creates the skeleton.
  const AnalyzeSkeleton({super.key});

  @override
  State<AnalyzeSkeleton> createState() => _AnalyzeSkeletonState();
}

class _AnalyzeSkeletonState extends State<AnalyzeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.analyzeSkeletonSemantics,
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(VidoraSpacing.lg),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: 0.4 + _controller.value * 0.3,
              child: child,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Block(width: 112, height: 72),
                    SizedBox(width: VidoraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Block(width: double.infinity, height: 20),
                          SizedBox(height: VidoraSpacing.sm),
                          _Block(width: 160, height: 14),
                          SizedBox(height: VidoraSpacing.md),
                          _Block(width: 120, height: 26),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: VidoraSpacing.lg),
                Row(
                  children: [
                    _Block(width: 72, height: 32),
                    SizedBox(width: VidoraSpacing.sm),
                    _Block(width: 72, height: 32),
                    SizedBox(width: VidoraSpacing.sm),
                    _Block(width: 72, height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: const BorderRadius.all(VidoraRadius.card),
        ),
      );
}
