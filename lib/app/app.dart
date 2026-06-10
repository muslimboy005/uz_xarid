import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:uzxarid/app/router/app_router.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/widgets/shake_detector.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/localization/locale_cubit.dart';
import 'package:uzxarid/core/theme/app_theme.dart';
import 'package:uzxarid/core/theme/theme_cubit.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_event.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

/// AI yordamchi ekrani allaqachon ochiqligini kuzatuvchi bayroq —
/// silkitishda ustma-ust ochilib ketmasligi uchun.
bool _aiAssistantOpen = false;

/// Qurilma silkitilganda AI yordamchi ekranini ochadi (global router orqali).
void _openAiAssistant() {
  if (_aiAssistantOpen) return;
  _aiAssistantOpen = true;
  AppRouter.router
      .pushNamed('ai-assistant')
      .whenComplete(() => _aiAssistantOpen = false);
}

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
        // Badge'ni HomePage initState() o'zi yuklaydi (har home ochilganda
        // yangilanadi) — bu yerda takroran yuklamaymiz.
        BlocProvider(
          create: (_) => getIt<NotificationBloc>(),
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
                  child: ShakeDetector(
                    onShake: _openAiAssistant,
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
                      // kaa/tg uchun Material/Cupertino lokalizatsiyasi yo'q —
                      // qo'llab-quvvatlanadigan tilga (kaa→uz, tg→ru) yo'naltiramiz.
                      _FallbackMaterialLocalizationsDelegate(),
                      _FallbackCupertinoLocalizationsDelegate(),
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    ),
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

/// kaa/tg kabi tillar Flutter'ning Material/Cupertino lokalizatsiyasida yo'q.
/// Shu tillar uchun eng yaqin qo'llab-quvvatlanadigan tilni qaytaramiz.
Locale _materialFallbackLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'kaa':
      return const Locale('uz');
    case 'tg':
      return const Locale('ru');
    default:
      return const Locale('ru');
  }
}

/// Faqat global delegat qo'llab-quvvatlamaydigan tillar uchun ishlaydi va
/// Material lokalizatsiyasini fallback tildan yuklaydi (crash o'rniga).
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      !GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_materialFallbackLocale(locale));

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      !GlobalCupertinoLocalizations.delegate.isSupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_materialFallbackLocale(locale));

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}
