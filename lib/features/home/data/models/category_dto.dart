import 'package:json_annotation/json_annotation.dart';
import 'package:uz_xarid/features/home/domain/entities/category_entity.dart';

part 'category_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CategoryDto {
  final int id;
  final String name;
  final String? image;

  CategoryDto({required this.id, required this.name, this.image});

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);

  CategoryEntity toEntity() => CategoryEntity(id: id, name: name, image: image);
}

@JsonSerializable()
class CategoryResponseDto {
  final bool status;
  final CategoryResponseData data;

  CategoryResponseDto({required this.status, required this.data});

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CategoryResponseData {
  final List<CategoryDto> results;

  CategoryResponseData({required this.results});

  factory CategoryResponseData.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseDataToJson(this);
}
