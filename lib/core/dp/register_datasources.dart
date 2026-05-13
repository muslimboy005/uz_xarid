import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uzxarid/features/catalog/data/datasources/category_children_api.dart';
import 'package:uzxarid/features/home/data/datasources/home_api.dart';
import 'package:uzxarid/features/product_detail/data/datasources/product_detail_api.dart';
import 'package:uzxarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uzxarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uzxarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uzxarid/features/search/data/datasources/search_api.dart';
import 'package:uzxarid/features/favorites/data/datasources/favorites_api.dart';
import 'package:uzxarid/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:uzxarid/features/author/data/datasources/author_api.dart';
import 'package:uzxarid/features/order/data/datasources/order_api.dart';
import 'package:uzxarid/features/chat/data/datasources/chat_api.dart';

import 'package:uzxarid/features/cart/data/datasources/cart_api.dart';
import 'package:uzxarid/features/cart/data/datasources/cart_remote_data_source.dart';

Future<void> registerDataSources(GetIt getIt) async {
  getIt
    ..registerLazySingleton<CartApi>(() => CartApi(getIt<DioClient>().dio))
    ..registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(cartApi: getIt<CartApi>()),
    )
    ..registerLazySingleton<ListingApi>(
      () => ListingApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<DioClient>(() => DioClient())
    ..registerLazySingleton<CatalogApi>(
      () => CatalogApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<HomeApi>(() => HomeApi(getIt<DioClient>().dio))
    ..registerLazySingleton<CategoryChildrenApi>(
      () => CategoryChildrenApi(
        getIt<DioClient>().dio,
        baseUrl: ApiUrls.baseUrlV2,
      ),
    )
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
    ..registerLazySingleton<AuthorApi>(() => AuthorApi(getIt<DioClient>().dio))
    ..registerLazySingleton<OrderApi>(() => OrderApi(getIt<DioClient>().dio))
    ..registerLazySingleton<ChatApi>(() => ChatApi(getIt<DioClient>().dio));
  log("Register Datasource Complate For GetIT");
}
