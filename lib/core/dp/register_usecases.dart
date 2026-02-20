import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:uz_xarid/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:uz_xarid/features/catalog/domain/usecases/get_categories.dart';
import 'package:uz_xarid/features/profile/domain/repositories/profile_repository.dart';
import 'package:uz_xarid/features/profile/domain/usecase/profile_usecase.dart';

Future<void> registerUseCases(GetIt getIt) async {
  getIt
    ..registerLazySingleton<GetCategories>(
      () => GetCategories(getIt<CatalogRepository>()),
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
    );
  log("Register Use Cases Complate For GetIT");
}
