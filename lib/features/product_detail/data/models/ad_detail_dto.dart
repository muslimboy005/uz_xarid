import 'package:json_annotation/json_annotation.dart';

part 'ad_detail_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AdDetailResponseDto {
  final bool status;
  final AdDetailDataDto data;

  const AdDetailResponseDto({required this.status, required this.data});

  factory AdDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AdDetailResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdDetailResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AdDetailDataDto {
  final String slug;
  final String title;
  @JsonKey(name: 'ad_type')
  final String? adType;
  @JsonKey(name: 'listing_type')
  final String? listingType;
  final AdCategoryDto? category;
  final String? price;
  @JsonKey(name: 'final_price')
  final String? finalPrice;
  final String? discount;
  @JsonKey(name: 'is_physical')
  final bool? isPhysical;
  @JsonKey(name: 'is_top')
  final bool? isTop;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  final String? status;
  @JsonKey(name: 'likes_count')
  final int? likesCount;
  @JsonKey(name: 'is_likes')
  final bool? isLikes;
  @JsonKey(name: 'views_count')
  final int? viewsCount;
  @JsonKey(name: 'call_count')
  final int? callCount;
  @JsonKey(name: 'main_image')
  final String? mainImage;
  final String? currency;
  final AdUserDto? user;
  final dynamic business;
  @JsonKey(name: 'total_ads')
  final int? totalAds;
  @JsonKey(name: 'total_comments_author')
  final int? totalCommentsAuthor;
  @JsonKey(name: 'average_rating_author')
  final double? averageRatingAuthor;
  final String? description;
  @JsonKey(name: 'dimension_unit')
  final String? dimensionUnit;
  @JsonKey(name: 'weight_unit')
  final String? weightUnit;
  final num? weight;
  final num? width;
  final num? height;
  final num? length;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'total_comments')
  final int? totalComments;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  final List<AdVariantDto>? variants;
  final List<AdOptionDto>? options;
  final List<dynamic>? tags;
  final List<AdImageDto>? images;
  final List<AdColorDto>? colors;
  final List<AdSizeDto>? sizes;

  const AdDetailDataDto({
    required this.slug,
    required this.title,
    this.adType,
    this.listingType,
    this.category,
    this.price,
    this.finalPrice,
    this.discount,
    this.isPhysical,
    this.isTop,
    this.isActive,
    this.status,
    this.likesCount,
    this.isLikes,
    this.viewsCount,
    this.callCount,
    this.mainImage,
    this.currency,
    this.user,
    this.business,
    this.totalAds,
    this.totalCommentsAuthor,
    this.averageRatingAuthor,
    this.description,
    this.dimensionUnit,
    this.weightUnit,
    this.weight,
    this.width,
    this.height,
    this.length,
    this.rating,
    this.reviewCount,
    this.totalComments,
    this.averageRating,
    this.variants,
    this.options,
    this.tags,
    this.images,
    this.colors,
    this.sizes,
  });

  factory AdDetailDataDto.fromJson(Map<String, dynamic> json) =>
      _$AdDetailDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdDetailDataDtoToJson(this);
}

@JsonSerializable()
class AdCategoryDto {
  final int id;
  final String name;
  final int? parent;
  final int? level;
  @JsonKey(name: 'show_home')
  final bool? showHome;
  @JsonKey(name: 'category_type')
  final String? categoryType;
  final String? image;
  final List<dynamic>? children;
  final dynamic parents;

  const AdCategoryDto({
    required this.id,
    required this.name,
    this.parent,
    this.level,
    this.showHome,
    this.categoryType,
    this.image,
    this.children,
    this.parents,
  });

  factory AdCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$AdCategoryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdCategoryDtoToJson(this);
}

@JsonSerializable()
class AdUserDto {
  final int id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? username;
  final String? phone;
  final String? avatar;
  @JsonKey(name: 'date_joined')
  final String? dateJoined;
  @JsonKey(name: 'ad_count')
  final int? adCount;

  const AdUserDto({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.phone,
    this.avatar,
    this.dateJoined,
    this.adCount,
  });

  factory AdUserDto.fromJson(Map<String, dynamic> json) =>
      _$AdUserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdUserDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AdVariantDto {
  final int id;
  final int ad;
  final AdColorDto? color;
  final AdSizeDto? size;
  @JsonKey(name: 'is_available')
  final bool? isAvailable;
  final String? price;
  final String? discount;
  @JsonKey(name: 'final_price')
  final String? finalPrice;

  const AdVariantDto({
    required this.id,
    required this.ad,
    this.color,
    this.size,
    this.isAvailable,
    this.price,
    this.discount,
    this.finalPrice,
  });

  factory AdVariantDto.fromJson(Map<String, dynamic> json) =>
      _$AdVariantDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdVariantDtoToJson(this);
}

@JsonSerializable()
class AdOptionDto {
  final int id;
  final int ad;
  final String name;
  final String value;

  const AdOptionDto({
    required this.id,
    required this.ad,
    required this.name,
    required this.value,
  });

  factory AdOptionDto.fromJson(Map<String, dynamic> json) =>
      _$AdOptionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdOptionDtoToJson(this);
}

@JsonSerializable()
class AdImageDto {
  final int id;
  final String image;

  const AdImageDto({required this.id, required this.image});

  factory AdImageDto.fromJson(Map<String, dynamic> json) =>
      _$AdImageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdImageDtoToJson(this);
}

@JsonSerializable()
class AdColorDto {
  final int id;
  final String name;
  final String color;

  const AdColorDto({required this.id, required this.name, required this.color});

  factory AdColorDto.fromJson(Map<String, dynamic> json) =>
      _$AdColorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdColorDtoToJson(this);
}

@JsonSerializable()
class AdSizeDto {
  final int id;
  final String name;

  const AdSizeDto({required this.id, required this.name});

  factory AdSizeDto.fromJson(Map<String, dynamic> json) =>
      _$AdSizeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdSizeDtoToJson(this);
}

/// Similar products response (paginated list like recommendations).
@JsonSerializable(explicitToJson: true)
class AdSimilarResponseDto {
  final bool status;
  final AdSimilarDataDto data;

  const AdSimilarResponseDto({required this.status, required this.data});

  factory AdSimilarResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AdSimilarResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdSimilarResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AdSimilarDataDto {
  final List<AdSimilarItemDto>? results;
  final dynamic links;
  @JsonKey(name: 'total_items')
  final int? totalItems;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'page_size')
  final int? pageSize;
  @JsonKey(name: 'current_page')
  final int? currentPage;

  const AdSimilarDataDto({
    this.results,
    this.links,
    this.totalItems,
    this.totalPages,
    this.pageSize,
    this.currentPage,
  });

  factory AdSimilarDataDto.fromJson(Map<String, dynamic> json) =>
      _$AdSimilarDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdSimilarDataDtoToJson(this);
}

@JsonSerializable()
class AdSimilarItemDto {
  final String slug;
  final String title;
  @JsonKey(name: 'main_image')
  final String? mainImage;
  final String? price;
  @JsonKey(name: 'final_price')
  final String? finalPrice;
  final String? currency;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;

  const AdSimilarItemDto({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency,
    this.rating,
    this.reviewCount,
  });

  factory AdSimilarItemDto.fromJson(Map<String, dynamic> json) =>
      _$AdSimilarItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdSimilarItemDtoToJson(this);
}

/// Color list API response.
@JsonSerializable(explicitToJson: true)
class ColorListResponseDto {
  final bool status;
  final ColorListDataDto data;

  const ColorListResponseDto({required this.status, required this.data});

  factory ColorListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ColorListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ColorListResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ColorListDataDto {
  final List<AdColorDto>? results;

  const ColorListDataDto({this.results});

  factory ColorListDataDto.fromJson(Map<String, dynamic> json) =>
      _$ColorListDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ColorListDataDtoToJson(this);
}

/// Size list API response.
@JsonSerializable(explicitToJson: true)
class SizeListResponseDto {
  final bool status;
  final SizeListDataDto data;

  const SizeListResponseDto({required this.status, required this.data});

  factory SizeListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SizeListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SizeListResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SizeListDataDto {
  final List<AdSizeDto>? results;

  const SizeListDataDto({this.results});

  factory SizeListDataDto.fromJson(Map<String, dynamic> json) =>
      _$SizeListDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SizeListDataDtoToJson(this);
}
