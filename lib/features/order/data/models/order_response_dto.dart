import 'package:json_annotation/json_annotation.dart';

part 'order_response_dto.g.dart';

@JsonSerializable()
class OrderResponseDto {
  final int id;
  @JsonKey(name: 'ad_slug')
  final String? adSlug;
  final int quantity;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'address_id')
  final int? addressId;
  @JsonKey(name: 'show_similar_products')
  final bool? showSimilarProducts;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? status; // active, pending, etc.

  const OrderResponseDto({
    required this.id,
    this.adSlug,
    required this.quantity,
    this.firstName,
    this.lastName,
    this.addressId,
    this.showSimilarProducts,
    this.notes,
    this.createdAt,
    this.status,
  });

  factory OrderResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return _$OrderResponseDtoFromJson(data);
  }

  Map<String, dynamic> toJson() => _$OrderResponseDtoToJson(this);
}

@JsonSerializable()
class OrderCreateResponseDto {
  final bool status;
  final OrderResponseDto data;

  const OrderCreateResponseDto({required this.status, required this.data});

  factory OrderCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderCreateResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderCreateResponseDtoToJson(this);
}

@JsonSerializable()
class OrderListResponseDto {
  final bool status;
  final OrderListDataDto data;

  const OrderListResponseDto({required this.status, required this.data});

  factory OrderListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListResponseDtoToJson(this);
}

@JsonSerializable()
class OrderListDataDto {
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'page_size')
  final int pageSize;
  @JsonKey(name: 'current_page')
  final int currentPage;
  final List<OrderResponseDto> results;

  const OrderListDataDto({
    required this.totalItems,
    required this.totalPages,
    required this.pageSize,
    required this.currentPage,
    required this.results,
  });

  factory OrderListDataDto.fromJson(Map<String, dynamic> json) =>
      _$OrderListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListDataDtoToJson(this);
}
