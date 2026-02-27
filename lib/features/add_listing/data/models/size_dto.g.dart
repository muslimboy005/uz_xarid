// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'size_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SizeDto _$SizeDtoFromJson(Map<String, dynamic> json) =>
    SizeDto(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$SizeDtoToJson(SizeDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

SizeResponseDto _$SizeResponseDtoFromJson(Map<String, dynamic> json) =>
    SizeResponseDto(
      status: json['status'] as bool,
      data: SizeResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SizeResponseDtoToJson(SizeResponseDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data.toJson(),
    };

SizeResponseData _$SizeResponseDataFromJson(Map<String, dynamic> json) =>
    SizeResponseData(
      results: (json['results'] as List<dynamic>)
          .map((e) => SizeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SizeResponseDataToJson(SizeResponseData instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
