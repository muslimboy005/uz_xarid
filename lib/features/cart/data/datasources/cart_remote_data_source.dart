import 'package:uz_xarid/features/cart/data/datasources/cart_api.dart';
import 'package:uz_xarid/features/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<CartResponseModel> getCart({int? page, int? pageSize});
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

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final CartApi cartApi;

  CartRemoteDataSourceImpl({required this.cartApi});

  @override
  Future<CartResponseModel> getCart({int? page, int? pageSize}) {
    return cartApi.getCart(page: page, pageSize: pageSize);
  }

  @override
  Future<void> addToCart({
    required String adSlug,
    int? variantId,
    required int quantity,
  }) async {
    final body = {
      'ad_slug': adSlug,
      'variant_id': variantId,
      'quantity': quantity,
    };
    await cartApi.addToCart(body);
  }

  @override
  Future<void> updateCart({required int id, required int quantity}) async {
    final body = {'quantity': quantity};
    await cartApi.updateCartItem(id.toString(), body);
  }

  @override
  Future<void> deleteCartItem(int id) async {
    await cartApi.deleteCartItem(id.toString());
  }

  @override
  Future<void> clearCart() async {
    await cartApi.clearCart();
  }

  @override
  Future<void> checkout({
    required String firstName,
    required String lastName,
    required int addressId,
    String? notes,
  }) async {
    final body = {
      'first_name': firstName,
      'last_name': lastName,
      'address_id': addressId,
      'notes': notes,
    };
    await cartApi.checkout(body);
  }
}
