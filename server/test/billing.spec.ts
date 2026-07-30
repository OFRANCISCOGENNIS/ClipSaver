/**
 * Unit tests of the billing rules: entitlement resolution against the
 * clock, per-store verification, and the replay guard.
 */
import { ConflictException, UnprocessableEntityException } from '@nestjs/common';
import { describe, expect, it } from 'vitest';
import { AppleVerifier } from '../src/modules/billing/apple-verifier.js';
import { BillingService } from '../src/modules/billing/billing.service.js';
import {
  GRACE_PERIOD_MS,
  resolveEntitlement,
  type EntitlementRecord,
  type VerifiedPurchase,
} from '../src/modules/billing/domain/entitlement.js';
import {
  ReceiptRejectedError,
  selectVerifier,
  type ReceiptVerifier,
} from '../src/modules/billing/domain/receipt-verifier.js';
import {
  GooglePlayVerifier,
  type HttpGet,
} from '../src/modules/billing/google-play-verifier.js';
import { InMemoryEntitlementsRepository } from '../src/modules/billing/ports.js';
import { StripeVerifier } from '../src/modules/billing/stripe-verifier.js';

const NOW = new Date('2026-07-29T12:00:00Z');

function record(overrides: Partial<EntitlementRecord> = {}): EntitlementRecord {
  return {
    userId: 'u1',
    provider: 'stripe',
    transactionId: 'sub_123',
    productId: 'vidora.premium.monthly',
    expiresAt: new Date(NOW.getTime() + 24 * 3600 * 1000),
    autoRenewing: true,
    updatedAt: NOW,
    ...overrides,
  };
}

/** HTTP fake returning a scripted status/body. */
function http(status: number, body: unknown): HttpGet {
  return async () => ({
    ok: status >= 200 && status < 300,
    status,
    json: async () => body,
  });
}

describe('resolveEntitlement', () => {
  it('no record means free', () => {
    const status = resolveEntitlement(null, NOW);
    expect(status.plan).toBe('free');
    expect(status.expiresAt).toBeNull();
  });

  it('a live subscription is premium', () => {
    const status = resolveEntitlement(record(), NOW);
    expect(status.plan).toBe('premium');
    expect(status.inGracePeriod).toBe(false);
    expect(status.productId).toBe('vidora.premium.monthly');
  });

  it('a lapsed but renewing subscription gets the grace window', () => {
    const expired = record({
      expiresAt: new Date(NOW.getTime() - 3600 * 1000),
      autoRenewing: true,
    });
    const status = resolveEntitlement(expired, NOW);
    expect(status.plan).toBe('premium');
    expect(status.inGracePeriod).toBe(true);
  });

  it('a cancelled subscription gets no grace: that time was not bought', () => {
    const cancelled = record({
      expiresAt: new Date(NOW.getTime() - 3600 * 1000),
      autoRenewing: false,
    });
    expect(resolveEntitlement(cancelled, NOW).plan).toBe('free');
  });

  it('the grace window ends', () => {
    const longGone = record({
      expiresAt: new Date(NOW.getTime() - GRACE_PERIOD_MS - 1000),
      autoRenewing: true,
    });
    expect(resolveEntitlement(longGone, NOW).plan).toBe('free');
  });
});

describe('selectVerifier', () => {
  it('refuses a provider nobody configured — fail closed', () => {
    expect(() => selectVerifier([], 'apple')).toThrow(ReceiptRejectedError);
  });
});

describe('StripeVerifier', () => {
  it('accepts an active subscription', async () => {
    const verifier = new StripeVerifier(
      'sk_test',
      http(200, {
        id: 'sub_123',
        status: 'active',
        cancel_at_period_end: false,
        current_period_end: 1_790_000_000,
        items: { data: [{ price: { id: 'price_premium' } }] },
      }),
    );
    const purchase = await verifier.verify('sub_123');
    expect(purchase.productId).toBe('price_premium');
    expect(purchase.autoRenewing).toBe(true);
    expect(purchase.expiresAt.getTime()).toBe(1_790_000_000_000);
  });

  it('rejects a token that is not a subscription id before any HTTP', async () => {
    let called = false;
    const verifier = new StripeVerifier('sk_test', async () => {
      called = true;
      throw new Error('não deveria chegar aqui');
    });
    await expect(verifier.verify('../../v1/charges')).rejects.toThrow(
      ReceiptRejectedError,
    );
    expect(called).toBe(false);
  });

  it('rejects a cancelled-and-lapsed subscription', async () => {
    const verifier = new StripeVerifier('sk_test', http(200, { status: 'canceled' }));
    await expect(verifier.verify('sub_dead')).rejects.toThrow(/não está ativa/);
  });

  it('accepts past_due — Stripe\'s own retry window', async () => {
    // Revoking on the first failed charge would punish the user for their
    // bank's timing while Stripe is still trying to collect.
    const verifier = new StripeVerifier(
      'sk_test',
      http(200, {
        id: 'sub_123',
        status: 'past_due',
        current_period_end: 1_790_000_000,
        items: { data: [{ price: { id: 'price_premium' } }] },
      }),
    );
    expect((await verifier.verify('sub_123')).autoRenewing).toBe(true);
  });

  it('rejects an HTTP error from Stripe', async () => {
    const verifier = new StripeVerifier('sk_test', http(404, {}));
    await expect(verifier.verify('sub_missing')).rejects.toThrow(/HTTP 404/);
  });

  it('rejects a response missing the price or the period', async () => {
    // A subscription with no price is not something to grant premium on;
    // guessing would hand out a plan nobody was charged for.
    const noPrice = new StripeVerifier(
      'sk_test',
      http(200, { id: 'sub_123', status: 'active', current_period_end: 1 }),
    );
    await expect(noPrice.verify('sub_123')).rejects.toThrow(/sem produto/);

    const noPeriod = new StripeVerifier(
      'sk_test',
      http(200, {
        id: 'sub_123',
        status: 'active',
        items: { data: [{ price: { id: 'price_premium' } }] },
      }),
    );
    await expect(noPeriod.verify('sub_123')).rejects.toThrow(/período corrente/);
  });

  it('rejects a response with no status at all', async () => {
    const verifier = new StripeVerifier('sk_test', http(200, { id: 'sub_123' }));
    await expect(verifier.verify('sub_123')).rejects.toThrow(/sem status/);
  });

  it('maps cancel_at_period_end onto autoRenewing', async () => {
    const verifier = new StripeVerifier(
      'sk_test',
      http(200, {
        id: 'sub_123',
        status: 'active',
        cancel_at_period_end: true,
        current_period_end: 1_790_000_000,
        items: { data: [{ price: { id: 'price_premium' } }] },
      }),
    );
    expect((await verifier.verify('sub_123')).autoRenewing).toBe(false);
  });
});

describe('GooglePlayVerifier', () => {
  const active = {
    subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
    latestOrderId: 'GPA.1234',
    lineItems: [
      {
        productId: 'vidora.premium.monthly',
        expiryTime: '2026-08-29T12:00:00Z',
        autoRenewingPlan: { autoRenewEnabled: true },
      },
    ],
  };

  it('accepts an active subscription', async () => {
    const verifier = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, active),
    );
    const purchase = await verifier.verify('opaque-token');
    expect(purchase.transactionId).toBe('GPA.1234');
    expect(purchase.productId).toBe('vidora.premium.monthly');
    expect(purchase.autoRenewing).toBe(true);
  });

  it('rejects an expired state', async () => {
    const verifier = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, { ...active, subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED' }),
    );
    await expect(verifier.verify('t')).rejects.toThrow(/não está ativa/);
  });

  it('rejects an unknown token (HTTP 404)', async () => {
    const verifier = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(404, {}),
    );
    await expect(verifier.verify('t')).rejects.toThrow(/HTTP 404/);
  });

  it('rejects a line item with no product or no expiry', async () => {
    const noProduct = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, {
        subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
        lineItems: [{ expiryTime: '2026-08-29T12:00:00Z' }],
      }),
    );
    await expect(noProduct.verify('t')).rejects.toThrow(/sem produto/);

    const noExpiry = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, {
        subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
        lineItems: [{ productId: 'vidora.premium.monthly' }],
      }),
    );
    await expect(noExpiry.verify('t')).rejects.toThrow(/data de expiração/);
  });

  it('ignores a line item whose expiry does not parse', async () => {
    // Garbage in one item must not poison the whole verification, but it
    // must not be treated as a date either.
    const verifier = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, {
        subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
        latestOrderId: 'order-1',
        lineItems: [
          { productId: 'p', expiryTime: 'não é uma data' },
          {
            productId: 'vidora.premium.monthly',
            expiryTime: '2026-08-29T12:00:00Z',
            autoRenewingPlan: { autoRenewEnabled: true },
          },
        ],
      }),
    );
    const purchase = await verifier.verify('t');
    expect(purchase.productId).toBe('vidora.premium.monthly');
  });

  it('rejects a response with no subscription state', async () => {
    const verifier = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, {}),
    );
    await expect(verifier.verify('t')).rejects.toThrow(/estado ausente/);
  });

  it('falls back to the purchase token when Google omits the order id',
    async () => {
      // The order id is what makes a replay detectable; without it the
      // token itself is the only stable identifier available.
      const verifier = new GooglePlayVerifier(
        'com.vidora.app',
        async () => 'token',
        http(200, {
          subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
          lineItems: [
            {
              productId: 'vidora.premium.monthly',
              expiryTime: '2026-08-29T12:00:00Z',
            },
          ],
        }),
      );
      const purchase = await verifier.verify('purchase-token-1');
      expect(purchase.transactionId).toBe('purchase-token-1');
      // No autoRenewingPlan means we must not claim it renews.
      expect(purchase.autoRenewing).toBe(false);
    });

  it('accepts a cancelled subscription still inside its paid period',
    async () => {
      const verifier = new GooglePlayVerifier(
        'com.vidora.app',
        async () => 'token',
        http(200, {
          subscriptionState: 'SUBSCRIPTION_STATE_CANCELED',
          latestOrderId: 'order-1',
          lineItems: [
            {
              productId: 'vidora.premium.monthly',
              expiryTime: '2026-08-29T12:00:00Z',
              autoRenewingPlan: { autoRenewEnabled: false },
            },
          ],
        }),
      );
      expect((await verifier.verify('t')).autoRenewing).toBe(false);
    });

  it('takes the line item that expires last', async () => {
    const verifier = new GooglePlayVerifier(
      'com.vidora.app',
      async () => 'token',
      http(200, {
        ...active,
        lineItems: [
          { productId: 'old', expiryTime: '2026-08-01T00:00:00Z' },
          {
            productId: 'current',
            expiryTime: '2026-09-01T00:00:00Z',
            autoRenewingPlan: { autoRenewEnabled: true },
          },
        ],
      }),
    );
    expect((await verifier.verify('t')).productId).toBe('current');
  });
});

describe('AppleVerifier', () => {
  /** Builds an unsigned JWS with the given payload, as tests need. */
  function jws(payload: object): string {
    const encode = (part: object) =>
      Buffer.from(JSON.stringify(part)).toString('base64url');
    return `${encode({ alg: 'ES256' })}.${encode(payload)}.sig`;
  }

  it('accepts an active transaction', async () => {
    const verifier = new AppleVerifier(
      async () => 'token',
      http(200, {
        data: [
          {
            lastTransactions: [
              {
                status: 1,
                signedTransactionInfo: jws({
                  transactionId: '2000000123',
                  productId: 'vidora.premium.monthly',
                  expiresDate: NOW.getTime() + 86_400_000,
                }),
              },
            ],
          },
        ],
      }),
    );
    const purchase = await verifier.verify('2000000123');
    expect(purchase.transactionId).toBe('2000000123');
    expect(purchase.autoRenewing).toBe(true);
  });

  it('rejects an expired status', async () => {
    const verifier = new AppleVerifier(
      async () => 'token',
      http(200, {
        data: [
          {
            lastTransactions: [
              {
                status: 2,
                signedTransactionInfo: jws({
                  transactionId: 't',
                  productId: 'p',
                  expiresDate: NOW.getTime() - 1000,
                }),
              },
            ],
          },
        ],
      }),
    );
    await expect(verifier.verify('t')).rejects.toThrow(/não está ativa/);
  });

  it('rejects a response with nothing usable', async () => {
    const verifier = new AppleVerifier(async () => 'token', http(200, { data: [] }));
    await expect(verifier.verify('t')).rejects.toThrow(/sem transação/);
  });

  it('rejects an HTTP error from the App Store', async () => {
    const verifier = new AppleVerifier(async () => 'token', http(401, {}));
    await expect(verifier.verify('t')).rejects.toThrow(/HTTP 401/);
  });

  it('skips transactions with no status or no signed payload', async () => {
    // Apple returns entries for subscription groups the user never bought;
    // treating a half-filled entry as a purchase would grant premium on
    // the strength of a placeholder.
    const verifier = new AppleVerifier(
      async () => 'token',
      http(200, {
        data: [
          { lastTransactions: [{ status: 1 }] },
          { lastTransactions: [{ signedTransactionInfo: jws({ productId: 'p' }) }] },
          {},
        ],
      }),
    );
    await expect(verifier.verify('t')).rejects.toThrow(/sem transação/);
  });

  it('skips a malformed JWS instead of failing the whole verification',
    async () => {
      const verifier = new AppleVerifier(
        async () => 'token',
        http(200, {
          data: [
            {
              lastTransactions: [
                { status: 1, signedTransactionInfo: 'não.é.jws.válido.mesmo' },
                {
                  status: 1,
                  signedTransactionInfo: jws({
                    transactionId: '2000000999',
                    productId: 'vidora.premium.yearly',
                    expiresDate: NOW.getTime() + 86_400_000,
                  }),
                },
              ],
            },
          ],
        }),
      );
      expect((await verifier.verify('t')).transactionId).toBe('2000000999');
    });

  it('skips a transaction with no expiry date', async () => {
    const verifier = new AppleVerifier(
      async () => 'token',
      http(200, {
        data: [
          {
            lastTransactions: [
              { status: 1, signedTransactionInfo: jws({ transactionId: 't', productId: 'p' }) },
            ],
          },
        ],
      }),
    );
    await expect(verifier.verify('t')).rejects.toThrow(/sem transação/);
  });

  it('picks the transaction that expires last across groups', async () => {
    const verifier = new AppleVerifier(
      async () => 'token',
      http(200, {
        data: [
          {
            lastTransactions: [
              {
                status: 1,
                signedTransactionInfo: jws({
                  transactionId: 'antiga',
                  productId: 'vidora.premium.monthly',
                  expiresDate: NOW.getTime() + 86_400_000,
                }),
              },
            ],
          },
          {
            lastTransactions: [
              {
                status: 1,
                signedTransactionInfo: jws({
                  transactionId: 'mais-longa',
                  productId: 'vidora.premium.yearly',
                  expiresDate: NOW.getTime() + 10 * 86_400_000,
                }),
              },
            ],
          },
        ],
      }),
    );
    // The entitlement is whatever the user is paid through, which is the
    // furthest expiry — not the first entry Apple happened to list.
    expect((await verifier.verify('t')).transactionId).toBe('mais-longa');
  });

  it('accepts status 4 — Apple\'s billing grace period', async () => {
    const verifier = new AppleVerifier(
      async () => 'token',
      http(200, {
        data: [
          {
            lastTransactions: [
              {
                status: 4,
                signedTransactionInfo: jws({
                  transactionId: 't',
                  productId: 'p',
                  expiresDate: NOW.getTime() - 1000,
                }),
              },
            ],
          },
        ],
      }),
    );
    expect((await verifier.verify('t')).autoRenewing).toBe(true);
  });
});

describe('BillingService', () => {
  function service(purchase: VerifiedPurchase | Error) {
    const verifier: ReceiptVerifier = {
      provider: 'stripe',
      verify: async () => {
        if (purchase instanceof Error) throw purchase;
        return purchase;
      },
    };
    const repository = new InMemoryEntitlementsRepository();
    return { billing: new BillingService([verifier], repository), repository };
  }

  const purchase: VerifiedPurchase = {
    provider: 'stripe',
    transactionId: 'sub_123',
    productId: 'price_premium',
    expiresAt: new Date(Date.now() + 86_400_000),
    autoRenewing: true,
  };

  it('a verified receipt turns the plan premium', async () => {
    const { billing } = service(purchase);
    const status = await billing.redeem('u1', 'stripe', 'sub_123');
    expect(status.plan).toBe('premium');
    expect((await billing.status('u1')).plan).toBe('premium');
  });

  it('a rejected receipt becomes 422, and grants nothing', async () => {
    const { billing } = service(new ReceiptRejectedError('recusado', 'stripe'));
    await expect(billing.redeem('u1', 'stripe', 'sub_x')).rejects.toThrow(
      UnprocessableEntityException,
    );
    expect((await billing.status('u1')).plan).toBe('free');
  });

  it('a transaction already bound to another account is refused', async () => {
    const { billing } = service(purchase);
    await billing.redeem('u1', 'stripe', 'sub_123');

    // The same store transaction shows up from a second account: sharing
    // it would make one subscription serve any number of users.
    await expect(billing.redeem('u2', 'stripe', 'sub_123')).rejects.toThrow(
      ConflictException,
    );
    expect((await billing.status('u2')).plan).toBe('free');
  });

  it('the same account can re-redeem its own receipt (restore)', async () => {
    const { billing } = service(purchase);
    await billing.redeem('u1', 'stripe', 'sub_123');
    const status = await billing.redeem('u1', 'stripe', 'sub_123');
    expect(status.plan).toBe('premium');
  });

  it('an unconfigured provider is refused fail-closed', async () => {
    const { billing } = service(purchase);
    await expect(billing.redeem('u1', 'apple', 'qualquer')).rejects.toThrow(
      UnprocessableEntityException,
    );
  });
});
