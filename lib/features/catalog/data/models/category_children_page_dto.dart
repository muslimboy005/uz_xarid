import 'package:json_annotation/json_annotation.dart';
import 'package:uz_xarid/core/utils/image_parser.dart';

part 'category_children_page_dto.g.dart';

@JsonSerializable()
class CategoryChildrenLinksDto {
  const CategoryChildrenLinksDto({this.previous, this.next});

  final String? previous;
  final String? next;

  factory CategoryChildrenLinksDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryChildrenLinksDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryChildrenLinksDtoToJson(this);
}

/// Javob: `GET /api/v2/category/{id}/children/?page_size=12`
@JsonSerializable(explicitToJson: true)
class CategoryChildrenPageDto {
  const CategoryChildrenPageDto({
    required this.links,
    required this.totalItems,
    required this.totalPages,
    required this.pageSize,
    required this.currentPage,
    required this.results,
  });

  final CategoryChildrenLinksDto links;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'page_size')
  final int pageSize;
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<CategoryChildV2Dto> results;

  factory CategoryChildrenPageDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryChildrenPageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryChildrenPageDtoToJson(this);
}

@JsonSerializable()
class CategoryChildV2Dto {
  const CategoryChildV2Dto({
    required this.id,
    required this.name,
    this.parent,
    this.level,
    this.showHome,
    this.categoryType,
    this.image,
    this.hasChildren,
  });

  final int id;
  final String name;
  final int? parent;
  final int? level;
  @JsonKey(name: 'show_home')
  final bool? showHome;
  @JsonKey(name: 'category_type')
  final String? categoryType;
  @JsonKey(fromJson: ImageParser.parse)
  final String? image;
  @JsonKey(name: 'has_children')
  final bool? hasChildren;

  factory CategoryChildV2Dto.fromJson(Map<String, dynamic> json) =>
      _$CategoryChildV2DtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryChildV2DtoToJson(this);
}
