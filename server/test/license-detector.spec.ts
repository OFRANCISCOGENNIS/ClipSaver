import { describe, expect, it } from 'vitest';
import {
  ALL_RIGHTS_RESERVED,
  detectLicense,
} from '../src/modules/eligibility/domain/license-detector.js';

describe('detectLicense', () => {
  it('maps canonical SPDX identifiers case-insensitively', () => {
    expect(detectLicense('CC-BY-4.0').spdxId).toBe('CC-BY-4.0');
    expect(detectLicense('cc-by-sa-4.0').spdxId).toBe('CC-BY-SA-4.0');
    expect(detectLicense('CC-BY-NC-4.0').spdxId).toBe('CC-BY-NC-4.0');
    expect(detectLicense('CC-BY-ND-4.0').spdxId).toBe('CC-BY-ND-4.0');
    expect(detectLicense('CC0-1.0').spdxId).toBe('CC0-1.0');
    expect(detectLicense('PDM').spdxId).toBe('PDM');
  });

  it('maps Creative Commons deed URLs', () => {
    expect(detectLicense('https://creativecommons.org/licenses/by/4.0/').spdxId).toBe('CC-BY-4.0');
    expect(detectLicense('https://creativecommons.org/licenses/by-nd/4.0/').spdxId).toBe(
      'CC-BY-ND-4.0',
    );
    expect(detectLicense('https://creativecommons.org/publicdomain/zero/1.0/').spdxId).toBe(
      'CC0-1.0',
    );
  });

  it('fails closed on null, empty and unknown declarations', () => {
    expect(detectLicense(null)).toBe(ALL_RIGHTS_RESERVED);
    expect(detectLicense(undefined)).toBe(ALL_RIGHTS_RESERVED);
    expect(detectLicense('')).toBe(ALL_RIGHTS_RESERVED);
    expect(detectLicense('Standard License')).toBe(ALL_RIGHTS_RESERVED);
    expect(detectLicense('https://creativecommons.org/licenses/by-nc-nd/4.0/')).toBe(
      ALL_RIGHTS_RESERVED,
    );
    expect(ALL_RIGHTS_RESERVED.allowsDownload).toBe(false);
  });

  it('every open license carries user-facing restriction text where due', () => {
    expect(detectLicense('CC-BY-4.0').restrictions).toContain('atribuição obrigatória');
    expect(detectLicense('CC-BY-NC-4.0').restrictions).toContain('uso não comercial');
    expect(detectLicense('CC0-1.0').restrictions).toHaveLength(0);
  });
});
