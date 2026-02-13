import 'dart:developer';

import 'package:get_it/get_it.dart';

import 'register_blocs.dart';
import 'register_repositories.dart';
import 'register_datasources.dart';
import 'register_services.dart';
import 'register_usecases.dart';

final GetIt getIt = GetIt.instance;
Future<void> setupDependencies() async {
  await registerServices(getIt);
  await registerDataSources(getIt);
  await registerRepositories(getIt);
  await registerUseCases(getIt);
  await registerBlocs(getIt);

  log("All Register Complate For GetIT");
}
