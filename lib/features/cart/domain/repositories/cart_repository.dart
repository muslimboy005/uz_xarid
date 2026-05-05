import 'package:uz_xarid/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart({int? page, int? pageSize});
  Future<void> addToCart({
    required String adSlug,
    int? variantId,
    required int quantity,
  });
  Future<void> updateCart({required int id, required int quantity});
  Future<void> deleteCartItem(int id);
  Future<void> clearCart();
  Future<void> checkout({
    required String firstName,
    required String lastName,
    required int addressId,
    String? notes,
  });
}
