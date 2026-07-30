/**
 * Stripe subscription verification (desktop/Web purchases, section 14).
 *
 * Responsibility: confirm a subscription id with Stripe's API and map the
 * answer onto [VerifiedPurchase]. The client only ever hands us the
 * subscription id from the Checkout success redirect — the authority on
 * whether it is paid is Stripe, reached with the secret key.
 */
import type { VerifiedPurchase } from './domain/entitlement.js';
import { ReceiptRejectedError, type ReceiptVerifier } from './domain/receipt-verifier.js';
import type { HttpGet } from './google-play-verifier.js';

/** Slice of Stripe's subscription object this code relies on. */
interface StripeSubscription {
  id?: string;
  status?: string;
  cancel_at_period_end?: boolean;
  current_period_end?: number;
  items?: { data?: Array<{ price?: { id?: string } }> };
}

/** Stripe states in which the user is entitled right now. */
const ACTIVE_STATUSES = new Set(['active', 'trialing', 'past_due']);

export class StripeVerifier implements ReceiptVerifier {
  readonly provider = 'stripe' as const;

  constructor(
    private readonly secretKey: string,
    private readonly httpGet: HttpGet,
    private readonly baseUrl = 'https://api.stripe.com',
  ) {}

  async verify(token: string): Promise<VerifiedPurchase> {
    // The token must look like a subscription id before it goes anywhere
    // near a URL: this API is called with our secret key.
    if (!/^sub_[A-Za-z0-9]+$/.test(token)) {
      throw new ReceiptRejectedError(
        'Identificador de assinatura inválido.',
        this.provider,
      );
    }

    const response = await this.httpGet(`${this.baseUrl}/v1/subscriptions/${token}`, {
      headers: { Authorization: `Bearer ${this.secretKey}` },
    });
    if (!response.ok) {
      throw new ReceiptRejectedError(
        `Stripe recusou a assinatura (HTTP ${response.status}).`,
        this.provider,
      );
    }

    const body = (await response.json()) as StripeSubscription;
    if (!ACTIVE_STATUSES.has(body.status ?? '')) {
      throw new ReceiptRejectedError(
        `Assinatura não está ativa (${body.status ?? 'sem status'}).`,
        this.provider,
      );
    }
    const priceId = body.items?.data?.[0]?.price?.id;
    if (!body.id || !body.current_period_end || !priceId) {
      throw new ReceiptRejectedError(
        'Resposta do Stripe sem produto ou período corrente.',
        this.provider,
      );
    }

    return {
      provider: this.provider,
      transactionId: body.id,
      productId: priceId,
      // Stripe reports epoch seconds.
      expiresAt: new Date(body.current_period_end * 1000),
      // `past_due` is Stripe's own retry window; `cancel_at_period_end`
      // means paid through the period but not renewing after it.
      autoRenewing: body.cancel_at_period_end !== true,
    };
  }
}
