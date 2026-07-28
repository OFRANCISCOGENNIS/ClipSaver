/**
 * Acceptance tests for the Eligibility Engine (section 18 of the spec):
 * the 10 documented negative cases MUST be refused and the 10 positive
 * cases MUST be approved, each with the correct authorization source.
 */
import { describe, expect, it } from 'vitest';
import { EligibilityService } from '../src/modules/eligibility/domain/eligibility.service.js';
import type { AnalysisContext, MediaFormat } from '../src/modules/eligibility/domain/types.js';

const service = new EligibilityService();

const video1080: MediaFormat = { id: 'v1080', kind: 'video', container: 'mp4', codec: 'h264', height: 1080 };
const audio128: MediaFormat = { id: 'a128', kind: 'audio', container: 'mp3', bitrateKbps: 128 };

/** Baseline context: public page, no barriers, no license, no platform. */
function context(overrides: Omit<Partial<AnalysisContext>, 'url'> & { url?: string } = {}): AnalysisContext {
  const { url, ...rest } = overrides;
  return {
    url: new URL(url ?? 'https://example.com/watch/123'),
    drm: { detected: false },
    accessControl: { paywalled: false, requiresAuthentication: false },
    ...rest,
  };
}

describe('EligibilityService — 10 negative acceptance cases (DoD)', () => {
  it('N1: refuses Widevine DRM streams', () => {
    const verdict = service.evaluate(context({ drm: { detected: true, system: 'widevine' } }));
    expect(verdict.eligible).toBe(false);
    expect(verdict.source).toBe('none');
    expect(verdict.reason).toContain('DRM');
  });

  it('N2: refuses FairPlay DRM streams', () => {
    const verdict = service.evaluate(context({ drm: { detected: true, system: 'fairplay' } }));
    expect(verdict.eligible).toBe(false);
  });

  it('N3: refuses PlayReady DRM streams', () => {
    const verdict = service.evaluate(context({ drm: { detected: true, system: 'playready' } }));
    expect(verdict.eligible).toBe(false);
  });

  it('N4: DRM wins even when an open license is also declared', () => {
    const verdict = service.evaluate(
      context({
        drm: { detected: true, system: 'other' },
        licenseMetadata: 'CC-BY-4.0',
        directFileFormats: [video1080],
      }),
    );
    expect(verdict.eligible).toBe(false);
  });

  it('N5: refuses paywalled content for non-owners', () => {
    const verdict = service.evaluate(
      context({ accessControl: { paywalled: true, requiresAuthentication: false } }),
    );
    expect(verdict.eligible).toBe(false);
    expect(verdict.reason).toContain('paywall');
  });

  it('N6: refuses third-party session-gated content, pointing to the legitimate path', () => {
    const verdict = service.evaluate(
      context({ accessControl: { paywalled: false, requiresAuthentication: true } }),
    );
    expect(verdict.eligible).toBe(false);
    expect(verdict.reason).toContain('plataforma de origem');
  });

  it('N7: refuses localhost URLs (SSRF)', () => {
    const verdict = service.evaluate(context({ url: 'http://localhost:8080/a.mp4' }));
    expect(verdict.eligible).toBe(false);
  });

  it('N8: refuses cloud metadata addresses (SSRF)', () => {
    const verdict = service.evaluate(context({ url: 'http://169.254.169.254/latest/meta-data' }));
    expect(verdict.eligible).toBe(false);
  });

  it('N9: refuses all-rights-reserved content with no official download', () => {
    const verdict = service.evaluate(
      context({
        licenseMetadata: 'Standard License',
        platform: { id: 'video_site', officialDownloadEnabled: false, formats: [video1080] },
      }),
    );
    expect(verdict.eligible).toBe(false);
    expect(verdict.availableFormats).toHaveLength(0);
    expect(verdict.reason).toContain('não permite download');
  });

  it('N10: refuses content with download disabled and no license metadata at all', () => {
    const verdict = service.evaluate(
      context({ platform: { id: 'video_site', officialDownloadEnabled: false, formats: [] } }),
    );
    expect(verdict.eligible).toBe(false);
    expect(verdict.source).toBe('none');
  });
});

describe('EligibilityService — 10 positive acceptance cases (DoD)', () => {
  it('P1: approves CC-BY content with the attribution restriction surfaced', () => {
    const verdict = service.evaluate(
      context({
        licenseMetadata: 'CC-BY-4.0',
        platform: { id: 'video_site', officialDownloadEnabled: false, formats: [video1080] },
      }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('open_license');
    expect(verdict.license).toBe('CC-BY-4.0');
    expect(verdict.restrictions).toContain('atribuição obrigatória');
  });

  it('P2: approves CC0 content with no restrictions', () => {
    const verdict = service.evaluate(
      context({ licenseMetadata: 'CC0-1.0', directFileFormats: [video1080] }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.restrictions).toHaveLength(0);
  });

  it('P3: approves public-domain content', () => {
    const verdict = service.evaluate(
      context({ licenseMetadata: 'PDM', directFileFormats: [audio128] }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('open_license');
  });

  it('P4: approves CC-BY-SA declared via Creative Commons URL', () => {
    const verdict = service.evaluate(
      context({
        licenseMetadata: 'https://creativecommons.org/licenses/by-sa/4.0/',
        directFileFormats: [video1080],
      }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.license).toBe('CC-BY-SA-4.0');
    expect(verdict.restrictions).toContain('compartilhamento pela mesma licença');
  });

  it('P5: approves CC-BY-NC content surfacing the non-commercial restriction', () => {
    const verdict = service.evaluate(
      context({ licenseMetadata: 'CC-BY-NC-4.0', directFileFormats: [video1080] }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.restrictions).toContain('uso não comercial');
  });

  it('P6: approves platform content whose creator enabled the official download', () => {
    const verdict = service.evaluate(
      context({
        platform: { id: 'video_site', officialDownloadEnabled: true, formats: [video1080] },
      }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('official_api');
    expect(verdict.availableFormats).toEqual([video1080]);
  });

  it('P7: approves podcast episodes served by RSS enclosure (official API)', () => {
    const verdict = service.evaluate(
      context({
        url: 'https://cdn.podcast.example/ep12.mp3',
        platform: { id: 'podcast_rss', officialDownloadEnabled: true, formats: [audio128] },
      }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('official_api');
  });

  it('P8: approves the user own content via OAuth, even behind authentication', () => {
    const verdict = service.evaluate(
      context({
        accessControl: { paywalled: false, requiresAuthentication: true },
        ownership: { authenticatedUserId: 'u42', contentOwnerId: 'u42' },
        platform: { id: 'video_site', officialDownloadEnabled: false, formats: [video1080] },
      }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('user_owned');
  });

  it('P9: approves a direct public .mp4 link', () => {
    const verdict = service.evaluate(context({ url: 'https://files.example.com/talk.mp4' }));
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('direct_file');
    expect(verdict.availableFormats[0]!.container).toBe('mp4');
  });

  it('P10: approves a direct audio file identified by Content-Type only', () => {
    const verdict = service.evaluate(
      context({ url: 'https://files.example.com/stream?id=9', contentType: 'audio/mpeg' }),
    );
    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('direct_file');
    expect(verdict.availableFormats[0]!.kind).toBe('audio');
  });
});

describe('EligibilityService — decision pipeline details', () => {
  it('ownership does NOT override DRM', () => {
    const verdict = service.evaluate(
      context({
        drm: { detected: true, system: 'widevine' },
        ownership: { authenticatedUserId: 'u1', contentOwnerId: 'u1' },
        platform: { id: 'x', officialDownloadEnabled: true, formats: [video1080] },
      }),
    );
    expect(verdict.eligible).toBe(false);
  });

  it('non-owner OAuth identity does not authorize', () => {
    const verdict = service.evaluate(
      context({
        ownership: { authenticatedUserId: 'u1', contentOwnerId: 'u2' },
        platform: { id: 'x', officialDownloadEnabled: false, formats: [video1080] },
      }),
    );
    expect(verdict.eligible).toBe(false);
  });

  it('official API wins over open license when both apply (priority order)', () => {
    const verdict = service.evaluate(
      context({
        licenseMetadata: 'CC-BY-4.0',
        platform: { id: 'x', officialDownloadEnabled: true, formats: [video1080] },
      }),
    );
    expect(verdict.source).toBe('official_api');
  });

  it('every ineligible verdict carries an educational reason and no formats', () => {
    const cases = [
      context({ drm: { detected: true } }),
      context({ accessControl: { paywalled: true, requiresAuthentication: false } }),
      context({ url: 'http://10.0.0.1/a.mp4' }),
      context(),
    ];
    for (const c of cases) {
      const verdict = service.evaluate(c);
      expect(verdict.eligible).toBe(false);
      expect(verdict.reason.length).toBeGreaterThan(20);
      expect(verdict.availableFormats).toHaveLength(0);
    }
  });

  it('exposes the adapter catalogue with legal basis for the compliance page', () => {
    for (const adapter of service.adapters) {
      expect(adapter.id.length).toBeGreaterThan(0);
      expect(adapter.legalBasis.length).toBeGreaterThan(20);
      expect(adapter.officialEndpoint.length).toBeGreaterThan(10);
    }
    expect(service.adapters.map((a) => a.id)).toEqual([
      'user_owned_oauth',
      'official_api',
      'open_license',
      'direct_file',
    ]);
  });
});
