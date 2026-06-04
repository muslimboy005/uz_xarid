// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanResponseModel _$PlanResponseModelFromJson(Map<String, dynamic> json) =>
    PlanResponseModel(
      status: json['status'] as bool,
      data: PlanData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlanResponseModelToJson(PlanResponseModel instance) =>
    <String, dynamic>{'status': instance.status, 'data': instance.data};

PlanData _$PlanDataFromJson(Map<String, dynamic> json) => PlanData(
  results: (json['results'] as List<dynamic>)
      .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalItems: (json['total_items'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
  currentPage: (json['current_page'] as num).toInt(),
);

Map<String, dynamic> _$PlanDataToJson(PlanData instance) => <String, dynamic>{
  'results': instance.results,
  'total_items': instance.totalItems,
  'total_pages': instance.totalPages,
  'current_page': instance.currentPage,
};

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) => PlanModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  type: json['type'] as String? ?? '',
  price: json['price'] as String? ?? '0.00',
  discountPercent: json['discount_percent'] as String? ?? '0.00',
  finalPrice: json['final_price'] as String? ?? '0.00',
  currencyPrice: json['currency_price'] as String? ?? '0.00',
  currency: json['currency'] as String? ?? 'uzs',
  durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
  isUrgent: json['is_urgent'] as bool? ?? false,
  features:
      (json['features'] as List<dynamic>?)
          ?.map((e) => PlanFeatureModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isPurchased: json['is_purchased'] as bool? ?? false,
);

Map<String, dynamic> _$PlanModelToJson(PlanModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'price': instance.price,
  'discount_percent': instance.discountPercent,
  'final_price': instance.finalPrice,
  'currency_price': instance.currencyPrice,
  'currency': instance.currency,
  'duration_days': instance.durationDays,
  'is_active': instance.isActive,
  'is_urgent': instance.isUrgent,
  'features': instance.features,
  'is_purchased': instance.isPurchased,
};

PlanFeatureModel _$PlanFeatureModelFromJson(Map<String, dynamic> json) =>
    PlanFeatureModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isIncluded: json['is_included'] as bool,
    );

Map<String, dynamic> _$PlanFeatureModelToJson(PlanFeatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_included': instance.isIncluded,
    };
