import 'package:flutter/material.dart';
import 'package:uz_xarid/app/app.dart';
import 'package:uz_xarid/core/dp/infection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await setupDependencies();
  runApp(const UzXaridApp());
}
