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

  static const String categories = 'category/';
  static const String banner = 'banner/';
  static const String recommendations = 'ad/recommendations/';
  static const String gifts = 'ad/gift/';
  static const String services = 'ad/services/';

  static const String ad = 'ad/';
  static const String color = 'color/';
  static const String size = 'size/';

  static const String address = 'address/';
}
