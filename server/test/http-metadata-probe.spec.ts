import { describe, expect, it } from 'vitest';
import { HttpMetadataProbe, type FetchLike } from '../src/modules/analysis/http-metadata-probe.js';

/** Builds a fetch fake serving fixed responses per method. */
function fakeFetch(responses: {
  head?: { status?: number; contentType?: string };
  get?: { status?: number; contentType?: string; body?: string };
}): FetchLike {
  return async (_url, init) => {
    const spec = init.method === 'HEAD' ? responses.head : responses.get;
    const contentType = spec?.contentType ?? null;
    return {
      status: spec?.status ?? 200,
      headers: { get: (name) => (name.toLowerCase() === 'content-type' ? contentType : null) },
      text: async (): Promise<string> => (spec as { body?: string } | undefined)?.body ?? '',
    };
  };
}

describe('HttpMetadataProbe', () => {
  const url = new URL('https://example.com/page');

  it('reports media content types without fetching the body', async () => {
    let gets = 0;
    const probe = new HttpMetadataProbe(async (u, init) => {
      if (init.method === 'GET') gets += 1;
      return {
        status: 200,
        headers: { get: () => 'video/mp4' },
        text: async () => '',
      };
    });
    const result = await probe.probe(new URL('https://example.com/talk.mp4'));
    expect(result.contentType).toBe('video/mp4');
    expect(result.drmDetected).toBe(false);
    expect(gets).toBe(0);
  });

  it('flags authentication walls from 401/403', async () => {
    for (const status of [401, 403]) {
      const probe = new HttpMetadataProbe(fakeFetch({ head: { status } }));
      const result = await probe.probe(url);
      expect(result.requiresAuthentication).toBe(true);
    }
  });

  it('flags payment walls from 402', async () => {
    const probe = new HttpMetadataProbe(fakeFetch({ head: { status: 402 } }));
    expect((await probe.probe(url)).paywalled).toBe(true);
  });

  it('extracts title, author, thumbnail and license from HTML metadata', async () => {
    const html = `
      <html><head>
        <title>Fallback</title>
        <meta property="og:title" content="Aula de F&#39;sica &amp; Química" />
        <meta name="author" content="Prof. Silva" />
        <meta property="og:image" content="https://cdn.example.com/thumb.jpg" />
        <link rel="license" href="https://creativecommons.org/licenses/by/4.0/" />
      </head></html>`;
    const probe = new HttpMetadataProbe(
      fakeFetch({
        head: { contentType: 'text/html; charset=utf-8' },
        get: { contentType: 'text/html', body: html },
      }),
    );
    const result = await probe.probe(url);
    expect(result.title).toBe("Aula de F'sica & Química");
    expect(result.author).toBe('Prof. Silva');
    expect(result.thumbnailUrl).toBe('https://cdn.example.com/thumb.jpg');
    expect(result.licenseMetadata).toBe('https://creativecommons.org/licenses/by/4.0/');
    expect(result.paywalled).toBe(false);
  });

  it('reads schema.org license and paywall flags from JSON-LD', async () => {
    const html = `
      <script type="application/ld+json">
        {"@type":"VideoObject","license":"CC-BY-4.0","isAccessibleForFree":false}
      </script>`;
    const probe = new HttpMetadataProbe(
      fakeFetch({ head: { contentType: 'text/html' }, get: { body: html } }),
    );
    const result = await probe.probe(url);
    expect(result.licenseMetadata).toBe('CC-BY-4.0');
    expect(result.paywalled).toBe(true);
  });

  it('detects DRM markers in the page', async () => {
    const probe = new HttpMetadataProbe(
      fakeFetch({
        head: { contentType: 'text/html' },
        get: { body: '<script src="/player-widevine.js"></script>' },
      }),
    );
    expect((await probe.probe(url)).drmDetected).toBe(true);
  });

  it('falls back to <title> when og:title is absent', async () => {
    const probe = new HttpMetadataProbe(
      fakeFetch({ head: { contentType: 'text/html' }, get: { body: '<title> Só título </title>' } }),
    );
    expect((await probe.probe(url)).title).toBe('Só título');
  });

  it('reports non-HTML, non-media types without parsing', async () => {
    const probe = new HttpMetadataProbe(fakeFetch({ head: { contentType: 'application/zip' } }));
    const result = await probe.probe(url);
    expect(result.contentType).toBe('application/zip');
    expect(result.title).toBeUndefined();
  });
});
