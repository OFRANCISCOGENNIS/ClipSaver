/**
 * Billing orchestration (section 14).
 *
 * Responsibility: the three rules that make a store purchase become a
 * plan, in order:
 *
 * 1. The store is the authority — the client's receipt is only a pointer
 *    to something the store must confirm.
 * 2. One transaction, one account — a receipt that already granted
 *    premium elsewhere is refused, not shared.
 * 3. Time decides the plan — resolution against the clock (including the
 *    grace window) lives in the pure domain function, so "what plan is in
 *    force" has exactly one implementation.
 */
import {
  ConflictException,
  Inject,
  Injectable,
  UnprocessableEntityException,
} from '@nestjs/common';
import {
  resolveEntitlement,
  type EntitlementStatus,
  type PurchaseProvider,
} from './domain/entitlement.js';
import {
  RECEIPT_VERIFIERS,
  ReceiptRejectedError,
  selectVerifier,
  type ReceiptVerifier,
} from './domain/receipt-verifier.js';
import { ENTITLEMENTS_REPOSITORY, type EntitlementsRepository } from './ports.js';

@Injectable()
export class BillingService {
  constructor(
    @Inject(RECEIPT_VERIFIERS)
    private readonly verifiers: readonly ReceiptVerifier[],
    @Inject(ENTITLEMENTS_REPOSITORY)
    private readonly entitlements: EntitlementsRepository,
  ) {}

  /**
   * Confirms [receipt] with [provider]'s store and stores the entitlement
   * for [userId]. Returns the status the app should act on.
   *
   * Throws [ReceiptRejectedError] when the store refuses the receipt and
   * [ConflictException] when the transaction already belongs to another
   * account — distinct failures, because the user-facing fix is different
   * ("buy/restore" versus "sign in with the account that bought it").
   */
  async redeem(
    userId: string,
    provider: PurchaseProvider,
    receipt: string,
  ): Promise<EntitlementStatus> {
    let purchase;
    try {
      const verifier = selectVerifier(this.verifiers, provider);
      purchase = await verifier.verify(receipt);
    } catch (error) {
      if (error instanceof ReceiptRejectedError) {
        // 422, not 400: the request was well-formed — it is the receipt
        // the store would not stand behind.
        throw new UnprocessableEntityException(error.message);
      }
      throw error;
    }

    const existing = await this.entitlements.findByTransaction(
      provider,
      purchase.transactionId,
    );
    if (existing && existing.userId !== userId) {
      throw new ConflictException(
        'Esta compra já está vinculada a outra conta. ' +
          'Entre com a conta que fez a assinatura para restaurá-la.',
      );
    }

    await this.entitlements.upsert({
      userId,
      provider: purchase.provider,
      transactionId: purchase.transactionId,
      productId: purchase.productId,
      expiresAt: purchase.expiresAt,
      autoRenewing: purchase.autoRenewing,
      updatedAt: new Date(),
    });

    return resolveEntitlement(await this.entitlements.findByUser(userId), new Date());
  }

  /** The plan in force for [userId] right now. */
  async status(userId: string): Promise<EntitlementStatus> {
    return resolveEntitlement(await this.entitlements.findByUser(userId), new Date());
  }
}
