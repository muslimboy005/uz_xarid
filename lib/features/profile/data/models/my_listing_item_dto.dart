import 'package:uzxarid/core/utils/image_parser.dart';

/// "Mening e'lonlarim" ro'yxati elementi (GET ad/me/ javobi).
class MyListingItemDto {
  const MyListingItemDto({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency = 'uzs',
    this.status,
    this.adType,
    this.listingType,
    this.categoryId,
    this.categoryName,
    this.description,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.callCount = 0,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.address,
  });

  final String slug;
  final String title;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final String? status;
  final String? adType;
  final String? listingType;
  final int? categoryId;
  final String? categoryName;
  final String? description;
  final int viewsCount;
  final int likesCount;
  final int callCount;
  final String? createdAt;
  final double? latitude;
  final double? longitude;
  final String? address;

  factory MyListingItemDto.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    int? categoryId;
    String? categoryName;
    if (category is Map<String, dynamic>) {
      categoryId = (category['id'] as num?)?.toInt();
      categoryName = category['name'] as String?;
    }

    final rawAddress = json['address'];
    String? addressText;
    double? latitude;
    double? longitude;
    String? addressCreatedAt;
    if (rawAddress is Map<String, dynamic>) {
      addressText = rawAddress['address'] as String?;
      latitude = (rawAddress['latitude'] as num?)?.toDouble();
      longitude = (rawAddress['longitude'] as num?)?.toDouble();
      addressCreatedAt = rawAddress['created_at'] as String?;
    } else if (rawAddress is String) {
      addressText = rawAddress;
    }

    return MyListingItemDto(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mainImage: ImageParser.parse(json['main_image']),
      price: json['price']?.toString(),
      finalPrice: json['final_price']?.toString(),
      currency: json['currency'] as String? ?? 'uzs',
      status: json['status'] as String?,
      adType: json['ad_type'] as String?,
      listingType: json['listing_type'] as String?,
      categoryId: categoryId,
      categoryName: categoryName,
      description: json['description'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      callCount: (json['call_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? addressCreatedAt,
      latitude: (json['latitude'] as num?)?.toDouble() ?? latitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? longitude,
      address: addressText,
    );
  }
}

class MyListingsResponseDto {
  const MyListingsResponseDto({required this.status, required this.data});

  final bool status;
  final MyListingsDataDto data;

  factory MyListingsResponseDto.fromJson(Map<String, dynamic> json) {
    return MyListingsResponseDto(
      status: json['status'] as bool? ?? false,
      data: MyListingsDataDto.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

class MyListingsDataDto {
  const MyListingsDataDto({
    required this.results,
    this.totalItems = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.pageSize = 10,
  });

  final List<MyListingItemDto> results;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  factory MyListingsDataDto.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List<dynamic>? ?? []).map((e) {
      return MyListingItemDto.fromJson(e as Map<String, dynamic>);
    }).toList();
    return MyListingsDataDto(
      results: list,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 10,
    );
  }
}
