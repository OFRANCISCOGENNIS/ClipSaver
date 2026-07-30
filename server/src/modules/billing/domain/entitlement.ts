/**
 * What a user's subscription entitles them to (section 14).
 *
 * Responsibility: be the single answer to "which plan is in force right
 * now". The store tells us when a subscription expires; deciding what that
 * means at this instant — still premium, in the grace period, or back to
 * free — is a rule, and rules belong here rather than scattered across the
 * callers that ask.
 */

/** The two plans of section 14. */
export type Plan = 'free' | 'premium';

/** Stores a purchase can come from. */
export type PurchaseProvider = 'apple' | 'google' | 'stripe';

/** A purchase after the store confirmed it. */
export interface VerifiedPurchase {
  /** Which store verified it. */
  readonly provider: PurchaseProvider;
  /** The store's own identifier, used to detect a replayed receipt. */
  readonly transactionId: string;
  /** Product the user bought, e.g. `vidora.premium.monthly`. */
  readonly productId: string;
  /** When the subscription lapses. */
  readonly expiresAt: Date;
  /**
   * True when the store says the subscription is cancelled but paid
   * through [expiresAt]. Access continues until then: the user paid for
   * that time.
   */
  readonly autoRenewing: boolean;
}

/** A stored entitlement row. */
export interface EntitlementRecord {
  readonly userId: string;
  readonly provider: PurchaseProvider;
  readonly transactionId: string;
  readonly productId: string;
  readonly expiresAt: Date;
  readonly autoRenewing: boolean;
  readonly updatedAt: Date;
}

/** The answer the app acts on. */
export interface EntitlementStatus {
  readonly plan: Plan;
  /** Null for a user who never subscribed. */
  readonly expiresAt: Date | null;
  /**
   * True while the subscription has lapsed but is inside the grace window.
   * The app keeps premium features and shows a renewal prompt.
   */
  readonly inGracePeriod: boolean;
  /** Set when the plan is premium; useful for support and receipts. */
  readonly productId: string | null;
}

/**
 * How long premium survives past its expiry date.
 *
 * Stores retry a failed renewal for days, and revoking features the
 * instant a card blips would punish the user for their bank's timing. The
 * window is short enough that a genuine cancellation still takes effect
 * quickly.
 */
export const GRACE_PERIOD_MS = 3 * 24 * 60 * 60 * 1000;

/** The plan of a user with no entitlement on record. */
export const FREE_STATUS: EntitlementStatus = {
  plan: 'free',
  expiresAt: null,
  inGracePeriod: false,
  productId: null,
};

/**
 * Resolves [record] against [now].
 *
 * Fails closed: anything that is not clearly a live subscription resolves
 * to `free`. Granting premium by accident costs revenue; the reverse costs
 * a support ticket the user can win.
 */
export function resolveEntitlement(
  record: EntitlementRecord | null,
  now: Date,
): EntitlementStatus {
  if (!record) return FREE_STATUS;

  const expiry = record.expiresAt.getTime();
  const current = now.getTime();

  if (current < expiry) {
    return {
      plan: 'premium',
      expiresAt: record.expiresAt,
      inGracePeriod: false,
      productId: record.productId,
    };
  }

  // Past the expiry date. Only a subscription the store still considers
  // renewing gets the grace window — one the user cancelled is simply
  // over, and pretending otherwise would be taking time they did not buy.
  if (record.autoRenewing && current < expiry + GRACE_PERIOD_MS) {
    return {
      plan: 'premium',
      expiresAt: record.expiresAt,
      inGracePeriod: true,
      productId: record.productId,
    };
  }

  return { ...FREE_STATUS, expiresAt: record.expiresAt };
}
