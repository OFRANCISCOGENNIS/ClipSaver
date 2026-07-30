/**
 * Receipt verification port (section 14).
 *
 * Responsibility: turn an opaque token the client hands us into a purchase
 * the *store* confirmed. The client is never the authority here — a
 * receipt is attacker-controlled input, and trusting its contents is how a
 * paywall becomes a suggestion.
 */
import type { PurchaseProvider, VerifiedPurchase } from './entitlement.js';

/** Raised when a store rejects a receipt, or answers something unusable. */
export class ReceiptRejectedError extends Error {
  constructor(
    message: string,
    /** Provider that rejected it, for logs and support. */
    readonly provider: PurchaseProvider,
  ) {
    super(message);
    this.name = 'ReceiptRejectedError';
  }
}

/** One store's verification. */
export interface ReceiptVerifier {
  /** The store this verifier speaks for. */
  readonly provider: PurchaseProvider;

  /**
   * Confirms [token] with the store.
   *
   * Throws [ReceiptRejectedError] when the store refuses it. Returning a
   * `free`-shaped result instead would make a rejection indistinguishable
   * from an expired-but-genuine purchase.
   */
  verify(token: string): Promise<VerifiedPurchase>;
}

/** Nest injection token for the verifier list. */
export const RECEIPT_VERIFIERS = Symbol('RECEIPT_VERIFIERS');

/**
 * Looks up the verifier for a provider.
 *
 * Fails closed on an unknown or unconfigured provider: a request naming a
 * store nobody wired up must be refused, not silently granted.
 */
export function selectVerifier(
  verifiers: readonly ReceiptVerifier[],
  provider: PurchaseProvider,
): ReceiptVerifier {
  const match = verifiers.find((verifier) => verifier.provider === provider);
  if (!match) {
    throw new ReceiptRejectedError(
      `Nenhum verificador configurado para ${provider}.`,
      provider,
    );
  }
  return match;
}
