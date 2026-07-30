/// Tests for the purchase flow: the store is necessary, the backend is
/// decisive, and entitlements never move on the client's own conclusion.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/error/failures.dart';
import 'package:vidora/core/error/result.dart';
import 'package:vidora/features/premium/application/purchase_manager.dart';
import 'package:vidora/features/premium/domain/entitlements.dart';
import 'package:vidora/features/premium/domain/purchase_gateway.dart';

final class _FakeStore implements StoreClient {
  _FakeStore({this.purchaseResult, this.restoreResult});

  Result<StorePurchase>? purchaseResult;
  Result<StorePurchase>? restoreResult;
  final List<String> purchased = [];

  @override
  PurchaseProvider get provider => PurchaseProvider.stripe;

  @override
  Future<Result<StorePurchase>> purchase(String productId) async {
    purchased.add(productId);
    return purchaseResult ??
        const Result.err(ValidationFailure('não configurado'));
  }

  @override
  Future<Result<StorePurchase>> restore() async =>
      restoreResult ?? const Result.err(ValidationFailure('não configurado'));
}

final class _FakeApi implements BillingApi {
  _FakeApi({this.redeemResult, this.statusResult});

  Result<EntitlementStatus>? redeemResult;
  Result<EntitlementStatus>? statusResult;
  final List<StorePurchase> redeemed = [];

  @override
  Future<Result<EntitlementStatus>> redeem(StorePurchase purchase) async {
    redeemed.add(purchase);
    return redeemResult ?? const Result.err(ServerFailure('não configurado'));
  }

  @override
  Future<Result<EntitlementStatus>> status() async =>
      statusResult ?? const Result.err(NetworkFailure('offline'));
}

const _purchase = StorePurchase(
  provider: PurchaseProvider.stripe,
  receipt: 'sub_valido',
);

const _premiumStatus = EntitlementStatus(entitlements: Entitlements.premium);

void main() {
  group('PurchaseManager.buy', () {
    test('store then backend, and premium only after the backend confirms',
        () async {
      final store = _FakeStore(purchaseResult: const Result.ok(_purchase));
      final api = _FakeApi(redeemResult: const Result.ok(_premiumStatus));
      final changes = <Entitlements>[];
      final manager = PurchaseManager(
        store: store,
        api: api,
        onEntitlementsChanged: changes.add,
      );

      expect(manager.current.isPremium, isFalse);
      final result = await manager.buy('vidora.premium.monthly');

      expect(result.isOk, isTrue);
      expect(store.purchased, ['vidora.premium.monthly']);
      expect(api.redeemed.single.receipt, 'sub_valido');
      expect(manager.current.isPremium, isTrue);
      expect(changes, [Entitlements.premium]);
    });

    test('a store refusal never reaches the backend', () async {
      final store = _FakeStore(
        purchaseResult:
            const Result.err(ValidationFailure('Compra cancelada.')),
      );
      final api = _FakeApi();
      final manager = PurchaseManager(store: store, api: api);

      final result = await manager.buy('vidora.premium.monthly');

      expect(result.isErr, isTrue);
      expect(api.redeemed, isEmpty);
      expect(manager.current.isPremium, isFalse);
    });

    test('store ok + backend refusal leaves the plan unchanged', () async {
      // The exact scenario a client-side paywall gets wrong: the store SDK
      // said "purchased", but the backend bound that receipt to another
      // account.
      final store = _FakeStore(purchaseResult: const Result.ok(_purchase));
      final api = _FakeApi(
        redeemResult: const Result.err(
          ServerFailure('Esta compra já está vinculada a outra conta.',
              statusCode: 409),
        ),
      );
      final manager = PurchaseManager(store: store, api: api);

      final result = await manager.buy('vidora.premium.monthly');

      expect(result.isErr, isTrue);
      expect(manager.current.isPremium, isFalse);
    });
  });

  group('PurchaseManager.restore', () {
    test('restores through the same backend verification', () async {
      final store = _FakeStore(restoreResult: const Result.ok(_purchase));
      final api = _FakeApi(redeemResult: const Result.ok(_premiumStatus));
      final manager = PurchaseManager(store: store, api: api);

      final result = await manager.restore();

      expect(result.isOk, isTrue);
      expect(manager.current.isPremium, isTrue);
    });
  });

  group('PurchaseManager.refresh', () {
    test('applies the backend status', () async {
      final manager = PurchaseManager(
        store: _FakeStore(),
        api: _FakeApi(statusResult: const Result.ok(_premiumStatus)),
      );

      await manager.refresh();

      expect(manager.current.isPremium, isTrue);
    });

    test('a network failure keeps the last known plan', () async {
      final api = _FakeApi(statusResult: const Result.ok(_premiumStatus));
      final manager = PurchaseManager(store: _FakeStore(), api: api);
      await manager.refresh();
      expect(manager.current.isPremium, isTrue);

      // Now the device goes offline. Being unreachable is not a lapse:
      // demoting here would flap the plan with connectivity.
      api.statusResult = const Result.err(NetworkFailure('offline'));
      final result = await manager.refresh();

      expect(result.isErr, isTrue);
      expect(manager.current.isPremium, isTrue);
    });

    test('a lapsed plan reported by the backend demotes to free', () async {
      final api = _FakeApi(statusResult: const Result.ok(_premiumStatus));
      final manager = PurchaseManager(store: _FakeStore(), api: api);
      await manager.refresh();

      api.statusResult = const Result.ok(
        EntitlementStatus(entitlements: Entitlements.free),
      );
      await manager.refresh();

      expect(manager.current.isPremium, isFalse);
    });
  });
}
