import 'package:uz_xarid/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:uz_xarid/features/cart/data/models/cart_item_model.dart';
import 'package:uz_xarid/features/cart/domain/entities/cart_item_entity.dart';
import 'package:uz_xarid/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CartEntity> getCart({int? page, int? pageSize}) async {
    final response =
        await remoteDataSource.getCart(page: page, pageSize: pageSize);
    return _mapToEntity(response.data);
  }

  @override
  Future<void> addToCart({
    required String adSlug,
    int? variantId,
    required int quantity,
  }) async {
    await remoteDataSource.addToCart(
      adSlug: adSlug,
      variantId: variantId,
      quantity: quantity,
    );
  }

  @override
  Future<void> updateCart({required int id, required int quantity}) async {
    await remoteDataSource.updateCart(id: id, quantity: quantity);
  }

  @override
  Future<void> deleteCartItem(int id) async {
    await remoteDataSource.deleteCartItem(id);
  }

  @override
  Future<void> clearCart() async {
    await remoteDataSource.clearCart();
  }

  @override
  Future<void> checkout({
    required String firstName,
    required String lastName,
    required int addressId,
    String? notes,
  }) async {
    await remoteDataSource.checkout(
      firstName: firstName,
      lastName: lastName,
      addressId: addressId,
      notes: notes,
    );
  }

  CartEntity _mapToEntity(CartDataModel data) {
    return CartEntity(
      items: data.results.map((e) => _mapToItemEntity(e)).toList(),
      totalItems: data.totalItems,
      totalPages: data.totalPages,
    );
  }

  CartItemEntity _mapToItemEntity(CartItemModel m) {
    return CartItemEntity(
      id: m.id,
      adSlug: m.ad.slug,
      adTitle: m.ad.title,
      adImage: m.ad.mainImage,
      unitPrice: m.unitPrice,
      subtotal: m.subtotal,
      currency: m.ad.currency,
      quantity: m.quantity,
      variantId: m.variant?.id,
      variantName: m.variant != null ? '${m.variant!.color} / ${m.variant!.size}' : null,
    );
  }
}
