import 'package:uz_xarid/core/utils/image_parser.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';

class RecommendationDto {
  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final bool isTop;

  RecommendationDto({
    required this.slug,
    required this.title,
    required this.currency,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.isTop = false,
  });

  factory RecommendationDto.fromJson(Map<String, dynamic> json) {
    return RecommendationDto(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mainImage: ImageParser.parse(json['main_image']),
      price: json['price']?.toString(),
      finalPrice: json['final_price']?.toString(),
      currency: json['currency'] as String? ?? 'uzs',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isTop: json['is_top'] as bool? ?? false,
    );
  }

  HomeRecommendation toHomeRecommendation() => HomeRecommendation(
    slug: slug,
    title: title,
    mainImage: mainImage,
    price: price,
    finalPrice: finalPrice,
    currency: currency,
    rating: rating,
    reviewCount: reviewCount,
    isTop: isTop,
  );
}
