import { describe, expect, it } from 'vitest';
import { DirectFileAdapter } from '../src/modules/eligibility/domain/adapters/direct-file.adapter.js';
import { OpenLicenseAdapter } from '../src/modules/eligibility/domain/adapters/open-license.adapter.js';
import { UserOwnedAdapter } from '../src/modules/eligibility/domain/adapters/user-owned.adapter.js';
import { PlatformAdapterRegistry } from '../src/modules/eligibility/domain/platform-adapter.js';
import type { AnalysisContext } from '../src/modules/eligibility/domain/types.js';

function context(overrides: Omit<Partial<AnalysisContext>, 'url'> & { url?: string } = {}): AnalysisContext {
  const { url, ...rest } = overrides;
  return {
    url: new URL(url ?? 'https://example.com/x'),
    drm: { detected: false },
    accessControl: { paywalled: false, requiresAuthentication: false },
    ...rest,
  };
}

describe('PlatformAdapterRegistry', () => {
  it('rejects duplicate adapter ids', () => {
    const registry = new PlatformAdapterRegistry();
    registry.register(new DirectFileAdapter());
    expect(() => registry.register(new DirectFileAdapter())).toThrow(/already registered/);
  });

  it('returns the first eligible verdict in registration order', () => {
    const registry = new PlatformAdapterRegistry();
    registry.register(new OpenLicenseAdapter());
    registry.register(new DirectFileAdapter());
    const verdict = registry.evaluate(
      context({ url: 'https://e.com/a.mp4', licenseMetadata: 'CC0-1.0', directFileFormats: [{ id: 'd', kind: 'video', container: 'mp4' }] }),
    );
    expect(verdict?.source).toBe('open_license');
  });

  it('returns null when no adapter applies', () => {
    const registry = new PlatformAdapterRegistry();
    registry.register(new UserOwnedAdapter());
    expect(registry.evaluate(context())).toBeNull();
  });
});

describe('UserOwnedAdapter', () => {
  const adapter = new UserOwnedAdapter();

  it('does not apply without both identity facts', () => {
    expect(adapter.evaluate(context())).toBeNull();
    expect(
      adapter.evaluate(context({ ownership: { authenticatedUserId: 'u1' } })),
    ).toBeNull();
    expect(adapter.evaluate(context({ ownership: { contentOwnerId: 'u1' } }))).toBeNull();
  });

  it('does not apply when there is no real format to offer', () => {
    expect(
      adapter.evaluate(context({ ownership: { authenticatedUserId: 'u1', contentOwnerId: 'u1' } })),
    ).toBeNull();
  });

  it('falls back to direct-file formats for user-owned raw files', () => {
    const verdict = adapter.evaluate(
      context({
        ownership: { authenticatedUserId: 'u1', contentOwnerId: 'u1' },
        directFileFormats: [{ id: 'd', kind: 'audio', container: 'mp3' }],
      }),
    );
    expect(verdict?.eligible).toBe(true);
    expect(verdict?.source).toBe('user_owned');
  });
});

describe('OfficialApiAdapter / OpenLicenseAdapter guardrails', () => {
  it('official API without real formats does not authorize', async () => {
    const { OfficialApiAdapter } = await import(
      '../src/modules/eligibility/domain/adapters/official-api.adapter.js'
    );
    const adapter = new OfficialApiAdapter();
    expect(
      adapter.evaluate(
        context({ platform: { id: 'x', officialDownloadEnabled: true, formats: [] } }),
      ),
    ).toBeNull();
  });

  it('open license without real formats does not authorize', () => {
    const adapter = new OpenLicenseAdapter();
    expect(adapter.evaluate(context({ licenseMetadata: 'CC0-1.0' }))).toBeNull();
  });
});

describe('DirectFileAdapter', () => {
  const adapter = new DirectFileAdapter();

  it('recognizes media by extension for all supported containers', () => {
    for (const ext of ['mp4', 'webm', 'mkv', 'mov', 'm4v']) {
      expect(adapter.evaluate(context({ url: `https://e.com/f.${ext}` }))?.availableFormats[0]?.kind).toBe('video');
    }
    for (const ext of ['mp3', 'aac', 'wav', 'flac', 'ogg', 'opus', 'm4a']) {
      expect(adapter.evaluate(context({ url: `https://e.com/f.${ext}` }))?.availableFormats[0]?.kind).toBe('audio');
    }
  });

  it('recognizes media by Content-Type when the path is opaque', () => {
    const verdict = adapter.evaluate(
      context({ url: 'https://e.com/stream?id=1', contentType: 'video/webm' }),
    );
    expect(verdict?.availableFormats[0]).toMatchObject({ kind: 'video', container: 'webm' });
  });

  it('does not apply to HTML pages or unknown types', () => {
    expect(adapter.evaluate(context({ contentType: 'text/html' }))).toBeNull();
    expect(adapter.evaluate(context({ url: 'https://e.com/file.pdf' }))).toBeNull();
    expect(adapter.evaluate(context({ url: 'https://e.com/noext' }))).toBeNull();
  });

  it('prefers richer origin-reported formats over the fallback', () => {
    const rich = { id: 'v720', kind: 'video' as const, container: 'mp4', height: 720 };
    const verdict = adapter.evaluate(
      context({ url: 'https://e.com/f.mp4', directFileFormats: [rich] }),
    );
    expect(verdict?.availableFormats).toEqual([rich]);
  });
});
