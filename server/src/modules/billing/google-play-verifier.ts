/**
 * Google Play receipt verification (Android Publisher API v3).
 *
 * Responsibility: ask Google whether a purchase token is a live
 * subscription, and map its answer onto [VerifiedPurchase].
 *
 * The OAuth access token is injected rather than minted here: obtaining it
 * means signing a service-account assertion, which is a credential concern
 * with its own rotation story. Keeping it behind a function makes this
 * class testable without a Google project — and lets the deployment choose
 * workload identity over a JSON key file.
 */
import type { VerifiedPurchase } from './domain/entitlement.js';
import { ReceiptRejectedError, type ReceiptVerifier } from './domain/receipt-verifier.js';

/** Minimal shape of the `subscriptionsv2` response this code relies on. */
interface SubscriptionPurchaseV2 {
  subscriptionState?: string;
  latestOrderId?: string;
  lineItems?: Array<{
    productId?: string;
    expiryTime?: string;
    autoRenewingPlan?: { autoRenewEnabled?: boolean };
  }>;
}

/** States Google reports for a subscription that is currently usable. */
const ACTIVE_STATES = new Set([
  'SUBSCRIPTION_STATE_ACTIVE',
  'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
  // Cancelled but paid through the current period: still entitled until
  // the expiry Google reports.
  'SUBSCRIPTION_STATE_CANCELED',
]);

/** Injected HTTP call, so tests need no network. */
export type HttpGet = (
  url: string,
  init: { headers: Record<string, string> },
) => Promise<{ ok: boolean; status: number; json: () => Promise<unknown> }>;

/** Supplies a bearer token for the Android Publisher API. */
export type AccessTokenProvider = () => Promise<string>;

export class GooglePlayVerifier implements ReceiptVerifier {
  readonly provider = 'google' as const;

  constructor(
    private readonly packageName: string,
    private readonly accessToken: AccessTokenProvider,
    private readonly httpGet: HttpGet,
    private readonly baseUrl = 'https://androidpublisher.googleapis.com',
  ) {}

  async verify(token: string): Promise<VerifiedPurchase> {
    const url =
      `${this.baseUrl}/androidpublisher/v3/applications/` +
      `${encodeURIComponent(this.packageName)}/purchases/subscriptionsv2/tokens/` +
      `${encodeURIComponent(token)}`;

    const response = await this.httpGet(url, {
      headers: { Authorization: `Bearer ${await this.accessToken()}` },
    });

    if (!response.ok) {
      // 404 is the common one: a token that never existed, or one from a
      // different package. Both mean "not entitled".
      throw new ReceiptRejectedError(
        `Google Play recusou o recibo (HTTP ${response.status}).`,
        this.provider,
      );
    }

    const body = (await response.json()) as SubscriptionPurchaseV2;
    const state = body.subscriptionState ?? '';
    if (!ACTIVE_STATES.has(state)) {
      throw new ReceiptRejectedError(
        `Assinatura não está ativa (${state || 'estado ausente'}).`,
        this.provider,
      );
    }

    // A subscription can carry several line items; the entitlement ends
    // with the last one to expire, which is what the user actually paid
    // through.
    const items = body.lineItems ?? [];
    let latest: { productId?: string; expiryTime?: string; auto: boolean } | null =
      null;
    for (const item of items) {
      if (!item.expiryTime) continue;
      const parsed = Date.parse(item.expiryTime);
      if (Number.isNaN(parsed)) continue;
      if (!latest || parsed > Date.parse(latest.expiryTime!)) {
        latest = {
          ...(item.productId !== undefined ? { productId: item.productId } : {}),
          expiryTime: item.expiryTime,
          auto: item.autoRenewingPlan?.autoRenewEnabled ?? false,
        };
      }
    }

    if (!latest?.expiryTime || !latest.productId) {
      throw new ReceiptRejectedError(
        'Resposta do Google Play sem produto ou data de expiração.',
        this.provider,
      );
    }

    return {
      provider: this.provider,
      // The order id identifies the purchase across renewals, which is
      // what makes a replayed receipt detectable.
      transactionId: body.latestOrderId ?? token,
      productId: latest.productId,
      expiresAt: new Date(latest.expiryTime),
      autoRenewing: latest.auto,
    };
  }
}
