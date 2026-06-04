import 'package:json_annotation/json_annotation.dart';
import 'package:uzxarid/features/profile/data/model/plan_model.dart';

part 'plan_history_model.g.dart';

@JsonSerializable()
class PlanHistoryResponseModel {
  final bool status;
  final PlanHistoryData data;

  PlanHistoryResponseModel({required this.status, required this.data});

  factory PlanHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanHistoryResponseModelFromJson(json);
}

@JsonSerializable()
class PlanHistoryData {
  final List<PlanHistoryItemModel> results;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'current_page')
  final int currentPage;

  PlanHistoryData({
    required this.results,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory PlanHistoryData.fromJson(Map<String, dynamic> json) =>
      _$PlanHistoryDataFromJson(json);
}

@JsonSerializable()
class PlanHistoryItemModel {
  final int id;
  @JsonKey(name: 'order_type')
  final String orderType;
  @JsonKey(name: 'user_plan')
  final PlanModel? userPlan;
  final String amount;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @JsonKey(name: 'payment_link')
  final String? paymentLink;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  PlanHistoryItemModel({
    required this.id,
    this.orderType = '',
    this.userPlan,
    this.amount = '0.00',
    this.paymentMethod,
    this.paymentStatus = '',
    this.paymentDate,
    this.paymentLink,
    this.createdAt,
  });

  /// Tarif nomi (ichki `user_plan` obyektidan).
  String get planName => userPlan?.name ?? '';

  factory PlanHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$PlanHistoryItemModelFromJson(json);
}
