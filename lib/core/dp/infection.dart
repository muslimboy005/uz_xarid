import 'dart:developer';

import 'package:get_it/get_it.dart';

import 'register_blocs.dart';
import 'register_repositories.dart';
import 'register_datasources.dart';
import 'register_services.dart';
import 'register_usecases.dart';

final GetIt getIt = GetIt.instance;
bool _isDependenciesRegistered = false;

Future<void> setupDependencies() async {
  if (_isDependenciesRegistered) return;

  await registerServices(getIt);
  await registerDataSources(getIt);
  await registerRepositories(getIt);
  await registerUseCases(getIt);
  await registerBlocs(getIt);

  _isDependenciesRegistered = true;
  log("All Register Complete For GetIT");
}
