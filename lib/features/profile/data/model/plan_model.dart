import 'package:json_annotation/json_annotation.dart';

part 'plan_model.g.dart';

@JsonSerializable()
class PlanResponseModel {
  final bool status;
  final PlanData data;

  PlanResponseModel({required this.status, required this.data});

  factory PlanResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PlanResponseModelFromJson(json);
}

@JsonSerializable()
class PlanData {
  final List<PlanModel> results;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'current_page')
  final int currentPage;

  PlanData({
    required this.results,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) =>
      _$PlanDataFromJson(json);
}

@JsonSerializable()
class PlanModel {
  final int id;
  final String name;
  final String price;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<PlanFeatureModel> features;
  @JsonKey(name: 'is_purchased')
  final bool isPurchased;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    required this.features,
    required this.isPurchased,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);
}

@JsonSerializable()
class PlanFeatureModel {
  final int id;
  final String name;
  @JsonKey(name: 'is_included')
  final bool isIncluded;

  PlanFeatureModel({
    required this.id,
    required this.name,
    required this.isIncluded,
  });

  factory PlanFeatureModel.fromJson(Map<String, dynamic> json) =>
      _$PlanFeatureModelFromJson(json);
}
