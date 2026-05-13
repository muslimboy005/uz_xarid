import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:uzxarid/app/router/app_router.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/localization/locale_cubit.dart';
import 'package:uzxarid/core/theme/app_theme.dart';
import 'package:uzxarid/core/theme/theme_cubit.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_event.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class UzXaridApp extends StatelessWidget {
  const UzXaridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()..load()),
        BlocProvider(create: (_) => ThemeCubit()..load()),
        BlocProvider(create: (_) => AppModeCubit()..load()),
        BlocProvider(
          create: (_) =>
              getIt<FavoritesBloc>()..add(const FavoritesLoadListRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<CartBloc>()..add(CartLoadRequested()),
        ),
        BlocProvider<CurrencyCubit>(
          create: (_) => getIt<CurrencyCubit>()..load(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<AppModeCubit, AppMode>(
              builder: (context, appMode) {
                final primary = appMode.primaryColor;
                return ScreenUtilInit(
                  child: MaterialApp.router(
                    onGenerateTitle: (context) =>
                        AppLocalizations.of(context)!.appName,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light(primary: primary),
                    darkTheme: AppTheme.dark(primary: primary),
                    themeMode: themeMode,
                    routerConfig: AppRouter.router,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
