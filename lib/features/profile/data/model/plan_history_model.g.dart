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
  orderType: json['order_type'] as String? ?? '',
  userPlan: json['user_plan'] == null
      ? null
      : PlanModel.fromJson(json['user_plan'] as Map<String, dynamic>),
  amount: json['amount'] as String? ?? '0.00',
  paymentMethod: json['payment_method'] as String?,
  paymentStatus: json['payment_status'] as String? ?? '',
  paymentDate: json['payment_date'] as String?,
  paymentLink: json['payment_link'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$PlanHistoryItemModelToJson(
  PlanHistoryItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_type': instance.orderType,
  'user_plan': instance.userPlan,
  'amount': instance.amount,
  'payment_method': instance.paymentMethod,
  'payment_status': instance.paymentStatus,
  'payment_date': instance.paymentDate,
  'payment_link': instance.paymentLink,
  'created_at': instance.createdAt,
};
