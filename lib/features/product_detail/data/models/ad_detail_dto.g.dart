// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdDetailResponseDto _$AdDetailResponseDtoFromJson(Map<String, dynamic> json) =>
    AdDetailResponseDto(
      status: json['status'] as bool,
      data: AdDetailDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdDetailResponseDtoToJson(
  AdDetailResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};

AdDetailDataDto _$AdDetailDataDtoFromJson(Map<String, dynamic> json) =>
    AdDetailDataDto(
      slug: json['slug'] as String,
      title: json['title'] as String,
      adType: parseString(json['ad_type']),
      listingType: parseString(json['listing_type']),
      category: json['category'] == null
          ? null
          : AdCategoryDto.fromJson(json['category'] as Map<String, dynamic>),
      price: parseString(json['price']),
      finalPrice: parseString(json['final_price']),
      discount: parseString(json['discount']),
      isPhysical: json['is_physical'] as bool?,
      isTop: json['is_top'] as bool?,
      isActive: json['is_active'] as bool?,
      status: parseString(json['status']),
      likesCount: parseInt(json['likes_count']),
      isLikes: json['is_likes'] as bool?,
      viewsCount: parseInt(json['views_count']),
      callCount: parseInt(json['call_count']),
      mainImage: ImageParser.parse(json['main_image']),
      currency: parseString(json['currency']),
      user: json['user'] == null
          ? null
          : AdUserDto.fromJson(json['user'] as Map<String, dynamic>),
      business: json['business'],
      totalAds: parseInt(json['total_ads']),
      totalCommentsAuthor: parseInt(json['total_comments_author']),
      averageRatingAuthor: parseDouble(json['average_rating_author']),
      description: parseString(json['description']),
      dimensionUnit: parseString(json['dimension_unit']),
      weightUnit: parseString(json['weight_unit']),
      weight: parseNum(json['weight']),
      width: parseNum(json['width']),
      height: parseNum(json['height']),
      length: parseNum(json['length']),
      rating: parseDouble(json['rating']),
      reviewCount: parseInt(json['review_count']),
      totalComments: parseInt(json['total_comments']),
      averageRating: parseDouble(json['average_rating']),
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => AdVariantDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => AdOptionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: json['tags'] as List<dynamic>?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => AdImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => AdColorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sizes: (json['sizes'] as List<dynamic>?)
          ?.map((e) => AdSizeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: adAttributesFromJson(json['attributes']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      address: parseString(json['address']),
    );

Map<String, dynamic> _$AdDetailDataDtoToJson(AdDetailDataDto instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'ad_type': instance.adType,
      'listing_type': instance.listingType,
      'category': instance.category?.toJson(),
      'price': instance.price,
      'final_price': instance.finalPrice,
      'discount': instance.discount,
      'is_physical': instance.isPhysical,
      'is_top': instance.isTop,
      'is_active': instance.isActive,
      'status': instance.status,
      'likes_count': instance.likesCount,
      'is_likes': instance.isLikes,
      'views_count': instance.viewsCount,
      'call_count': instance.callCount,
      'main_image': instance.mainImage,
      'currency': instance.currency,
      'user': instance.user?.toJson(),
      'business': instance.business,
      'total_ads': instance.totalAds,
      'total_comments_author': instance.totalCommentsAuthor,
      'average_rating_author': instance.averageRatingAuthor,
      'description': instance.description,
      'dimension_unit': instance.dimensionUnit,
      'weight_unit': instance.weightUnit,
      'weight': instance.weight,
      'width': instance.width,
      'height': instance.height,
      'length': instance.length,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'total_comments': instance.totalComments,
      'average_rating': instance.averageRating,
      'variants': instance.variants?.map((e) => e.toJson()).toList(),
      'options': instance.options?.map((e) => e.toJson()).toList(),
      'tags': instance.tags,
      'images': instance.images?.map((e) => e.toJson()).toList(),
      'colors': instance.colors?.map((e) => e.toJson()).toList(),
      'sizes': instance.sizes?.map((e) => e.toJson()).toList(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
    };

AdCategoryDto _$AdCategoryDtoFromJson(Map<String, dynamic> json) =>
    AdCategoryDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      parent: parseInt(json['parent']),
      level: parseInt(json['level']),
      showHome: json['show_home'] as bool?,
      categoryType: json['category_type'] as String?,
      image: ImageParser.parse(json['image']),
      children: json['children'] as List<dynamic>?,
      parents: json['parents'],
    );

Map<String, dynamic> _$AdCategoryDtoToJson(AdCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent,
      'level': instance.level,
      'show_home': instance.showHome,
      'category_type': instance.categoryType,
      'image': instance.image,
      'children': instance.children,
      'parents': instance.parents,
    };

AdUserDto _$AdUserDtoFromJson(Map<String, dynamic> json) => AdUserDto(
  id: (json['id'] as num).toInt(),
  firstName: parseString(json['first_name']),
  lastName: parseString(json['last_name']),
  username: parseString(json['username']),
  phone: parseString(json['phone']),
  avatar: ImageParser.parse(json['avatar']),
  dateJoined: parseString(json['date_joined']),
  adCount: parseInt(json['ad_count']),
);

Map<String, dynamic> _$AdUserDtoToJson(AdUserDto instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'username': instance.username,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'date_joined': instance.dateJoined,
  'ad_count': instance.adCount,
};

AdVariantDto _$AdVariantDtoFromJson(Map<String, dynamic> json) => AdVariantDto(
  id: (json['id'] as num).toInt(),
  ad: (json['ad'] as num).toInt(),
  color: json['color'] == null
      ? null
      : AdColorDto.fromJson(json['color'] as Map<String, dynamic>),
  size: json['size'] == null
      ? null
      : AdSizeDto.fromJson(json['size'] as Map<String, dynamic>),
  isAvailable: json['is_available'] as bool?,
  price: parseString(json['price']),
  discount: parseString(json['discount']),
  finalPrice: parseString(json['final_price']),
);

Map<String, dynamic> _$AdVariantDtoToJson(AdVariantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad': instance.ad,
      'color': instance.color?.toJson(),
      'size': instance.size?.toJson(),
      'is_available': instance.isAvailable,
      'price': instance.price,
      'discount': instance.discount,
      'final_price': instance.finalPrice,
    };

AdOptionDto _$AdOptionDtoFromJson(Map<String, dynamic> json) => AdOptionDto(
  id: (json['id'] as num).toInt(),
  ad: (json['ad'] as num).toInt(),
  name: parseRequiredString(json['name']),
  value: parseRequiredString(json['value']),
);

Map<String, dynamic> _$AdOptionDtoToJson(AdOptionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad': instance.ad,
      'name': instance.name,
      'value': instance.value,
    };

AdImageDto _$AdImageDtoFromJson(Map<String, dynamic> json) => AdImageDto(
  id: (json['id'] as num).toInt(),
  image: ImageParser.parse(json['image']),
);

Map<String, dynamic> _$AdImageDtoToJson(AdImageDto instance) =>
    <String, dynamic>{'id': instance.id, 'image': instance.image};

AdColorDto _$AdColorDtoFromJson(Map<String, dynamic> json) => AdColorDto(
  id: (json['id'] as num).toInt(),
  name: parseRequiredString(json['name']),
  color: parseRequiredString(json['color']),
);

Map<String, dynamic> _$AdColorDtoToJson(AdColorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
    };

AdSizeDto _$AdSizeDtoFromJson(Map<String, dynamic> json) => AdSizeDto(
  id: (json['id'] as num).toInt(),
  name: parseRequiredString(json['name']),
);

Map<String, dynamic> _$AdSizeDtoToJson(AdSizeDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

AdSimilarResponseDto _$AdSimilarResponseDtoFromJson(
  Map<String, dynamic> json,
) => AdSimilarResponseDto(
  status: json['status'] as bool,
  data: AdSimilarDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AdSimilarResponseDtoToJson(
  AdSimilarResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};

AdSimilarDataDto _$AdSimilarDataDtoFromJson(Map<String, dynamic> json) =>
    AdSimilarDataDto(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => AdSimilarItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: json['links'],
      totalItems: parseInt(json['total_items']),
      totalPages: parseInt(json['total_pages']),
      pageSize: parseInt(json['page_size']),
      currentPage: parseInt(json['current_page']),
    );

Map<String, dynamic> _$AdSimilarDataDtoToJson(AdSimilarDataDto instance) =>
    <String, dynamic>{
      'results': instance.results?.map((e) => e.toJson()).toList(),
      'links': instance.links,
      'total_items': instance.totalItems,
      'total_pages': instance.totalPages,
      'page_size': instance.pageSize,
      'current_page': instance.currentPage,
    };

AdSimilarItemDto _$AdSimilarItemDtoFromJson(Map<String, dynamic> json) =>
    AdSimilarItemDto(
      slug: json['slug'] as String,
      title: parseRequiredString(json['title']),
      mainImage: ImageParser.parse(json['main_image']),
      price: parseString(json['price']),
      finalPrice: parseString(json['final_price']),
      currency: parseString(json['currency']),
      rating: parseDouble(json['rating']),
      reviewCount: parseInt(json['review_count']),
      address: parseString(json['address']),
    );

Map<String, dynamic> _$AdSimilarItemDtoToJson(AdSimilarItemDto instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'main_image': instance.mainImage,
      'price': instance.price,
      'final_price': instance.finalPrice,
      'currency': instance.currency,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'address': instance.address,
    };

ColorListResponseDto _$ColorListResponseDtoFromJson(
  Map<String, dynamic> json,
) => ColorListResponseDto(
  status: json['status'] as bool,
  data: ColorListDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ColorListResponseDtoToJson(
  ColorListResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};

ColorListDataDto _$ColorListDataDtoFromJson(Map<String, dynamic> json) =>
    ColorListDataDto(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => AdColorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ColorListDataDtoToJson(ColorListDataDto instance) =>
    <String, dynamic>{
      'results': instance.results?.map((e) => e.toJson()).toList(),
    };

SizeListResponseDto _$SizeListResponseDtoFromJson(Map<String, dynamic> json) =>
    SizeListResponseDto(
      status: json['status'] as bool,
      data: SizeListDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SizeListResponseDtoToJson(
  SizeListResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};

SizeListDataDto _$SizeListDataDtoFromJson(Map<String, dynamic> json) =>
    SizeListDataDto(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => AdSizeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SizeListDataDtoToJson(SizeListDataDto instance) =>
    <String, dynamic>{
      'results': instance.results?.map((e) => e.toJson()).toList(),
    };
