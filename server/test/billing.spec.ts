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
