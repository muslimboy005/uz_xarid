
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uz_xarid/core/service/local_service.dart';

Future<void> registerServices(GetIt getIt) async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerLazySingleton<SharedPreferences>(() => prefs)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(storage: getIt<FlutterSecureStorage>()),
    );

  log("Register Services Complete For GetIT");
}
