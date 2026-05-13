import 'package:json_annotation/json_annotation.dart';
import 'package:uzxarid/features/add_listing/domain/entities/color_entity.dart';

part 'color_dto.g.dart';

String _normalizeHex(Object? v) {
  final s = v is String ? v : '#000000';
  return s.replaceFirst(RegExp(r'^#+'), '#');
}

@JsonSerializable()
class ColorDto {
  final int id;
  final String name;
  @JsonKey(fromJson: _normalizeHex)
  final String color;

  ColorDto({required this.id, required this.name, required this.color});

  factory ColorDto.fromJson(Map<String, dynamic> json) =>
      _$ColorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ColorDtoToJson(this);

  ColorEntity toEntity() => ColorEntity(id: id, name: name, hex: color);
}

@JsonSerializable(explicitToJson: true)
class ColorResponseDto {
  final bool status;
  final ColorResponseData data;

  ColorResponseDto({required this.status, required this.data});

  factory ColorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ColorResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ColorResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ColorResponseData {
  final List<ColorDto> results;

  ColorResponseData({required this.results});

  factory ColorResponseData.fromJson(Map<String, dynamic> json) =>
      _$ColorResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ColorResponseDataToJson(this);
}
