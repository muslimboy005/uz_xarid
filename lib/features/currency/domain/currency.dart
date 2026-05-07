import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  const Currency({
    required this.id,
    required this.code,
    required this.ccy,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.nominal,
    required this.rate,
    required this.diff,
    required this.date,
  });

  final int id;
  final String code;
  final String ccy;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final int nominal;
  final double rate;
  final double diff;
  final String date;

  factory Currency.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return Currency(
      id: parseInt(json['id']),
      code: (json['Code'] ?? '').toString(),
      ccy: (json['Ccy'] ?? '').toString(),
      nameUz: (json['CcyNm_UZ'] ?? '').toString(),
      nameRu: (json['CcyNm_RU'] ?? '').toString(),
      nameEn: (json['CcyNm_EN'] ?? '').toString(),
      nominal: parseInt(json['Nominal']),
      rate: parseDouble(json['Rate']),
      diff: parseDouble(json['Diff']),
      date: (json['Date'] ?? '').toString(),
    );
  }

  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return nameRu;
      case 'en':
        return nameEn;
      default:
        return nameUz;
    }
  }

  @override
  List<Object?> get props => [id, ccy, rate, date];
}

/// Maps a currency code (ISO 4217) to a Unicode flag emoji
/// by deriving the country from the currency.
String currencyFlagEmoji(String ccy) {
  const map = <String, String>{
    'UZS': 'UZ', 'USD': 'US', 'EUR': 'EU', 'RUB': 'RU', 'GBP': 'GB', 'JPY': 'JP',
    'AZN': 'AZ', 'BDT': 'BD', 'BHD': 'BH', 'BND': 'BN', 'BRL': 'BR',
    'BYN': 'BY', 'CAD': 'CA', 'CHF': 'CH', 'CNY': 'CN', 'CUP': 'CU',
    'CZK': 'CZ', 'DKK': 'DK', 'DZD': 'DZ', 'EGP': 'EG', 'AFN': 'AF',
    'ARS': 'AR', 'GEL': 'GE', 'HKD': 'HK', 'HUF': 'HU', 'IDR': 'ID',
    'ILS': 'IL', 'INR': 'IN', 'IQD': 'IQ', 'IRR': 'IR', 'ISK': 'IS',
    'JOD': 'JO', 'AUD': 'AU', 'KGS': 'KG', 'KHR': 'KH', 'KRW': 'KR',
    'KWD': 'KW', 'KZT': 'KZ', 'LAK': 'LA', 'LBP': 'LB', 'LYD': 'LY',
    'MAD': 'MA', 'MDL': 'MD', 'MMK': 'MM', 'MNT': 'MN', 'MXN': 'MX',
    'MYR': 'MY', 'NOK': 'NO', 'NZD': 'NZ', 'OMR': 'OM', 'PHP': 'PH',
    'PKR': 'PK', 'PLN': 'PL', 'QAR': 'QA', 'RON': 'RO', 'RSD': 'RS',
    'AMD': 'AM', 'SAR': 'SA', 'SDG': 'SD', 'SEK': 'SE', 'SGD': 'SG',
    'SYP': 'SY', 'THB': 'TH', 'TJS': 'TJ', 'TMT': 'TM', 'TND': 'TN',
    'TRY': 'TR', 'UAH': 'UA', 'AED': 'AE', 'UYU': 'UY', 'VES': 'VE',
    'VND': 'VN', 'YER': 'YE', 'ZAR': 'ZA',
  };
  final country = map[ccy];
  if (country == null || country.length != 2) return '';
  const base = 0x1F1E6;
  final a = country.codeUnitAt(0) - 0x41 + base;
  final b = country.codeUnitAt(1) - 0x41 + base;
  return String.fromCharCodes([a, b]);
}

/// Returns a short symbol for a currency (e.g. ₽, $, €). Falls back to ccy code.
String currencySymbol(String ccy) {
  switch (ccy) {
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    case 'RUB':
      return '₽';
    case 'GBP':
      return '£';
    case 'JPY':
    case 'CNY':
      return '¥';
    case 'KRW':
      return '₩';
    case 'TRY':
      return '₺';
    case 'INR':
      return '₹';
    case 'UAH':
      return '₴';
    case 'KZT':
      return '₸';
    default:
      return ccy;
  }
}

/// Narx yonida ko'rsatiladigan valyuta yorlig'i.
/// UZS — "so'm" sifatida ko'rsatiladi, boshqa valyutalar — belgisi (yo'q bo'lsa, kodi).
String currencyDisplayLabel(String ccy) {
  final code = ccy.toUpperCase();
  if (code == 'UZS') return "so'm";
  return currencySymbol(code);
}
