import 'package:flutter/material.dart';

import 'package:uz_xarid/app/router/app_router.dart';
import 'package:uz_xarid/core/constants/app_strings.dart';
import 'package:uz_xarid/core/theme/app_theme.dart';

class UzXaridApp extends StatelessWidget {
  const UzXaridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
