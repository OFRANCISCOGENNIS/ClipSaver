// Playwright against the built site tree.
//
// Serves `../site` — the exact directory the Pages workflow uploads — so
// the tests exercise the artifact rather than a dev server that resolves
// paths differently. `tool/serve_site.mjs` reproduces the two Pages
// behaviours that matter here: a single 404.html for the whole site, and
// directory URLs resolving to index.html.

import { defineConfig, devices } from '@playwright/test';

const PORT = 8123;

// Escape hatch for environments that already ship a Chromium at a fixed
// path and cannot run `playwright install` (a sandbox with a pinned
// browser build). CI leaves it unset and uses the standard download, so
// what runs there is the version this config pins.
const executablePath = process.env.PLAYWRIGHT_CHROMIUM_PATH;

export default defineConfig({
  testDir: '.',
  // A failing browser check is a real defect, not flakiness to retry away.
  retries: 0,
  // The Flutter build is ~5MB of JS plus a WASM CanvasKit; on a cold CI
  // runner the first paint takes well past Playwright's 30s default, and
  // a timeout there would read as "the app is broken" when it is not.
  timeout: 90_000,
  reporter: [['list']],
  use: {
    baseURL: `http://127.0.0.1:${PORT}`,
    trace: 'retain-on-failure',
    ...(executablePath ? { launchOptions: { executablePath } } : {}),
  },
  webServer: {
    command: `node ${new URL('./serve_site.mjs', import.meta.url).pathname}`,
    port: PORT,
    reuseExistingServer: true,
    timeout: 30_000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
