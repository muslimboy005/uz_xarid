import 'package:json_annotation/json_annotation.dart';
import 'package:uzxarid/features/product_detail/data/models/ad_detail_dto.dart';

part 'author_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthorResponseDto {
  final bool status;
  final AuthorDataDto data;

  const AuthorResponseDto({required this.status, required this.data});

  factory AuthorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuthorDataDto {
  final List<AdSimilarItemDto>? results;
  final dynamic links;
  @JsonKey(name: 'total_items')
  final int? totalItems;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'page_size')
  final int? pageSize;
  @JsonKey(name: 'current_page')
  final int? currentPage;
  final AdUserDto? user;
  final dynamic business;
  @JsonKey(name: 'total_ads')
  final int? totalAds;
  @JsonKey(name: 'total_comments_author')
  final int? totalCommentsAuthor;
  @JsonKey(name: 'average_rating_author')
  final double? averageRatingAuthor;

  const AuthorDataDto({
    this.results,
    this.links,
    this.totalItems,
    this.totalPages,
    this.pageSize,
    this.currentPage,
    this.user,
    this.business,
    this.totalAds,
    this.totalCommentsAuthor,
    this.averageRatingAuthor,
  });

  factory AuthorDataDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorDataDtoToJson(this);
}
