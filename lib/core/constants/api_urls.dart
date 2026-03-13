class ApiUrls {
  static const String baseUrl = "https://uzxarid.felixits.uz/api/v1/";

  static const String sendOtp = 'auth/send-code/';
  static const String confirmOtp = 'auth/confirm/';
  static const String profileUpdate = 'auth/user-update/';
  static const String getProfile = 'auth/me/';
  static const String resendOtp = 'auth/resend/';
  static const String tokenRefresh = 'auth/token/refresh/';

  static const String business = 'business/';
  static const String businessId = 'business/{id}/';
  static const String businessMe = 'business/me/';
  static const String businessDelete = 'business/delete/';

  /// Order API
  static const String order = 'order/';
  static const String myOrders = 'order/my-orders/';

  static const String categories = 'category/';
  static const String banner = 'banner/';
  static const String recommendations = 'ad/recommendations/';
  static const String gifts = 'ad/gift/';
  static const String services = 'ad/services/';

  static const String ad = 'ad/';
  static const String adsSearch = 'ads/search/';
  static const String color = 'color/';
  static const String size = 'size/';

  /// Backend path: user-like (favorites)
  static const String favoritesToggle = 'user-like/toggle/';
  static const String favoritesList = 'user-like/';
  static const String address = 'address/';
  static const String viewedAds = 'viewed-ads/';
  static const String viewedAdsClear = 'viewed-ads/clear/';
  static const String plans = 'plan/';
  static const String planHistory = 'plan-order-history/';

  /// Foydalanuvchi e'lonlari: GET ad/me/?status=active|pending|unpaid|inactive|rejected
  static const String myListings = 'ad/me/';

  /// Sort param values for recommendations endpoint (?sort=...)
  static const String sortPopular = 'popular';
  static const String sortCheap = 'cheap';
  static const String sortExpensive = 'expensive';
  static const String sortHighRanking = 'high-ranking';
}
