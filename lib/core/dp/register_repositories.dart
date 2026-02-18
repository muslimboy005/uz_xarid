import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/features/profile/data/datasource/profile_datasource.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';

Future<void> registerRepositories(GetIt getIt) async {
  getIt
    .registerLazySingleton(() => ProfileRepository(getIt<ProfileApi>()));
  log("Register Repositories Complate For GetIT");
}