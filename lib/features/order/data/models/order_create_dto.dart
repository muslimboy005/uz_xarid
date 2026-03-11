import 'package:json_annotation/json_annotation.dart';

part 'order_create_dto.g.dart';

@JsonSerializable()
class OrderCreateDto {
  @JsonKey(name: 'ad_slug')
  final String adSlug;
  final int quantity;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'address_id')
  final int addressId;
  @JsonKey(name: 'show_similar_products')
  final bool showSimilarProducts;
  final String notes;

  const OrderCreateDto({
    required this.adSlug,
    required this.quantity,
    required this.firstName,
    required this.lastName,
    required this.addressId,
    required this.showSimilarProducts,
    required this.notes,
  });

  factory OrderCreateDto.fromJson(Map<String, dynamic> json) =>
      _$OrderCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderCreateDtoToJson(this);
}
