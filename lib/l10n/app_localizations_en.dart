// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Uz Xarid';

  @override
  String get homeTitle => 'Uz Xarid';

  @override
  String get homeSubtitle => 'Find products quickly and easily';

  @override
  String get homeBody =>
      'Clean Architecture (DDD) structure is ready for your project.';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get catalogBody => 'Products catalog will appear here.';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesBody => 'Your favorite products will appear here.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileBody => 'Profile information will appear here.';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchHint => 'Search...';
}
