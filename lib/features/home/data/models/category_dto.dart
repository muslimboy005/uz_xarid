import 'package:json_annotation/json_annotation.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/features/home/domain/entities/home_entity.dart';

part 'category_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CategoryDto {
  final int id;
  final String name;
  @JsonKey(fromJson: ImageParser.parse)
  final String? image;
  final List<CategoryDto> children;
  @JsonKey(name: 'show_home')
  final bool showHome;

  CategoryDto({
    required this.id,
    required this.name,
    this.image,
    this.children = const [],
    this.showHome = true,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);

  String _safeName() => name.trim().isEmpty ? 'Category $id' : name;

  HomeCategory toHomeCategory() => HomeCategory(
    id: id,
    name: name.isEmpty ? _safeName() : name,
    image: image,
  );

  /// Flatten this category and all nested children into a single list.
  List<HomeCategory> toHomeCategoriesFlatten() => [
    toHomeCategory(),
    for (final child in children) ...child.toHomeCategoriesFlatten(),
  ];
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
