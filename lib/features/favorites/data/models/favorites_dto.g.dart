// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoritesToggleResponseDto _$FavoritesToggleResponseDtoFromJson(
  Map<String, dynamic> json,
) => FavoritesToggleResponseDto(
  status: json['status'] as bool,
  data: json['data'] == null
      ? null
      : FavoritesToggleDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavoritesToggleResponseDtoToJson(
  FavoritesToggleResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data?.toJson(),
};

FavoritesToggleDataDto _$FavoritesToggleDataDtoFromJson(
  Map<String, dynamic> json,
) => FavoritesToggleDataDto(
  status: json['status'] as String?,
  likesCount: (json['likes_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$FavoritesToggleDataDtoToJson(
  FavoritesToggleDataDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'likes_count': instance.likesCount,
};

FavoritesListResponseDto _$FavoritesListResponseDtoFromJson(
  Map<String, dynamic> json,
) => FavoritesListResponseDto(
  status: json['status'] as bool,
  data: FavoritesListDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavoritesListResponseDtoToJson(
  FavoritesListResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};

FavoritesListDataDto _$FavoritesListDataDtoFromJson(
  Map<String, dynamic> json,
) => FavoritesListDataDto(
  links: json['links'],
  totalItems: (json['total_items'] as num?)?.toInt(),
  totalPages: (json['total_pages'] as num?)?.toInt(),
  pageSize: (json['page_size'] as num?)?.toInt(),
  currentPage: (json['current_page'] as num?)?.toInt(),
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => FavoritesItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FavoritesListDataDtoToJson(
  FavoritesListDataDto instance,
) => <String, dynamic>{
  'links': instance.links,
  'total_items': instance.totalItems,
  'total_pages': instance.totalPages,
  'page_size': instance.pageSize,
  'current_page': instance.currentPage,
  'results': instance.results?.map((e) => e.toJson()).toList(),
};

FavoritesItemDto _$FavoritesItemDtoFromJson(Map<String, dynamic> json) =>
    FavoritesItemDto(
      id: (json['id'] as num).toInt(),
      ad: FavoritesAdDto.fromJson(json['ad'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavoritesItemDtoToJson(FavoritesItemDto instance) =>
    <String, dynamic>{'id': instance.id, 'ad': instance.ad.toJson()};

FavoritesAdDto _$FavoritesAdDtoFromJson(Map<String, dynamic> json) =>
    FavoritesAdDto(
      slug: json['slug'] as String,
      title: json['title'] as String,
      mainImage: json['main_image'] as String?,
      price: json['price'] as String?,
      finalPrice: json['final_price'] as String?,
      currency: json['currency'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      isLikes: json['is_likes'] as bool?,
    );

Map<String, dynamic> _$FavoritesAdDtoToJson(FavoritesAdDto instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'main_image': instance.mainImage,
      'price': instance.price,
      'final_price': instance.finalPrice,
      'currency': instance.currency,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'is_likes': instance.isLikes,
    };
