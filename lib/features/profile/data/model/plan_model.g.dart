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
  price: json['price'] as String,
  isActive: json['is_active'] as bool,
  features: (json['features'] as List<dynamic>)
      .map((e) => PlanFeatureModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  isPurchased: json['is_purchased'] as bool,
);

Map<String, dynamic> _$PlanModelToJson(PlanModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'is_active': instance.isActive,
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
