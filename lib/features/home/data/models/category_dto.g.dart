// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => CategoryDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  image: json['image'] as String?,
  children: (json['children'] as List<dynamic>?)
          ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  showHome: json['show_home'] as bool? ?? true,
);

Map<String, dynamic> _$CategoryDtoToJson(CategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'children': instance.children.map((e) => e.toJson()).toList(),
      'show_home': instance.showHome,
    };

CategoryResponseDto _$CategoryResponseDtoFromJson(Map<String, dynamic> json) =>
    CategoryResponseDto(
      status: json['status'] as bool,
      data: CategoryResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CategoryResponseDtoToJson(
  CategoryResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

CategoryResponseData _$CategoryResponseDataFromJson(
  Map<String, dynamic> json,
) => CategoryResponseData(
  results: (json['results'] as List<dynamic>)
      .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryResponseDataToJson(
  CategoryResponseData instance,
) => <String, dynamic>{
  'results': instance.results.map((e) => e.toJson()).toList(),
};
