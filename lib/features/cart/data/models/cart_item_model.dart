import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable(createToJson: false)
class CartResponseModel {
  @JsonKey(name: 'status')
  final bool status;
  @JsonKey(name: 'data')
  final CartDataModel data;

  CartResponseModel({required this.status, required this.data});

  factory CartResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CartResponseModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CartDataModel {
  @JsonKey(name: 'results')
  final List<CartItemModel> results;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'current_page')
  final int currentPage;

  CartDataModel({
    required this.results,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory CartDataModel.fromJson(Map<String, dynamic> json) =>
      _$CartDataModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CartItemModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'ad')
  final CartAdModel ad;
  @JsonKey(name: 'variant')
  final CartVariantModel? variant;
  @JsonKey(name: 'quantity')
  final int quantity;
  @JsonKey(name: 'unit_price')
  final String unitPrice;
  @JsonKey(name: 'subtotal')
  final String subtotal;
  @JsonKey(name: 'created_at')
  final String createdAt;

  CartItemModel({
    required this.id,
    required this.ad,
    this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CartAdModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'slug')
  final String slug;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'final_price')
  final String finalPrice;
  @JsonKey(name: 'currency')
  final String currency;
  @JsonKey(name: 'main_image')
  final String? mainImage;

  CartAdModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.finalPrice,
    required this.currency,
    this.mainImage,
  });

  factory CartAdModel.fromJson(Map<String, dynamic> json) =>
      _$CartAdModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CartVariantModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'final_price')
  final String? finalPrice;
  @JsonKey(name: 'color')
  final String? color;
  @JsonKey(name: 'size')
  final String? size;

  CartVariantModel({
    required this.id,
    this.finalPrice,
    this.color,
    this.size,
  });

  factory CartVariantModel.fromJson(Map<String, dynamic> json) =>
      _$CartVariantModelFromJson(json);
}
