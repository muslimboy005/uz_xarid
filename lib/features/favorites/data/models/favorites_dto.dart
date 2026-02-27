import 'package:json_annotation/json_annotation.dart';

part 'favorites_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FavoritesToggleResponseDto {
  final bool status;
  final FavoritesToggleDataDto? data;

  const FavoritesToggleResponseDto({required this.status, this.data});

  factory FavoritesToggleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FavoritesToggleResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesToggleResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FavoritesToggleDataDto {
  final String? status; // "liked" | "unliked"
  @JsonKey(name: 'likes_count')
  final int? likesCount;

  const FavoritesToggleDataDto({this.status, this.likesCount});

  factory FavoritesToggleDataDto.fromJson(Map<String, dynamic> json) =>
      _$FavoritesToggleDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesToggleDataDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FavoritesListResponseDto {
  final bool status;
  final FavoritesListDataDto data;

  const FavoritesListResponseDto({required this.status, required this.data});

  factory FavoritesListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FavoritesListResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesListResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FavoritesListDataDto {
  final dynamic links;
  @JsonKey(name: 'total_items')
  final int? totalItems;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'page_size')
  final int? pageSize;
  @JsonKey(name: 'current_page')
  final int? currentPage;
  final List<FavoritesItemDto>? results;

  const FavoritesListDataDto({
    this.links,
    this.totalItems,
    this.totalPages,
    this.pageSize,
    this.currentPage,
    this.results,
  });

  factory FavoritesListDataDto.fromJson(Map<String, dynamic> json) =>
      _$FavoritesListDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesListDataDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FavoritesItemDto {
  final int id;
  final FavoritesAdDto ad;

  const FavoritesItemDto({required this.id, required this.ad});

  factory FavoritesItemDto.fromJson(Map<String, dynamic> json) =>
      _$FavoritesItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesItemDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FavoritesAdDto {
  final String slug;
  final String title;
  @JsonKey(name: 'main_image')
  final String? mainImage;
  final String? price;
  @JsonKey(name: 'final_price')
  final String? finalPrice;
  final String? currency;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'is_likes')
  final bool? isLikes;

  const FavoritesAdDto({
    required this.slug,
    required this.title,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency,
    this.rating,
    this.reviewCount,
    this.isLikes,
  });

  factory FavoritesAdDto.fromJson(Map<String, dynamic> json) =>
      _$FavoritesAdDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesAdDtoToJson(this);
}
