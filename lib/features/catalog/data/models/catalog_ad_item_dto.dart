import 'package:uz_xarid/core/utils/image_parser.dart';

/// E'lon ro'yxati elementi (katalog bo'yicha mahsulotlar).
class CatalogAdItemDto {
  const CatalogAdItemDto({
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

  factory CatalogAdItemDto.fromJson(Map<String, dynamic> json) {
    return CatalogAdItemDto(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mainImage: ImageParser.parse(json['main_image']),
      price: json['price']?.toString(),
      finalPrice: json['final_price']?.toString(),
      currency: json['currency'] as String? ?? 'uzs',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Paginated javob: /ad/?ad_type=...&category=...&listing_type=...
class CatalogAdListResponseDto {
  const CatalogAdListResponseDto({required this.status, required this.data});

  final bool status;
  final CatalogAdListDataDto data;

  factory CatalogAdListResponseDto.fromJson(Map<String, dynamic> json) {
    return CatalogAdListResponseDto(
      status: json['status'] as bool? ?? false,
      data: CatalogAdListDataDto.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

class CatalogAdListDataDto {
  const CatalogAdListDataDto({
    required this.results,
    this.totalItems = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.pageSize = 10,
  });

  final List<CatalogAdItemDto> results;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  factory CatalogAdListDataDto.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>? ?? []).map((e) {
      return CatalogAdItemDto.fromJson(e as Map<String, dynamic>);
    }).toList();
    return CatalogAdListDataDto(
      results: list,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 10,
    );
  }
}
