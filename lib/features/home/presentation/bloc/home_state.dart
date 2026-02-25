part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    required this.selectedIndex,
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.categoryIdToChildren = const {},
    this.banners = const [],
    this.recommendations = const [],
    this.gifts = const [],
    this.services = const [],
    this.error,
  });

  final int selectedIndex;
  final HomeStatus status;
  final List<HomeCategory> categories;
  /// Turkum id → uning bolalari (product list subcategory strip uchun).
  final Map<int, List<HomeCategory>> categoryIdToChildren;
  final List<HomeBanner> banners;
  final List<HomeRecommendation> recommendations;
  final List<HomeRecommendation> gifts;
  final List<HomeRecommendation> services;
  final String? error;

  HomeState copyWith({
    int? selectedIndex,
    HomeStatus? status,
    List<HomeCategory>? categories,
    Map<int, List<HomeCategory>>? categoryIdToChildren,
    List<HomeBanner>? banners,
    List<HomeRecommendation>? recommendations,
    List<HomeRecommendation>? gifts,
    List<HomeRecommendation>? services,
    String? error,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      categoryIdToChildren: categoryIdToChildren ?? this.categoryIdToChildren,
      banners: banners ?? this.banners,
      recommendations: recommendations ?? this.recommendations,
      gifts: gifts ?? this.gifts,
      services: services ?? this.services,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    selectedIndex,
    status,
    categories,
    categoryIdToChildren,
    banners,
    recommendations,
    gifts,
    services,
    error,
  ];
}
