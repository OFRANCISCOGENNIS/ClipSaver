/// Purchase port of the app (section 14).
///
/// Responsibility: describe how the app talks to a store and to the
/// backend about purchases, without naming StoreKit, Play Billing or
/// Stripe anywhere a ViewModel can see. The store SDK produces a receipt;
/// the backend — never the client — decides what that receipt is worth,
/// because a client-side paywall is a suggestion.
library;

import '../../../core/error/result.dart';
import 'entitlements.dart';

/// Stores a purchase can go through, mirroring the backend contract.
enum PurchaseProvider {
  /// App Store (iOS/macOS).
  apple('apple'),

  /// Google Play (Android).
  google('google'),

  /// Stripe Checkout (Windows/Linux/Web).
  stripe('stripe');

  const PurchaseProvider(this.wireValue);

  /// Value used in the backend contract.
  final String wireValue;
}

/// What the backend answered about the plan in force.
final class EntitlementStatus {
  /// Creates a status snapshot.
  const EntitlementStatus({
    required this.entitlements,
    this.expiresAt,
    this.inGracePeriod = false,
  });

  /// The capability set to apply now.
  final Entitlements entitlements;

  /// When the subscription lapses; null for a free user.
  final DateTime? expiresAt;

  /// True while a lapsed-but-renewing subscription is in the grace window
  /// — premium stays on and the UI shows a renewal prompt.
  final bool inGracePeriod;
}

/// One store purchase as the SDK reports it, before the backend verdict.
final class StorePurchase {
  /// Creates a purchase handle.
  const StorePurchase({required this.provider, required this.receipt});

  /// Store it came from.
  final PurchaseProvider provider;

  /// Opaque token to send to the backend for verification.
  final String receipt;
}

/// Port to the platform's store SDK.
///
/// Implementations wrap StoreKit 2, Play Billing or a Stripe Checkout
/// redirect; tests fake this without touching any of them.
abstract interface class StoreClient {
  /// The provider this client speaks for on the current platform.
  PurchaseProvider get provider;

  /// Starts the purchase flow and returns the receipt, a failure when the
  /// store refuses, or `Result.ok(null)`-like cancellation via failure —
  /// cancellation is a [Failure] with a user-facing message.
  Future<Result<StorePurchase>> purchase(String productId);

  /// Returns the receipt of an existing subscription, for restore.
  Future<Result<StorePurchase>> restore();
}

/// Port to the backend's billing endpoints.
abstract interface class BillingApi {
  /// Sends a receipt for verification; the answer is the plan in force.
  Future<Result<EntitlementStatus>> redeem(StorePurchase purchase);

  /// The plan in force for the signed-in account.
  Future<Result<EntitlementStatus>> status();
}
