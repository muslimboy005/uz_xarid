// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthorResponseDto _$AuthorResponseDtoFromJson(Map<String, dynamic> json) =>
    AuthorResponseDto(
      status: json['status'] as bool,
      data: AuthorDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthorResponseDtoToJson(AuthorResponseDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data.toJson(),
    };

AuthorDataDto _$AuthorDataDtoFromJson(Map<String, dynamic> json) =>
    AuthorDataDto(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => AdSimilarItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: json['links'],
      totalItems: (json['total_items'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
      pageSize: (json['page_size'] as num?)?.toInt(),
      currentPage: (json['current_page'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : AdUserDto.fromJson(json['user'] as Map<String, dynamic>),
      business: json['business'],
      totalAds: (json['total_ads'] as num?)?.toInt(),
      totalCommentsAuthor: (json['total_comments_author'] as num?)?.toInt(),
      averageRatingAuthor: (json['average_rating_author'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AuthorDataDtoToJson(AuthorDataDto instance) =>
    <String, dynamic>{
      'results': instance.results?.map((e) => e.toJson()).toList(),
      'links': instance.links,
      'total_items': instance.totalItems,
      'total_pages': instance.totalPages,
      'page_size': instance.pageSize,
      'current_page': instance.currentPage,
      'user': instance.user?.toJson(),
      'business': instance.business,
      'total_ads': instance.totalAds,
      'total_comments_author': instance.totalCommentsAuthor,
      'average_rating_author': instance.averageRatingAuthor,
    };
