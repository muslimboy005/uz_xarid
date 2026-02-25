import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
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
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

Future<void> registerRepositories(GetIt getIt) async {
  getIt
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
    );
  log("Register Repositories Complate For GetIT");
}
