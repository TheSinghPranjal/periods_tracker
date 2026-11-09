import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sketch/sketch_card.dart';

/// Comma-separated store product ids, set at build time. Prices always come
/// from the store, so none are written in this code.
const _productIds = String.fromEnvironment('LUNA_PLUS_PRODUCT_IDS');
const _entitlementKey = 'premium.active';

@immutable
class PremiumState {
  const PremiumState({
    this.configured = false,
    this.loading = false,
    this.entitled = false,
    this.products = const [],
    this.message,
  });
  final bool configured;
  final bool loading;
  final bool entitled;
  final List<ProductDetails> products;
  final String? message;

  PremiumState copyWith({
    bool? loading,
    bool? entitled,
    List<ProductDetails>? products,
    String? message,
  }) => PremiumState(
    configured: configured,
    loading: loading ?? this.loading,
    entitled: entitled ?? this.entitled,
    products: products ?? this.products,
    message: message,
  );
}

class PremiumController extends Notifier<PremiumState> {
  StreamSubscription<List<PurchaseDetails>>? _purchases;

  Set<String> get _ids =>
      _productIds.split(',').where((s) => s.trim().isNotEmpty).toSet();

  @override
  PremiumState build() {
    ref.onDispose(() => _purchases?.cancel());
    if (_ids.isEmpty) return const PremiumState();
    _purchases = InAppPurchase.instance.purchaseStream.listen(_onPurchases);
    unawaited(_load());
    return const PremiumState(configured: true, loading: true);
  }

  Future<void> _load() async {
    final saved =
        await ref.read(secureStoreProvider).read(_entitlementKey) == 'true';
    try {
      if (!await InAppPurchase.instance.isAvailable()) {
        state = state.copyWith(
          loading: false,
          entitled: saved,
          message: 'The store isn\'t available right now.',
        );
        return;
      }
      final response = await InAppPurchase.instance.queryProductDetails(_ids);
      state = state.copyWith(
        loading: false,
        entitled: saved,
        products: response.productDetails,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        entitled: saved,
        message: 'We couldn\'t reach the store. Please try again later.',
      );
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> updates) async {
    for (final p in updates) {
      switch (p.status) {
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          await ref.read(secureStoreProvider).write(_entitlementKey, 'true');
          state = state.copyWith(
            entitled: true,
            message: 'Thank you. LunaCycle Plus is active.',
          );
        case PurchaseStatus.error:
          state = state.copyWith(
            message:
                'The purchase didn\'t go through. You have not been charged by LunaCycle.',
          );
        case PurchaseStatus.canceled:
          state = state.copyWith();
        case PurchaseStatus.pending:
          state = state.copyWith(message: 'Your purchase is pending.');
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  Future<void> buy(ProductDetails product) => InAppPurchase.instance
      .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  Future<void> restore() => InAppPurchase.instance.restorePurchases();
}

final premiumProvider = NotifierProvider<PremiumController, PremiumState>(
  PremiumController.new,
);

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(premiumProvider);
    final text = Theme.of(context).textTheme;
    return LunaPage(
      title: 'LunaCycle Plus',
      subtitle: 'Optional. Everything you need to track your cycle stays free.',
      showBack: true,
      children: [
        SketchCard(
          seed: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Included with Plus', style: text.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Two extra colour themes: Autumn momiji and Plum dusk.',
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SketchCard(
          seed: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Always free', style: text.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Unlimited logging, calendar, estimates, symptoms and moods, history, reminders, app lock, export and deletion.',
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (!p.configured)
          const PrivacyNotice(
            'LunaCycle Plus isn\'t on sale in this version of the app.',
            icon: Icons.storefront_outlined,
          )
        else if (p.loading)
          const Center(child: CircularProgressIndicator())
        else if (p.entitled)
          const PrivacyNotice(
            'LunaCycle Plus is active on this device.',
            icon: Icons.check_circle_outline_rounded,
          )
        else
          for (final product in p.products)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PrimaryButton(
                label: '${product.title} · ${product.price}',
                onPressed: () =>
                    ref.read(premiumProvider.notifier).buy(product),
              ),
            ),
        if (p.message != null) ...[
          const SizedBox(height: 10),
          PrivacyNotice(p.message!, icon: Icons.info_outline_rounded),
        ],
        if (p.configured) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => ref.read(premiumProvider.notifier).restore(),
            child: const Text('Restore purchases'),
          ),
        ],
      ],
    );
  }
}
