import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uzxarid/app/app.dart';
import 'package:uzxarid/core/app_config.dart';
import 'package:uzxarid/core/dp/infection.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:uzxarid/core/service/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await FirebaseService.init();
  await setupDependencies();
  AppConfig.packageName = null; // Standalone mode
  runApp(const UzXaridApp());
}
