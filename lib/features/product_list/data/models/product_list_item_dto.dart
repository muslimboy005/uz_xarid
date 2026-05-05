import 'package:uz_xarid/core/utils/image_parser.dart';
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
    this.categoryName,
  });

  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String? categoryName;

  factory ProductListItemDto.fromJson(Map<String, dynamic> json) {
    String? category;
    if (json['category'] != null) {
      category = json['category']['name'];
    }
    return ProductListItemDto(
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      mainImage: ImageParser.parse(json['main_image'] ?? json['mainImage']),
      price: json['price']?.toString(),
      finalPrice:
          json['final_price']?.toString() ?? json['finalPrice']?.toString(),
      currency: json['currency'] ?? 'uzs',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      categoryName: category,
    );
  }

  ProductListItemEntity toEntity() => ProductListItemEntity(
    slug: slug,
    title: title,
    mainImage: mainImage,
    price: price,
    finalPrice: finalPrice,
    currency: currency,
    rating: rating,
    reviewCount: reviewCount,
    categoryName: categoryName,
  );
}
