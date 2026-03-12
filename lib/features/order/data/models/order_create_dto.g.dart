// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderCreateDto _$OrderCreateDtoFromJson(Map<String, dynamic> json) =>
    OrderCreateDto(
      adSlug: json['ad_slug'] as String,
      quantity: (json['quantity'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      addressId: (json['address_id'] as num).toInt(),
      showSimilarProducts: json['show_similar_products'] as bool,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$OrderCreateDtoToJson(OrderCreateDto instance) =>
    <String, dynamic>{
      'ad_slug': instance.adSlug,
      'quantity': instance.quantity,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'address_id': instance.addressId,
      'show_similar_products': instance.showSimilarProducts,
      'notes': instance.notes,
    };
