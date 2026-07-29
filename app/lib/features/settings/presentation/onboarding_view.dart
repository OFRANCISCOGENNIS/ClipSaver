/// Compliance onboarding (section 2.3).
///
/// Responsibility: on first run, explain in plain language what Vidora
/// does and does not download. Three screens, no legalese — the spec caps
/// it at three precisely so nobody swipes past without reading.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/l10n.dart';
import 'settings_view_model.dart';

/// One onboarding page.
final class OnboardingPage {
  /// Creates a page.
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  /// Illustration.
  final IconData icon;

  /// Headline.
  final String title;

  /// Explanation.
  final String body;
}

/// The three compliance pages (section 2.3).
///
/// Resolved against [l10n] rather than held as a `const` list: this text
/// is the compliance promise itself, so it has to reach the user in their
/// own language, not in the language the app happened to be written in.
List<OnboardingPage> onboardingPages(AppLocalizations l10n) => [
      OnboardingPage(
        icon: Icons.verified_user_outlined,
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      OnboardingPage(
        icon: Icons.workspace_premium_outlined,
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      OnboardingPage(
        icon: Icons.block_outlined,
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
      ),
    ];

/// How many pages the onboarding has (section 2.3 caps it at three).
const int kOnboardingPageCount = 3;

/// First-run compliance onboarding.
class OnboardingView extends ConsumerStatefulWidget {
  /// Creates the screen; [onFinished] runs after the last page.
  const OnboardingView({required this.onFinished, super.key});

  /// Called once the user accepts.
  final VoidCallback onFinished;

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastPage => _page == kOnboardingPageCount - 1;

  Future<void> _next() async {
    if (!_isLastPage) {
      await _controller.nextPage(
        duration: VidoraMotion.standard,
        curve: VidoraMotion.transition,
      );
      return;
    }
    await ref.read(settingsViewModelProvider.notifier).completeOnboarding();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pages = onboardingPages(l10n);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(VidoraSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: VidoraSpacing.xl),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: VidoraSpacing.lg),
                        Text(
                          page.body,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(
                      horizontal: VidoraSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: kPagePadding,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _isLastPage ? l10n.onboardingFinish : l10n.actionContinue,
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
