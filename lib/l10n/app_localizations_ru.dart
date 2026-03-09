// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Uz Xarid';

  @override
  String get homeTitle => 'Uz Xarid';

  @override
  String get homeSubtitle => 'Найдите товары быстро и удобно';

  @override
  String get homeBody => 'Структура Clean Architecture (DDD) уже подготовлена.';

  @override
  String get catalogTitle => 'Каталог';

  @override
  String get catalogBody => 'Каталог товаров будет отображаться здесь.';

  @override
  String get productsNotFoundTitle => 'Товары не найдены';

  @override
  String get productsNotFoundSubtitle =>
      'По вашему запросу товары не найдены.\nПожалуйста, попробуйте снова.';

  @override
  String get allCategories => 'Все категории';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get favoritesTitle => 'Избранные';

  @override
  String get favoritesBody => 'Ваши избранные товары будут здесь.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileBody => 'Информация профиля будет отображаться здесь.';

  @override
  String get navHome => 'Главная';

  @override
  String get navCatalog => 'Каталог';

  @override
  String get navFavorites => 'Избранные';

  @override
  String get navProfile => 'Профиль';

  @override
  String get searchHint => 'Искать...';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchFindByCategory => 'Найти по категории';

  @override
  String get searchFrequentlySearched => 'Часто ищут';

  @override
  String get homeHeadline => 'Найдите. Покупайте. Продавайте.';

  @override
  String get categoryGoods => 'Товары и покупки';

  @override
  String get categoryConstruction => 'Объекты строительства';

  @override
  String get categoryAutoMoto => 'Авто и мототехника';

  @override
  String get categoryServices => 'Услуги и работа';

  @override
  String get recommendationsTitle => 'Рекомендуем вам';

  @override
  String get seeAll => 'Все';

  @override
  String get allProducts => 'Все товары';

  @override
  String get topTag => 'Топ';

  @override
  String get reviewsLabel => 'отзывов';

  @override
  String get dataLoadError => 'Не удалось загрузить данные';

  @override
  String get view => 'Посмотреть';

  @override
  String get adAuthorTitle => 'Автор объявления';

  @override
  String get adAuthorOtherAds => 'Другие объявления автора';

  @override
  String adAuthorOnPlatformSince(String date) {
    return 'На платформе с $date';
  }

  @override
  String get tabFullInfo => 'Полная информация';

  @override
  String get tabReviews => 'Отзывы';

  @override
  String get reviewsEmptyTitle => 'Отзывов нет';

  @override
  String get reviewsEmptySubtitle => 'Отзывы пока отсутствуют';

  @override
  String get reviewsWriteReview => 'Написать отзыв';

  @override
  String get productDetailErrorDefault => 'Ошибка';

  @override
  String get productDetailColorLabel => 'Цвет:';

  @override
  String get productDetailSizeLabel => 'Размер:';

  @override
  String get productDetailCall => 'Позвонить';

  @override
  String get productDetailTelegram => 'Telegram';

  @override
  String get productDetailPlaceOrder => 'Оформить заказ';

  @override
  String get productDetailFeatures => 'Характеристики';

  @override
  String get productDetailSimilarProducts => 'Похожие товары';

  @override
  String get productDetailDescription => 'Описание';

  @override
  String get productDetailWatchVideo => 'Смотреть видео';

  @override
  String productDetailInStock(String count) {
    return 'В наличии: $count шт';
  }

  @override
  String get productDetailShowAll => 'Смотреть все';

  @override
  String get productDetailHide => 'Скрыть';

  @override
  String productDetailReviewsCount(String count) {
    return '$count отзывов';
  }

  @override
  String get authorTabAds => 'Объявления';

  @override
  String get authorTabAbout => 'О нас';

  @override
  String get authorTabContacts => 'Контакты';

  @override
  String get authorAdsEmpty => 'Объявления не найдены';

  @override
  String get authorAboutEmpty => 'Информация о нас отсутствует';

  @override
  String get authorContactsTitle => 'Контакты';

  @override
  String get authorContactPhone => 'Контакт';

  @override
  String get authorContactWorkTime => 'Рабочее время';

  @override
  String get authorContactWorkTimeContent =>
      'Пн–Пт 9:00–18:00. Обед: 13:00–14:00';

  @override
  String get authorContactAddress => 'Адрес';

  @override
  String get authorContactAddressDefault =>
      'Республика Узбекистан, город Ташкент';

  @override
  String get authorActionCall => 'Позвонить';

  @override
  String get authorActionOpenMaps => 'Открыть Google Maps';

  @override
  String get giftHeadline => 'Идеальные подарки для всех';

  @override
  String get servicesTitle => 'Сервис рядом';

  @override
  String get servicesSeeAll => 'Все';

  @override
  String get productListFilters => 'Фильтры';

  @override
  String get sortPopular => 'Популярные';

  @override
  String get sortCheaper => 'Подешевле';

  @override
  String get sortExpensive => 'Подороже';

  @override
  String get sortHighRating => 'Высокий рейтинг';

  @override
  String get servicesEmptyTitle => 'Сервисы не найдены';

  @override
  String get servicesEmptySubtitle => 'Извините! Рядом сервисов нет';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionGo => 'Перейти';

  @override
  String get actionLogout => 'Выйти';

  @override
  String get profileBasicAccount => 'Базовый аккаунт';

  @override
  String get profileVerifyAccount => 'Подтвердите аккаунт';

  @override
  String get profileMenuPersonalData => 'Личные данные';

  @override
  String get profileMenuMyAds => 'Мои объявления';

  @override
  String get profileMenuMyOrders => 'Мои заказы';

  @override
  String get profileMenuFavorites => 'Избранное';

  @override
  String get profileMenuNotifications => 'Push-уведомления';

  @override
  String get profileMenuMyBusiness => 'Мой бизнес';

  @override
  String get profileMenuMyAddresses => 'Мои адреса';

  @override
  String get profileMenuPayment => 'Оплата и тарифы';

  @override
  String get profileMenuSupport => 'Поддержка';

  @override
  String get profileMenuViewHistory => 'История просмотров';

  @override
  String get profileMenuSettings => 'Настройки';

  @override
  String get profileBecomeBusinessTitle => 'Станьте бизнес\nпользователем';

  @override
  String get profileLogoutDialogTitle => 'Выйти из аккаунта?';

  @override
  String get profileLogoutDialogMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get profileAuthBenefitsTitle => 'Что даёт авторизация?';

  @override
  String get profileBenefitOfferServices =>
      'Возможность предлагать свои услуги';

  @override
  String get profileBenefitUseServices =>
      'Пользоваться услугами других пользователей';

  @override
  String get profileBenefitExclusive =>
      'Эксклюзивные предложения именно для вас';

  @override
  String get profileBenefitAdsFavorites => 'Размещение объявлений и избранное';

  @override
  String get profileAuthCta => 'Войти или создать профиль';

  @override
  String get profileAuthDescription =>
      'Покупайте, продавайте и пользуйтесь услугами! Размещайте объявления, находите нужное и добавляйте в избранное';

  @override
  String get loginSheetTitle => 'Вход в аккаунт';

  @override
  String get loginSheetDescription =>
      'Мы отправим проверочный код на введённый номер по SMS.';

  @override
  String get loginPhoneLabel => 'Телефон';

  @override
  String get loginPhoneHint => '+998 90 123-45-67';

  @override
  String get loginPhoneError => 'Введите номер телефона полностью';

  @override
  String get loginGetCode => 'Получить код';

  @override
  String get loginPolicyPrefix => 'Авторизуясь, вы соглашаетесь с ';

  @override
  String get loginPolicyLink => 'политикой обработки персональных данных';

  @override
  String get loginPolicySuffix => '.';

  @override
  String get otpSheetTitle => 'Введите код';

  @override
  String otpSentToNumber(Object phone) {
    return 'Код был отправлен на ваш номер телефона $phone. Пожалуйста, проверьте SMS.';
  }

  @override
  String get otpInputError => 'Введите 6-значный код из SMS';

  @override
  String get otpResend => 'Отправить код повторно';

  @override
  String otpResendCountdown(Object seconds) {
    return 'Отправить код повторно ($seconds)';
  }

  @override
  String get nameSheetTitle => 'Почти готово';

  @override
  String get nameSheetSubtitle => 'Ваш профиль почти готов, представьтесь';

  @override
  String get firstNameLabel => 'Имя';

  @override
  String get firstNameHint => 'Ваше имя';

  @override
  String get lastNameLabel => 'Фамилия';

  @override
  String get lastNameHint => 'Ваша фамилия';

  @override
  String get nameRequiredError => 'Введите имя и фамилию';

  @override
  String get personalDataTitle => 'Личные данные';

  @override
  String get contactDataTitle => 'Контактные данные';

  @override
  String get addressTitle => 'Адрес';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get phoneHint => '+998 XX XXX-XX-XX';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailHint => 'Введите E-mail';

  @override
  String get cityLabel => 'Город';

  @override
  String get cityHint => 'Введите город';

  @override
  String get streetLabel => 'Улица';

  @override
  String get streetHint => 'Введите улицу';

  @override
  String get houseLabel => 'Дом / Квартира';

  @override
  String get houseHint => 'Дом / Квартира';

  @override
  String get districtLabel => 'Район';

  @override
  String get districtHint => 'Введите район';

  @override
  String get profilePhotoLabel => 'Фото профиля';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get genderLabel => 'Пол';

  @override
  String get genderMale => 'Мужчина';

  @override
  String get genderFemale => 'Женщина';

  @override
  String get genderHint => 'Выберите пол';

  @override
  String get birthDateLabel => 'Дата рождения';

  @override
  String get birthDatePlaceholder => 'ДД.ММ.ГГГГ';

  @override
  String get myOrdersTitle => 'Мои заказы';

  @override
  String get myRequestsTab => 'Мои запросы';

  @override
  String get myOrdersTab => 'Мои заказы';

  @override
  String get myOrdersEmptyTitle => 'У вас пока нет заказов.';

  @override
  String get myOrdersEmptySubtitle =>
      'Сделайте первый заказ и попробуйте, как это удобно!';

  @override
  String get favoritesProfileTitle => 'Избранное';

  @override
  String get favoritesTab => 'Избранное';

  @override
  String get savedFilterTab => 'Сохранённый фильтр';

  @override
  String get favoritesEmptyTitle => 'Избранных нет';

  @override
  String get favoritesEmptySubtitle => 'Добавьте объявления в избранное';

  @override
  String get notificationsTitle => 'Push-уведомления';

  @override
  String get notificationsContractsTab => 'Договоры';

  @override
  String get notificationsSystemTab => 'Системный';

  @override
  String get notificationsEmptyTitle => 'Пока пусто';

  @override
  String get notificationsEmptySubtitle =>
      'Уведомления появятся здесь, как только они будут доступны';

  @override
  String comingSoonSection(Object section) {
    return '$section — скоро';
  }

  @override
  String get supportTitle => 'Поддержка';

  @override
  String get paymentTitle => 'Оплата и тарифы';

  @override
  String get viewHistoryTitle => 'История просмотров';

  @override
  String get myAddressesTitle => 'Мои адреса';

  @override
  String get myAdsTitle => 'Мои объявления';

  @override
  String get profileVerifyBanner => 'Подтвердите аккаунт';

  @override
  String get myBusinessTitle => 'Мой бизнес';

  @override
  String get companyInfoSection => 'Информация о компании';

  @override
  String get changeAvatar => 'Изменить аватар';

  @override
  String get companyNameLabel => 'Название компании';

  @override
  String get companyNameHint => 'Введите название компании';

  @override
  String get companyAboutLabel => 'Описание';

  @override
  String get companyAboutHint => 'Описание';

  @override
  String get uploadCover => 'Загрузить обложку';

  @override
  String get contactDataToggle => 'Контактные данные';

  @override
  String get phone1Label => 'Телефон 1';

  @override
  String get phone2Label => 'Телефон 2';

  @override
  String get workingTimeSection => 'Рабочее время';

  @override
  String get workingDaysLabel => 'Рабочие дни и время';

  @override
  String get workingDaysHint => 'Например: Пн.–Пя. с 9:00 до 18:00';

  @override
  String get workingDaysOptionWeekdays => 'Пн.–Пя. с 9:00 до 18:00';

  @override
  String get workingDaysOptionSat => 'Пн.–Сб. с 9:00 до 18:00';

  @override
  String get workingDaysOptionDaily => 'Ежедневно с 9:00 до 22:00';

  @override
  String get lunchBreakLabel => 'Перерыв (обед)';

  @override
  String get lunchBreakHint => 'Например: 13:00–14:00';

  @override
  String get landmarkLabel => 'Ориентир';

  @override
  String get landmarkHint => 'Укажите ближайший ориентир';

  @override
  String get socialNetworksSection => 'Социальные сети';

  @override
  String get instagramHint => 'Введите ссылку на Instagram';

  @override
  String get facebookHint => 'Введите ссылку на Facebook';

  @override
  String get telegramHint => 'Введите ссылку на Telegram';

  @override
  String get youtubeHint => 'Введите ссылку на YouTube';

  @override
  String get savedFilterCategoryLabel => 'Категория:';

  @override
  String get savedFilterRegionLabel => 'Регион:';

  @override
  String get savedFilterCityLabel => 'Город:';

  @override
  String get savedFilterBusinessOnlyLabel => 'Только бизнес объявления:';

  @override
  String get savedFilterCurrencyLabel => 'Валюта:';

  @override
  String get savedFilterSortByLabel => 'Сортировать по:';

  @override
  String get savedFilterStatusEmpty => 'Новые объявления не найдены';

  @override
  String get savedFilterDateSample => '1 мин назад';

  @override
  String get savedFilterCategoryHomeGarden => 'Дом и сад';

  @override
  String get savedFilterRegionTashkent => 'Ташкентская область';

  @override
  String get savedFilterCityTashkent => 'Ташкент';

  @override
  String get savedFilterBusinessOnlyValue => 'Только бизнес объявления';

  @override
  String get savedFilterCurrencyValue => 'у.е.';

  @override
  String get savedFilterSortMostRelevant => 'Наиболее важный';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get orderTitle => 'Заказ';

  @override
  String get orderSendToAllAds => 'Отправить запрос по всем таким объявлениям';

  @override
  String get orderDelivery => 'Доставка';

  @override
  String get orderAddressNotSelected => 'Адрес не выбран';

  @override
  String get orderSelectDeliveryAddress => 'Выберите адрес доставки';

  @override
  String get orderSelectAddress => 'Выбрать адрес';

  @override
  String get orderComment => 'Комментарий';

  @override
  String get orderCommentHint => 'Введите ваш комментарий.';

  @override
  String get orderSubmit => 'Отправить';

  @override
  String get orderQuantityDona => 'шт';
}
