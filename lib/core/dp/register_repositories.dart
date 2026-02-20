import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

Future<void> registerRepositories(GetIt getIt) async {
  getIt
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(homeApi: getIt<HomeApi>()),
    )
    ..registerLazySingleton(
      () => ProfileRepository(getIt<ProfileApi>(), getIt<DioClient>().dio),
    );
  log("Register Repositories Complate For GetIT");
}
