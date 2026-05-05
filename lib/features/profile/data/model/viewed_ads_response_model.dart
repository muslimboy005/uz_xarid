import 'package:uz_xarid/features/product_list/data/models/product_list_item_dto.dart';

class ViewedAdsResponseModel {
  final bool status;
  final ViewedAdsData data;

  ViewedAdsResponseModel({required this.status, required this.data});

  factory ViewedAdsResponseModel.fromJson(Map<String, dynamic> json) {
    return ViewedAdsResponseModel(
      status: json['status'] ?? false,
      data: ViewedAdsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ViewedAdsData {
  final int totalItems;
  final int totalPages;
  final int pageSize;
  final int currentPage;
  final List<ProductListItemDto> results;
  final String? next;
  final String? previous;

  ViewedAdsData({
    required this.totalItems,
    required this.totalPages,
    required this.pageSize,
    required this.currentPage,
    required this.results,
    this.next,
    this.previous,
  });

  factory ViewedAdsData.fromJson(Map<String, dynamic> json) {
    final links = json['links'] ?? {};
    return ViewedAdsData(
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      next: links['next'],
      previous: links['previous'],
      results: json['results'] != null
          ? List<ProductListItemDto>.from(
              json['results'].map((x) {
                final adJson = x['ad'] ?? x;
                return ProductListItemDto.fromJson(adJson);
              }),
            )
          : [],
    );
  }
}
