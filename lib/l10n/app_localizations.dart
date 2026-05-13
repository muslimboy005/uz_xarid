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

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

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

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @adAuthorOnPlatformSince.
  ///
  /// In en, this message translates to:
  /// **'On the platform since {date}'**
  String adAuthorOnPlatformSince(String date);

  /// No description provided for @adAuthorOtherAds.
  ///
  /// In en, this message translates to:
  /// **'Other ads by the author'**
  String get adAuthorOtherAds;

  /// No description provided for @adAuthorTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad author'**
  String get adAuthorTitle;

  /// No description provided for @adTypeBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get adTypeBuy;

  /// No description provided for @adTypeSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get adTypeSell;

  /// No description provided for @addListingAddColors.
  ///
  /// In en, this message translates to:
  /// **'Add colors'**
  String get addListingAddColors;

  /// No description provided for @addListingAddColorsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add available colors (max {count})'**
  String addListingAddColorsDescription(int count);

  /// No description provided for @addListingAddParameter.
  ///
  /// In en, this message translates to:
  /// **'Add parameter'**
  String get addListingAddParameter;

  /// No description provided for @addListingAddParameterDescription.
  ///
  /// In en, this message translates to:
  /// **'Add available parameters (max {count})'**
  String addListingAddParameterDescription(int count);

  /// No description provided for @addListingAddSizes.
  ///
  /// In en, this message translates to:
  /// **'Add sizes'**
  String get addListingAddSizes;

  /// No description provided for @addListingAddSizesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add available sizes (max {count})'**
  String addListingAddSizesDescription(int count);

  /// No description provided for @addListingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get addListingBack;

  /// No description provided for @addListingCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addListingCategory;

  /// No description provided for @addListingCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {lat}, {lng}'**
  String addListingCoordinates(Object lat, Object lng);

  /// No description provided for @addListingCreateHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add listing'**
  String get addListingCreateHeadline;

  /// No description provided for @addListingCreated.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully'**
  String get addListingCreated;

  /// No description provided for @addListingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get addListingCurrency;

  /// No description provided for @addListingDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addListingDescription;

  /// No description provided for @addListingDimensionUnit.
  ///
  /// In en, this message translates to:
  /// **'Dimension unit'**
  String get addListingDimensionUnit;

  /// No description provided for @addListingDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get addListingDimensions;

  /// No description provided for @addListingDimensionsAndWeight.
  ///
  /// In en, this message translates to:
  /// **'Dimensions and weight'**
  String get addListingDimensionsAndWeight;

  /// No description provided for @addListingDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount % (optional)'**
  String get addListingDiscount;

  /// No description provided for @addListingDiscountHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 10'**
  String get addListingDiscountHint;

  /// No description provided for @addListingDiscountOptional.
  ///
  /// In en, this message translates to:
  /// **'Discount % (optional)'**
  String get addListingDiscountOptional;

  /// No description provided for @addListingEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get addListingEnterAmount;

  /// No description provided for @addListingEnterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get addListingEnterProductName;

  /// No description provided for @addListingHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get addListingHeight;

  /// No description provided for @addListingImageUpload.
  ///
  /// In en, this message translates to:
  /// **'Image upload'**
  String get addListingImageUpload;

  /// No description provided for @addListingLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get addListingLength;

  /// No description provided for @addListingLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get addListingLoading;

  /// No description provided for @addListingLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get addListingLocation;

  /// No description provided for @addListingViloyat.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get addListingViloyat;

  /// No description provided for @addListingMahalla.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get addListingMahalla;

  /// No description provided for @addListingSelectViloyat.
  ///
  /// In en, this message translates to:
  /// **'Select a region'**
  String get addListingSelectViloyat;

  /// No description provided for @addListingSelectTuman.
  ///
  /// In en, this message translates to:
  /// **'Select a district'**
  String get addListingSelectTuman;

  /// No description provided for @addListingLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'Please log in before posting.'**
  String get addListingLoginDescription;

  /// No description provided for @addListingMainImage.
  ///
  /// In en, this message translates to:
  /// **'Main image'**
  String get addListingMainImage;

  /// No description provided for @addListingParameterHint.
  ///
  /// In en, this message translates to:
  /// **'Color, Size, Material, etc.'**
  String get addListingParameterHint;

  /// No description provided for @addListingParameterName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addListingParameterName;

  /// No description provided for @addListingParameterValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get addListingParameterValue;

  /// No description provided for @addListingParameterValueHint.
  ///
  /// In en, this message translates to:
  /// **'Red, XL, Plastic, etc.'**
  String get addListingParameterValueHint;

  /// No description provided for @addListingParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get addListingParameters;

  /// No description provided for @addListingPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get addListingPrice;

  /// No description provided for @addListingPriceOptional.
  ///
  /// In en, this message translates to:
  /// **'Price (optional)'**
  String get addListingPriceOptional;

  /// No description provided for @addListingProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get addListingProductName;

  /// No description provided for @addListingSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addListingSave;

  /// No description provided for @addListingSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get addListingSelectCategory;

  /// No description provided for @addListingSelectColor.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get addListingSelectColor;

  /// No description provided for @addListingSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get addListingSelectCurrency;

  /// No description provided for @addListingSelectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on map'**
  String get addListingSelectOnMap;

  /// No description provided for @addListingSelectSize.
  ///
  /// In en, this message translates to:
  /// **'Select size'**
  String get addListingSelectSize;

  /// No description provided for @addListingSelectSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Select subcategory'**
  String get addListingSelectSubcategory;

  /// No description provided for @addListingSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get addListingSelectType;

  /// No description provided for @addListingTanlang.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get addListingTanlang;

  /// No description provided for @addListingUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get addListingUnit;

  /// No description provided for @addListingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Listing updated'**
  String get addListingUpdated;

  /// No description provided for @addListingUploadMainImage.
  ///
  /// In en, this message translates to:
  /// **'Upload main image'**
  String get addListingUploadMainImage;

  /// No description provided for @addListingValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get addListingValue;

  /// No description provided for @addListingWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get addListingWeight;

  /// No description provided for @addListingWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get addListingWidth;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addressAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addressAdd;

  /// No description provided for @addressAddMapHint.
  ///
  /// In en, this message translates to:
  /// **'Enter location from map'**
  String get addressAddMapHint;

  /// No description provided for @addressAddMapSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Address on map'**
  String get addressAddMapSelectedLabel;

  /// No description provided for @addressAddMapSelectedSub.
  ///
  /// In en, this message translates to:
  /// **'Selected address'**
  String get addressAddMapSelectedSub;

  /// No description provided for @addressAddOwn.
  ///
  /// In en, this message translates to:
  /// **'Add your address'**
  String get addressAddOwn;

  /// No description provided for @addressAddOwnSub.
  ///
  /// In en, this message translates to:
  /// **'Save addresses for quick\ncheckout.'**
  String get addressAddOwnSub;

  /// No description provided for @addressAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to deliver?'**
  String get addressAddTitle;

  /// No description provided for @addressAptHint.
  ///
  /// In en, this message translates to:
  /// **'Apt'**
  String get addressAptHint;

  /// No description provided for @addressAptLabel.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get addressAptLabel;

  /// No description provided for @addressCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get addressCityHint;

  /// No description provided for @addressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addressCityLabel;

  /// No description provided for @addressDefaultName.
  ///
  /// In en, this message translates to:
  /// **'My address'**
  String get addressDefaultName;

  /// No description provided for @addressEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get addressEdit;

  /// No description provided for @addressHouseHint.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get addressHouseHint;

  /// No description provided for @addressHouseLabel.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get addressHouseLabel;

  /// No description provided for @addressIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'Address {index}'**
  String addressIndexLabel(int index);

  /// No description provided for @addressLandmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nearest landmark'**
  String get addressLandmarkHint;

  /// No description provided for @addressLandmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get addressLandmarkLabel;

  /// No description provided for @addressMyAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get addressMyAddressesTitle;

  /// No description provided for @addressNameHint.
  ///
  /// In en, this message translates to:
  /// **'Home, Work, etc.'**
  String get addressNameHint;

  /// No description provided for @addressNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Address Name'**
  String get addressNameLabel;

  /// No description provided for @addressRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Fill in the field'**
  String get addressRequiredError;

  /// No description provided for @addressSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addressSave;

  /// No description provided for @addressStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter street'**
  String get addressStreetHint;

  /// No description provided for @addressStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get addressStreetLabel;

  /// No description provided for @addressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressTitle;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProducts;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'uzxarid'**
  String get appName;

  /// No description provided for @appsTitle.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get appsTitle;

  /// No description provided for @authorAboutEmpty.
  ///
  /// In en, this message translates to:
  /// **'No information about us'**
  String get authorAboutEmpty;

  /// No description provided for @authorActionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get authorActionCall;

  /// No description provided for @authorActionOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Open Google Maps'**
  String get authorActionOpenMaps;

  /// No description provided for @authorAdsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ads found'**
  String get authorAdsEmpty;

  /// No description provided for @authorContactAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get authorContactAddress;

  /// No description provided for @authorContactAddressDefault.
  ///
  /// In en, this message translates to:
  /// **'Republic of Uzbekistan, Tashkent'**
  String get authorContactAddressDefault;

  /// No description provided for @authorContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get authorContactPhone;

  /// No description provided for @authorContactWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get authorContactWorkTime;

  /// No description provided for @authorContactWorkTimeContent.
  ///
  /// In en, this message translates to:
  /// **'Mon–Fri 9:00–18:00. Lunch: 13:00–14:00'**
  String get authorContactWorkTimeContent;

  /// No description provided for @authorContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get authorContactsTitle;

  /// No description provided for @authorTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get authorTabAbout;

  /// No description provided for @authorTabAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get authorTabAds;

  /// No description provided for @authorTabContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get authorTabContacts;

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

  /// No description provided for @businessAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get businessAddress;

  /// No description provided for @businessChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get businessChangeAvatar;

  /// No description provided for @businessCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get businessCity;

  /// No description provided for @businessCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get businessCityHint;

  /// No description provided for @businessCompanyInfo.
  ///
  /// In en, this message translates to:
  /// **'Company Info'**
  String get businessCompanyInfo;

  /// No description provided for @businessCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get businessCompanyName;

  /// No description provided for @businessCompanyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get businessCompanyNameHint;

  /// No description provided for @businessContactData.
  ///
  /// In en, this message translates to:
  /// **'Contact data'**
  String get businessContactData;

  /// No description provided for @businessDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get businessDescription;

  /// No description provided for @businessDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get businessDescriptionHint;

  /// No description provided for @businessFacebookHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Facebook link'**
  String get businessFacebookHint;

  /// No description provided for @businessHouseApt.
  ///
  /// In en, this message translates to:
  /// **'House / Apt'**
  String get businessHouseApt;

  /// No description provided for @businessInstagramHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Instagram link'**
  String get businessInstagramHint;

  /// No description provided for @businessLandmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get businessLandmark;

  /// No description provided for @businessLandmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Specify nearest landmark'**
  String get businessLandmarkHint;

  /// No description provided for @businessLunchBreak.
  ///
  /// In en, this message translates to:
  /// **'Lunch break'**
  String get businessLunchBreak;

  /// No description provided for @businessLunchBreakHint.
  ///
  /// In en, this message translates to:
  /// **'For example: 13:00–14:00'**
  String get businessLunchBreakHint;

  /// No description provided for @businessMyBusiness.
  ///
  /// In en, this message translates to:
  /// **'My business'**
  String get businessMyBusiness;

  /// No description provided for @businessPhoneIndex.
  ///
  /// In en, this message translates to:
  /// **'Phone {index}'**
  String businessPhoneIndex(int index);

  /// No description provided for @businessPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get businessPhoneLabel;

  /// No description provided for @businessSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get businessSocialMedia;

  /// No description provided for @businessStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get businessStreet;

  /// No description provided for @businessStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter street'**
  String get businessStreetHint;

  /// No description provided for @businessTelegramHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Telegram link'**
  String get businessTelegramHint;

  /// No description provided for @businessUploadCover.
  ///
  /// In en, this message translates to:
  /// **'Upload cover'**
  String get businessUploadCover;

  /// No description provided for @businessWorkingDaysHours.
  ///
  /// In en, this message translates to:
  /// **'Working days and hours'**
  String get businessWorkingDaysHours;

  /// No description provided for @businessWorkingDaysHoursHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Mon.-Fri. from 9:00 to 18:00'**
  String get businessWorkingDaysHoursHint;

  /// No description provided for @businessWorkingExample1.
  ///
  /// In en, this message translates to:
  /// **'Mon.-Fri. from 9:00 to 18:00'**
  String get businessWorkingExample1;

  /// No description provided for @businessWorkingExample2.
  ///
  /// In en, this message translates to:
  /// **'Mon.-Sat. from 9:00 to 18:00'**
  String get businessWorkingExample2;

  /// No description provided for @businessWorkingExample3.
  ///
  /// In en, this message translates to:
  /// **'Every day, 24/7'**
  String get businessWorkingExample3;

  /// No description provided for @businessWorkingExample3Alt.
  ///
  /// In en, this message translates to:
  /// **'Every day from 9:00 to 22:00'**
  String get businessWorkingExample3Alt;

  /// No description provided for @businessWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get businessWorkingHours;

  /// No description provided for @businessYoutubeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter YouTube link'**
  String get businessYoutubeHint;

  /// No description provided for @cartClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the cart?'**
  String get cartClearConfirm;

  /// No description provided for @cartClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get cartClearTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add products to cart'**
  String get cartEmptySubtitle;

  /// No description provided for @cartStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get cartStartShopping;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get cartTotal;

  /// No description provided for @catalogBody.
  ///
  /// In en, this message translates to:
  /// **'Products catalog will appear here.'**
  String get catalogBody;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// No description provided for @categoryAutoMoto.
  ///
  /// In en, this message translates to:
  /// **'Auto & moto'**
  String get categoryAutoMoto;

  /// No description provided for @categoryConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get categoryConstruction;

  /// No description provided for @categoryEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get categoryEquipment;

  /// No description provided for @categoryGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods & shopping'**
  String get categoryGoods;

  /// No description provided for @categoryServices.
  ///
  /// In en, this message translates to:
  /// **'Services & jobs'**
  String get categoryServices;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @chatDescription.
  ///
  /// In en, this message translates to:
  /// **'Communication with sellers and buyers'**
  String get chatDescription;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any chats yet'**
  String get chatEmpty;

  /// No description provided for @chatSenderYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatSenderYou;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'My Chats'**
  String get chatTitle;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get cityHint;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @comingSoonSection.
  ///
  /// In en, this message translates to:
  /// **'{section} — coming soon'**
  String comingSoonSection(Object section);

  /// No description provided for @companyAboutHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get companyAboutHint;

  /// No description provided for @companyAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get companyAboutLabel;

  /// No description provided for @companyInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Company information'**
  String get companyInfoSection;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get companyNameHint;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyNameLabel;

  /// No description provided for @contactDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact data'**
  String get contactDataTitle;

  /// No description provided for @contactDataToggle.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactDataToggle;

  /// No description provided for @currencySom.
  ///
  /// In en, this message translates to:
  /// **'sum'**
  String get currencySom;

  /// No description provided for @dataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get dataLoadError;

  /// No description provided for @districtHint.
  ///
  /// In en, this message translates to:
  /// **'Enter district'**
  String get districtHint;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get emailHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @facebookHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Facebook link'**
  String get facebookHint;

  /// No description provided for @favoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Your favorite products will appear here.'**
  String get favoritesBody;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add ads to favorites'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

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

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstNameHint;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

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

  /// No description provided for @giftHeadline.
  ///
  /// In en, this message translates to:
  /// **'Perfect gifts for everyone'**
  String get giftHeadline;

  /// No description provided for @giftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We also recommend all ideal gifts for you'**
  String get giftSubtitle;

  /// No description provided for @homeBody.
  ///
  /// In en, this message translates to:
  /// **'Clean Architecture (DDD) structure is ready for your project.'**
  String get homeBody;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find. Buy. Sell.'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find products quickly and easily'**
  String get homeSubtitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'uzxarid'**
  String get homeTitle;

  /// No description provided for @houseHint.
  ///
  /// In en, this message translates to:
  /// **'House / Apartment'**
  String get houseHint;

  /// No description provided for @houseLabel.
  ///
  /// In en, this message translates to:
  /// **'House / Apartment'**
  String get houseLabel;

  /// No description provided for @instagramHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Instagram link'**
  String get instagramHint;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Specify the nearest landmark'**
  String get landmarkHint;

  /// No description provided for @landmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmarkLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get lastNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @listingTypeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get listingTypeAuto;

  /// No description provided for @listingTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get listingTypeHome;

  /// No description provided for @listingTypeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get listingTypeProduct;

  /// No description provided for @listingTypeService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get listingTypeService;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services disabled'**
  String get locationServicesDisabled;

  /// No description provided for @loginGetCode.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get loginGetCode;

  /// No description provided for @loginPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter the full phone number'**
  String get loginPhoneError;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+998 90 123-45-67'**
  String get loginPhoneHint;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginPhoneLabel;

  /// No description provided for @loginPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'personal data processing policy'**
  String get loginPolicyLink;

  /// No description provided for @loginPolicyPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing in you agree to the '**
  String get loginPolicyPrefix;

  /// No description provided for @loginPolicySuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get loginPolicySuffix;

  /// No description provided for @loginSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to the entered number via SMS.'**
  String get loginSheetDescription;

  /// No description provided for @loginSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Account login'**
  String get loginSheetTitle;

  /// No description provided for @lunchBreakHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 13:00–14:00'**
  String get lunchBreakHint;

  /// No description provided for @lunchBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Lunch break'**
  String get lunchBreakLabel;

  /// No description provided for @myAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get myAddressesTitle;

  /// No description provided for @myAdsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get myAdsDelete;

  /// No description provided for @myAdsDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action cannot be undone.'**
  String get myAdsDeleteDialogMessage;

  /// No description provided for @myAdsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete ad'**
  String get myAdsDeleteDialogTitle;

  /// No description provided for @myAdsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get myAdsEdit;

  /// No description provided for @myAdsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first ad and start selling!'**
  String get myAdsEmptySubtitle;

  /// No description provided for @myAdsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no ads yet.'**
  String get myAdsEmptyTitle;

  /// No description provided for @myAdsIncreaseLimit.
  ///
  /// In en, this message translates to:
  /// **'Increase limit'**
  String get myAdsIncreaseLimit;

  /// No description provided for @myAdsLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad limit'**
  String get myAdsLimitTitle;

  /// No description provided for @myAdsLimitUpTo.
  ///
  /// In en, this message translates to:
  /// **'You can post up to {count} ads'**
  String myAdsLimitUpTo(int count);

  /// No description provided for @myAdsPromoFrom.
  ///
  /// In en, this message translates to:
  /// **'Promo from 7,000 soum'**
  String get myAdsPromoFrom;

  /// No description provided for @myAdsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myAdsStatusActive;

  /// No description provided for @myAdsStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get myAdsStatusInactive;

  /// No description provided for @myAdsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get myAdsStatusPending;

  /// No description provided for @myAdsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get myAdsStatusRejected;

  /// No description provided for @myAdsStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get myAdsStatusUnpaid;

  /// No description provided for @myAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'My ads'**
  String get myAdsTitle;

  /// No description provided for @myBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'My business'**
  String get myBusinessTitle;

  /// No description provided for @myOrdersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place your first order and see how convenient it is!'**
  String get myOrdersEmptySubtitle;

  /// No description provided for @myOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders yet.'**
  String get myOrdersEmptyTitle;

  /// No description provided for @myOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrdersTab;

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

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter first and last name'**
  String get nameRequiredError;

  /// No description provided for @nameSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile is almost ready—please introduce yourself'**
  String get nameSheetSubtitle;

  /// No description provided for @nameSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get nameSheetTitle;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

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

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navKeraklilar.
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get navKeraklilar;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @noViewHistory.
  ///
  /// In en, this message translates to:
  /// **'No views yet'**
  String get noViewHistory;

  /// No description provided for @notificationsContractsTab.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get notificationsContractsTab;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications will appear here as soon as they are available'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsSystemTab.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsSystemTab;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notificationsTitle;

  /// No description provided for @orderAddString.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get orderAddString;

  /// No description provided for @orderAddressNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Address not selected'**
  String get orderAddressNotSelected;

  /// No description provided for @orderAddressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get orderAddressPlaceholder;

  /// No description provided for @orderComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get orderComment;

  /// No description provided for @orderCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your note.'**
  String get orderCommentHint;

  /// No description provided for @orderDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get orderDelivery;

  /// No description provided for @orderQuantityDona.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get orderQuantityDona;

  /// No description provided for @orderSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get orderSelectAddress;

  /// No description provided for @orderSelectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select delivery address'**
  String get orderSelectDeliveryAddress;

  /// No description provided for @orderSendToAllAds.
  ///
  /// In en, this message translates to:
  /// **'Send request to all such ads'**
  String get orderSendToAllAds;

  /// No description provided for @orderSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get orderSubmit;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderTitle;

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

  /// No description provided for @otpSentToNumber.
  ///
  /// In en, this message translates to:
  /// **'The code was sent to your phone number {phone}. Please check the SMS.'**
  String otpSentToNumber(Object phone);

  /// No description provided for @otpSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpSheetTitle;

  /// No description provided for @paymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get paymentAccount;

  /// No description provided for @paymentCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get paymentCurrentPlan;

  /// No description provided for @paymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get paymentHistoryTitle;

  /// No description provided for @paymentSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select plan'**
  String get paymentSelectPlan;

  /// No description provided for @paymentTariff.
  ///
  /// In en, this message translates to:
  /// **'Tariff'**
  String get paymentTariff;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments and tariffs'**
  String get paymentTitle;

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionCamera;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionDenied;

  /// No description provided for @permissionGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get permissionGallery;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionGranted;

  /// No description provided for @permissionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permissionLocation;

  /// No description provided for @permissionNotification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionNotification;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @personalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get personalDataTitle;

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

  /// No description provided for @phoneDoimiy.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get phoneDoimiy;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+998 XX XXX-XX-XX'**
  String get phoneHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @productDetailCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get productDetailCall;

  /// No description provided for @productDetailChat.
  ///
  /// In en, this message translates to:
  /// **'Connect via chat'**
  String get productDetailChat;

  /// No description provided for @productDetailColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color:'**
  String get productDetailColorLabel;

  /// No description provided for @productDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDetailDescription;

  /// No description provided for @productDetailErrorDefault.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get productDetailErrorDefault;

  /// No description provided for @productDetailFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get productDetailFeatures;

  /// No description provided for @productDetailHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get productDetailHide;

  /// No description provided for @productDetailInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock: {count} pcs'**
  String productDetailInStock(String count);

  /// No description provided for @productDetailPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get productDetailPlaceOrder;

  /// No description provided for @productDetailReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String productDetailReviewsCount(String count);

  /// No description provided for @productDetailShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get productDetailShowAll;

  /// No description provided for @productDetailLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Property location'**
  String get productDetailLocationTitle;

  /// No description provided for @productDetailSimilarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar products'**
  String get productDetailSimilarProducts;

  /// No description provided for @productDetailSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size:'**
  String get productDetailSizeLabel;

  /// No description provided for @productDetailTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get productDetailTelegram;

  /// No description provided for @productDetailWatchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch video'**
  String get productDetailWatchVideo;

  /// No description provided for @productListFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get productListFilters;

  /// No description provided for @productsNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We could not find products according to your query.\nPlease try again.'**
  String get productsNotFoundSubtitle;

  /// No description provided for @productsNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Products not found'**
  String get productsNotFoundTitle;

  /// No description provided for @profileAddressSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddressSectionLabel;

  /// No description provided for @profileAuthBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why sign in?'**
  String get profileAuthBenefitsTitle;

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

  /// No description provided for @profileBasicAccount.
  ///
  /// In en, this message translates to:
  /// **'Basic account'**
  String get profileBasicAccount;

  /// No description provided for @profileBecomeBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a business\nuser'**
  String get profileBecomeBusinessTitle;

  /// No description provided for @profileBenefitAdsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Post ads and manage favorites'**
  String get profileBenefitAdsFavorites;

  /// No description provided for @profileBenefitExclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive offers just for you'**
  String get profileBenefitExclusive;

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

  /// No description provided for @profileBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'DD.MM.YYYY'**
  String get profileBirthDateHint;

  /// No description provided for @profileBirthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get profileBirthDateLabel;

  /// No description provided for @profileBody.
  ///
  /// In en, this message translates to:
  /// **'Profile information will appear here.'**
  String get profileBody;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get profileCityHint;

  /// No description provided for @profileCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileCityLabel;

  /// No description provided for @profileContactDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Data'**
  String get profileContactDataLabel;

  /// No description provided for @profileDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Enter district'**
  String get profileDistrictHint;

  /// No description provided for @profileDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get profileDistrictLabel;

  /// No description provided for @profileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get profileEmailHint;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get profileFirstNameHint;

  /// No description provided for @profileFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get profileFirstNameLabel;

  /// No description provided for @profileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderHint.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get profileGenderHint;

  /// No description provided for @profileGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGenderLabel;

  /// No description provided for @profileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileGenderMale;

  /// No description provided for @profileHouseOrAptHint.
  ///
  /// In en, this message translates to:
  /// **'House / Apartment'**
  String get profileHouseOrAptHint;

  /// No description provided for @profileHouseOrAptLabel.
  ///
  /// In en, this message translates to:
  /// **'House / Apartment'**
  String get profileHouseOrAptLabel;

  /// No description provided for @profileLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get profileLastNameHint;

  /// No description provided for @profileLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get profileLastNameLabel;

  /// No description provided for @profileLogoutBottomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can always log back in\nwhenever you want'**
  String get profileLogoutBottomSubtitle;

  /// No description provided for @profileLogoutBottomTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you\nwant to log out?'**
  String get profileLogoutBottomTitle;

  /// No description provided for @profileLogoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutDialogMessage;

  /// No description provided for @profileLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of account?'**
  String get profileLogoutDialogTitle;

  /// No description provided for @profileMenuFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileMenuFavorites;

  /// No description provided for @profileMenuMyAddresses.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get profileMenuMyAddresses;

  /// No description provided for @profileMenuMyAds.
  ///
  /// In en, this message translates to:
  /// **'My ads'**
  String get profileMenuMyAds;

  /// No description provided for @profileMenuMyBusiness.
  ///
  /// In en, this message translates to:
  /// **'My business'**
  String get profileMenuMyBusiness;

  /// No description provided for @profileMenuMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get profileMenuMyOrders;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileMenuPayment.
  ///
  /// In en, this message translates to:
  /// **'Payments and tariffs'**
  String get profileMenuPayment;

  /// No description provided for @profileMenuPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get profileMenuPersonalData;

  /// No description provided for @profileMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileMenuSettings;

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

  /// No description provided for @profilePersonalDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get profilePersonalDataLabel;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+998 XX XXX-XX-XX'**
  String get profilePhoneHint;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhotoLabel;

  /// No description provided for @profileStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter street'**
  String get profileStreetHint;

  /// No description provided for @profileStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get profileStreetLabel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get profileVerifyAccount;

  /// No description provided for @profileVerifyBanner.
  ///
  /// In en, this message translates to:
  /// **'Confirm your account'**
  String get profileVerifyBanner;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendationsTitle;

  /// No description provided for @reviewsCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsCountTitle;

  /// No description provided for @reviewsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews are not yet available'**
  String get reviewsEmptySubtitle;

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviewsLabel;

  /// No description provided for @reviewsWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewsWriteReview;

  /// No description provided for @savedFilterBusinessOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Business-only ads:'**
  String get savedFilterBusinessOnlyLabel;

  /// No description provided for @savedFilterBusinessOnlyValue.
  ///
  /// In en, this message translates to:
  /// **'Business-only ads'**
  String get savedFilterBusinessOnlyValue;

  /// No description provided for @savedFilterCategoryHomeGarden.
  ///
  /// In en, this message translates to:
  /// **'Home & garden'**
  String get savedFilterCategoryHomeGarden;

  /// No description provided for @savedFilterCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category:'**
  String get savedFilterCategoryLabel;

  /// No description provided for @savedFilterCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City:'**
  String get savedFilterCityLabel;

  /// No description provided for @savedFilterCityTashkent.
  ///
  /// In en, this message translates to:
  /// **'Tashkent'**
  String get savedFilterCityTashkent;

  /// No description provided for @savedFilterCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency:'**
  String get savedFilterCurrencyLabel;

  /// No description provided for @savedFilterCurrencyValue.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get savedFilterCurrencyValue;

  /// No description provided for @savedFilterDateSample.
  ///
  /// In en, this message translates to:
  /// **'1 min ago'**
  String get savedFilterDateSample;

  /// No description provided for @savedFilterRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region:'**
  String get savedFilterRegionLabel;

  /// No description provided for @savedFilterRegionTashkent.
  ///
  /// In en, this message translates to:
  /// **'Tashkent region'**
  String get savedFilterRegionTashkent;

  /// No description provided for @savedFilterSortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get savedFilterSortByLabel;

  /// No description provided for @savedFilterSortMostRelevant.
  ///
  /// In en, this message translates to:
  /// **'Most relevant'**
  String get savedFilterSortMostRelevant;

  /// No description provided for @savedFilterStatusEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new ads found'**
  String get savedFilterStatusEmpty;

  /// No description provided for @savedFilterTab.
  ///
  /// In en, this message translates to:
  /// **'Saved filter'**
  String get savedFilterTab;

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

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get seeAll;

  /// No description provided for @sellerAdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get sellerAdsLabel;

  /// No description provided for @servicesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sorry! No services around you'**
  String get servicesEmptySubtitle;

  /// No description provided for @servicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get servicesEmptyTitle;

  /// No description provided for @servicesSeeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get servicesSeeAll;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services nearby'**
  String get servicesTitle;

  /// No description provided for @settingsLangRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLangRussian;

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

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @socialNetworksSection.
  ///
  /// In en, this message translates to:
  /// **'Social networks'**
  String get socialNetworksSection;

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

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTitle;

  /// No description provided for @streetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter street'**
  String get streetHint;

  /// No description provided for @streetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get streetLabel;

  /// No description provided for @supportChat.
  ///
  /// In en, this message translates to:
  /// **'Chat with a specialist'**
  String get supportChat;

  /// No description provided for @supportChatDocument.
  ///
  /// In en, this message translates to:
  /// **'Document / File'**
  String get supportChatDocument;

  /// No description provided for @supportChatGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery (Photo)'**
  String get supportChatGallery;

  /// No description provided for @supportChatHint.
  ///
  /// In en, this message translates to:
  /// **'Write your question...'**
  String get supportChatHint;

  /// No description provided for @supportCloseChat.
  ///
  /// In en, this message translates to:
  /// **'Close chat'**
  String get supportCloseChat;

  /// No description provided for @supportErrorDefault.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get supportErrorDefault;

  /// No description provided for @supportHint.
  ///
  /// In en, this message translates to:
  /// **'Write your question...'**
  String get supportHint;

  /// No description provided for @supportMenuAksiyalar.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get supportMenuAksiyalar;

  /// No description provided for @supportMenuChegirmalar.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get supportMenuChegirmalar;

  /// No description provided for @supportMenuDeliveryAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Delivery and payment'**
  String get supportMenuDeliveryAndPayment;

  /// No description provided for @supportMenuHowToOrder.
  ///
  /// In en, this message translates to:
  /// **'How to order?'**
  String get supportMenuHowToOrder;

  /// No description provided for @supportMenuQollabQuvvatlash.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportMenuQollabQuvvatlash;

  /// No description provided for @supportMenuSotaman.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get supportMenuSotaman;

  /// No description provided for @supportMenuSotibOlaman.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get supportMenuSotibOlaman;

  /// No description provided for @supportPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone support'**
  String get supportPhone;

  /// No description provided for @supportQuickReply1.
  ///
  /// In en, this message translates to:
  /// **'Complaint about user or ad'**
  String get supportQuickReply1;

  /// No description provided for @supportQuickReply2.
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get supportQuickReply2;

  /// No description provided for @supportQuickReply3.
  ///
  /// In en, this message translates to:
  /// **'Issues with ad'**
  String get supportQuickReply3;

  /// No description provided for @supportQuickReply4.
  ///
  /// In en, this message translates to:
  /// **'Other / Ask a question'**
  String get supportQuickReply4;

  /// No description provided for @supportQuickReply5.
  ///
  /// In en, this message translates to:
  /// **'Suggestions and feedback'**
  String get supportQuickReply5;

  /// No description provided for @supportRoomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Support is not configured yet...\nPlease try again later or contact the administrator.'**
  String get supportRoomNotFound;

  /// No description provided for @supportSourceDocument.
  ///
  /// In en, this message translates to:
  /// **'Document / File'**
  String get supportSourceDocument;

  /// No description provided for @supportSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery (Photo)'**
  String get supportSourceGallery;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

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

  /// No description provided for @telegramHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Telegram link'**
  String get telegramHint;

  /// No description provided for @tezEltSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery service'**
  String get tezEltSubtitle;

  /// No description provided for @topTag.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get topTag;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @uploadCover.
  ///
  /// In en, this message translates to:
  /// **'Upload cover'**
  String get uploadCover;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @viewHistoryEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Start searching to see interesting offers and products'**
  String get viewHistoryEmptyDesc;

  /// No description provided for @viewHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistoryTitle;

  /// No description provided for @workingDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Mon–Fri 9:00–18:00'**
  String get workingDaysHint;

  /// No description provided for @workingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Working days and time'**
  String get workingDaysLabel;

  /// No description provided for @workingDaysOptionDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily 9:00–22:00'**
  String get workingDaysOptionDaily;

  /// No description provided for @workingDaysOptionSat.
  ///
  /// In en, this message translates to:
  /// **'Mon–Sat 9:00–18:00'**
  String get workingDaysOptionSat;

  /// No description provided for @workingDaysOptionWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Mon–Fri 9:00–18:00'**
  String get workingDaysOptionWeekdays;

  /// No description provided for @workingTimeSection.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingTimeSection;

  /// No description provided for @youtubeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter YouTube link'**
  String get youtubeHint;
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
