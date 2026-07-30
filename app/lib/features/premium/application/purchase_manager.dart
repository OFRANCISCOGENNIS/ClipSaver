/// Purchase orchestration (section 14).
///
/// Responsibility: the buy/restore flows as one sequence — store SDK
/// first, backend verification second — and the rule that entitlements
/// only ever change on a backend answer. The store saying "purchased" is
/// necessary but not sufficient: until the backend confirms the receipt,
/// the plan stays what it was.
library;

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../domain/entitlements.dart';
import '../domain/purchase_gateway.dart';

/// Drives purchases and keeps the current entitlements.
final class PurchaseManager {
  /// Creates the manager over the two ports.
  PurchaseManager({
    required StoreClient store,
    required BillingApi api,
    void Function(Entitlements entitlements)? onEntitlementsChanged,
  })  : _store = store,
        _api = api,
        _onChanged = onEntitlementsChanged;

  final StoreClient _store;
  final BillingApi _api;
  final void Function(Entitlements entitlements)? _onChanged;

  Entitlements _current = Entitlements.free;

  /// The capability set in force right now.
  Entitlements get current => _current;

  /// Buys [productId]: store flow, then backend verification.
  Future<Result<EntitlementStatus>> buy(String productId) async {
    final purchased = await _store.purchase(productId);
    return purchased.fold(_redeem, Result.err);
  }

  /// Restores an existing subscription on this account.
  Future<Result<EntitlementStatus>> restore() async {
    final restored = await _store.restore();
    return restored.fold(_redeem, Result.err);
  }

  /// Refreshes the plan from the backend, e.g. on app start.
  ///
  /// A network failure keeps the last known entitlements rather than
  /// demoting to free: punishing the user for being offline would make
  /// the plan flap with connectivity.
  Future<Result<EntitlementStatus>> refresh() async {
    final status = await _api.status();
    status.fold(_apply, (_) {});
    return status;
  }

  Future<Result<EntitlementStatus>> _redeem(StorePurchase purchase) async {
    final verdict = await _api.redeem(purchase);
    return verdict.fold(
      (status) {
        _apply(status);
        return Result.ok(status);
      },
      (failure) {
        // The store approved but the backend did not: the receipt may be
        // bound to another account or the store rejected it server-side.
        // Entitlements stay unchanged — never granted on the client's own
        // conclusion.
        return Result.err(
          failure is ServerFailure || failure is NetworkFailure
              ? failure
              : ValidationFailure(failure.message),
        );
      },
    );
  }

  void _apply(EntitlementStatus status) {
    if (status.entitlements == _current) return;
    _current = status.entitlements;
    _onChanged?.call(_current);
  }
}
