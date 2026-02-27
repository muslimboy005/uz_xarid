import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/features/add_listing/domain/repositories/listing_repository.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_colors.dart';
import 'package:uz_xarid/features/add_listing/domain/usecases/get_sizes.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_ads_by_category.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/product_detail/domain/repositories/product_detail_repository.dart';
import 'package:uz_xarid/features/product_detail/domain/usecases/get_ad_detail.dart';
import 'package:uz_xarid/features/product_list/domain/repositories/product_list_repository.dart';
import 'package:uz_xarid/features/product_list/domain/usecases/get_product_list.dart';
import 'package:uz_xarid/features/product_list/domain/usecases/get_subcategories_by_category_id.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uz_xarid/features/profile/domain/usecase/profile_usecase.dart';
import 'package:uz_xarid/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:uz_xarid/features/favorites/domain/usecases/get_favorites_list.dart';
import 'package:uz_xarid/features/favorites/domain/usecases/toggle_favorite.dart';

Future<void> registerUseCases(GetIt getIt) async {
  getIt
    ..registerLazySingleton<GetColors>(
      () => GetColors(getIt<ListingRepository>()),
    )
    ..registerLazySingleton<GetSizes>(
      () => GetSizes(getIt<ListingRepository>()),
    )
    ..registerLazySingleton<GetCategories>(
      () => GetCategories(getIt<CatalogRepository>()),
    )
    ..registerLazySingleton<GetAdsByCategory>(
      () => GetAdsByCategory(getIt<CatalogRepository>()),
    )
    ..registerLazySingleton<GetAdDetail>(
      () => GetAdDetail(getIt<ProductDetailRepository>()),
    )
    ..registerLazySingleton<GetProductList>(
      () => GetProductList(getIt<ProductListRepository>()),
    )
    ..registerLazySingleton<GetSubcategoriesByCategoryId>(
      () => GetSubcategoriesByCategoryId(getIt<CatalogRepository>()),
    )
    ..registerLazySingleton<ProfileSendOtpUsecase>(
      () => ProfileSendOtpUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileConfirmOtpUsecase>(
      () => ProfileConfirmOtpUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileSignSubmitUsecase>(
      () => ProfileSignSubmitUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileGetUsecase>(
      () => ProfileGetUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileResendOtpUsecase>(
      () => ProfileResendOtpUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileUpdateUsecase>(
      () => ProfileUpdateUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileCreateBusinessUsecase>(
      () => ProfileCreateBusinessUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileUpdateBusinessUsecase>(
      () => ProfileUpdateBusinessUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<GetCategoriesParams>(() => GetCategoriesParams())
    ..registerLazySingleton<GetFavoritesList>(
      () => GetFavoritesList(getIt<FavoritesRepository>()),
    )
    ..registerLazySingleton<ToggleFavorite>(
      () => ToggleFavorite(getIt<FavoritesRepository>()),
    )
    ..registerLazySingleton<ProfileGetAddressesUsecase>(
      () => ProfileGetAddressesUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileCreateAddressUsecase>(
      () => ProfileCreateAddressUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileUpdateAddressUsecase>(
      () => ProfileUpdateAddressUsecase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<ProfileDeleteAddressUsecase>(
      () => ProfileDeleteAddressUsecase(getIt<ProfileRepository>()),
    );
  log("Register Use Cases Complate For GetIT");
}
