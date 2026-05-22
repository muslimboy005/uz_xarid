/// Foydalanuvchining e'lon yaratish limiti haqida ma'lumot
/// (GET ad/limit-info/ javobi).
class AdLimitInfoDto {
  const AdLimitInfoDto({
    required this.adsCreated,
    required this.adsRemaining,
    required this.maxAdsAllowed,
    required this.canCreateAd,
    this.accountType,
  });

  final int adsCreated;
  final int adsRemaining;
  final int maxAdsAllowed;
  final bool canCreateAd;
  final String? accountType;

  factory AdLimitInfoDto.fromJson(Map<String, dynamic> json) {
    return AdLimitInfoDto(
      adsCreated: (json['ads_created'] as num?)?.toInt() ?? 0,
      adsRemaining: (json['ads_remaining'] as num?)?.toInt() ?? 0,
      maxAdsAllowed: (json['max_ads_allowed'] as num?)?.toInt() ?? 0,
      canCreateAd: json['can_create_ad'] as bool? ?? false,
      accountType: json['account_type'] as String?,
    );
  }
}
