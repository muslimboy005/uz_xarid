import 'package:flutter/material.dart';

import 'package:uz_xarid/core/theme/app_theme.dart';
import 'package:uz_xarid/features/home/presentation/pages/home_page.dart';

class UzXaridApp extends StatelessWidget {
  const UzXaridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uz Xarid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

