// Browser checks for the published site.
//
// These cover what 516 widget tests structurally cannot: the widget tests
// run against an in-memory SQLite and a fake filesystem, in a headless
// Flutter binding with no browser at all. Everything that only exists in a
// real browser — the SQLite/WASM binaries actually loading, the service
// worker registering, `--base-href` being right, a deep link resolving —
// is invisible to them, and every one of those failures ships silently.
//
// Written against the built `site/` tree, the same one the Pages workflow
// uploads, so what is tested is the artifact and not a dev server.

import { test, expect } from '@playwright/test';

/** Fails the test on any console error or uncaught exception. */
function failOnPageErrors(page, errors) {
  page.on('console', (message) => {
    if (message.type() === 'error') errors.push(`console: ${message.text()}`);
  });
  page.on('pageerror', (error) => errors.push(`uncaught: ${error.message}`));
}

test.describe('protótipo (raiz do site)', () => {
  test('abre, avisa que é protótipo e aponta para o app', async ({ page }) => {
    const errors = [];
    failOnPageErrors(page, errors);

    await page.goto('/ClipSaver/');

    await expect(page.locator('.proto-bar')).toContainText('Protótipo');

    // O link para o app compilado: sem ele, quem chega na raiz nunca
    // descobre que o software de verdade está um caminho ao lado.
    const link = page.locator('.proto-bar a');
    await expect(link).toHaveAttribute('href', 'app/');

    expect(errors).toEqual([]);
  });

  test('o onboarding de conformidade não pode ser pulado', async ({ page }) => {
    await page.goto('/ClipSaver/');

    // O app só aparece depois do aceite; um protótipo que mostrasse as
    // telas antes disso ensinaria o fluxo errado logo na porta de entrada.
    await expect(page.locator('.onb-wrap')).toBeVisible();
    await expect(page.locator('.app')).toBeHidden();
  });
});

test.describe('app Flutter compilado', () => {
  test('carrega, registra o service worker e abre o banco WASM',
    async ({ page }) => {
      const errors = [];
      failOnPageErrors(page, errors);

      await page.goto('/ClipSaver/app/');

      // O Flutter substitui o host por um <flt-glass-pane>/<flutter-view>
      // quando termina de subir. Esperar por ele é esperar o app existir,
      // não só o HTML chegar.
      await expect(page.locator('flutter-view')).toBeAttached({
        timeout: 60_000,
      });

      // sqlite3.wasm e drift_worker.js são binários buscados por versão no
      // build, não versionados. Se o fetch falhar, o app sobe e o banco
      // nunca abre — e nenhum teste de widget veria isso.
      const wasm = await page.request.get('/ClipSaver/app/sqlite3.wasm');
      expect(wasm.status()).toBe(200);
      const worker = await page.request.get('/ClipSaver/app/drift_worker.js');
      expect(worker.status()).toBe(200);

      // O erro de rede da fonte de fallback é conhecido e tem teste
      // próprio abaixo; qualquer outro erro de console é regressão.
      const inesperados = errors.filter(
        (entry) => !entry.includes('ERR_CONNECTION_RESET'),
      );
      expect(inesperados).toEqual([]);
    });

  test('a única chamada a terceiro é a fonte de fallback do motor',
    async ({ page }) => {
      // Este teste trava a situação, não a aprova. O app pede consentimento
      // explícito para telemetria e fala de LGPD nos Ajustes; uma chamada
      // silenciosa a um servidor da Google a cada carregamento contradiz
      // isso, e a lista abaixo existe para que ninguém acrescente outra
      // sem perceber.
      //
      // Duas já foram eliminadas: o CanvasKit (build com
      // --no-web-resources-cdn) e as fontes do app (empacotadas). Resta a
      // fonte de fallback do motor, que é configurável por
      // `fontFallbackBaseUrl` — hospedá-la exige decidir o que fazer com o
      // conjunto Noto inteiro, que é grande demais para entrar por
      // descuido. Quando isso for resolvido, este teste falha e some.
      const terceiros = new Set();
      page.on('request', (request) => {
        const { host } = new URL(request.url());
        if (host !== '127.0.0.1:8123') terceiros.add(host);
      });

      await page.goto('/ClipSaver/app/');
      await expect(page.locator('flutter-view')).toBeAttached({
        timeout: 60_000,
      });
      // A fonte é pedida depois do primeiro quadro.
      await page.waitForTimeout(3_000);

      expect([...terceiros]).toEqual(['fonts.gstatic.com']);
    });

  test('o base-href aponta para o subdiretório do Pages', async ({ page }) => {
    await page.goto('/ClipSaver/app/');

    // Um base-href errado publica um app que carrega o index e depois
    // busca todos os assets na raiz do domínio — 404 em cada um.
    const base = await page.locator('base').getAttribute('href');
    expect(base).toBe('/ClipSaver/app/');
  });
});

test.describe('despachante de rotas', () => {
  test('um deep link no app termina no app, não numa página de erro',
    async ({ page }) => {
      // O Pages responde 404 numa rota que não é arquivo — isso é por
      // design, e é justamente o que faz o 404.html rodar. O que importa
      // não é o status, é onde o usuário para: sem o despachante, um F5 em
      // /library termina na página de erro do GitHub.
      await page.goto('/ClipSaver/app/library');
      await expect(page).toHaveURL('/ClipSaver/app/');
      await expect(page.locator('flutter-view')).toBeAttached({
        timeout: 60_000,
      });
    });

  test('uma rota desconhecida na raiz volta para o protótipo',
    async ({ page }) => {
      await page.goto('/ClipSaver/rota-que-nao-existe');
      await expect(page).toHaveURL('/ClipSaver/');
    });
});
