import 'package:json_annotation/json_annotation.dart';
import 'package:uz_xarid/core/utils/image_parser.dart';

part 'ad_detail_dto.g.dart';

/// Avto / mototexnika e'lonlari: API `attributes` obyekti (har kalit — label + value).
List<AdAttributePairDto>? adAttributesFromJson(dynamic raw) {
  if (raw == null || raw is! Map) return null;
  final map = Map<String, dynamic>.from(raw);
  const order = <String>[
    'mark',
    'model',
    'manufacture',
    'probeg',
    'engine_capacity',
    'engine_power',
    'fuel_type',
    'transmission_type',
    'privod',
    'body',
    'color',
    'condition',
    'configuration',
    'payment_type',
  ];
  final seen = <String>{};
  final list = <AdAttributePairDto>[];

  void tryAdd(String key) {
    final v = map[key];
    if (v is! Map) return;
    final m = Map<String, dynamic>.from(v);
    final label = (m['label'] as String?)?.trim() ?? '';
    final val = m['value']?.toString().trim() ?? '';
    if (label.isEmpty && val.isEmpty) return;
    list.add(
      AdAttributePairDto(
        label: label.isNotEmpty ? label : key,
        value: val,
      ),
    );
    seen.add(key);
  }

  for (final k in order) {
    if (map.containsKey(k)) tryAdd(k);
  }
  final rest = map.keys.where((k) => !seen.contains(k)).toList()..sort();
  for (final k in rest) {
    tryAdd(k);
  }
  return list.isEmpty ? null : list;
}

class AdAttributePairDto {
  const AdAttributePairDto({required this.label, required this.value});

  final String label;
  final String value;
}

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
  @JsonKey(name: 'ad_type', fromJson: parseString)
  final String? adType;
  @JsonKey(name: 'listing_type', fromJson: parseString)
  final String? listingType;
  final AdCategoryDto? category;
  @JsonKey(fromJson: parseString)
  final String? price;
  @JsonKey(name: 'final_price', fromJson: parseString)
  final String? finalPrice;
  @JsonKey(fromJson: parseString)
  final String? discount;
  @JsonKey(name: 'is_physical')
  final bool? isPhysical;
  @JsonKey(name: 'is_top')
  final bool? isTop;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(fromJson: parseString)
  final String? status;
  @JsonKey(name: 'likes_count', fromJson: parseInt)
  final int? likesCount;
  @JsonKey(name: 'is_likes')
  final bool? isLikes;
  @JsonKey(name: 'views_count', fromJson: parseInt)
  final int? viewsCount;
  @JsonKey(name: 'call_count', fromJson: parseInt)
  final int? callCount;
  @JsonKey(name: 'main_image', fromJson: ImageParser.parse)
  final String? mainImage;
  @JsonKey(fromJson: parseString)
  final String? currency;
  final AdUserDto? user;
  final dynamic business;
  @JsonKey(name: 'total_ads', fromJson: parseInt)
  final int? totalAds;
  @JsonKey(name: 'total_comments_author', fromJson: parseInt)
  final int? totalCommentsAuthor;
  @JsonKey(name: 'average_rating_author', fromJson: parseDouble)
  final double? averageRatingAuthor;

  @JsonKey(fromJson: parseString)
  final String? description;

  @JsonKey(name: 'dimension_unit', fromJson: parseString)
  final String? dimensionUnit;
  @JsonKey(name: 'weight_unit', fromJson: parseString)
  final String? weightUnit;
  @JsonKey(fromJson: parseNum)
  final num? weight;
  @JsonKey(fromJson: parseNum)
  final num? width;
  @JsonKey(fromJson: parseNum)
  final num? height;
  @JsonKey(fromJson: parseNum)
  final num? length;
  @JsonKey(fromJson: parseDouble)
  final double? rating;
  @JsonKey(name: 'review_count', fromJson: parseInt)
  final int? reviewCount;
  @JsonKey(name: 'total_comments', fromJson: parseInt)
  final int? totalComments;
  @JsonKey(name: 'average_rating', fromJson: parseDouble)
  final double? averageRating;
  final List<AdVariantDto>? variants;
  final List<AdOptionDto>? options;
  final List<dynamic>? tags;
  final List<AdImageDto>? images;
  final List<AdColorDto>? colors;
  final List<AdSizeDto>? sizes;
  @JsonKey(
    name: 'attributes',
    fromJson: adAttributesFromJson,
    includeToJson: false,
  )
  final List<AdAttributePairDto>? attributes;
  @JsonKey(fromJson: parseDouble)
  final double? latitude;
  @JsonKey(fromJson: parseDouble)
  final double? longitude;
  @JsonKey(fromJson: parseString)
  final String? address;

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
    this.attributes,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory AdDetailDataDto.fromJson(Map<String, dynamic> json) =>
      _$AdDetailDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdDetailDataDtoToJson(this);
}

@JsonSerializable()
class AdCategoryDto {
  final int id;
  final String name;
  @JsonKey(fromJson: parseInt)
  final int? parent;
  @JsonKey(fromJson: parseInt)
  final int? level;
  @JsonKey(name: 'show_home')
  final bool? showHome;
  @JsonKey(name: 'category_type')
  final String? categoryType;
  @JsonKey(fromJson: ImageParser.parse)
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
  @JsonKey(name: 'first_name', fromJson: parseString)
  final String? firstName;
  @JsonKey(name: 'last_name', fromJson: parseString)
  final String? lastName;
  @JsonKey(fromJson: parseString)
  final String? username;
  @JsonKey(fromJson: parseString)
  final String? phone;
  @JsonKey(fromJson: ImageParser.parse)
  final String? avatar;
  @JsonKey(name: 'date_joined', fromJson: parseString)
  final String? dateJoined;
  @JsonKey(name: 'ad_count', fromJson: parseInt)
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
  @JsonKey(fromJson: parseString)
  final String? price;
  @JsonKey(fromJson: parseString)
  final String? discount;
  @JsonKey(name: 'final_price', fromJson: parseString)
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
  @JsonKey(fromJson: parseRequiredString)
  final String name;
  @JsonKey(fromJson: parseRequiredString)
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
  @JsonKey(fromJson: ImageParser.parse)
  final String? image;

  const AdImageDto({required this.id, required this.image});

  factory AdImageDto.fromJson(Map<String, dynamic> json) =>
      _$AdImageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdImageDtoToJson(this);
}

@JsonSerializable()
class AdColorDto {
  final int id;
  @JsonKey(fromJson: parseRequiredString)
  final String name;
  @JsonKey(fromJson: parseRequiredString)
  final String color;

  const AdColorDto({required this.id, required this.name, required this.color});

  factory AdColorDto.fromJson(Map<String, dynamic> json) =>
      _$AdColorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdColorDtoToJson(this);
}

@JsonSerializable()
class AdSizeDto {
  final int id;
  @JsonKey(fromJson: parseRequiredString)
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
  @JsonKey(name: 'total_items', fromJson: parseInt)
  final int? totalItems;
  @JsonKey(name: 'total_pages', fromJson: parseInt)
  final int? totalPages;
  @JsonKey(name: 'page_size', fromJson: parseInt)
  final int? pageSize;
  @JsonKey(name: 'current_page', fromJson: parseInt)
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
  @JsonKey(fromJson: parseRequiredString)
  final String title;
  @JsonKey(name: 'main_image', fromJson: ImageParser.parse)
  final String? mainImage;
  @JsonKey(fromJson: parseString)
  final String? price;
  @JsonKey(name: 'final_price', fromJson: parseString)
  final String? finalPrice;
  @JsonKey(fromJson: parseString)
  final String? currency;
  @JsonKey(fromJson: parseDouble)
  final double? rating;
  @JsonKey(name: 'review_count', fromJson: parseInt)
  final int? reviewCount;
  @JsonKey(fromJson: parseString)
  final String? address;

  const AdSimilarItemDto({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency,
    this.rating,
    this.reviewCount,
    this.address,
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

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

num? parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? parseString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    for (final key in const ['value', 'name', 'label', 'title', 'text']) {
      final candidate = parseString(map[key]);
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
  }
  return value.toString();
}

String parseRequiredString(dynamic value) {
  return parseString(value) ?? '';
}
