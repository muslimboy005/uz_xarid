// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_children_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryChildrenLinksDto _$CategoryChildrenLinksDtoFromJson(
  Map<String, dynamic> json,
) => CategoryChildrenLinksDto(
  previous: json['previous'] as String?,
  next: json['next'] as String?,
);

Map<String, dynamic> _$CategoryChildrenLinksDtoToJson(
  CategoryChildrenLinksDto instance,
) => <String, dynamic>{'previous': instance.previous, 'next': instance.next};

CategoryChildrenPageDto _$CategoryChildrenPageDtoFromJson(
  Map<String, dynamic> json,
) => CategoryChildrenPageDto(
  links: CategoryChildrenLinksDto.fromJson(
    json['links'] as Map<String, dynamic>,
  ),
  totalItems: (json['total_items'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
  currentPage: (json['current_page'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => CategoryChildV2Dto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryChildrenPageDtoToJson(
  CategoryChildrenPageDto instance,
) => <String, dynamic>{
  'links': instance.links.toJson(),
  'total_items': instance.totalItems,
  'total_pages': instance.totalPages,
  'page_size': instance.pageSize,
  'current_page': instance.currentPage,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

CategoryChildV2Dto _$CategoryChildV2DtoFromJson(Map<String, dynamic> json) =>
    CategoryChildV2Dto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      parent: (json['parent'] as num?)?.toInt(),
      level: (json['level'] as num?)?.toInt(),
      showHome: json['show_home'] as bool?,
      categoryType: json['category_type'] as String?,
      image: ImageParser.parse(json['image']),
      hasChildren: json['has_children'] as bool?,
    );

Map<String, dynamic> _$CategoryChildV2DtoToJson(CategoryChildV2Dto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent,
      'level': instance.level,
      'show_home': instance.showHome,
      'category_type': instance.categoryType,
      'image': instance.image,
      'has_children': instance.hasChildren,
    };
