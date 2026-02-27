// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorDto _$ColorDtoFromJson(Map<String, dynamic> json) => ColorDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: _normalizeHex(json['color']),
);

Map<String, dynamic> _$ColorDtoToJson(ColorDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
};

ColorResponseDto _$ColorResponseDtoFromJson(Map<String, dynamic> json) =>
    ColorResponseDto(
      status: json['status'] as bool,
      data: ColorResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ColorResponseDtoToJson(ColorResponseDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data.toJson(),
    };

ColorResponseData _$ColorResponseDataFromJson(Map<String, dynamic> json) =>
    ColorResponseData(
      results: (json['results'] as List<dynamic>)
          .map((e) => ColorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ColorResponseDataToJson(ColorResponseData instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
