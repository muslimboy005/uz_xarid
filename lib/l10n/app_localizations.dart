import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Uz Xarid'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Uz Xarid'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find products quickly and easily'**
  String get homeSubtitle;

  /// No description provided for @homeBody.
  ///
  /// In en, this message translates to:
  /// **'Clean Architecture (DDD) structure is ready for your project.'**
  String get homeBody;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// No description provided for @catalogBody.
  ///
  /// In en, this message translates to:
  /// **'Products catalog will appear here.'**
  String get catalogBody;

  /// No description provided for @productsNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Products not found'**
  String get productsNotFoundTitle;

  /// No description provided for @productsNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We could not find products according to your query.\nPlease try again.'**
  String get productsNotFoundSubtitle;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Your favorite products will appear here.'**
  String get favoritesBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileBody.
  ///
  /// In en, this message translates to:
  /// **'Profile information will appear here.'**
  String get profileBody;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchFindByCategory.
  ///
  /// In en, this message translates to:
  /// **'Find by category'**
  String get searchFindByCategory;

  /// No description provided for @searchFrequentlySearched.
  ///
  /// In en, this message translates to:
  /// **'Frequently searched'**
  String get searchFrequentlySearched;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find. Buy. Sell.'**
  String get homeHeadline;

  /// No description provided for @categoryGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods & shopping'**
  String get categoryGoods;

  /// No description provided for @categoryConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get categoryConstruction;

  /// No description provided for @categoryAutoMoto.
  ///
  /// In en, this message translates to:
  /// **'Auto & moto'**
  String get categoryAutoMoto;

  /// No description provided for @categoryServices.
  ///
  /// In en, this message translates to:
  /// **'Services & jobs'**
  String get categoryServices;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendationsTitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get seeAll;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @topTag.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get topTag;

  /// No description provided for @reviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviewsLabel;

  /// No description provided for @dataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get dataLoadError;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @adAuthorTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad author'**
  String get adAuthorTitle;

  /// No description provided for @adAuthorOtherAds.
  ///
  /// In en, this message translates to:
  /// **'Other ads by the author'**
  String get adAuthorOtherAds;

  /// No description provided for @adAuthorOnPlatformSince.
  ///
  /// In en, this message translates to:
  /// **'On the platform since {date}'**
  String adAuthorOnPlatformSince(String date);

  /// No description provided for @tabFullInfo.
  ///
  /// In en, this message translates to:
  /// **'Full info'**
  String get tabFullInfo;

  /// No description provided for @tabReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get tabReviews;

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews are not yet available'**
  String get reviewsEmptySubtitle;

  /// No description provided for @reviewsWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewsWriteReview;

  /// No description provided for @productDetailErrorDefault.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get productDetailErrorDefault;

  /// No description provided for @productDetailColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color:'**
  String get productDetailColorLabel;

  /// No description provided for @productDetailSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size:'**
  String get productDetailSizeLabel;

  /// No description provided for @productDetailCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get productDetailCall;

  /// No description provided for @productDetailTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get productDetailTelegram;

  /// No description provided for @productDetailPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get productDetailPlaceOrder;

  /// No description provided for @productDetailFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get productDetailFeatures;

  /// No description provided for @productDetailSimilarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar products'**
  String get productDetailSimilarProducts;

  /// No description provided for @giftHeadline.
  ///
  /// In en, this message translates to:
  /// **'Perfect gifts for everyone'**
  String get giftHeadline;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services nearby'**
  String get servicesTitle;

  /// No description provided for @servicesSeeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get servicesSeeAll;

  /// No description provided for @productListFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get productListFilters;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// No description provided for @sortCheaper.
  ///
  /// In en, this message translates to:
  /// **'Cheaper'**
  String get sortCheaper;

  /// No description provided for @sortExpensive.
  ///
  /// In en, this message translates to:
  /// **'More expensive'**
  String get sortExpensive;

  /// No description provided for @sortHighRating.
  ///
  /// In en, this message translates to:
  /// **'High rating'**
  String get sortHighRating;

  /// No description provided for @servicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get servicesEmptyTitle;

  /// No description provided for @servicesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sorry! No services around you'**
  String get servicesEmptySubtitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get actionGo;

  /// No description provided for @actionLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get actionLogout;

  /// No description provided for @profileBasicAccount.
  ///
  /// In en, this message translates to:
  /// **'Basic account'**
  String get profileBasicAccount;

  /// No description provided for @profileVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get profileVerifyAccount;

  /// No description provided for @profileMenuPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get profileMenuPersonalData;

  /// No description provided for @profileMenuMyAds.
  ///
  /// In en, this message translates to:
  /// **'My ads'**
  String get profileMenuMyAds;

  /// No description provided for @profileMenuMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get profileMenuMyOrders;

  /// No description provided for @profileMenuFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileMenuFavorites;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuMyBusiness.
  ///
  /// In en, this message translates to:
  /// **'My business'**
  String get profileMenuMyBusiness;

  /// No description provided for @profileMenuMyAddresses.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get profileMenuMyAddresses;

  /// No description provided for @profileMenuPayment.
  ///
  /// In en, this message translates to:
  /// **'Payments and tariffs'**
  String get profileMenuPayment;

  /// No description provided for @profileMenuSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileMenuSupport;

  /// No description provided for @profileMenuViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get profileMenuViewHistory;

  /// No description provided for @profileMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileMenuSettings;

  /// No description provided for @profileBecomeBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a business\nuser'**
  String get profileBecomeBusinessTitle;

  /// No description provided for @profileLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of account?'**
  String get profileLogoutDialogTitle;

  /// No description provided for @profileLogoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutDialogMessage;

  /// No description provided for @profileAuthBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why sign in?'**
  String get profileAuthBenefitsTitle;

  /// No description provided for @profileBenefitOfferServices.
  ///
  /// In en, this message translates to:
  /// **'Offer your own services'**
  String get profileBenefitOfferServices;

  /// No description provided for @profileBenefitUseServices.
  ///
  /// In en, this message translates to:
  /// **'Use services from other users'**
  String get profileBenefitUseServices;

  /// No description provided for @profileBenefitExclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive offers just for you'**
  String get profileBenefitExclusive;

  /// No description provided for @profileBenefitAdsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Post ads and manage favorites'**
  String get profileBenefitAdsFavorites;

  /// No description provided for @profileAuthCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create profile'**
  String get profileAuthCta;

  /// No description provided for @profileAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Buy, sell, and use services! Post ads, find what you need, and add to favorites.'**
  String get profileAuthDescription;

  /// No description provided for @loginSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Account login'**
  String get loginSheetTitle;

  /// No description provided for @loginSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to the entered number via SMS.'**
  String get loginSheetDescription;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+998 90 123-45-67'**
  String get loginPhoneHint;

  /// No description provided for @loginPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter the full phone number'**
  String get loginPhoneError;

  /// No description provided for @loginGetCode.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get loginGetCode;

  /// No description provided for @loginPolicyPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing in you agree to the '**
  String get loginPolicyPrefix;

  /// No description provided for @loginPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'personal data processing policy'**
  String get loginPolicyLink;

  /// No description provided for @loginPolicySuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get loginPolicySuffix;

  /// No description provided for @otpSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpSheetTitle;

  /// No description provided for @otpSentToNumber.
  ///
  /// In en, this message translates to:
  /// **'The code was sent to your phone number {phone}. Please check the SMS.'**
  String otpSentToNumber(Object phone);

  /// No description provided for @otpInputError.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit SMS code'**
  String get otpInputError;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Send code again'**
  String get otpResend;

  /// No description provided for @otpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Send code again ({seconds})'**
  String otpResendCountdown(Object seconds);

  /// No description provided for @nameSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get nameSheetTitle;

  /// No description provided for @nameSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile is almost ready—please introduce yourself'**
  String get nameSheetSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get lastNameHint;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter first and last name'**
  String get nameRequiredError;

  /// No description provided for @personalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get personalDataTitle;

  /// No description provided for @contactDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact data'**
  String get contactDataTitle;

  /// No description provided for @addressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+998 XX XXX-XX-XX'**
  String get phoneHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get emailHint;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get cityHint;

  /// No description provided for @streetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get streetLabel;

  /// No description provided for @streetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter street'**
  String get streetHint;

  /// No description provided for @houseLabel.
  ///
  /// In en, this message translates to:
  /// **'House / Apartment'**
  String get houseLabel;

  /// No description provided for @houseHint.
  ///
  /// In en, this message translates to:
  /// **'House / Apartment'**
  String get houseHint;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @districtHint.
  ///
  /// In en, this message translates to:
  /// **'Enter district'**
  String get districtHint;

  /// No description provided for @profilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoLabel;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderHint.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get genderHint;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDateLabel;

  /// No description provided for @birthDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'DD.MM.YYYY'**
  String get birthDatePlaceholder;

  /// No description provided for @myOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrdersTitle;

  /// No description provided for @myRequestsTab.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequestsTab;

  /// No description provided for @myOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrdersTab;

  /// No description provided for @myOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders yet.'**
  String get myOrdersEmptyTitle;

  /// No description provided for @myOrdersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place your first order and see how convenient it is!'**
  String get myOrdersEmptySubtitle;

  /// No description provided for @favoritesProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesProfileTitle;

  /// No description provided for @favoritesTab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTab;

  /// No description provided for @savedFilterTab.
  ///
  /// In en, this message translates to:
  /// **'Saved filter'**
  String get savedFilterTab;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add ads to favorites'**
  String get favoritesEmptySubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsContractsTab.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get notificationsContractsTab;

  /// No description provided for @notificationsSystemTab.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsSystemTab;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications will appear here as soon as they are available'**
  String get notificationsEmptySubtitle;

  /// No description provided for @comingSoonSection.
  ///
  /// In en, this message translates to:
  /// **'{section} — coming soon'**
  String comingSoonSection(Object section);

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments and tariffs'**
  String get paymentTitle;

  /// No description provided for @viewHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistoryTitle;

  /// No description provided for @myAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get myAddressesTitle;

  /// No description provided for @myAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'My ads'**
  String get myAdsTitle;

  /// No description provided for @profileVerifyBanner.
  ///
  /// In en, this message translates to:
  /// **'Confirm your account'**
  String get profileVerifyBanner;

  /// No description provided for @myBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'My business'**
  String get myBusinessTitle;

  /// No description provided for @companyInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Company information'**
  String get companyInfoSection;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyNameLabel;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get companyNameHint;

  /// No description provided for @companyAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get companyAboutLabel;

  /// No description provided for @companyAboutHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get companyAboutHint;

  /// No description provided for @uploadCover.
  ///
  /// In en, this message translates to:
  /// **'Upload cover'**
  String get uploadCover;

  /// No description provided for @contactDataToggle.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactDataToggle;

  /// No description provided for @phone1Label.
  ///
  /// In en, this message translates to:
  /// **'Phone 1'**
  String get phone1Label;

  /// No description provided for @phone2Label.
  ///
  /// In en, this message translates to:
  /// **'Phone 2'**
  String get phone2Label;

  /// No description provided for @workingTimeSection.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingTimeSection;

  /// No description provided for @workingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Working days and time'**
  String get workingDaysLabel;

  /// No description provided for @workingDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Mon–Fri 9:00–18:00'**
  String get workingDaysHint;

  /// No description provided for @workingDaysOptionWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Mon–Fri 9:00–18:00'**
  String get workingDaysOptionWeekdays;

  /// No description provided for @workingDaysOptionSat.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat 9:00–18:00'**
  String get workingDaysOptionSat;

  /// No description provided for @workingDaysOptionDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily 9:00–22:00'**
  String get workingDaysOptionDaily;

  /// No description provided for @lunchBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Lunch break'**
  String get lunchBreakLabel;

  /// No description provided for @lunchBreakHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 13:00–14:00'**
  String get lunchBreakHint;

  /// No description provided for @landmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmarkLabel;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Specify the nearest landmark'**
  String get landmarkHint;

  /// No description provided for @socialNetworksSection.
  ///
  /// In en, this message translates to:
  /// **'Social networks'**
  String get socialNetworksSection;

  /// No description provided for @instagramHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Instagram link'**
  String get instagramHint;

  /// No description provided for @facebookHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Facebook link'**
  String get facebookHint;

  /// No description provided for @telegramHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Telegram link'**
  String get telegramHint;

  /// No description provided for @youtubeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter YouTube link'**
  String get youtubeHint;

  /// No description provided for @savedFilterCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category:'**
  String get savedFilterCategoryLabel;

  /// No description provided for @savedFilterRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region:'**
  String get savedFilterRegionLabel;

  /// No description provided for @savedFilterCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City:'**
  String get savedFilterCityLabel;

  /// No description provided for @savedFilterBusinessOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Business-only ads:'**
  String get savedFilterBusinessOnlyLabel;

  /// No description provided for @savedFilterCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency:'**
  String get savedFilterCurrencyLabel;

  /// No description provided for @savedFilterSortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get savedFilterSortByLabel;

  /// No description provided for @savedFilterStatusEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new ads found'**
  String get savedFilterStatusEmpty;

  /// No description provided for @savedFilterDateSample.
  ///
  /// In en, this message translates to:
  /// **'1 min ago'**
  String get savedFilterDateSample;

  /// No description provided for @savedFilterCategoryHomeGarden.
  ///
  /// In en, this message translates to:
  /// **'Home & garden'**
  String get savedFilterCategoryHomeGarden;

  /// No description provided for @savedFilterRegionTashkent.
  ///
  /// In en, this message translates to:
  /// **'Tashkent region'**
  String get savedFilterRegionTashkent;

  /// No description provided for @savedFilterCityTashkent.
  ///
  /// In en, this message translates to:
  /// **'Tashkent'**
  String get savedFilterCityTashkent;

  /// No description provided for @savedFilterBusinessOnlyValue.
  ///
  /// In en, this message translates to:
  /// **'Business-only ads'**
  String get savedFilterBusinessOnlyValue;

  /// No description provided for @savedFilterCurrencyValue.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get savedFilterCurrencyValue;

  /// No description provided for @savedFilterSortMostRelevant.
  ///
  /// In en, this message translates to:
  /// **'Most relevant'**
  String get savedFilterSortMostRelevant;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
