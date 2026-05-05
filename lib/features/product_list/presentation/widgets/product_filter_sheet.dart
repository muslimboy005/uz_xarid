import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uz_xarid/core/constants/api_urls.dart';
import 'package:uz_xarid/core/dio/dio_client.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/features/add_listing/domain/entities/category_field_entity.dart';
import 'package:uz_xarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Narx maydonlari: minglik bo‘shliq bilan (masalan 10 000 000).
String _formatSumInt(int n) {
  if (n < 0) n = 0;
  final s = n.toString();
  if (s.length <= 3) return s;
  final rem = s.length % 3;
  final first = rem == 0 ? 3 : rem;
  final buf = StringBuffer()..write(s.substring(0, first));
  for (var i = first; i < s.length; i += 3) {
    buf.write(' ');
    buf.write(s.substring(i, math.min(i + 3, s.length)));
  }
  return buf.toString();
}

int? _parseDigitsOnly(String? text) {
  if (text == null) return null;
  final d = text.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return null;
  return int.tryParse(d);
}

// ─── Model ────────────────────────────────────────────────────────────────────

class ProductFilterData {
  ProductFilterData({
    this.minPrice,
    this.maxPrice,
    this.hasDiscount = false,
    this.hasServices = false,
    this.selectedCategoryIndex = 0,
    this.selectedConditionIndex,
    this.selectedSellerTypeIndex,
    this.selectedColorIndex,
    this.selectedSizeIndex,
    this.vehiclePrimaryCategoryId,
    this.vehicleMark,
    this.vehicleModel,
    this.yearFrom,
    this.yearTo,
    this.probegFrom,
    this.probegTo,
    this.engineCcFrom,
    this.engineCcTo,
    this.enginePowerFrom,
    this.enginePowerTo,
    this.vehicleFuelType,
    this.vehicleTransmission,
    this.vehiclePrivod,
    this.vehicleBody,
    this.vehicleExteriorColor,
    this.vehicleConfiguration,
    this.vehiclePaymentType,
    this.onlyTop = false,
    this.dynamicFields = const {},
  });

  double? minPrice;
  double? maxPrice;
  bool hasDiscount;
  bool hasServices;
  int selectedCategoryIndex;
  int? selectedConditionIndex;
  int? selectedSellerTypeIndex;
  int? selectedColorIndex;
  int? selectedSizeIndex;

  /// Avto ro‘yxatida asosiy turkum (chip) — `null` «Barcha turkumlar».
  int? vehiclePrimaryCategoryId;
  String? vehicleMark;
  String? vehicleModel;
  int? yearFrom;
  int? yearTo;
  int? probegFrom;
  int? probegTo;
  int? engineCcFrom;
  int? engineCcTo;
  int? enginePowerFrom;
  int? enginePowerTo;
  String? vehicleFuelType;
  String? vehicleTransmission;
  String? vehiclePrivod;
  String? vehicleBody;
  String? vehicleExteriorColor;
  String? vehicleConfiguration;
  String? vehiclePaymentType;
  bool onlyTop;
  Map<String, dynamic> dynamicFields;

  ProductFilterData copyWith({
    double? minPrice,
    double? maxPrice,
    bool? hasDiscount,
    bool? hasServices,
    int? selectedCategoryIndex,
    int? selectedConditionIndex,
    int? selectedSellerTypeIndex,
    int? selectedColorIndex,
    int? selectedSizeIndex,
    int? vehiclePrimaryCategoryId,
    String? vehicleMark,
    String? vehicleModel,
    int? yearFrom,
    int? yearTo,
    int? probegFrom,
    int? probegTo,
    int? engineCcFrom,
    int? engineCcTo,
    int? enginePowerFrom,
    int? enginePowerTo,
    String? vehicleFuelType,
    String? vehicleTransmission,
    String? vehiclePrivod,
    String? vehicleBody,
    String? vehicleExteriorColor,
    String? vehicleConfiguration,
    String? vehiclePaymentType,
    bool? onlyTop,
    Map<String, dynamic>? dynamicFields,
  }) {
    return ProductFilterData(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      hasServices: hasServices ?? this.hasServices,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedConditionIndex:
          selectedConditionIndex ?? this.selectedConditionIndex,
      selectedSellerTypeIndex:
          selectedSellerTypeIndex ?? this.selectedSellerTypeIndex,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      selectedSizeIndex: selectedSizeIndex ?? this.selectedSizeIndex,
      vehiclePrimaryCategoryId:
          vehiclePrimaryCategoryId ?? this.vehiclePrimaryCategoryId,
      vehicleMark: vehicleMark ?? this.vehicleMark,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      probegFrom: probegFrom ?? this.probegFrom,
      probegTo: probegTo ?? this.probegTo,
      engineCcFrom: engineCcFrom ?? this.engineCcFrom,
      engineCcTo: engineCcTo ?? this.engineCcTo,
      enginePowerFrom: enginePowerFrom ?? this.enginePowerFrom,
      enginePowerTo: enginePowerTo ?? this.enginePowerTo,
      vehicleFuelType: vehicleFuelType ?? this.vehicleFuelType,
      vehicleTransmission: vehicleTransmission ?? this.vehicleTransmission,
      vehiclePrivod: vehiclePrivod ?? this.vehiclePrivod,
      vehicleBody: vehicleBody ?? this.vehicleBody,
      vehicleExteriorColor: vehicleExteriorColor ?? this.vehicleExteriorColor,
      vehicleConfiguration: vehicleConfiguration ?? this.vehicleConfiguration,
      vehiclePaymentType: vehiclePaymentType ?? this.vehiclePaymentType,
      onlyTop: onlyTop ?? this.onlyTop,
      dynamicFields: dynamicFields ?? this.dynamicFields,
    );
  }
}

/// Filtr varag‘i yopilganda: qo‘llash, tozalash yoki xarita rejimi.
class ProductFilterSheetResult {
  const ProductFilterSheetResult({
    this.filter,
    this.openMapView = false,
    this.clearedFilters = false,
  });

  /// «Qo‘llash» yoki «Xaritada ko‘rsatish» dagi joriy filtr holati.
  final ProductFilterData? filter;
  final bool openMapView;
  final bool clearedFilters;
}

/// Filtr varag‘i. [null] — yopildi (surib tashlash).
Future<ProductFilterSheetResult?> showProductFilterSheet(
  BuildContext context, {
  ProductFilterData? initial,
  bool vehicleListing = false,
  List<SubcategoryItem> vehiclePrimaryCategories = const [],
  int? currentVehiclePrimaryCategoryId,
  required String listingType,
  int? categoryId,
}) async {
  return showModalBottomSheet<ProductFilterSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductFilterSheet(
      initial: initial ?? ProductFilterData(),
      vehicleListing: vehicleListing,
      vehiclePrimaryCategories: vehiclePrimaryCategories,
      currentVehiclePrimaryCategoryId: currentVehiclePrimaryCategoryId,
      listingType: listingType,
      categoryId: categoryId,
    ),
  );
}

// ─── Sheet Widget ─────────────────────────────────────────────────────────────

class _ProductFilterSheet extends StatefulWidget {
  const _ProductFilterSheet({
    required this.initial,
    this.vehicleListing = false,
    this.vehiclePrimaryCategories = const [],
    this.currentVehiclePrimaryCategoryId,
    required this.listingType,
    this.categoryId,
  });
  final ProductFilterData initial;
  final bool vehicleListing;
  final List<SubcategoryItem> vehiclePrimaryCategories;
  final int? currentVehiclePrimaryCategoryId;
  final String listingType;
  final int? categoryId;

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  late ProductFilterData _data;
  List<CategoryFieldEntity> _dynamicFields = [];
  bool _dynamicFieldsLoading = false;
  final Map<String, TextEditingController> _dynamicControllers = {};

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  RangeValues _priceRange = const RangeValues(0, 10000000);
  static const double _maxSlider = 10000000;
  // Prevents text-field onChanged from firing when slider updates the controllers
  bool _updatingFromSlider = false;

  bool _categoryExpanded = true;
  bool _conditionExpanded = false;
  bool _sellerExpanded = false;
  bool _colorExpanded = true;
  bool _sizeExpanded = true;

  // ── Avto / mototexnika ────────────────────────────────────────────────────
  int? _vehiclePrimaryCategoryId;
  bool _vehicleCategoryExpanded = true;
  bool _vehicleMarkExpanded = true;
  bool _vehicleTechExpanded = true;
  bool _vehicleBodyExpanded = true;
  bool _vehicleConditionExpanded = true;

  final _vehicleModelCtrl = TextEditingController();
  final _yearFromCtrl = TextEditingController();
  final _yearToCtrl = TextEditingController();
  final _probegFromCtrl = TextEditingController();
  final _probegToCtrl = TextEditingController();
  final _engineCcFromCtrl = TextEditingController();
  final _engineCcToCtrl = TextEditingController();
  final _enginePowerFromCtrl = TextEditingController();
  final _enginePowerToCtrl = TextEditingController();
  final _vehicleConfigCtrl = TextEditingController();

  static const _vehicleMarks = ['CHEVROLET', 'HYUNDAI', 'KIA'];
  static const _fuelTypes = [
    ('BENZIN', 'benzin'),
    ('DIZEL', 'dizel'),
    ('GAZ', 'gaz'),
    ('ELEKTR', 'elektr'),
    ('GIBRID', 'gibrid'),
  ];
  static const _transmissions = [
    ('MEXANIKA', 'mexanika'),
    ('AVTOMAT', 'avtomat'),
    ('VARIATOR', 'variator'),
    ('ROBOT', 'robot'),
  ];
  static const _privods = [
    ('OLDINGI', 'oldingi'),
    ('ORQA', 'orqa'),
    ("TO'LIQ", 'tolik'),
  ];
  static const _bodies = [
    ('SEDAN', 'sedan'),
    ('XETCHBEK', 'xetchbek'),
    ('SUV', 'suv'),
    ('PIKAP', 'pikap'),
    ('KUPE', 'kupe'),
  ];
  static const _payments = [('NAQD', 'naqd'), ('KREDIT', 'kredit')];
  static const _vehicleConditions = ['Yangi', 'Ishlatilgan', 'Ta\'mir talab'];

  final _categories = const [
    'Barcha kategoriyalar',
    'Qurilish',
    'Mebel va jihozlar',
    'Sanitariya',
    'Mevali o\'simliklar',
    'Kimyoviy mahsulotlar',
    'Oziq-ovqat',
  ];

  final _conditions = const ['Yangi', 'Ishlatilgan', 'Remont kerak'];
  final _sellerTypes = const ['Jismoniy shaxs', 'Biznes'];

  final _colors = const [
    Color(0xFF9C27B0),
    Color(0xFFE53935),
    Color(0xFFEC407A),
    Color(0xFFF4A460),
    Color(0xFFFFEB3B),
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
    Color(0xFF4CAF50),
    Color(0xFF795548),
    Color(0xFF212121),
    Color(0xFF212121),
    Color(0xFF9E9E9E),
    Color(0xFFFFFFFF),
  ];

  final _sizes = const ['2XS', 'XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
    final min = _data.minPrice ?? 0;
    final max = _data.maxPrice ?? _maxSlider;
    _priceRange = RangeValues(min, max);

    _minCtrl.text = _formatSumInt(min > 0 ? min.toInt() : 0);
    _maxCtrl.text = _formatSumInt(
      max < _maxSlider ? max.toInt() : _maxSlider.toInt(),
    );

    if (widget.vehicleListing) {
      _vehiclePrimaryCategoryId =
          _data.vehiclePrimaryCategoryId ??
          widget.currentVehiclePrimaryCategoryId;
      if (_data.vehicleModel != null) {
        _vehicleModelCtrl.text = _data.vehicleModel!;
      }
      if (_data.yearFrom != null) {
        _yearFromCtrl.text = _data.yearFrom!.toString();
      }
      if (_data.yearTo != null) {
        _yearToCtrl.text = _data.yearTo!.toString();
      }
      if (_data.probegFrom != null) {
        _probegFromCtrl.text = _data.probegFrom!.toString();
      }
      if (_data.probegTo != null) {
        _probegToCtrl.text = _data.probegTo!.toString();
      }
      if (_data.engineCcFrom != null) {
        _engineCcFromCtrl.text = _data.engineCcFrom!.toString();
      }
      if (_data.engineCcTo != null) {
        _engineCcToCtrl.text = _data.engineCcTo!.toString();
      }
      if (_data.enginePowerFrom != null) {
        _enginePowerFromCtrl.text = _data.enginePowerFrom!.toString();
      }
      if (_data.enginePowerTo != null) {
        _enginePowerToCtrl.text = _data.enginePowerTo!.toString();
      }
      if (_data.vehicleConfiguration != null) {
        _vehicleConfigCtrl.text = _data.vehicleConfiguration!;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDynamicFields();
    });
  }

  Future<void> _loadDynamicFields() async {
    setState(() => _dynamicFieldsLoading = true);
    try {
      final dio = getIt<DioClient>().dio;
      final response = await dio.get(
        ApiUrls.categoryFields,
        queryParameters: {
          'listing_type': widget.listingType,
          if (widget.categoryId != null) 'category': widget.categoryId,
        },
      );
      final raw = response.data;
      if (raw is! Map) {
        setState(() {
          _dynamicFields = [];
          _dynamicFieldsLoading = false;
        });
        return;
      }
      final map = raw.cast<String, dynamic>();
      final listRaw = map['data'];
      if (listRaw is! List) {
        setState(() {
          _dynamicFields = [];
          _dynamicFieldsLoading = false;
        });
        return;
      }
      final parsed = <CategoryFieldEntity>[];
      for (final e in listRaw) {
        if (e is Map<String, dynamic>) {
          parsed.add(CategoryFieldEntity.fromJson(e));
        } else if (e is Map) {
          parsed.add(CategoryFieldEntity.fromJson(e.cast<String, dynamic>()));
        }
      }
      if (!mounted) return;
      setState(() {
        _dynamicFields = parsed;
        _dynamicFieldsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dynamicFields = [];
        _dynamicFieldsLoading = false;
      });
    }
  }

  bool _isDynamicVisible(CategoryFieldEntity field) {
    final cond = field.condition;
    if (cond == null) return true;
    final current = _data.dynamicFields[cond.field];
    return current?.toString() == cond.equals;
  }

  TextEditingController _controllerForField(String key) {
    return _dynamicControllers.putIfAbsent(key, () {
      final c = TextEditingController();
      final initial = _data.dynamicFields[key];
      if (initial != null) c.text = initial.toString();
      return c;
    });
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _yearFromCtrl.dispose();
    _yearToCtrl.dispose();
    _probegFromCtrl.dispose();
    _probegToCtrl.dispose();
    _engineCcFromCtrl.dispose();
    _engineCcToCtrl.dispose();
    _enginePowerFromCtrl.dispose();
    _enginePowerToCtrl.dispose();
    _vehicleConfigCtrl.dispose();
    for (final c in _dynamicControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _reset() {
    Navigator.of(
      context,
    ).pop(const ProductFilterSheetResult(clearedFilters: true));
  }

  int? _parseIntCtrl(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  ProductFilterData _snapshotFilter() {
    final dynamicMap = <String, dynamic>{};
    for (final field in _dynamicFields.where(_isDynamicVisible)) {
      final type = field.type.toLowerCase();
      dynamic val;
      if (type == 'text' || type == 'number') {
        val = _dynamicControllers[field.name]?.text.trim();
      } else {
        val = _data.dynamicFields[field.name];
      }
      if (val != null && (val is! String || val.isNotEmpty)) {
        dynamicMap[field.name] = val;
      }
    }
    if (widget.vehicleListing) {
      return ProductFilterData(
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < _maxSlider ? _priceRange.end : null,
        hasDiscount: _data.hasDiscount,
        hasServices: false,
        selectedConditionIndex: _data.selectedConditionIndex,
        vehiclePrimaryCategoryId: _vehiclePrimaryCategoryId,
        vehicleMark: _data.vehicleMark,
        vehicleModel: _vehicleModelCtrl.text.trim().isEmpty
            ? null
            : _vehicleModelCtrl.text.trim(),
        yearFrom: _parseIntCtrl(_yearFromCtrl),
        yearTo: _parseIntCtrl(_yearToCtrl),
        probegFrom: _parseIntCtrl(_probegFromCtrl),
        probegTo: _parseIntCtrl(_probegToCtrl),
        engineCcFrom: _parseIntCtrl(_engineCcFromCtrl),
        engineCcTo: _parseIntCtrl(_engineCcToCtrl),
        enginePowerFrom: _parseIntCtrl(_enginePowerFromCtrl),
        enginePowerTo: _parseIntCtrl(_enginePowerToCtrl),
        vehicleFuelType: _data.vehicleFuelType,
        vehicleTransmission: _data.vehicleTransmission,
        vehiclePrivod: _data.vehiclePrivod,
        vehicleBody: _data.vehicleBody,
        selectedColorIndex: _data.selectedColorIndex,
        vehicleConfiguration: _vehicleConfigCtrl.text.trim().isEmpty
            ? null
            : _vehicleConfigCtrl.text.trim(),
        vehiclePaymentType: _data.vehiclePaymentType,
        onlyTop: _data.onlyTop,
        dynamicFields: dynamicMap,
      );
    }
    return ProductFilterData(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxSlider ? _priceRange.end : null,
      hasDiscount: _data.hasDiscount,
      hasServices: _data.hasServices,
      selectedCategoryIndex: _data.selectedCategoryIndex,
      selectedConditionIndex: _data.selectedConditionIndex,
      selectedSellerTypeIndex: _data.selectedSellerTypeIndex,
      selectedColorIndex: _data.selectedColorIndex,
      selectedSizeIndex: _data.selectedSizeIndex,
      dynamicFields: dynamicMap,
    );
  }

  /// Matn chip emas — dumaloq rang namunalari (mahsulot va avto filtrlarda bir xil).
  List<Widget> _buildRangFilterSection({
    required Color border,
    required Color textSecondary,
  }) {
    return [
      _SectionHeader(
        title: 'Rang',
        expanded: _colorExpanded,
        trailing: _data.selectedColorIndex != null
            ? _ColorLabel(
                color: _colors[_data.selectedColorIndex!],
                textColor: textSecondary,
              )
            : null,
        onToggle: () => setState(() => _colorExpanded = !_colorExpanded),
      ),
      if (_colorExpanded) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _colors.asMap().entries.map((e) {
            final sel = _data.selectedColorIndex == e.key;
            final isWhite = e.value == const Color(0xFFFFFFFF);
            return GestureDetector(
              onTap: () =>
                  setState(() => _data.selectedColorIndex = sel ? null : e.key),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sel
                        ? AppColors.primary
                        : isWhite
                        ? border
                        : Colors.transparent,
                    width: sel ? 2.5 : 1,
                  ),
                ),
                child: sel
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: isWhite ? Colors.black : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _vehiclePlainField({
    required TextEditingController controller,
    required String hint,
    required Color border,
    required Color textPrimary,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textPrimary.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _vehicleDualNum({
    required Color border,
    required Color textPrimary,
    required TextEditingController a,
    required TextEditingController b,
    String hintA = 'dan',
    String hintB = 'gacha',
  }) {
    return Row(
      children: [
        Expanded(
          child: _PriceField(
            controller: a,
            hint: hintA,
            borderColor: border,
            textColor: textPrimary,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PriceField(
            controller: b,
            hint: hintB,
            borderColor: border,
            textColor: textPrimary,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVehicleFilterBody({
    required Color border,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return [
      _SectionHeader(title: 'Summa', expanded: true, onToggle: null),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _SumPriceField(
              controller: _minCtrl,
              hint: 'Dan',
              borderColor: border,
              textColor: textPrimary,
              maxValue: _maxSlider.toInt(),
              onChanged: (v) {
                if (_updatingFromSlider) return;
                final parsed = _parseDigitsOnly(v) ?? 0;
                final val = parsed
                    .toDouble()
                    .clamp(0.0, _priceRange.end)
                    .toDouble();
                setState(() {
                  _priceRange = RangeValues(val, _priceRange.end);
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SumPriceField(
              controller: _maxCtrl,
              hint: 'Gacha',
              borderColor: border,
              textColor: textPrimary,
              maxValue: _maxSlider.toInt(),
              onChanged: (v) {
                if (_updatingFromSlider) return;
                final parsed = _parseDigitsOnly(v);
                final val = (parsed ?? _maxSlider.toInt())
                    .toDouble()
                    .clamp(_priceRange.start, _maxSlider)
                    .toDouble();
                setState(() {
                  _priceRange = RangeValues(_priceRange.start, val);
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: border,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withValues(alpha: 0.12),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        ),
        child: RangeSlider(
          values: _priceRange,
          min: 0,
          max: _maxSlider,
          onChanged: (v) {
            _updatingFromSlider = true;
            setState(() {
              _priceRange = v;
              _minCtrl.text = _formatSumInt(v.start > 0 ? v.start.toInt() : 0);
              _maxCtrl.text = _formatSumInt(
                v.end < _maxSlider ? v.end.toInt() : _maxSlider.toInt(),
              );
            });
            _updatingFromSlider = false;
          },
        ),
      ),
      const SizedBox(height: 4),
      Divider(color: border),
      _ToggleRow(
        title: 'Chegirmalar va aksiyalar',
        value: _data.hasDiscount,
        textColor: textPrimary,
        onChanged: (v) => setState(() => _data.hasDiscount = v),
      ),
      Divider(color: border),
      _ToggleRow(
        title: 'Faqat TOP',
        value: _data.onlyTop,
        textColor: textPrimary,
        onChanged: (v) => setState(() => _data.onlyTop = v),
      ),
      Divider(color: border),
      _SectionHeader(
        title: 'Kategoriya',
        expanded: _vehicleCategoryExpanded,
        onToggle: () => setState(
          () => _vehicleCategoryExpanded = !_vehicleCategoryExpanded,
        ),
      ),
      if (_vehicleCategoryExpanded) ...[
        const SizedBox(height: 8),
        if (widget.vehiclePrimaryCategories.isEmpty)
          Text(
            'Kategoriyani tanlang',
            style: TextStyle(color: textSecondary, fontSize: 14),
          )
        else ...[
          _vehicleCategoryRadioRow(
            border: border,
            textPrimary: textPrimary,
            label: 'Barcha turkumlar',
            selected: _vehiclePrimaryCategoryId == null,
            onTap: () => setState(() => _vehiclePrimaryCategoryId = null),
          ),
          ...widget.vehiclePrimaryCategories.map(
            (s) => _vehicleCategoryRadioRow(
              border: border,
              textPrimary: textPrimary,
              label: s.name,
              selected: _vehiclePrimaryCategoryId == s.id,
              onTap: () => setState(() => _vehiclePrimaryCategoryId = s.id),
            ),
          ),
        ],
        const SizedBox(height: 4),
      ],
      Divider(color: border),
      _SectionHeader(
        title: 'MARKA',
        expanded: _vehicleMarkExpanded,
        onToggle: () =>
            setState(() => _vehicleMarkExpanded = !_vehicleMarkExpanded),
      ),
      if (_vehicleMarkExpanded) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _vehicleMarks.map((m) {
            final sel = _data.vehicleMark == m;
            return _ChipButton(
              label: m,
              selected: sel,
              card: card,
              border: border,
              textColor: textPrimary,
              onTap: () => setState(() => _data.vehicleMark = sel ? null : m),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
      Divider(color: border),
      Text(
        'MODEL',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      _vehiclePlainField(
        controller: _vehicleModelCtrl,
        hint: 'MODEL',
        border: border,
        textPrimary: textPrimary,
      ),
      const SizedBox(height: 12),
      Divider(color: border),
      Text(
        'ISHLAB CHIQARILGAN YIL',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      _vehicleDualNum(
        border: border,
        textPrimary: textPrimary,
        a: _yearFromCtrl,
        b: _yearToCtrl,
        hintA: 'dan',
        hintB: 'gacha',
      ),
      const SizedBox(height: 12),
      Divider(color: border),
      Text(
        'PROBEG (KM)',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      _vehicleDualNum(
        border: border,
        textPrimary: textPrimary,
        a: _probegFromCtrl,
        b: _probegToCtrl,
      ),
      const SizedBox(height: 12),
      Divider(color: border),
      Text(
        'DVIGATEL HAJMI (SM³)',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      _vehicleDualNum(
        border: border,
        textPrimary: textPrimary,
        a: _engineCcFromCtrl,
        b: _engineCcToCtrl,
      ),
      const SizedBox(height: 12),
      Divider(color: border),
      Text(
        'DVIGATEL QUVVATI',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      _vehicleDualNum(
        border: border,
        textPrimary: textPrimary,
        a: _enginePowerFromCtrl,
        b: _enginePowerToCtrl,
      ),
      const SizedBox(height: 12),
      Divider(color: border),
      _SectionHeader(
        title: 'YOQULGI TURI',
        expanded: _vehicleTechExpanded,
        onToggle: () =>
            setState(() => _vehicleTechExpanded = !_vehicleTechExpanded),
      ),
      if (_vehicleTechExpanded) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _fuelTypes.map((e) {
            final sel = _data.vehicleFuelType == e.$2;
            return _ChipButton(
              label: e.$1,
              selected: sel,
              card: card,
              border: border,
              textColor: textPrimary,
              onTap: () =>
                  setState(() => _data.vehicleFuelType = sel ? null : e.$2),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'TRANSMISSIYA TURI',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _transmissions.map((e) {
            final sel = _data.vehicleTransmission == e.$2;
            return _ChipButton(
              label: e.$1,
              selected: sel,
              card: card,
              border: border,
              textColor: textPrimary,
              onTap: () =>
                  setState(() => _data.vehicleTransmission = sel ? null : e.$2),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'PRIVOD',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _privods.map((e) {
            final sel = _data.vehiclePrivod == e.$2;
            return _ChipButton(
              label: e.$1,
              selected: sel,
              card: card,
              border: border,
              textColor: textPrimary,
              onTap: () =>
                  setState(() => _data.vehiclePrivod = sel ? null : e.$2),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
      Divider(color: border),
      _SectionHeader(
        title: 'KUZOV TURI',
        expanded: _vehicleBodyExpanded,
        onToggle: () =>
            setState(() => _vehicleBodyExpanded = !_vehicleBodyExpanded),
      ),
      if (_vehicleBodyExpanded) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _bodies.map((e) {
            final sel = _data.vehicleBody == e.$2;
            return _ChipButton(
              label: e.$1,
              selected: sel,
              card: card,
              border: border,
              textColor: textPrimary,
              onTap: () =>
                  setState(() => _data.vehicleBody = sel ? null : e.$2),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
      Divider(color: border),
      ..._buildRangFilterSection(border: border, textSecondary: textSecondary),
      Divider(color: border),
      _SectionHeader(
        title: 'HOLATI',
        expanded: _vehicleConditionExpanded,
        onToggle: () => setState(
          () => _vehicleConditionExpanded = !_vehicleConditionExpanded,
        ),
      ),
      if (_vehicleConditionExpanded) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _vehicleConditions.asMap().entries.map((e) {
            final sel = _data.selectedConditionIndex == e.key;
            return _ChipButton(
              label: e.value,
              selected: sel,
              card: card,
              border: border,
              textColor: textPrimary,
              onTap: () => setState(
                () => _data.selectedConditionIndex = sel ? null : e.key,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
      Divider(color: border),
      Text(
        'KOMPLEKTATSIYA',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      _vehiclePlainField(
        controller: _vehicleConfigCtrl,
        hint: 'KOMPLEKTATSIYA',
        border: border,
        textPrimary: textPrimary,
      ),
      const SizedBox(height: 12),
      Divider(color: border),
      Text(
        "TO'LOV TURI",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _payments.map((e) {
          final sel = _data.vehiclePaymentType == e.$2;
          return _ChipButton(
            label: e.$1,
            selected: sel,
            card: card,
            border: border,
            textColor: textPrimary,
            onTap: () =>
                setState(() => _data.vehiclePaymentType = sel ? null : e.$2),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget _vehicleCategoryRadioRow({
    required Color border,
    required Color textPrimary,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _apply() => Navigator.of(
    context,
  ).pop(ProductFilterSheetResult(filter: _snapshotFilter()));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final border = context.borderColor;
    final card = context.surfaceContainer;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Filtrlar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _reset,
                    child: Text(
                      'Tozalash',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: border, height: 1),
            // Scrollable content
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  _FilterMapPreviewCard(
                    textPrimary: textPrimary,
                    onShowOnMap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(
                        ProductFilterSheetResult(
                          filter: _snapshotFilter(),
                          openMapView: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Divider(color: border),
                  if (widget.vehicleListing)
                    ..._buildVehicleFilterBody(
                      border: border,
                      card: card,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    )
                  else ...[
                    // ── Price Range ──────────────────────────────────────────
                    _SectionHeader(
                      title: 'Narx oralig\'i',
                      expanded: true,
                      onToggle: null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SumPriceField(
                            controller: _minCtrl,
                            hint: 'Dan',
                            borderColor: border,
                            textColor: textPrimary,
                            maxValue: _maxSlider.toInt(),
                            onChanged: (v) {
                              if (_updatingFromSlider) return;
                              final parsed = _parseDigitsOnly(v) ?? 0;
                              final val = parsed
                                  .toDouble()
                                  .clamp(0.0, _priceRange.end)
                                  .toDouble();
                              setState(() {
                                _priceRange = RangeValues(val, _priceRange.end);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SumPriceField(
                            controller: _maxCtrl,
                            hint: 'Gacha',
                            borderColor: border,
                            textColor: textPrimary,
                            maxValue: _maxSlider.toInt(),
                            onChanged: (v) {
                              if (_updatingFromSlider) return;
                              final parsed = _parseDigitsOnly(v);
                              final val = (parsed ?? _maxSlider.toInt())
                                  .toDouble()
                                  .clamp(_priceRange.start, _maxSlider)
                                  .toDouble();
                              setState(() {
                                _priceRange = RangeValues(
                                  _priceRange.start,
                                  val,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: border,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withValues(alpha: 0.12),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: _maxSlider,
                        onChanged: (v) {
                          _updatingFromSlider = true;
                          setState(() {
                            _priceRange = v;
                            _minCtrl.text = _formatSumInt(
                              v.start > 0 ? v.start.toInt() : 0,
                            );
                            _maxCtrl.text = _formatSumInt(
                              v.end < _maxSlider
                                  ? v.end.toInt()
                                  : _maxSlider.toInt(),
                            );
                          });
                          _updatingFromSlider = false;
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Divider(color: border),
                    // ── Toggles ──────────────────────────────────────────────
                    _ToggleRow(
                      title: 'Chegirma va aksiyalar',
                      value: _data.hasDiscount,
                      textColor: textPrimary,
                      onChanged: (v) => setState(() => _data.hasDiscount = v),
                    ),
                    Divider(color: border),
                    _ToggleRow(
                      title: 'Tegishli xizmatlar',
                      value: _data.hasServices,
                      textColor: textPrimary,
                      onChanged: (v) => setState(() => _data.hasServices = v),
                    ),
                    Divider(color: border),
                    // ── Category ─────────────────────────────────────────────
                    _SectionHeader(
                      title: 'Kategoriya',
                      expanded: _categoryExpanded,
                      onToggle: () => setState(
                        () => _categoryExpanded = !_categoryExpanded,
                      ),
                    ),
                    if (_categoryExpanded) ...[
                      const SizedBox(height: 8),
                      ..._categories.asMap().entries.map((e) {
                        final selected = _data.selectedCategoryIndex == e.key;
                        return InkWell(
                          onTap: () => setState(
                            () => _data.selectedCategoryIndex = e.key,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : border,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  e.value,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 15,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                    ],
                    Divider(color: border),
                    // ── Condition ────────────────────────────────────────────
                    _SectionHeader(
                      title: 'Holat',
                      expanded: _conditionExpanded,
                      onToggle: () => setState(
                        () => _conditionExpanded = !_conditionExpanded,
                      ),
                    ),
                    if (_conditionExpanded) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _conditions.asMap().entries.map((e) {
                          final sel = _data.selectedConditionIndex == e.key;
                          return _ChipButton(
                            label: e.value,
                            selected: sel,
                            card: card,
                            border: border,
                            textColor: textPrimary,
                            onTap: () => setState(
                              () => _data.selectedConditionIndex = sel
                                  ? null
                                  : e.key,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Divider(color: border),
                    // ── Seller Type ──────────────────────────────────────────
                    _SectionHeader(
                      title: 'Sotuvchi turi',
                      expanded: _sellerExpanded,
                      onToggle: () =>
                          setState(() => _sellerExpanded = !_sellerExpanded),
                    ),
                    if (_sellerExpanded) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sellerTypes.asMap().entries.map((e) {
                          final sel = _data.selectedSellerTypeIndex == e.key;
                          return _ChipButton(
                            label: e.value,
                            selected: sel,
                            card: card,
                            border: border,
                            textColor: textPrimary,
                            onTap: () => setState(
                              () => _data.selectedSellerTypeIndex = sel
                                  ? null
                                  : e.key,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Divider(color: border),
                    // ── Color (dumaloq namunalar) ───────────────────────────
                    ..._buildRangFilterSection(
                      border: border,
                      textSecondary: textSecondary,
                    ),
                    Divider(color: border),
                    // ── Size ─────────────────────────────────────────────────
                    _SectionHeader(
                      title: 'O\'lcham',
                      expanded: _sizeExpanded,
                      onToggle: () =>
                          setState(() => _sizeExpanded = !_sizeExpanded),
                    ),
                    if (_sizeExpanded) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sizes.asMap().entries.map((e) {
                          final sel = _data.selectedSizeIndex == e.key;
                          return _ChipButton(
                            label: e.value,
                            selected: sel,
                            card: card,
                            border: border,
                            textColor: textPrimary,
                            onTap: () => setState(
                              () =>
                                  _data.selectedSizeIndex = sel ? null : e.key,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                  if (_dynamicFieldsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_dynamicFields.isNotEmpty) ...[
                    Divider(color: border),
                    _SectionHeader(
                      title: "Qo'shimcha filtrlar",
                      expanded: true,
                      onToggle: null,
                    ),
                    const SizedBox(height: 8),
                    ..._dynamicFields.where(_isDynamicVisible).map((field) {
                      final type = field.type.toLowerCase();
                      if (type == 'checkbox') {
                        final checked = _data.dynamicFields[field.name] == true;
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            field.label,
                            style: TextStyle(color: textPrimary),
                          ),
                          value: checked,
                          onChanged: (v) {
                            setState(
                              () => _data.dynamicFields[field.name] = v == true,
                            );
                          },
                        );
                      }
                      if (type == 'select') {
                        final selected = _data.dynamicFields[field.name]
                            ?.toString();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DropdownButtonFormField<String>(
                            initialValue: selected,
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: field.options
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                    value: e.value,
                                    child: Text(e.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(
                                () => _data.dynamicFields[field.name] = v,
                              );
                            },
                          ),
                        );
                      }
                      final c = _controllerForField(field.name);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: c,
                          keyboardType: type == 'number'
                              ? TextInputType.number
                              : TextInputType.text,
                          onChanged: (v) {
                            _data.dynamicFields[field.name] = v;
                          },
                          decoration: InputDecoration(
                            labelText: field.label,
                            hintText: field.placeholder,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // ── Apply Button ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.of(context).viewPadding.bottom,
              ),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Qo\'llash',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small Helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.expanded,
    required this.onToggle,
    this.trailing,
  });
  final String title;
  final bool expanded;
  final VoidCallback? onToggle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const Spacer(),
            ?trailing,
            if (onToggle != null) ...[
              const SizedBox(width: 8),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: context.textSecondary,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.textColor,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Narx: faqat raqam, ko‘rinishda minglik bo‘shliq.
class _SumThousandsFormatter extends TextInputFormatter {
  _SumThousandsFormatter({required this.maxValue});
  final int maxValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    var n = int.tryParse(d) ?? 0;
    if (n > maxValue) n = maxValue;
    final formatted = _formatSumInt(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _SumPriceField extends StatelessWidget {
  const _SumPriceField({
    required this.controller,
    required this.hint,
    required this.borderColor,
    required this.textColor,
    required this.onChanged,
    required this.maxValue,
  });
  final TextEditingController controller;
  final String hint;
  final Color borderColor;
  final Color textColor;
  final ValueChanged<String> onChanged;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_SumThousandsFormatter(maxValue: maxValue)],
      onChanged: onChanged,
      style: TextStyle(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.hint,
    required this.borderColor,
    required this.textColor,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final Color borderColor;
  final Color textColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: TextStyle(color: textColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.card,
    required this.border,
    required this.textColor,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color card;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }
}

class _ColorLabel extends StatelessWidget {
  const _ColorLabel({required this.color, required this.textColor});
  final Color color;
  final Color textColor;

  String _colorName(Color c) {
    const names = {
      0xFF9C27B0: 'Binafsha',
      0xFFE53935: 'Qizil',
      0xFFEC407A: 'Pushti',
      0xFFF4A460: 'To\'q sariq',
      0xFFFFEB3B: 'Sariq',
      0xFF2196F3: 'Ko\'k',
      0xFF64B5F6: 'Och ko\'k',
      0xFF4CAF50: 'Yashil',
      0xFF795548: 'Jigarrang',
      0xFF212121: 'Qora',
      0xFF9E9E9E: 'Kulrang',
      0xFFFFFFFF: 'Oq',
    };
    return names[c.toARGB32()] ?? 'Rang';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _colorName(color),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Filtr varag‘ida Yandex xarita preview (chizma emas).
class _FilterMapPreviewCard extends StatefulWidget {
  const _FilterMapPreviewCard({
    required this.textPrimary,
    required this.onShowOnMap,
  });
  final Color textPrimary;
  final VoidCallback onShowOnMap;

  @override
  State<_FilterMapPreviewCard> createState() => _FilterMapPreviewCardState();
}

class _FilterMapPreviewCardState extends State<_FilterMapPreviewCard> {
  /// Yandex coverage so‘rovi bilan mos boshlang‘ich nuqta (ll, z=14).
  static const Point _kCenter = Point(
    latitude: 41.32178969,
    longitude: 69.24735733,
  );

  static const double _kInitialZoom = 14;

  bool _mapVisible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _mapVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFFEEF2F6),
              child: _mapVisible
                  ? IgnorePointer(
                      ignoring: true,
                      child: YandexMap(
                        mode2DEnabled: true,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        onMapCreated: (YandexMapController c) {
                          c.moveCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _kCenter,
                                zoom: _kInitialZoom,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            Center(
              child: Material(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: widget.onShowOnMap,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Text(
                      'Xaritada ko\'rsatish',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
