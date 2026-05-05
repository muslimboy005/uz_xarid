class CartItemEntity {
  final int id;
  final String adSlug;
  final String adTitle;
  final String? adImage;
  final String unitPrice;
  final String subtotal;
  final String currency;
  final int quantity;
  final int? variantId;
  final String? variantName;

  CartItemEntity({
    required this.id,
    required this.adSlug,
    required this.adTitle,
    this.adImage,
    required this.unitPrice,
    required this.subtotal,
    required this.currency,
    required this.quantity,
    this.variantId,
    this.variantName,
  });

  CartItemEntity copyWith({int? quantity, String? subtotal}) {
    return CartItemEntity(
      id: id,
      adSlug: adSlug,
      adTitle: adTitle,
      adImage: adImage,
      unitPrice: unitPrice,
      subtotal: subtotal ?? this.subtotal,
      currency: currency,
      quantity: quantity ?? this.quantity,
      variantId: variantId,
      variantName: variantName,
    );
  }
}

class CartEntity {
  final List<CartItemEntity> items;
  final int totalItems;
  final int totalPages;

  CartEntity({
    required this.items,
    required this.totalItems,
    required this.totalPages,
  });
}
