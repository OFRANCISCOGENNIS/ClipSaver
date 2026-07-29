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
const List<OnboardingPage> kOnboardingPages = [
  OnboardingPage(
    icon: Icons.verified_user_outlined,
    title: 'Só o que é permitido',
    body: 'O Vidora baixa mídia quando a plataforma de origem ou o titular '
        'dos direitos autoriza. Todo link é verificado antes de qualquer '
        'download começar.',
  ),
  OnboardingPage(
    icon: Icons.workspace_premium_outlined,
    title: 'Quatro formas de autorização',
    body: 'Download oficial da plataforma, licença aberta (como Creative '
        'Commons), conteúdo do seu próprio perfil, ou arquivo público de '
        'acesso direto. Você vê qual delas valeu em cada item.',
  ),
  OnboardingPage(
    icon: Icons.block_outlined,
    title: 'O que o app não faz',
    body: 'Nada de contornar DRM, paywall ou login de terceiros. Quando um '
        'link não pode ser baixado, explicamos o motivo e, quando existe, '
        'o caminho legítimo.',
  ),
];

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

  bool get _isLastPage => _page == kOnboardingPages.length - 1;

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: kOnboardingPages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = kOnboardingPages[index];
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
                for (var i = 0; i < kOnboardingPages.length; i++)
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
                  child: Text(_isLastPage ? 'Entendi, começar' : 'Continuar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
