
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

Future<void> registerServices(GetIt getIt) async {
  getIt
    .registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );

  log("Register Services Complete For GetIT");
}
