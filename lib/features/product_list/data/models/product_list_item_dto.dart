import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';

/// Mahsulot ro'yxati elementining DTO si (tavsiyalar yoki turkum API javobidan).
class ProductListItemDto {
  const ProductListItemDto({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency = 'uzs',
    this.rating = 0,
    this.reviewCount = 0,
  });

  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;

  ProductListItemEntity toEntity() => ProductListItemEntity(
        slug: slug,
        title: title,
        mainImage: mainImage,
        price: price,
        finalPrice: finalPrice,
        currency: currency,
        rating: rating,
        reviewCount: reviewCount,
      );
}
