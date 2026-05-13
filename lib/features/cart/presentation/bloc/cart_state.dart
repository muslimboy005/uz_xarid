import 'package:equatable/equatable.dart';
import 'package:uzxarid/features/cart/domain/entities/cart_item_entity.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> items;
  final int totalItems;
  final String? errorMessage;
  final Set<String> loadingSlugs; // Slugs of ads currently being added
  final Set<int> loadingIds; // IDs of cart items currently being updated/removed

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.totalItems = 0,
    this.errorMessage,
    this.loadingSlugs = const {},
    this.loadingIds = const {},
  });

  bool isLoading(String slug, {int? itemId}) {
    if (loadingSlugs.contains(slug)) return true;
    if (itemId != null && loadingIds.contains(itemId)) return true;
    return false;
  }

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    int? totalItems,
    String? errorMessage,
    Set<String>? loadingSlugs,
    Set<int>? loadingIds,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage ?? this.errorMessage,
      loadingSlugs: loadingSlugs ?? this.loadingSlugs,
      loadingIds: loadingIds ?? this.loadingIds,
    );
  }

  // Helper method to get quantity of an ad (useful for sync)
  int getQuantityOfAd(String slug, {int? variantId}) {
    final item = items.where((e) => e.adSlug == slug && e.variantId == variantId).firstOrNull;
    return item?.quantity ?? 0;
  }

  @override
  List<Object?> get props => [status, items, totalItems, errorMessage, loadingSlugs, loadingIds];
}
