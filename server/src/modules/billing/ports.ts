/**
 * Persistence port of the billing module.
 *
 * Responsibility: keep BillingService independent of Prisma so the
 * verification and replay rules are testable without Postgres — the same
 * split the auth module uses.
 */
import type { EntitlementRecord } from './domain/entitlement.js';

/** Entitlement persistence port. */
export interface EntitlementsRepository {
  /** The user's current entitlement, or null if they never subscribed. */
  findByUser(userId: string): Promise<EntitlementRecord | null>;

  /**
   * The entitlement holding [transactionId], regardless of user.
   *
   * This is the replay check: a store transaction belongs to exactly one
   * account, and a receipt that already granted premium to someone else
   * must be refused rather than shared.
   */
  findByTransaction(
    provider: string,
    transactionId: string,
  ): Promise<EntitlementRecord | null>;

  /** Inserts or replaces the user's entitlement. */
  upsert(record: EntitlementRecord): Promise<void>;
}

/** Nest injection token. */
export const ENTITLEMENTS_REPOSITORY = Symbol('ENTITLEMENTS_REPOSITORY');

/** In-memory implementation for tests and DATABASE_URL-less dev. */
export class InMemoryEntitlementsRepository implements EntitlementsRepository {
  private readonly byUser = new Map<string, EntitlementRecord>();

  async findByUser(userId: string): Promise<EntitlementRecord | null> {
    return this.byUser.get(userId) ?? null;
  }

  async findByTransaction(
    provider: string,
    transactionId: string,
  ): Promise<EntitlementRecord | null> {
    for (const record of this.byUser.values()) {
      if (record.provider === provider && record.transactionId === transactionId) {
        return record;
      }
    }
    return null;
  }

  async upsert(record: EntitlementRecord): Promise<void> {
    this.byUser.set(record.userId, record);
  }
}
