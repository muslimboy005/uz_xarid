import 'package:json_annotation/json_annotation.dart';
import 'package:uzxarid/features/add_listing/domain/entities/size_entity.dart';

part 'size_dto.g.dart';

@JsonSerializable()
class SizeDto {
  final int id;
  final String name;

  SizeDto({required this.id, required this.name});

  factory SizeDto.fromJson(Map<String, dynamic> json) =>
      _$SizeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SizeDtoToJson(this);

  SizeEntity toEntity() => SizeEntity(id: id, name: name);
}

@JsonSerializable(explicitToJson: true)
class SizeResponseDto {
  final bool status;
  final SizeResponseData data;

  SizeResponseDto({required this.status, required this.data});

  factory SizeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SizeResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SizeResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SizeResponseData {
  final List<SizeDto> results;

  SizeResponseData({required this.results});

  factory SizeResponseData.fromJson(Map<String, dynamic> json) =>
      _$SizeResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SizeResponseDataToJson(this);
}
