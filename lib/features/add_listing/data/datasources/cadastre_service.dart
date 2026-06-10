import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

/// UZKAD (O'zbekiston yer kadastri) tizimidan kadastr raqami bo'yicha
/// ma'lumot oluvchi servis.
///
/// `main.py` (Python referens backend) 3 manbadan foydalanadi:
///   * open.ngis.uz  — 401 / anti-bot (mobil clientdan ishlamaydi);
///   * davreestr.uz  — rasm captcha (faqat server tomonda OCR bilan yechiladi);
///   * UZKAD ArcGIS  — public REST, **captcha YO'Q** — biz shundan foydalanamiz.
///
/// Shu sabab bu servis to'g'ridan-to'g'ri UZKAD ArcGIS FeatureServer'ga
/// so'rov yuboradi: hech qanday recaptcha chiqmaydi. Qaytadigan ma'lumot:
/// viloyat, tuman, mahalla, obyekt turi, qavatlar, maydon (geometriyadan
/// hisoblangan) va markaziy nuqta (lat/lng — xaritaga avtomatik joylash uchun).
class CadastreService {
  CadastreService({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static const String _base =
      'https://db.ngis.uz:6443/arcgis/rest/services/UZKAD';

  /// UZKAD service kodlari. Birinchi mos kelgan natija olinadi, shuning uchun
  /// turar/noturar joy avval kelsin (uy-joy e'lonlari uchun eng ehtimoliy).
  static const List<String> _services = [
    'TURAR', // turar joy
    'NOTURAR', // noturar joy
    'AGR_ONLY', // qishloq xo'jaligi
    'DZY', // dala hovli / bog'
    'MAHALLA', // mahalla
    'FOREST', // o'rmon
    'WATER', // suv obyektlari
    'MUHOFAZA', // muhofaza hududlar
    'AVTOYUL', // avto yo'llar
  ];

  static const Duration _timeout = Duration(seconds: 15);

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    // UZKAD serverida o'z-o'zini imzolagan (self-signed) sertifikat bor —
    // Python'dagi `verify=False` kabi TLS tekshiruvini o'tkazib yuboramiz.
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
    // Har bir so'rov va javobni konsolda ko'rsatish (avtomobil tex-passport
    // qidiruvidagi kabi). Bularsiz request/response loglarda ko'rinmaydi.
    dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          enabled: true,
          printRequestHeaders: true,
          printRequestData: true,
          printResponseData: true,
          printResponseHeaders: true,
          printResponseMessage: true,
          printErrorData: true,
          printErrorHeaders: true,
          printErrorMessage: true,
        ),
      ),
    );
    return dio;
  }

  static void _log(String message) =>
      developer.log(message, name: 'CADASTRE');

  /// Kadastr raqami bo'yicha qidiradi. Topilmasa va bu sub-kadastr bo'lsa
  /// (masalan xonadon), ota (parent) yer uchastkasini ham sinab ko'radi.
  /// Hech narsa topilmasa `null` qaytaradi.
  Future<CadastreResult?> lookup(String cadastreNumber) async {
    final number = cadastreNumber.trim();
    if (number.length < 5) {
      _log('SKIP: kadastr juda qisqa: "$number"');
      return null;
    }

    _log('LOOKUP boshlandi: "$number" → ${_services.length} service parallel');
    final result = await _queryAllServices(number);
    if (result != null) {
      _log('LOOKUP topildi: service=${result.serviceCode}, '
          'maydon=${result.areaSqm?.toStringAsFixed(2)}, '
          'lat=${result.latitude}, lng=${result.longitude}');
      return result;
    }

    // Sub-kadastr → ota parcelni sinash (10:..:0170:0001:019 → 10:..:0170)
    final parent = _parentCadastre(number);
    if (parent != null && parent != number) {
      _log('Aniq topilmadi → ota (parent) kadastr sinaladi: "$parent"');
      final parentResult = await _queryAllServices(parent);
      if (parentResult != null) {
        _log('PARENT topildi: service=${parentResult.serviceCode}');
        return parentResult.copyWith(isParentMatch: true);
      }
    }
    _log('LOOKUP yakuni: "$number" bo\'yicha hech narsa topilmadi');
    return null;
  }

  Future<CadastreResult?> _queryAllServices(String number) async {
    final futures = _services.map((code) => _queryService(code, number));
    final results = await Future.wait(futures);
    // `_services` ro'yxati tartibida birinchi mos kelganini olamiz.
    for (var i = 0; i < results.length; i++) {
      if (results[i] != null) {
        _log('Mos keldi: ${_services[i]} (boshqalar e\'tiborsiz)');
        return results[i];
      }
    }
    return null;
  }

  Future<CadastreResult?> _queryService(String code, String number) async {
    // Har bir service'da yagona parcel layeri — FeatureServer/0.
    // (MapServer query'ni qo'llab-quvvatlamaydi, FeatureServer qiladi.)
    final url = '$_base/${code}_UZKAD_DB16/FeatureServer/0/query';
    final safe = number.replaceAll("'", "''");
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'where': "cadastral_number='$safe'",
          'outFields': '*',
          'returnGeometry': 'true',
          'f': 'json',
        },
        options: Options(responseType: ResponseType.json),
      );
      final data = response.data;
      if (data == null) {
        _log('[$code] bo\'sh javob');
        return null;
      }
      if (data['error'] != null) {
        _log('[$code] ArcGIS xato: ${data['error']}');
        return null;
      }
      final features = data['features'];
      if (features is! List || features.isEmpty) {
        _log('[$code] topilmadi (0 ta obyekt)');
        return null;
      }

      final feature = features.first as Map<String, dynamic>;
      final attrs = (feature['attributes'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final geometry =
          (feature['geometry'] as Map?)?.cast<String, dynamic>();

      _log('[$code] TOPILDI: ${attrs['cadastral_number']} — '
          '${attrs['region_name']}, ${attrs['district_name']}, '
          '${attrs['mahalla_name']}');
      return CadastreResult.fromArcgis(
        serviceCode: code,
        attributes: attrs,
        geometry: geometry,
      );
    } catch (e) {
      // Tarmoq / parse xatosi — bu service'ni o'tkazib yuboramiz.
      _log('[$code] exception: $e');
      return null;
    }
  }

  /// `10:12:02:01:01:5420:0001:019` → `10:12:02:01:01:5420`.
  /// Standart yer uchastkasi 6 qismdan iborat; undan ortig'i — sub-obyekt.
  static String? _parentCadastre(String cad) {
    final parts = cad.split(':');
    if (parts.length > 6) return parts.sublist(0, 6).join(':');
    return null;
  }
}

/// Kadastr qidiruv natijasi (autofill uchun tayyor qiymatlar bilan).
class CadastreResult {
  CadastreResult({
    required this.cadastreNumber,
    required this.serviceCode,
    required this.attributes,
    this.regionName,
    this.districtName,
    this.mahallaName,
    this.propertyKindCode,
    this.unitTypeCode,
    this.landCategoryDescription,
    this.landTypeDescription,
    this.storeCount,
    this.height,
    this.areaSqm,
    this.latitude,
    this.longitude,
    this.isParentMatch = false,
  });

  final String cadastreNumber;
  final String serviceCode;
  final Map<String, dynamic> attributes;

  final String? regionName; // Viloyat / shahar
  final String? districtName; // Tuman
  final String? mahallaName; // Mahalla / MFY
  final String? propertyKindCode; // prop_kind_private_house, ...
  final String? unitTypeCode; // spatial_unit_type_land, ...
  final String? landCategoryDescription;
  final String? landTypeDescription;
  final int? storeCount; // qavatlar soni
  final double? height; // balandlik (m)
  final double? areaSqm; // maydon (kv.m) — geometriyadan yoki Shape__Area
  final double? latitude; // markaziy nuqta (WGS84)
  final double? longitude;

  /// Aniq kadastr topilmay, ota (parent) parcel topilgan bo'lsa `true`.
  final bool isParentMatch;

  CadastreResult copyWith({bool? isParentMatch}) => CadastreResult(
        cadastreNumber: cadastreNumber,
        serviceCode: serviceCode,
        attributes: attributes,
        regionName: regionName,
        districtName: districtName,
        mahallaName: mahallaName,
        propertyKindCode: propertyKindCode,
        unitTypeCode: unitTypeCode,
        landCategoryDescription: landCategoryDescription,
        landTypeDescription: landTypeDescription,
        storeCount: storeCount,
        height: height,
        areaSqm: areaSqm,
        latitude: latitude,
        longitude: longitude,
        isParentMatch: isParentMatch ?? this.isParentMatch,
      );

  factory CadastreResult.fromArcgis({
    required String serviceCode,
    required Map<String, dynamic> attributes,
    Map<String, dynamic>? geometry,
  }) {
    // Maydon: avval Shape__Area attributi, bo'lmasa geometriyadan (shoelace).
    double? area = _toDouble(
      attributes['Shape__Area'] ??
          attributes['Shape_Area'] ??
          attributes['shape_area'],
    );
    final rings = _ringsOf(geometry);
    if (area == null && rings != null) {
      area = _polygonArea(rings);
    }

    // Markaziy nuqta (UTM 42N → WGS84).
    double? lat;
    double? lng;
    final centroid = _centroidUtm(rings);
    if (centroid != null) {
      final latlng = _utmToLatLng(centroid[0], centroid[1]);
      lat = latlng[0];
      lng = latlng[1];
    }

    return CadastreResult(
      cadastreNumber: attributes['cadastral_number']?.toString() ?? '',
      serviceCode: serviceCode,
      attributes: attributes,
      regionName: _str(attributes['region_name']),
      districtName: _str(attributes['district_name']),
      mahallaName: _str(attributes['mahalla_name']),
      propertyKindCode: _str(attributes['property_kind']),
      unitTypeCode: _str(attributes['sp_unit_type']),
      landCategoryDescription:
          _str(attributes['land_fund_category_description']),
      landTypeDescription: _str(attributes['land_fund_type_description']),
      storeCount: _toInt(attributes['store_count']),
      height: _toDouble(attributes['height']),
      areaSqm: area,
      latitude: lat,
      longitude: lng,
    );
  }

  /// Obyekt turi (property_kind) — odam o'qiy oladigan o'zbekcha nom.
  String? get propertyKindLabel {
    final code = propertyKindCode;
    if (code == null) return null;
    return _propertyKindLabels[code] ?? _humanizeCode(code);
  }

  /// Yer uchastkasi turi (sp_unit_type) — o'zbekcha nom.
  String? get unitTypeLabel {
    final code = unitTypeCode;
    if (code == null) return null;
    return _unitTypeLabels[code] ?? _humanizeCode(code);
  }

  /// Eng to'liq mavjud obyekt tavsifi.
  String? get objectDescription =>
      propertyKindLabel ?? unitTypeLabel ?? landTypeDescription;

  static const Map<String, String> _propertyKindLabels = {
    'prop_kind_private_house': 'Yakka tartibdagi turar joy (uy)',
    'prop_kind_apartment': 'Kvartira (xonadon)',
    'prop_kind_multi_apartment': "Ko'p kvartirali uy",
    'prop_kind_commercial': 'Tijorat obyekti',
    'prop_kind_industrial': 'Sanoat obyekti',
    'prop_kind_garage': 'Garaj',
    'prop_kind_office': 'Ofis',
    'prop_kind_building': 'Bino',
    'prop_kind_construction': 'Inshoot',
    'prop_kind_land': 'Yer uchastkasi',
  };

  static const Map<String, String> _unitTypeLabels = {
    'spatial_unit_type_land': 'Yer uchastkasi',
    'spatial_unit_type_land_agr': "Qishloq xo'jaligi yeri",
    'spatial_unit_type_building': 'Bino',
    'spatial_unit_type_apartment': 'Xonadon',
  };

  static String _humanizeCode(String code) {
    var c = code;
    for (final p in ['prop_kind_', 'spatial_unit_type_', 'bu_type_']) {
      if (c.startsWith(p)) c = c.substring(p.length);
    }
    c = c.replaceAll('_', ' ').trim();
    if (c.isEmpty) return code;
    return c[0].toUpperCase() + c.substring(1);
  }

  // ── Parse helpers ──────────────────────────────────────────────────────

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static List<List<List<double>>>? _ringsOf(Map<String, dynamic>? geometry) {
    final rings = geometry?['rings'];
    if (rings is! List || rings.isEmpty) return null;
    final out = <List<List<double>>>[];
    for (final ring in rings) {
      if (ring is! List) continue;
      final pts = <List<double>>[];
      for (final p in ring) {
        if (p is List && p.length >= 2) {
          final x = _toDouble(p[0]);
          final y = _toDouble(p[1]);
          if (x != null && y != null) pts.add([x, y]);
        }
      }
      if (pts.length >= 3) out.add(pts);
    }
    return out.isEmpty ? null : out;
  }

  /// Shoelace formulasi — birinchi ring (tashqi kontur) maydoni (kv.m).
  static double _polygonArea(List<List<List<double>>> rings) {
    if (rings.isEmpty) return 0;
    final ring = rings.first;
    final n = ring.length;
    var s = 0.0;
    for (var i = 0; i < n; i++) {
      final x1 = ring[i][0], y1 = ring[i][1];
      final x2 = ring[(i + 1) % n][0], y2 = ring[(i + 1) % n][1];
      s += x1 * y2 - x2 * y1;
    }
    return s.abs() / 2.0;
  }

  static List<double>? _centroidUtm(List<List<List<double>>>? rings) {
    if (rings == null || rings.isEmpty) return null;
    final ring = rings.first;
    if (ring.length < 3) return null;
    var sx = 0.0, sy = 0.0;
    for (final p in ring) {
      sx += p[0];
      sy += p[1];
    }
    return [sx / ring.length, sy / ring.length];
  }

  /// UTM Zone 42N (EPSG:32642, WGS84) → [lat, lng] daraja.
  /// Snyder teskari formulasi (mm aniqlikda).
  static List<double> _utmToLatLng(double easting, double northing,
      {int zone = 42}) {
    const a = 6378137.0;
    const f = 1 / 298.257223563;
    const k0 = 0.9996;
    const e2 = f * (2 - f);
    final e1 = (1 - math.sqrt(1 - e2)) / (1 + math.sqrt(1 - e2));

    final x = easting - 500000.0;
    final m = northing / k0; // shimoliy yarim shar
    final mu =
        m / (a * (1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256));

    final phi1 = mu +
        (3 * e1 / 2 - 27 * e1 * e1 * e1 / 32) * math.sin(2 * mu) +
        (21 * e1 * e1 / 16 - 55 * e1 * e1 * e1 * e1 / 32) * math.sin(4 * mu) +
        (151 * e1 * e1 * e1 / 96) * math.sin(6 * mu) +
        (1097 * e1 * e1 * e1 * e1 / 512) * math.sin(8 * mu);

    final ep2 = e2 / (1 - e2);
    final cosPhi1 = math.cos(phi1);
    final sinPhi1 = math.sin(phi1);
    final tanPhi1 = math.tan(phi1);

    final c1 = ep2 * cosPhi1 * cosPhi1;
    final t1 = tanPhi1 * tanPhi1;
    final n1 = a / math.sqrt(1 - e2 * sinPhi1 * sinPhi1);
    final r1 =
        a * (1 - e2) / math.pow(1 - e2 * sinPhi1 * sinPhi1, 1.5).toDouble();
    final d = x / (n1 * k0);

    final lat = phi1 -
        (n1 * tanPhi1 / r1) *
            (d * d / 2 -
                (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * ep2) *
                    math.pow(d, 4) /
                    24 +
                (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 252 * ep2 - 3 * c1 * c1) *
                    math.pow(d, 6) /
                    720);

    final lng = (d -
            (1 + 2 * t1 + c1) * math.pow(d, 3) / 6 +
            (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * ep2 + 24 * t1 * t1) *
                math.pow(d, 5) /
                120) /
        cosPhi1;

    final lon0 = _deg2rad((zone * 6 - 183).toDouble());
    return [_rad2deg(lat), _rad2deg(lon0 + lng)];
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / math.pi;
}
