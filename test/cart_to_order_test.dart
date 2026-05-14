import 'package:flutter_test/flutter_test.dart';
import 'package:uzxarid/features/cart/domain/entities/cart_item_entity.dart';
import 'package:uzxarid/features/product_detail/domain/entities/ad_detail_entity.dart';

void main() {
  test('AdDetailEntity built from CartItemEntity carries required order fields', () {
    final item = CartItemEntity(
      id: 1,
      adSlug: 'sedan',
      adTitle: 'Sedan',
      adImage: 'https://example.com/img.jpg',
      unitPrice: '14000',
      subtotal: '14000',
      currency: 'UZS',
      quantity: 1,
    );

    final ad = AdDetailEntity(
      slug: item.adSlug,
      title: item.adTitle,
      mainImage: item.adImage,
      price: item.unitPrice,
      finalPrice: item.unitPrice,
      currency: item.currency,
    );

    expect(ad.slug, 'sedan');
    expect(ad.title, 'Sedan');
    expect(ad.mainImage, 'https://example.com/img.jpg');
    expect(ad.price, '14000');
    expect(ad.finalPrice, '14000');
    expect(ad.currency, 'UZS');
  });
}
