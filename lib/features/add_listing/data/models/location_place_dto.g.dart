// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_place_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationPlaceDto _$LocationPlaceDtoFromJson(Map<String, dynamic> json) =>
    LocationPlaceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      region: (json['region'] as num?)?.toInt(),
      district: (json['district'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LocationPlaceDtoToJson(LocationPlaceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'region': instance.region,
      'district': instance.district,
    };

LocationPagedDataDto _$LocationPagedDataDtoFromJson(
  Map<String, dynamic> json,
) => LocationPagedDataDto(
  totalItems: (json['total_items'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
  currentPage: (json['current_page'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => LocationPlaceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationPagedDataDtoToJson(
  LocationPagedDataDto instance,
) => <String, dynamic>{
  'total_items': instance.totalItems,
  'total_pages': instance.totalPages,
  'page_size': instance.pageSize,
  'current_page': instance.currentPage,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

LocationPagedResponseDto _$LocationPagedResponseDtoFromJson(
  Map<String, dynamic> json,
) => LocationPagedResponseDto(
  status: json['status'] as bool,
  data: LocationPagedDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationPagedResponseDtoToJson(
  LocationPagedResponseDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data.toJson(),
};
