import 'package:flutter/material.dart';

/// Simple localization class supporting `en`, `ru`, and `uz`.
///
/// This does not rely on code generation and keeps all copy in a single map,
/// but is wired through Flutter's localization system so it can be accessed
/// with `AppLocalizations.of(context)`.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('ru'),
    Locale('uz'),
    Locale('en'),
  ];

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appName': 'Uz Xarid',
      'homeTitle': 'Uz Xarid',
      'homeSubtitle': 'Find products quickly and easily',
      'homeBody':
          'Clean Architecture (DDD) structure is ready for your project.',
      'catalogTitle': 'Catalog',
      'catalogBody': 'Products catalog will appear here.',
      'favoritesTitle': 'Favorites',
      'favoritesBody': 'Your favorite products will appear here.',
      'profileTitle': 'Profile',
      'profileBody': 'Profile information will appear here.',
      'navHome': 'Home',
      'navCatalog': 'Catalog',
      'navFavorites': 'Favorites',
      'navProfile': 'Profile',
      'searchHint': 'Search...',
    },
    'ru': {
      'appName': 'Uz Xarid',
      'homeTitle': 'Uz Xarid',
      'homeSubtitle': 'Найдите товары быстро и удобно',
      'homeBody': 'Структура Clean Architecture (DDD) уже подготовлена.',
      'catalogTitle': 'Каталог',
      'catalogBody': 'Каталог товаров будет отображаться здесь.',
      'favoritesTitle': 'Избранные',
      'favoritesBody': 'Ваши избранные товары будут здесь.',
      'profileTitle': 'Профиль',
      'profileBody': 'Информация профиля будет отображаться здесь.',
      'navHome': 'Главная',
      'navCatalog': 'Каталог',
      'navFavorites': 'Избранные',
      'navProfile': 'Профиль',
      'searchHint': 'Искать...',
    },
    'uz': {
      'appName': 'Uz Xarid',
      'homeTitle': 'Uz Xarid',
      'homeSubtitle': 'Mahsulotlarni qulay va tez toping',
      'homeBody': 'Clean Architecture (DDD) struktura tayyor.',
      'catalogTitle': 'Katalog',
      'catalogBody': 'Mahsulotlar katalogi shu yerda bo‘ladi.',
      'favoritesTitle': 'Sevimlilar',
      'favoritesBody': 'Sevimli mahsulotlaringiz shu yerda bo‘ladi.',
      'profileTitle': 'Profil',
      'profileBody': 'Profil ma’lumotlari shu yerda bo‘ladi.',
      'navHome': 'Bosh sahifa',
      'navCatalog': 'Katalog',
      'navFavorites': 'Sevimlilar',
      'navProfile': 'Profil',
      'searchHint': 'Qidirish...',
    },
  };

  String _text(String key) {
    final languageCode = locale.languageCode;
    final values = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return values[key] ?? _localizedValues['en']![key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Exposed getters
  String get appName => _text('appName');
  String get homeTitle => _text('homeTitle');
  String get homeSubtitle => _text('homeSubtitle');
  String get homeBody => _text('homeBody');

  String get catalogTitle => _text('catalogTitle');
  String get catalogBody => _text('catalogBody');

  String get favoritesTitle => _text('favoritesTitle');
  String get favoritesBody => _text('favoritesBody');

  String get profileTitle => _text('profileTitle');
  String get profileBody => _text('profileBody');

  String get navHome => _text('navHome');
  String get navCatalog => _text('navCatalog');
  String get navFavorites => _text('navFavorites');
  String get navProfile => _text('navProfile');

  String get searchHint => _text('searchHint');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) =>
      false;
}

