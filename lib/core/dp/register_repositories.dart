import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/favorites/data/datasources/favorites_api.dart';
import 'package:uz_xarid/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:uz_xarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uz_xarid/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/product_detail/data/datasources/product_detail_api.dart';
import 'package:uz_xarid/features/product_detail/data/repositories/product_detail_repository_impl.dart';
import 'package:uz_xarid/features/product_detail/domain/repositories/product_detail_repository.dart';
import 'package:uz_xarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uz_xarid/features/product_list/data/repositories/product_list_repository_impl.dart';
import 'package:uz_xarid/features/product_list/domain/repositories/product_list_repository.dart';
import 'package:uz_xarid/features/add_listing/data/datasources/listing_api.dart';
import 'package:uz_xarid/features/add_listing/data/repositories/listing_repository_impl.dart';
import 'package:uz_xarid/features/add_listing/domain/repositories/listing_repository.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/data/repositories/my_listings_repository_impl.dart';
import 'package:uz_xarid/features/profile/domain/repositories/my_listings_repository.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uz_xarid/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:uz_xarid/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:uz_xarid/features/author/data/datasources/author_api.dart';
import 'package:uz_xarid/features/author/data/repositories/author_repository_impl.dart';
import 'package:uz_xarid/features/author/domain/repositories/author_repository.dart';

Future<void> registerRepositories(GetIt getIt) async {
  getIt
    ..registerLazySingleton<ListingRepository>(
      () => ListingRepositoryImpl(
        api: getIt<ListingApi>(),
        dio: getIt<DioClient>().dio,
      ),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        homeApi: getIt<HomeApi>(),
        catalogApi: getIt<CatalogApi>(),
      ),
    )
    ..registerLazySingleton<ProductDetailRepository>(
      () => ProductDetailRepositoryImpl(api: getIt<ProductDetailApi>()),
    )
    ..registerLazySingleton<ProductListRepository>(
      () => ProductListRepositoryImpl(getIt<ProductListRemoteDatasource>()),
    )
    ..registerLazySingleton(
      () => ProfileRepository(getIt<ProfileApi>(), getIt<DioClient>().dio),
    )
    ..registerLazySingleton<MyListingsRepository>(
      () => MyListingsRepositoryImpl(dio: getIt<DioClient>().dio),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        api: getIt<FavoritesApi>(),
        localDatasource: getIt<FavoritesLocalDatasource>(),
        secureStorage: getIt<SecureStorageService>(),
      ),
    )
    ..registerLazySingleton<AuthorRepository>(
      () => AuthorRepositoryImpl(remoteDataSource: getIt<AuthorApi>()),
    );
  log("Register Repositories Complate For GetIT");
}
