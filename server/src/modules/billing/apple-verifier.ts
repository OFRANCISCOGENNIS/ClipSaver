/**
 * App Store receipt verification (App Store Server API v1).
 *
 * Responsibility: ask Apple for the subscription statuses behind a
 * transaction id and map the answer onto [VerifiedPurchase].
 *
 * The API bearer token is injected: minting it means signing an ES256 JWT
 * with the App Store Connect key, which is a credential concern with its
 * own rotation story — and keeping it out makes this class testable
 * without an Apple developer account.
 */
import type { VerifiedPurchase } from './domain/entitlement.js';
import { ReceiptRejectedError, type ReceiptVerifier } from './domain/receipt-verifier.js';
import type { AccessTokenProvider, HttpGet } from './google-play-verifier.js';

/** Slice of the `subscriptionStatuses` response this code relies on. */
interface StatusResponse {
  data?: Array<{
    lastTransactions?: Array<{
      status?: number;
      signedTransactionInfo?: string;
    }>;
  }>;
}

/** Claims inside a signed transaction this code reads. */
interface TransactionClaims {
  transactionId?: string;
  productId?: string;
  expiresDate?: number;
}

/**
 * Apple's status codes for a subscription that is currently usable:
 * 1 = active, 4 = billing grace period.
 */
const ACTIVE_STATUSES = new Set([1, 4]);

/**
 * Decodes the payload of an Apple-signed JWS.
 *
 * The signature is NOT verified here and that is deliberate: the payload
 * arrived over TLS *from Apple itself* in response to our authenticated
 * call — it is not the client-supplied receipt. What the client sent was
 * only the transaction id we asked Apple about.
 */
function decodeJwsPayload(jws: string): TransactionClaims {
  const parts = jws.split('.');
  if (parts.length !== 3 || !parts[1]) {
    throw new Error('JWS malformado');
  }
  const payload = Buffer.from(parts[1], 'base64url').toString('utf8');
  return JSON.parse(payload) as TransactionClaims;
}

export class AppleVerifier implements ReceiptVerifier {
  readonly provider = 'apple' as const;

  constructor(
    private readonly accessToken: AccessTokenProvider,
    private readonly httpGet: HttpGet,
    private readonly baseUrl = 'https://api.storekit.itunes.apple.com',
  ) {}

  async verify(token: string): Promise<VerifiedPurchase> {
    const url = `${this.baseUrl}/inApps/v1/subscriptions/${encodeURIComponent(token)}`;
    const response = await this.httpGet(url, {
      headers: { Authorization: `Bearer ${await this.accessToken()}` },
    });

    if (!response.ok) {
      throw new ReceiptRejectedError(
        `App Store recusou a transação (HTTP ${response.status}).`,
        this.provider,
      );
    }

    const body = (await response.json()) as StatusResponse;
    // Pick the latest usable transaction across the subscription groups —
    // the entitlement is whatever the user is paid through right now.
    let best: { claims: TransactionClaims; status: number } | null = null;
    for (const group of body.data ?? []) {
      for (const transaction of group.lastTransactions ?? []) {
        if (transaction.status === undefined || !transaction.signedTransactionInfo) {
          continue;
        }
        let claims: TransactionClaims;
        try {
          claims = decodeJwsPayload(transaction.signedTransactionInfo);
        } catch {
          continue;
        }
        if (!claims.expiresDate) continue;
        if (!best || claims.expiresDate > (best.claims.expiresDate ?? 0)) {
          best = { claims, status: transaction.status };
        }
      }
    }

    if (!best || !best.claims.productId || !best.claims.transactionId) {
      throw new ReceiptRejectedError(
        'Resposta da App Store sem transação utilizável.',
        this.provider,
      );
    }
    if (!ACTIVE_STATUSES.has(best.status)) {
      throw new ReceiptRejectedError(
        `Assinatura não está ativa (status ${best.status}).`,
        this.provider,
      );
    }

    return {
      provider: this.provider,
      transactionId: best.claims.transactionId,
      productId: best.claims.productId,
      expiresAt: new Date(best.claims.expiresDate!),
      // Status 4 is Apple's own billing-retry window: the store itself
      // still considers the plan renewing.
      autoRenewing: true,
    };
  }
}
