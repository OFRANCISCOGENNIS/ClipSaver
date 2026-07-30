import { describe, expect, it } from 'vitest';
import {
  checkUrlSafety,
  isBlockedIpLiteral,
} from '../src/modules/eligibility/domain/url-safety.js';

describe('checkUrlSafety', () => {
  it('accepts plain public http(s) URLs', () => {
    expect(checkUrlSafety('https://example.com/a.mp4').safe).toBe(true);
    expect(checkUrlSafety('http://cdn.example.org/x').safe).toBe(true);
    expect(checkUrlSafety('  https://example.com/a.mp4  ').safe).toBe(true);
  });

  it('refuses malformed URLs', () => {
    expect(checkUrlSafety('not a url').safe).toBe(false);
  });

  it('refuses non-http schemes', () => {
    for (const url of ['file:///etc/passwd', 'ftp://example.com/a', 'gopher://x', 'javascript:alert(1)']) {
      expect(checkUrlSafety(url).safe, url).toBe(false);
    }
  });

  it('refuses embedded credentials', () => {
    expect(checkUrlSafety('https://user:pass@example.com/a').safe).toBe(false);
    expect(checkUrlSafety('https://user@example.com/a').safe).toBe(false);
  });

  it('refuses local hostnames', () => {
    for (const url of [
      'http://localhost/a',
      'http://foo.localhost/a',
      'http://nas.local/a',
      'http://db.internal/a',
    ]) {
      expect(checkUrlSafety(url).safe, url).toBe(false);
    }
  });

  it('refuses private and reserved IP literals', () => {
    for (const url of [
      'http://127.0.0.1/a',
      'http://10.1.2.3/a',
      'http://192.168.0.10/a',
      'http://172.16.5.5/a',
      'http://169.254.169.254/latest/meta-data',
      'http://100.64.0.1/a',
      'http://0.0.0.0/a',
      'http://224.0.0.1/a',
      'http://[::1]/a',
      'http://[fe80::1]/a',
      'http://[fd00::1]/a',
      'http://[::ffff:10.0.0.1]/a',
    ]) {
      expect(checkUrlSafety(url).safe, url).toBe(false);
    }
  });

  it('accepts public IP literals', () => {
    expect(checkUrlSafety('http://203.0.113.9/a').safe).toBe(true);
    expect(checkUrlSafety('http://172.32.0.1/a').safe).toBe(true);
  });

  it('never echoes the full URL in the reason (log hygiene)', () => {
    const verdict = checkUrlSafety('http://10.0.0.1/secret/path?token=abc');
    expect(verdict.reason).not.toContain('secret');
    expect(verdict.reason).not.toContain('token');
  });
});

describe('isBlockedIpLiteral', () => {
  it('handles bracketed IPv6 input defensively', () => {
    expect(isBlockedIpLiteral('[::1]')).toBe(true);
  });

  it('treats out-of-range octets as blocked (malformed)', () => {
    expect(isBlockedIpLiteral('300.1.1.1')).toBe(true);
  });

  it('returns false for hostnames (handled elsewhere)', () => {
    expect(isBlockedIpLiteral('example.com')).toBe(false);
  });
});
