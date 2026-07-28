/**
 * SSRF guard for user-supplied URLs (section 13, "sanitização de URLs").
 *
 * Responsibility: refuse any URL that could make the backend reach into
 * itself, private networks or cloud metadata services. This runs before
 * any network fetch and is the server-side twin of the client-side
 * `MediaUrl` validation (defense in depth — the server never trusts the
 * client's check).
 */

/** Outcome of the safety check; `reason` is safe to log (no full URL). */
export interface UrlSafetyVerdict {
  safe: boolean;
  reason: string;
}

const BLOCKED_HOST_SUFFIXES = ['.localhost', '.local', '.internal'];

/** Returns whether [raw] may be fetched by the analysis workers. */
export function checkUrlSafety(raw: string): UrlSafetyVerdict {
  let url: URL;
  try {
    url = new URL(raw.trim());
  } catch {
    return { safe: false, reason: 'malformed URL' };
  }
  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    return { safe: false, reason: `blocked scheme ${url.protocol}` };
  }
  if (url.username !== '' || url.password !== '') {
    return { safe: false, reason: 'embedded credentials' };
  }
  const host = url.hostname.toLowerCase();
  if (host === 'localhost' || BLOCKED_HOST_SUFFIXES.some((s) => host.endsWith(s))) {
    return { safe: false, reason: 'local hostname' };
  }
  if (isBlockedIpLiteral(host)) {
    return { safe: false, reason: 'private or reserved IP address' };
  }
  return { safe: true, reason: 'ok' };
}

/**
 * Blocks loopback, RFC1918, link-local (incl. cloud metadata at
 * 169.254.169.254), CGNAT, "this network" and their IPv6 equivalents.
 * Note: DNS names resolving to private IPs must additionally be blocked
 * at fetch time (the HTTP client pins the resolved address); this
 * function handles IP *literals* only.
 */
export function isBlockedIpLiteral(host: string): boolean {
  // IPv6 literals arrive bracket-stripped from URL.hostname on Node,
  // but keep the strip defensive for direct callers.
  const bare = host.replace(/^\[|\]$/g, '').toLowerCase();
  if (bare === '::' || bare === '::1') return true;
  if (/^(fe80|fc[0-9a-f]{2}|fd[0-9a-f]{2}):/i.test(bare)) return true;
  // IPv4-mapped IPv6, dotted (::ffff:10.0.0.1) or hex-normalized
  // (::ffff:a00:1 — what Node's URL parser produces for the dotted form).
  let candidate = bare;
  const mappedDotted = bare.match(/^::ffff:(\d{1,3}(?:\.\d{1,3}){3})$/);
  const mappedHex = bare.match(/^::ffff:([0-9a-f]{1,4}):([0-9a-f]{1,4})$/);
  if (mappedDotted) {
    candidate = mappedDotted[1]!;
  } else if (mappedHex) {
    const high = parseInt(mappedHex[1]!, 16);
    const low = parseInt(mappedHex[2]!, 16);
    candidate = `${high >> 8}.${high & 0xff}.${low >> 8}.${low & 0xff}`;
  }

  const octets = candidate.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
  if (!octets) return false;
  const [a, b, c, d] = octets.slice(1).map(Number) as [number, number, number, number];
  if ([a, b, c, d].some((o) => o > 255)) return true; // malformed → block
  return (
    a === 0 || // "this network"
    a === 10 ||
    a === 127 ||
    (a === 100 && b >= 64 && b <= 127) || // CGNAT
    (a === 169 && b === 254) || // link-local & cloud metadata
    (a === 172 && b >= 16 && b <= 31) ||
    (a === 192 && b === 168) ||
    a >= 224 // multicast + reserved
  );
}
