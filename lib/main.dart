import 'package:flutter/material.dart';
import 'package:uz_xarid/app/app.dart';
import 'package:uz_xarid/core/app_config.dart';
import 'package:uz_xarid/core/dp/infection.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:uz_xarid/core/service/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseService.init();
  await setupDependencies();
  AppConfig.packageName = null; // Standalone mode
  runApp(const UzXaridApp());
}
