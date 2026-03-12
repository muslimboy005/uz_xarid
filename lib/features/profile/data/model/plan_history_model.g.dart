// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanHistoryResponseModel _$PlanHistoryResponseModelFromJson(
  Map<String, dynamic> json,
) => PlanHistoryResponseModel(
  status: json['status'] as bool,
  data: PlanHistoryData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlanHistoryResponseModelToJson(
  PlanHistoryResponseModel instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

PlanHistoryData _$PlanHistoryDataFromJson(Map<String, dynamic> json) =>
    PlanHistoryData(
      results: (json['results'] as List<dynamic>)
          .map((e) => PlanHistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['total_items'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
    );

Map<String, dynamic> _$PlanHistoryDataToJson(PlanHistoryData instance) =>
    <String, dynamic>{
      'results': instance.results,
      'total_items': instance.totalItems,
      'total_pages': instance.totalPages,
      'current_page': instance.currentPage,
    };

PlanHistoryItemModel _$PlanHistoryItemModelFromJson(
  Map<String, dynamic> json,
) => PlanHistoryItemModel(
  id: (json['id'] as num).toInt(),
  planName: json['plan_name'] as String,
  amount: json['amount'] as String,
  status: json['status'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$PlanHistoryItemModelToJson(
  PlanHistoryItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'plan_name': instance.planName,
  'amount': instance.amount,
  'status': instance.status,
  'created_at': instance.createdAt,
};
