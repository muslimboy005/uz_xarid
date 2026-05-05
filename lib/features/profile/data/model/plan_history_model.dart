import 'package:json_annotation/json_annotation.dart';

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
  @JsonKey(name: 'plan_name')
  final String planName;
  @JsonKey(name: 'amount')
  final String amount;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;

  PlanHistoryItemModel({
    required this.id,
    required this.planName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PlanHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$PlanHistoryItemModelFromJson(json);
}
