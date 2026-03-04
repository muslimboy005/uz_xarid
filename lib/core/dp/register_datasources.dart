import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/product_detail/data/datasources/product_detail_api.dart';
import 'package:uz_xarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uz_xarid/features/search/data/datasources/search_api.dart';
import 'package:uz_xarid/features/favorites/data/datasources/favorites_api.dart';
import 'package:uz_xarid/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:uz_xarid/features/author/data/datasources/author_api.dart';

Future<void> registerDataSources(GetIt getIt) async {
  getIt
    ..registerLazySingleton<ListingApi>(
      () => ListingApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<DioClient>(() => DioClient())
    ..registerLazySingleton<CatalogApi>(
      () => CatalogApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<HomeApi>(() => HomeApi(getIt<DioClient>().dio))
    ..registerLazySingleton<ProductDetailApi>(
      () => ProductDetailApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<SearchApi>(() => SearchApi(getIt<DioClient>().dio))
    ..registerLazySingleton<ProductListRemoteDatasource>(
      () => ProductListRemoteDatasourceImpl(
        homeApi: getIt<HomeApi>(),
        catalogApi: getIt<CatalogApi>(),
        searchApi: getIt<SearchApi>(),
      ),
    )
    ..registerLazySingleton<ProfileApi>(
      () => ProfileApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<FavoritesApi>(
      () => FavoritesApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<FavoritesLocalDatasource>(
      () => FavoritesLocalDatasourceImpl(prefs: getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<AuthorApi>(() => AuthorApi(getIt<DioClient>().dio));
  log("Register Datasource Complate For GetIT");
}
