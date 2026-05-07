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

/// Narx maydonlari: minglik bo'shliq bilan (masalan 10 000 000).
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
    this.onlyTop = false,
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
    this.dynamicFields = const {},
  });

  double? minPrice;
  double? maxPrice;
  bool hasDiscount;
  bool hasServices;
  bool onlyTop;

  int selectedCategoryIndex;
  int? selectedConditionIndex;
  int? selectedSellerTypeIndex;
  int? selectedColorIndex;
  int? selectedSizeIndex;

  /// Avto ro'yxatida asosiy turkum (chip) — `null` «Barcha turkumlar».
  int? vehiclePrimaryCategoryId;

  // Quyidagi maydonlar — orqaga moslik uchun saqlanadi (ko'pincha null bo'ladi).
  // Yangi filtr UI dynamicFields orqali ishlaydi.
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

  /// API dan kelgan field nomlari bilan kalitlanadigan filtr qiymatlari.
  /// select → String, multiselect → `List<String>`, range → `{name}_min`/`{name}_max`,
  /// text/number → String, checkbox → bool.
  Map<String, dynamic> dynamicFields;

  ProductFilterData copyWith({
    double? minPrice,
    double? maxPrice,
    bool? hasDiscount,
    bool? hasServices,
    bool? onlyTop,
    int? selectedCategoryIndex,
    int? selectedConditionIndex,
    int? selectedSellerTypeIndex,
    int? selectedColorIndex,
    int? selectedSizeIndex,
    int? vehiclePrimaryCategoryId,
    Map<String, dynamic>? dynamicFields,
  }) {
    return ProductFilterData(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      hasServices: hasServices ?? this.hasServices,
      onlyTop: onlyTop ?? this.onlyTop,
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
      dynamicFields: dynamicFields ?? this.dynamicFields,
    );
  }
}

/// Filtr varag'i yopilganda: qo'llash, tozalash yoki xarita rejimi.
class ProductFilterSheetResult {
  const ProductFilterSheetResult({
    this.filter,
    this.openMapView = false,
    this.clearedFilters = false,
  });

  final ProductFilterData? filter;
  final bool openMapView;
  final bool clearedFilters;
}

/// Filtr varag'i. [null] — yopildi (surib tashlash).
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
  String? _dynamicFieldsError;

  /// Har bir field uchun dropdown/section ochilgan-yopilgan holati.
  final Map<String, bool> _sectionExpanded = {};
  final Map<String, TextEditingController> _textControllers = {};

  /// Range fieldlar uchun lokal slayder qiymatlari.
  final Map<String, RangeValues> _rangeValues = {};
  final Map<String, double> _rangeMax = {};
  final Map<String, TextEditingController> _rangeMinCtrl = {};
  final Map<String, TextEditingController> _rangeMaxCtrl = {};
  bool _updatingFromSlider = false;

  // ── Narx ──────────────────────────────────────────────────────────────────
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 10000000);
  static const double _maxSlider = 10000000;
  bool _updatingPriceFromSlider = false;
  bool _priceExpanded = true;

  // ── Avto: asosiy turkum (Auto kategoriyasi uchun chiplar) ─────────────────
  int? _vehiclePrimaryCategoryId;
  bool _vehicleCategoryExpanded = true;

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
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDynamicFields();
    });
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    for (final c in _rangeMinCtrl.values) {
      c.dispose();
    }
    for (final c in _rangeMaxCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDynamicFields() async {
    setState(() {
      _dynamicFieldsLoading = true;
      _dynamicFieldsError = null;
    });
    try {
      final dio = getIt<DioClient>().dio;
      final response = await dio.get(
        ApiUrls.categoryFieldsUsed,
        queryParameters: {
          'listing_type': widget.listingType,
          if (widget.categoryId != null) 'category': widget.categoryId,
        },
      );
      final raw = response.data;
      final listRaw = raw is Map ? raw['data'] : null;
      final parsed = <CategoryFieldEntity>[];
      if (listRaw is List) {
        for (final e in listRaw) {
          if (e is Map<String, dynamic>) {
            parsed.add(CategoryFieldEntity.fromJson(e));
          } else if (e is Map) {
            parsed.add(CategoryFieldEntity.fromJson(e.cast<String, dynamic>()));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _dynamicFields = parsed;
        _dynamicFieldsLoading = false;
        for (final f in parsed) {
          _sectionExpanded.putIfAbsent(f.name, () => true);
          if (f.type.toLowerCase() == 'range') {
            _ensureRangeState(f);
          } else if (_isTextLike(f.type)) {
            _ensureTextController(f);
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dynamicFields = [];
        _dynamicFieldsLoading = false;
        _dynamicFieldsError = e.toString();
      });
    }
  }

  bool _isTextLike(String type) {
    final t = type.toLowerCase();
    return t == 'text' || t == 'number';
  }

  void _ensureTextController(CategoryFieldEntity field) {
    _textControllers.putIfAbsent(field.name, () {
      final c = TextEditingController();
      final initial = _data.dynamicFields[field.name];
      if (initial != null) c.text = initial.toString();
      return c;
    });
  }

  void _ensureRangeState(CategoryFieldEntity field) {
    if (_rangeMinCtrl.containsKey(field.name)) return;
    final maxVal = _rangeMaxFor(field);
    final initMin = (_data.dynamicFields['${field.name}_min'] as num?)
            ?.toDouble() ??
        0;
    final initMax = (_data.dynamicFields['${field.name}_max'] as num?)
            ?.toDouble() ??
        maxVal;
    _rangeMax[field.name] = maxVal;
    _rangeValues[field.name] =
        RangeValues(initMin.clamp(0, maxVal), initMax.clamp(0, maxVal));
    _rangeMinCtrl[field.name] =
        TextEditingController(text: _formatSumInt(initMin.toInt()));
    _rangeMaxCtrl[field.name] =
        TextEditingController(text: _formatSumInt(initMax.toInt()));
  }

  double _rangeMaxFor(CategoryFieldEntity field) {
    final m = field.name.toLowerCase();
    if (m.contains('probeg')) return 1000000;
    if (m.contains('year') || m.contains('manufacture')) return 2025;
    if (m.contains('engine') && m.contains('power')) return 1000;
    if (m.contains('engine')) return 10000;
    return 1000000;
  }

  bool _isVisible(CategoryFieldEntity field) {
    final cond = field.condition;
    if (cond == null) return true;
    final current = _data.dynamicFields[cond.field];
    if (current == null) return false;
    if (current is List) return current.contains(cond.equals);
    return current.toString() == cond.equals;
  }

  void _reset() {
    Navigator.of(
      context,
    ).pop(const ProductFilterSheetResult(clearedFilters: true));
  }

  ProductFilterData _snapshot() {
    final dynamicMap = <String, dynamic>{};
    for (final f in _dynamicFields.where(_isVisible)) {
      final type = f.type.toLowerCase();
      if (type == 'select') {
        final v = _data.dynamicFields[f.name];
        if (v is String && v.isNotEmpty) dynamicMap[f.name] = v;
      } else if (type == 'multiselect') {
        final v = _data.dynamicFields[f.name];
        if (v is List && v.isNotEmpty) {
          dynamicMap[f.name] = v.join(',');
        }
      } else if (type == 'range') {
        final r = _rangeValues[f.name];
        final maxVal = _rangeMax[f.name] ?? 0;
        if (r != null) {
          if (r.start > 0) dynamicMap['${f.name}_min'] = r.start.toInt();
          if (r.end < maxVal) dynamicMap['${f.name}_max'] = r.end.toInt();
        }
      } else if (type == 'checkbox') {
        if (_data.dynamicFields[f.name] == true) {
          dynamicMap[f.name] = true;
        }
      } else if (_isTextLike(type)) {
        final v = _textControllers[f.name]?.text.trim() ?? '';
        if (v.isNotEmpty) dynamicMap[f.name] = v;
      }
    }
    return ProductFilterData(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxSlider ? _priceRange.end : null,
      hasDiscount: _data.hasDiscount,
      hasServices: _data.hasServices,
      onlyTop: _data.onlyTop,
      selectedCategoryIndex: _data.selectedCategoryIndex,
      selectedConditionIndex: _data.selectedConditionIndex,
      selectedSellerTypeIndex: _data.selectedSellerTypeIndex,
      selectedColorIndex: _data.selectedColorIndex,
      selectedSizeIndex: _data.selectedSizeIndex,
      vehiclePrimaryCategoryId:
          widget.vehicleListing ? _vehiclePrimaryCategoryId : null,
      dynamicFields: dynamicMap,
    );
  }

  void _apply() => Navigator.of(
        context,
      ).pop(ProductFilterSheetResult(filter: _snapshot()));

  // ── UI ────────────────────────────────────────────────────────────────────

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
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: textSecondary, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: border, height: 1),
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
                          filter: _snapshot(),
                          openMapView: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Divider(color: border),
                  // ── Always-on: Summa ──────────────────────────────────────
                  _SectionHeader(
                    title: 'Summa',
                    expanded: _priceExpanded,
                    onToggle: () =>
                        setState(() => _priceExpanded = !_priceExpanded),
                  ),
                  if (_priceExpanded) ...[
                    const SizedBox(height: 12),
                    _buildPriceInputs(border, textPrimary),
                    const SizedBox(height: 8),
                    _buildPriceSlider(border),
                    const SizedBox(height: 4),
                  ],
                  Divider(color: border),
                  // ── Always-on: Toggles ────────────────────────────────────
                  _ToggleRow(
                    title: 'Chegirma va aksiyalar',
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
                  // ── Avto kategoriyasi (Auto holatida) ─────────────────────
                  if (widget.vehicleListing &&
                      widget.vehiclePrimaryCategories.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Kategoriya',
                      expanded: _vehicleCategoryExpanded,
                      onToggle: () => setState(() =>
                          _vehicleCategoryExpanded = !_vehicleCategoryExpanded),
                    ),
                    if (_vehicleCategoryExpanded) ...[
                      const SizedBox(height: 8),
                      _categoryRadioRow(
                        border: border,
                        textPrimary: textPrimary,
                        label: 'Barcha turkumlar',
                        selected: _vehiclePrimaryCategoryId == null,
                        onTap: () =>
                            setState(() => _vehiclePrimaryCategoryId = null),
                      ),
                      ...widget.vehiclePrimaryCategories.map(
                        (s) => _categoryRadioRow(
                          border: border,
                          textPrimary: textPrimary,
                          label: s.name,
                          selected: _vehiclePrimaryCategoryId == s.id,
                          onTap: () => setState(
                              () => _vehiclePrimaryCategoryId = s.id),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Divider(color: border),
                  ],
                  // ── API dan kelgan dynamic fieldlar ───────────────────────
                  if (_dynamicFieldsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_dynamicFieldsError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Filtr maydonlarini yuklashda xatolik',
                        style: TextStyle(color: AppColors.red, fontSize: 13),
                      ),
                    )
                  else
                    ..._buildDynamicSections(
                      border: border,
                      card: card,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // ── Apply Button ──────────────────────────────────────────────
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Qo'llash",
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

  Widget _buildPriceInputs(Color border, Color textPrimary) {
    return Row(
      children: [
        Expanded(
          child: _SumPriceField(
            controller: _minCtrl,
            hint: 'Dan',
            borderColor: border,
            textColor: textPrimary,
            maxValue: _maxSlider.toInt(),
            onChanged: (v) {
              if (_updatingPriceFromSlider) return;
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
              if (_updatingPriceFromSlider) return;
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
    );
  }

  Widget _buildPriceSlider(Color border) {
    return SliderTheme(
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
          _updatingPriceFromSlider = true;
          setState(() {
            _priceRange = v;
            _minCtrl.text = _formatSumInt(v.start > 0 ? v.start.toInt() : 0);
            _maxCtrl.text = _formatSumInt(
              v.end < _maxSlider ? v.end.toInt() : _maxSlider.toInt(),
            );
          });
          _updatingPriceFromSlider = false;
        },
      ),
    );
  }

  List<Widget> _buildDynamicSections({
    required Color border,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final widgets = <Widget>[];
    final visible = _dynamicFields.where(_isVisible).toList();
    for (var i = 0; i < visible.length; i++) {
      final f = visible[i];
      widgets.add(_buildField(
        f,
        border: border,
        card: card,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      ));
      widgets.add(Divider(color: border));
    }
    return widgets;
  }

  Widget _buildField(
    CategoryFieldEntity field, {
    required Color border,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final type = field.type.toLowerCase();
    final expanded = _sectionExpanded[field.name] ?? true;
    Widget? body;

    switch (type) {
      case 'select':
        body = _buildSelectChips(field, card: card, textPrimary: textPrimary,
            border: border);
        break;
      case 'multiselect':
        body = _buildMultiSelectChips(field, card: card,
            textPrimary: textPrimary, border: border);
        break;
      case 'range':
        body = _buildRangeBody(field, border: border, textPrimary: textPrimary);
        break;
      case 'checkbox':
        // Checkbox — to'g'ridan-to'g'ri toggle, header yo'q.
        return _ToggleRow(
          title: _capitalize(field.label),
          value: _data.dynamicFields[field.name] == true,
          textColor: textPrimary,
          onChanged: (v) =>
              setState(() => _data.dynamicFields[field.name] = v),
        );
      case 'text':
      case 'number':
        body = _buildTextField(field, border: border, textPrimary: textPrimary);
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: _capitalize(field.label),
          expanded: expanded,
          trailing: _selectionSummary(field, textSecondary),
          onToggle: () => setState(() {
            _sectionExpanded[field.name] = !expanded;
          }),
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          body,
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget? _selectionSummary(CategoryFieldEntity field, Color textSecondary) {
    final type = field.type.toLowerCase();
    if (type == 'select') {
      final v = _data.dynamicFields[field.name];
      if (v == null) return null;
      final opt = field.options.firstWhere(
        (o) => o.value == v.toString(),
        orElse: () => CategoryFieldOptionEntity(label: v.toString(), value: ''),
      );
      return _Pill(text: opt.label);
    }
    if (type == 'multiselect') {
      final v = _data.dynamicFields[field.name];
      if (v is! List || v.isEmpty) return null;
      return _Pill(text: '${v.length} ta');
    }
    if (type == 'range') {
      final r = _rangeValues[field.name];
      final maxVal = _rangeMax[field.name] ?? 0;
      if (r == null) return null;
      if (r.start <= 0 && r.end >= maxVal) return null;
      return _Pill(
        text:
            '${_formatSumInt(r.start.toInt())} – ${_formatSumInt(r.end.toInt())}',
      );
    }
    return null;
  }

  Widget _buildSelectChips(
    CategoryFieldEntity field, {
    required Color card,
    required Color textPrimary,
    required Color border,
  }) {
    final selected = _data.dynamicFields[field.name]?.toString();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: field.options.map((o) {
        final sel = selected == o.value;
        return _ChipButton(
          label: o.label,
          selected: sel,
          card: card,
          border: border,
          textColor: textPrimary,
          onTap: () => setState(() {
            if (sel) {
              _data.dynamicFields.remove(field.name);
            } else {
              _data.dynamicFields[field.name] = o.value;
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChips(
    CategoryFieldEntity field, {
    required Color card,
    required Color textPrimary,
    required Color border,
  }) {
    final raw = _data.dynamicFields[field.name];
    final selected = <String>{};
    if (raw is List) {
      for (final v in raw) {
        selected.add(v.toString());
      }
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: field.options.map((o) {
        final sel = selected.contains(o.value);
        return _ChipButton(
          label: o.label,
          selected: sel,
          card: card,
          border: border,
          textColor: textPrimary,
          onTap: () => setState(() {
            if (sel) {
              selected.remove(o.value);
            } else {
              selected.add(o.value);
            }
            if (selected.isEmpty) {
              _data.dynamicFields.remove(field.name);
            } else {
              _data.dynamicFields[field.name] = selected.toList();
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _buildRangeBody(
    CategoryFieldEntity field, {
    required Color border,
    required Color textPrimary,
  }) {
    _ensureRangeState(field);
    final maxVal = _rangeMax[field.name]!;
    final values = _rangeValues[field.name]!;
    final minCtrl = _rangeMinCtrl[field.name]!;
    final maxCtrl = _rangeMaxCtrl[field.name]!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SumPriceField(
                controller: minCtrl,
                hint: '0',
                borderColor: border,
                textColor: textPrimary,
                maxValue: maxVal.toInt(),
                onChanged: (v) {
                  if (_updatingFromSlider) return;
                  final parsed = _parseDigitsOnly(v) ?? 0;
                  final val = parsed
                      .toDouble()
                      .clamp(0.0, values.end)
                      .toDouble();
                  setState(() {
                    _rangeValues[field.name] = RangeValues(val, values.end);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SumPriceField(
                controller: maxCtrl,
                hint: _formatSumInt(maxVal.toInt()),
                borderColor: border,
                textColor: textPrimary,
                maxValue: maxVal.toInt(),
                onChanged: (v) {
                  if (_updatingFromSlider) return;
                  final parsed = _parseDigitsOnly(v);
                  final val = (parsed ?? maxVal.toInt())
                      .toDouble()
                      .clamp(values.start, maxVal)
                      .toDouble();
                  setState(() {
                    _rangeValues[field.name] = RangeValues(values.start, val);
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
            values: values,
            min: 0,
            max: maxVal,
            onChanged: (v) {
              _updatingFromSlider = true;
              setState(() {
                _rangeValues[field.name] = v;
                minCtrl.text =
                    _formatSumInt(v.start > 0 ? v.start.toInt() : 0);
                maxCtrl.text = _formatSumInt(
                    v.end < maxVal ? v.end.toInt() : maxVal.toInt());
              });
              _updatingFromSlider = false;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    CategoryFieldEntity field, {
    required Color border,
    required Color textPrimary,
  }) {
    _ensureTextController(field);
    final c = _textControllers[field.name]!;
    final isNumber = field.type.toLowerCase() == 'number';
    return TextField(
      controller: c,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: field.placeholder?.isNotEmpty == true
            ? field.placeholder
            : field.label,
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

  Widget _categoryRadioRow({
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

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
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
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 8),
            ],
            if (onToggle != null)
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: context.textSecondary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Narx: faqat raqam, ko'rinishda minglik bo'shliq.
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

/// Filtr varag'ida Yandex xarita preview (chizma emas).
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
                      "Xaritada ko'rsatish",
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
