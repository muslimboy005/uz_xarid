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
  String get productsNotFoundTitle => 'Products not found';

  @override
  String get productsNotFoundSubtitle =>
      'We could not find products according to your query.\nPlease try again.';

  @override
  String get allCategories => 'All categories';

  @override
  String get actionRetry => 'Retry';

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

  @override
  String get searchTitle => 'Search';

  @override
  String get searchFindByCategory => 'Find by category';

  @override
  String get searchFrequentlySearched => 'Frequently searched';

  @override
  String get homeHeadline => 'Find. Buy. Sell.';

  @override
  String get categoryGoods => 'Goods & shopping';

  @override
  String get categoryConstruction => 'Construction';

  @override
  String get categoryAutoMoto => 'Auto & moto';

  @override
  String get categoryServices => 'Services & jobs';

  @override
  String get recommendationsTitle => 'Recommended for you';

  @override
  String get seeAll => 'All';

  @override
  String get allProducts => 'All products';

  @override
  String get topTag => 'Top';

  @override
  String get reviewsLabel => 'reviews';

  @override
  String get dataLoadError => 'Failed to load data';

  @override
  String get view => 'View';

  @override
  String get adAuthorTitle => 'Ad author';

  @override
  String get adAuthorOtherAds => 'Other ads by the author';

  @override
  String adAuthorOnPlatformSince(String date) {
    return 'On the platform since $date';
  }

  @override
  String get tabFullInfo => 'Full info';

  @override
  String get tabReviews => 'Reviews';

  @override
  String get reviewsEmptyTitle => 'No reviews';

  @override
  String get reviewsEmptySubtitle => 'Reviews are not yet available';

  @override
  String get reviewsWriteReview => 'Write a review';

  @override
  String get productDetailErrorDefault => 'Error';

  @override
  String get productDetailColorLabel => 'Color:';

  @override
  String get productDetailSizeLabel => 'Size:';

  @override
  String get productDetailCall => 'Call';

  @override
  String get productDetailTelegram => 'Telegram';

  @override
  String get productDetailPlaceOrder => 'Place order';

  @override
  String get productDetailFeatures => 'Features';

  @override
  String get productDetailSimilarProducts => 'Similar products';

  @override
  String get productDetailDescription => 'Description';

  @override
  String get productDetailWatchVideo => 'Watch video';

  @override
  String productDetailInStock(String count) {
    return 'In stock: $count pcs';
  }

  @override
  String get productDetailShowAll => 'Show all';

  @override
  String get productDetailHide => 'Hide';

  @override
  String productDetailReviewsCount(String count) {
    return '$count reviews';
  }

  @override
  String get authorTabAds => 'Ads';

  @override
  String get authorTabAbout => 'About us';

  @override
  String get authorTabContacts => 'Contacts';

  @override
  String get authorAdsEmpty => 'No ads found';

  @override
  String get authorAboutEmpty => 'No information about us';

  @override
  String get authorContactsTitle => 'Contacts';

  @override
  String get authorContactPhone => 'Contact';

  @override
  String get authorContactWorkTime => 'Working hours';

  @override
  String get authorContactWorkTimeContent =>
      'Mon–Fri 9:00–18:00. Lunch: 13:00–14:00';

  @override
  String get authorContactAddress => 'Address';

  @override
  String get authorContactAddressDefault => 'Republic of Uzbekistan, Tashkent';

  @override
  String get authorActionCall => 'Call';

  @override
  String get authorActionOpenMaps => 'Open Google Maps';

  @override
  String get giftHeadline => 'Perfect gifts for everyone';

  @override
  String get giftSubtitle => 'We also recommend all ideal gifts for you';

  @override
  String get servicesTitle => 'Services nearby';

  @override
  String get servicesSeeAll => 'All';

  @override
  String get productListFilters => 'Filters';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortCheaper => 'Cheaper';

  @override
  String get sortExpensive => 'More expensive';

  @override
  String get sortHighRating => 'High rating';

  @override
  String get servicesEmptyTitle => 'No services found';

  @override
  String get servicesEmptySubtitle => 'Sorry! No services around you';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionGo => 'Go';

  @override
  String get actionLogout => 'Log out';

  @override
  String get profileBasicAccount => 'Basic account';

  @override
  String get profileVerifyAccount => 'Verify your account';

  @override
  String get profileMenuPersonalData => 'Personal data';

  @override
  String get profileMenuMyAds => 'My ads';

  @override
  String get profileMenuMyOrders => 'My orders';

  @override
  String get profileMenuFavorites => 'Favorites';

  @override
  String get profileMenuNotifications => 'Push notifications';

  @override
  String get profileMenuMyBusiness => 'My business';

  @override
  String get profileMenuMyAddresses => 'My addresses';

  @override
  String get profileMenuPayment => 'Payments and tariffs';

  @override
  String get profileMenuSupport => 'Support';

  @override
  String get profileMenuViewHistory => 'View history';

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String get profileBecomeBusinessTitle => 'Become a business\nuser';

  @override
  String get profileLogoutDialogTitle => 'Log out of account?';

  @override
  String get profileLogoutDialogMessage => 'Are you sure you want to log out?';

  @override
  String get profileAuthBenefitsTitle => 'Why sign in?';

  @override
  String get profileBenefitOfferServices => 'Offer your own services';

  @override
  String get profileBenefitUseServices => 'Use services from other users';

  @override
  String get profileBenefitExclusive => 'Exclusive offers just for you';

  @override
  String get profileBenefitAdsFavorites => 'Post ads and manage favorites';

  @override
  String get profileAuthCta => 'Sign in or create profile';

  @override
  String get profileAuthDescription =>
      'Buy, sell, and use services! Post ads, find what you need, and add to favorites.';

  @override
  String get loginSheetTitle => 'Account login';

  @override
  String get loginSheetDescription =>
      'We will send a verification code to the entered number via SMS.';

  @override
  String get loginPhoneLabel => 'Phone';

  @override
  String get loginPhoneHint => '+998 90 123-45-67';

  @override
  String get loginPhoneError => 'Enter the full phone number';

  @override
  String get loginGetCode => 'Get code';

  @override
  String get loginPolicyPrefix => 'By signing in you agree to the ';

  @override
  String get loginPolicyLink => 'personal data processing policy';

  @override
  String get loginPolicySuffix => '.';

  @override
  String get otpSheetTitle => 'Enter the code';

  @override
  String otpSentToNumber(Object phone) {
    return 'The code was sent to your phone number $phone. Please check the SMS.';
  }

  @override
  String get otpInputError => 'Enter the 6-digit SMS code';

  @override
  String get otpResend => 'Send code again';

  @override
  String otpResendCountdown(Object seconds) {
    return 'Send code again ($seconds)';
  }

  @override
  String get nameSheetTitle => 'Almost done';

  @override
  String get nameSheetSubtitle =>
      'Your profile is almost ready—please introduce yourself';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get firstNameHint => 'Your first name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get lastNameHint => 'Your last name';

  @override
  String get nameRequiredError => 'Please enter first and last name';

  @override
  String get personalDataTitle => 'Personal data';

  @override
  String get contactDataTitle => 'Contact data';

  @override
  String get addressTitle => 'Address';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneHint => '+998 XX XXX-XX-XX';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter email';

  @override
  String get cityLabel => 'City';

  @override
  String get cityHint => 'Enter city';

  @override
  String get streetLabel => 'Street';

  @override
  String get streetHint => 'Enter street';

  @override
  String get houseLabel => 'House / Apartment';

  @override
  String get houseHint => 'House / Apartment';

  @override
  String get districtLabel => 'District';

  @override
  String get districtHint => 'Enter district';

  @override
  String get profilePhotoLabel => 'Profile photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderHint => 'Select gender';

  @override
  String get birthDateLabel => 'Date of birth';

  @override
  String get birthDatePlaceholder => 'DD.MM.YYYY';

  @override
  String get myOrdersTitle => 'My orders';

  @override
  String get myRequestsTab => 'My requests';

  @override
  String get myOrdersTab => 'My orders';

  @override
  String get myOrdersEmptyTitle => 'You don\'t have any orders yet.';

  @override
  String get myOrdersEmptySubtitle =>
      'Place your first order and see how convenient it is!';

  @override
  String get favoritesProfileTitle => 'Favorites';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get savedFilterTab => 'Saved filter';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle => 'Add ads to favorites';

  @override
  String get notificationsTitle => 'Push notifications';

  @override
  String get notificationsContractsTab => 'Contracts';

  @override
  String get notificationsSystemTab => 'System';

  @override
  String get notificationsEmptyTitle => 'Nothing yet';

  @override
  String get notificationsEmptySubtitle =>
      'Notifications will appear here as soon as they are available';

  @override
  String comingSoonSection(Object section) {
    return '$section — coming soon';
  }

  @override
  String get supportTitle => 'Support';

  @override
  String get supportChat => 'Chat with a specialist';

  @override
  String get supportPhone => 'Phone support';

  @override
  String get paymentTitle => 'Payments and tariffs';

  @override
  String get viewHistoryTitle => 'View history';

  @override
  String get noViewHistory => 'No views yet';

  @override
  String get viewHistoryEmptyDesc =>
      'Start searching to see interesting offers and products';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get myAddressesTitle => 'My addresses';

  @override
  String get myAdsTitle => 'My ads';

  @override
  String get profileVerifyBanner => 'Confirm your account';

  @override
  String get myBusinessTitle => 'My business';

  @override
  String get companyInfoSection => 'Company information';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get companyNameHint => 'Enter company name';

  @override
  String get companyAboutLabel => 'Description';

  @override
  String get companyAboutHint => 'Description';

  @override
  String get uploadCover => 'Upload cover';

  @override
  String get contactDataToggle => 'Contact information';

  @override
  String get phone1Label => 'Phone 1';

  @override
  String get phone2Label => 'Phone 2';

  @override
  String get workingTimeSection => 'Working hours';

  @override
  String get workingDaysLabel => 'Working days and time';

  @override
  String get workingDaysHint => 'Example: Mon–Fri 9:00–18:00';

  @override
  String get workingDaysOptionWeekdays => 'Mon–Fri 9:00–18:00';

  @override
  String get workingDaysOptionSat => 'Mon–Sat 9:00–18:00';

  @override
  String get workingDaysOptionDaily => 'Daily 9:00–22:00';

  @override
  String get lunchBreakLabel => 'Lunch break';

  @override
  String get lunchBreakHint => 'Example: 13:00–14:00';

  @override
  String get landmarkLabel => 'Landmark';

  @override
  String get landmarkHint => 'Specify the nearest landmark';

  @override
  String get socialNetworksSection => 'Social networks';

  @override
  String get instagramHint => 'Enter Instagram link';

  @override
  String get facebookHint => 'Enter Facebook link';

  @override
  String get telegramHint => 'Enter Telegram link';

  @override
  String get youtubeHint => 'Enter YouTube link';

  @override
  String get savedFilterCategoryLabel => 'Category:';

  @override
  String get savedFilterRegionLabel => 'Region:';

  @override
  String get savedFilterCityLabel => 'City:';

  @override
  String get savedFilterBusinessOnlyLabel => 'Business-only ads:';

  @override
  String get savedFilterCurrencyLabel => 'Currency:';

  @override
  String get savedFilterSortByLabel => 'Sort by:';

  @override
  String get savedFilterStatusEmpty => 'No new ads found';

  @override
  String get savedFilterDateSample => '1 min ago';

  @override
  String get savedFilterCategoryHomeGarden => 'Home & garden';

  @override
  String get savedFilterRegionTashkent => 'Tashkent region';

  @override
  String get savedFilterCityTashkent => 'Tashkent';

  @override
  String get savedFilterBusinessOnlyValue => 'Business-only ads';

  @override
  String get savedFilterCurrencyValue => 'USD';

  @override
  String get savedFilterSortMostRelevant => 'Most relevant';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get orderTitle => 'Order';

  @override
  String get orderSendToAllAds => 'Send request to all such ads';

  @override
  String get orderDelivery => 'Delivery';

  @override
  String get orderAddressNotSelected => 'Address not selected';

  @override
  String get orderSelectDeliveryAddress => 'Select delivery address';

  @override
  String get orderSelectAddress => 'Select address';

  @override
  String get orderComment => 'Comment';

  @override
  String get orderCommentHint => 'Enter your note.';

  @override
  String get orderSubmit => 'Submit';

  @override
  String get orderQuantityDona => 'pcs';

  @override
  String get myAdsLimitTitle => 'Ad limit';

  @override
  String myAdsLimitUpTo(int count) {
    return 'You can post up to $count ads';
  }

  @override
  String get myAdsIncreaseLimit => 'Increase limit';

  @override
  String get myAdsStatusActive => 'Active';

  @override
  String get myAdsStatusPending => 'Pending';

  @override
  String get myAdsStatusUnpaid => 'Unpaid';

  @override
  String get myAdsStatusInactive => 'Inactive';

  @override
  String get myAdsStatusRejected => 'Rejected';

  @override
  String get myAdsEmptyTitle => 'You have no ads yet.';

  @override
  String get myAdsEmptySubtitle => 'Create your first ad and start selling!';

  @override
  String get myAdsDeleteDialogTitle => 'Delete ad';

  @override
  String get myAdsDeleteDialogMessage =>
      'Are you sure? This action cannot be undone.';

  @override
  String get myAdsDelete => 'Delete';

  @override
  String get myAdsEdit => 'Edit';

  @override
  String get myAdsPromoFrom => 'Promo from 7,000 soum';

  @override
  String get adTypeSell => 'Sell';

  @override
  String get adTypeBuy => 'Buy';

  @override
  String get listingTypeProduct => 'Product';

  @override
  String get listingTypeService => 'Service';

  @override
  String get listingTypeAuto => 'Auto';

  @override
  String get listingTypeHome => 'Home';
}
