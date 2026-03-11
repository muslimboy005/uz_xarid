// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResponseDto _$OrderResponseDtoFromJson(Map<String, dynamic> json) =>
    OrderResponseDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      adSlug: json['ad_slug'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      addressId: (json['address_id'] as num?)?.toInt(),
      showSimilarProducts: json['show_similar_products'] as bool?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$OrderResponseDtoToJson(OrderResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ad_slug': instance.adSlug,
      'quantity': instance.quantity,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'address_id': instance.addressId,
      'show_similar_products': instance.showSimilarProducts,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'status': instance.status,
    };

OrderListResponseDto _$OrderListResponseDtoFromJson(
  Map<String, dynamic> json,
) => OrderListResponseDto(
  status: json['status'] as bool,
  data: OrderListDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderListResponseDtoToJson(
  OrderListResponseDto instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

OrderCreateResponseDto _$OrderCreateResponseDtoFromJson(Map<String, dynamic> json) =>
    OrderCreateResponseDto(
      status: json['status'] as bool? ?? false,
      data: OrderResponseDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderCreateResponseDtoToJson(OrderCreateResponseDto instance) =>
    <String, dynamic>{'status': instance.status, 'data': instance.data};

OrderListDataDto _$OrderListDataDtoFromJson(Map<String, dynamic> json) =>
    OrderListDataDto(
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 0,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 0,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => OrderResponseDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );

Map<String, dynamic> _$OrderListDataDtoToJson(OrderListDataDto instance) =>
    <String, dynamic>{
      'total_items': instance.totalItems,
      'total_pages': instance.totalPages,
      'page_size': instance.pageSize,
      'current_page': instance.currentPage,
      'results': instance.results,
    };
