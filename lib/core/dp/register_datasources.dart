import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/features/home/data/datasources/home_api.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';

Future<void> registerDataSources(GetIt getIt) async {
  getIt
    ..registerLazySingleton<DioClient>(() => DioClient())
    ..registerLazySingleton<HomeApi>(
      () => HomeApi(getIt<DioClient>().dio),
    )
    ..registerLazySingleton<ProfileApi>(
      () => ProfileApi(getIt<DioClient>().dio),
    );
  log("Register Datasource Complate For GetIT");
}