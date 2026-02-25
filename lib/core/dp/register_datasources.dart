import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/features/catalog/data/datasources/catalog_api.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/product_detail/data/datasources/product_detail_api.dart';
import 'package:uz_xarid/features/product_list/data/datasources/product_list_remote_datasource.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';

Future<void> registerDataSources(GetIt getIt) async {
  getIt
    ..registerLazySingleton<DioClient>(() => DioClient())
    ..registerLazySingleton<CatalogApi>(
      () => CatalogApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<HomeApi>(
      () => HomeApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<ProductDetailApi>(
      () => ProductDetailApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<ProductListRemoteDatasource>(
      () => ProductListRemoteDatasourceImpl(
        homeApi: getIt<HomeApi>(),
        catalogApi: getIt<CatalogApi>(),
      ),
    )
    ..registerLazySingleton<ProfileApi>(
      () => ProfileApi(getIt<DioClient>().dio),
    );
  log("Register Datasource Complate For GetIT");
}