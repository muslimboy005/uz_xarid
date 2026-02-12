import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:uz_xarid/app/router/app_router.dart';
import 'package:uz_xarid/core/constants/app_strings.dart';
import 'package:uz_xarid/core/localization/app_localizations.dart';
import 'package:uz_xarid/core/theme/app_theme.dart';

class UzXaridApp extends StatefulWidget {
  const UzXaridApp({super.key});

  /// Helper to access the state from anywhere in the widget tree, e.g. to
  /// update the current locale from the app bar language selector.
  static _UzXaridAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_UzXaridAppState>()!;
  }

  @override
  State<UzXaridApp> createState() => _UzXaridAppState();
}

class _UzXaridAppState extends State<UzXaridApp> {
  Locale _locale = const Locale('ru');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

