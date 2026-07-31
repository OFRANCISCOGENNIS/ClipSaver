// Static server that behaves like GitHub Pages.
//
// Two behaviours are load-bearing for the tests and differ from a naive
// static server:
//   - a directory URL serves that directory's index.html;
//   - anything missing serves the site-wide 404.html, which is where the
//     deep-link dispatcher lives.
// Without the second one the dispatcher would never run, and the test that
// proves deep links work would pass against a server that does not behave
// like the real host.

import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../site', import.meta.url));
const PORT = Number(process.env.PORT ?? 8123);

// Pages serves a project site under /<repo>/, and the app was built with
// `--base-href /ClipSaver/app/`. Serving the tree at `/` instead would
// make every asset 404 and the 404.html dispatcher redirect to a path this
// server does not have — an infinite loop that says nothing about the app.
const BASE = '/ClipSaver';

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.webmanifest': 'application/manifest+json',
};

async function resolve(pathname) {
  if (pathname !== BASE && !pathname.startsWith(`${BASE}/`)) {
    return { file: join(ROOT, '404.html'), status: 404 };
  }
  const withinSite = pathname.slice(BASE.length) || '/';
  // normalize + the leading-slash strip keep `../` from escaping ROOT.
  const relative = normalize(decodeURIComponent(withinSite)).replace(/^(\.\.[/\\])+/, '');
  let file = join(ROOT, relative);
  try {
    const info = await stat(file);
    if (info.isDirectory()) file = join(file, 'index.html');
    await stat(file);
    return { file, status: 200 };
  } catch {
    return { file: join(ROOT, '404.html'), status: 404 };
  }
}

createServer(async (request, response) => {
  const { pathname } = new URL(request.url, `http://${request.headers.host}`);
  const { file, status } = await resolve(pathname);
  try {
    const body = await readFile(file);
    response.writeHead(status, {
      'content-type': TYPES[extname(file)] ?? 'application/octet-stream',
      // The Flutter web bootstrap needs these for its WASM worker.
      'cross-origin-opener-policy': 'same-origin',
      'cross-origin-embedder-policy': 'credentialless',
    });
    response.end(body);
  } catch {
    response.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
    response.end('not found');
  }
}).listen(PORT, '127.0.0.1', () => {
  process.stdout.write(`serving ${ROOT} on http://127.0.0.1:${PORT}\n`);
});
