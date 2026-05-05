// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartResponseModel _$CartResponseModelFromJson(Map<String, dynamic> json) =>
    CartResponseModel(
      status: json['status'] as bool,
      data: CartDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

CartDataModel _$CartDataModelFromJson(Map<String, dynamic> json) =>
    CartDataModel(
      results: (json['results'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['total_items'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
    );

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    CartItemModel(
      id: (json['id'] as num).toInt(),
      ad: CartAdModel.fromJson(json['ad'] as Map<String, dynamic>),
      variant: json['variant'] == null
          ? null
          : CartVariantModel.fromJson(json['variant'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: json['unit_price'] as String,
      subtotal: json['subtotal'] as String,
      createdAt: json['created_at'] as String,
    );

CartAdModel _$CartAdModelFromJson(Map<String, dynamic> json) => CartAdModel(
  id: (json['id'] as num).toInt(),
  slug: json['slug'] as String,
  title: json['title'] as String,
  finalPrice: json['final_price'] as String,
  currency: json['currency'] as String,
  mainImage: json['main_image'] as String?,
);

CartVariantModel _$CartVariantModelFromJson(Map<String, dynamic> json) =>
    CartVariantModel(
      id: (json['id'] as num).toInt(),
      finalPrice: json['final_price'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
    );
