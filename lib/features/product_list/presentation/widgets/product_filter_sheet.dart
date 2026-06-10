import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uzxarid/core/constants/api_urls.dart';
import 'package:uzxarid/core/dio/dio_client.dart';
import 'package:uzxarid/core/dp/infection.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/either/either.dart';
import 'package:uzxarid/core/error/failures.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/responsive.dart';
import 'package:uzxarid/features/add_listing/domain/entities/category_field_entity.dart';
import 'package:uzxarid/features/product_list/domain/entities/subcategory_item.dart';
import 'package:uzxarid/features/product_list/domain/usecases/get_subcategories_by_category_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

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

Color? _hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final val = int.tryParse(hex, radix: 16);
  return val != null ? Color(val) : null;
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
    List<int>? categoryPathIds,
    this.vehiclePrimaryCategoryId,
    this.vehicleMarkId,
    this.vehicleMark,
    this.vehicleModelId,
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
    this.vehicleConfigurationId,
    this.vehicleConfiguration,
    this.vehiclePaymentType,
    Map<String, dynamic>? dynamicFields,
  }) : categoryPathIds = List<int>.from(categoryPathIds ?? const []),
       dynamicFields = Map<String, dynamic>.from(dynamicFields ?? {});

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

  List<int> categoryPathIds;
  int? vehiclePrimaryCategoryId;

  int? vehicleMarkId;
  String? vehicleMark;
  int? vehicleModelId;
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
  int? vehicleConfigurationId;
  String? vehicleConfiguration;
  String? vehiclePaymentType;

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
    List<int>? categoryPathIds,
    int? vehiclePrimaryCategoryId,
    int? vehicleMarkId,
    String? vehicleMark,
    int? vehicleModelId,
    String? vehicleModel,
    int? vehicleConfigurationId,
    String? vehicleConfiguration,
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
      categoryPathIds: categoryPathIds ?? this.categoryPathIds,
      vehiclePrimaryCategoryId:
          vehiclePrimaryCategoryId ?? this.vehiclePrimaryCategoryId,
      vehicleMarkId: vehicleMarkId ?? this.vehicleMarkId,
      vehicleMark: vehicleMark ?? this.vehicleMark,
      vehicleModelId: vehicleModelId ?? this.vehicleModelId,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleConfigurationId:
          vehicleConfigurationId ?? this.vehicleConfigurationId,
      vehicleConfiguration:
          vehicleConfiguration ?? this.vehicleConfiguration,
      dynamicFields: dynamicFields != null
          ? Map<String, dynamic>.from(dynamicFields)
          : Map<String, dynamic>.from(this.dynamicFields),
    );
  }
}

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

Future<ProductFilterSheetResult?> showProductFilterSheet(
  BuildContext context, {
  ProductFilterData? initial,
  bool vehicleListing = false,
  List<SubcategoryItem> vehiclePrimaryCategories = const [],
  int? currentVehiclePrimaryCategoryId,
  List<int> baseCategoryPathIds = const [],
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
      listingType: listingType,
      categoryId: categoryId,
      baseCategoryPathIds: baseCategoryPathIds,
    ),
  );
}

// ─── Sheet Widget ─────────────────────────────────────────────────────────────

class _ProductFilterSheet extends StatefulWidget {
  const _ProductFilterSheet({
    required this.initial,
    required this.listingType,
    this.categoryId,
    this.baseCategoryPathIds = const [],
  });
  final ProductFilterData initial;
  final String listingType;
  final int? categoryId;
  final List<int> baseCategoryPathIds;

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  Color get primaryColor => context.read<AppModeCubit>().state.primaryColor;

  static const int _sheetSearchThreshold = 6;

  late ProductFilterData _data;
  List<CategoryFieldEntity> _dynamicFields = [];
  bool _dynamicFieldsLoading = false;
  String? _dynamicFieldsError;

  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, RangeValues> _rangeValues = {};
  final Map<String, double> _rangeMin = {};
  final Map<String, double> _rangeMax = {};
  final Map<String, TextEditingController> _rangeMinCtrl = {};
  final Map<String, TextEditingController> _rangeMaxCtrl = {};
  bool _updatingFromSlider = false;

  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 1000000000);
  static const double _maxPriceSlider = 1000000000;
  bool _updatingPriceFromSlider = false;

  // ── Kategoriya tanlash ──
  List<SubcategoryItem> _categories = [];
  final Map<int, List<SubcategoryItem>> _childrenByParent = {};
  final Set<int> _loadingParentIds = {};
  final List<SubcategoryItem> _categoryPath = [];
  bool _categoriesLoading = false;
  bool get _isVehicleListing => widget.listingType == 'Auto';
  SubcategoryItem? get _selectedRootCategory =>
      _categoryPath.isNotEmpty ? _categoryPath.first : null;
  SubcategoryItem? get _selectedLeafCategory =>
      _categoryPath.isNotEmpty ? _categoryPath.last : null;
  int? get _effectiveCategoryId => _selectedLeafCategory?.id ?? widget.categoryId;
  List<int> get _activeCategoryPathIds => _categoryPath
      .map((item) => item.id)
      .toList(growable: false);

  void _setDynamicField(String key, dynamic value) {
    final next = Map<String, dynamic>.from(_data.dynamicFields);
    next[key] = value;
    _data.dynamicFields = next;
  }

  void _removeDynamicField(String key) {
    final next = Map<String, dynamic>.from(_data.dynamicFields);
    next.remove(key);
    _data.dynamicFields = next;
  }

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
    _data.dynamicFields = Map<String, dynamic>.from(_data.dynamicFields);
    final min = _data.minPrice ?? 0;
    final max = _data.maxPrice ?? _maxPriceSlider;
    _priceRange = RangeValues(min, max);
    _minCtrl.text = min > 0 ? _formatSumInt(min.toInt()) : '';
    _maxCtrl.text = max < _maxPriceSlider ? _formatSumInt(max.toInt()) : '';
    _data.categoryPathIds = List<int>.from(_data.categoryPathIds);
    _data.dynamicFields = Map<String, dynamic>.from(_data.dynamicFields);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeCategoryState();
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

  Future<void> _initializeCategoryState() async {
    await _loadCategories();
    if (!mounted) return;
    final desiredPathIds = _data.categoryPathIds.isNotEmpty
        ? _data.categoryPathIds
        : widget.baseCategoryPathIds;
    if (desiredPathIds.isNotEmpty) {
      final restored = await _restoreCategoryPath(desiredPathIds);
      if (restored) return;
    }
    if (widget.categoryId != null) {
      await _loadDynamicFields();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _categoriesLoading = true);
    final result = await getIt<GetSubcategoriesByCategoryId>()(
      GetSubcategoriesByCategoryIdParams(categoryType: widget.listingType),
    );
    if (!mounted) return;
    setState(() {
      _categoriesLoading = false;
      if (result is Right<Failure, List<SubcategoryItem>>) {
        _categories = result.right;
      }
    });
  }

  Future<bool> _restoreCategoryPath(List<int> pathIds) async {
    if (_categories.isEmpty || pathIds.isEmpty) return false;

    final normalizedPathIds = _normalizedCategoryPathIds(pathIds);
    final restored = <SubcategoryItem>[];
    SubcategoryItem? current = _categories.cast<SubcategoryItem?>().firstWhere(
      (item) => item?.id == normalizedPathIds.first,
      orElse: () => null,
    );
    if (current == null) return false;

    restored.add(current);

    for (final nextId in normalizedPathIds.skip(1)) {
      final children = await _loadChildCategories(
        current!.id,
        showLoading: false,
      );
      final next = children.cast<SubcategoryItem?>().firstWhere(
        (item) => item?.id == nextId,
        orElse: () => null,
      );
      if (next == null) break;
      restored.add(next);
      current = next;
    }

    setState(() {
      _categoryPath
        ..clear()
        ..addAll(restored);
    });

    if (restored.isNotEmpty) {
      await _loadDynamicFields();
    }
    return true;
  }

  Future<List<SubcategoryItem>> _loadChildCategories(
    int parentId, {
    bool showLoading = true,
  }) async {
    if (_childrenByParent.containsKey(parentId)) {
      return _childrenByParent[parentId]!;
    }
    if (showLoading && mounted) {
      setState(() => _loadingParentIds.add(parentId));
    }
    final result = await getIt<GetSubcategoriesByCategoryId>()(
      GetSubcategoriesByCategoryIdParams(
        categoryId: parentId,
        categoryType: widget.listingType,
      ),
    );
    if (!mounted) return const <SubcategoryItem>[];
    final children = result is Right<Failure, List<SubcategoryItem>>
        ? result.right
        : const <SubcategoryItem>[];
    setState(() {
      _loadingParentIds.remove(parentId);
      _childrenByParent[parentId] = children;
    });
    return children;
  }

  void _truncateCategoryPath(int level) {
    if (level < 0 || level >= _categoryPath.length) return;
    final removed = _categoryPath.sublist(level);
    _categoryPath.removeRange(level, _categoryPath.length);
    for (final item in removed) {
      _childrenByParent.remove(item.id);
      _loadingParentIds.remove(item.id);
    }
  }

  void _resetVehicleStaticSelection() {
    _data.vehicleMarkId = null;
    _data.vehicleMark = null;
    _data.vehicleModelId = null;
    _data.vehicleModel = null;
    _data.vehicleConfigurationId = null;
    _data.vehicleConfiguration = null;
  }

  Future<void> _onCategorySelected(int level, SubcategoryItem category) async {
    setState(() {
      _truncateCategoryPath(level);
      _categoryPath.add(category);
      _dynamicFields = [];
      _dynamicFieldsError = null;
      _clearRangeState();
      if (_isVehicleListing) {
        _resetVehicleStaticSelection();
      }
    });
    await _loadDynamicFields();
    await _loadChildCategories(category.id);
  }

  List<int> _normalizedCategoryPathIds(List<int> rawIds) {
    final ids = <int>[];
    for (final id in rawIds) {
      if (id <= 0) continue;
      if (ids.isEmpty || ids.last != id) {
        ids.add(id);
      }
    }
    return ids;
  }

  bool _sameCategoryPath(List<int> a, List<int> b) {
    final left = _normalizedCategoryPathIds(a);
    final right = _normalizedCategoryPathIds(b);
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  void _clearRangeState() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    _textControllers.clear();
    for (final c in _rangeMinCtrl.values) {
      c.dispose();
    }
    _rangeMinCtrl.clear();
    for (final c in _rangeMaxCtrl.values) {
      c.dispose();
    }
    _rangeMaxCtrl.clear();
    _rangeValues.clear();
    _rangeMin.clear();
    _rangeMax.clear();
    _data.dynamicFields = <String, dynamic>{};
  }

  // ── Dinamik filterlarni yuklash ──
  Future<void> _loadDynamicFields() async {
    final catId = _effectiveCategoryId;
    if (catId == null) return;

    setState(() {
      _dynamicFieldsLoading = true;
      _dynamicFieldsError = null;
    });
    try {
      final dio = getIt<DioClient>().dio;
      final response = await dio.get(
        ApiUrls.categoryFieldsFilters,
        queryParameters: {
          'listing_type': widget.listingType,
          'category_id': catId,
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
        _dynamicFields = parsed.where((f) => f.isFilterable).toList();
        _dynamicFieldsLoading = false;
        for (final f in _dynamicFields) {
          if (_effectiveRenderType(f) == _RenderType.range) {
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
    return t == 'text';
  }

  _RenderType _effectiveRenderType(CategoryFieldEntity field) {
    final type = field.type.toLowerCase();
    final filterType = field.filterType?.toLowerCase();

    if (type == 'range' || (type == 'number' && filterType == 'range')) {
      return _RenderType.range;
    }
    if (type == 'select') return _RenderType.dropdown;
    if (type == 'multiselect') return _RenderType.multiPicker;
    if (type == 'checkbox') return _RenderType.toggle;
    if (type == 'number') return _RenderType.textInput;
    if (type == 'text') return _RenderType.textInput;

    return _RenderType.textInput;
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
    final minVal = field.minValue ?? 0;
    final maxVal = field.maxValue ?? _rangeMaxFallback(field);
    final initMin =
        (_data.dynamicFields['${field.name}_min'] as num?)?.toDouble() ??
        minVal;
    final initMax =
        (_data.dynamicFields['${field.name}_max'] as num?)?.toDouble() ??
        maxVal;
    _rangeMin[field.name] = minVal;
    _rangeMax[field.name] = maxVal;
    _rangeValues[field.name] = RangeValues(
      initMin.clamp(minVal, maxVal),
      initMax.clamp(minVal, maxVal),
    );
    _rangeMinCtrl[field.name] = TextEditingController(
      text: initMin > minVal ? _formatSumInt(initMin.toInt()) : '',
    );
    _rangeMaxCtrl[field.name] = TextEditingController(
      text: initMax < maxVal ? _formatSumInt(initMax.toInt()) : '',
    );
  }

  double _rangeMaxFallback(CategoryFieldEntity field) {
    final m = field.name.toLowerCase();
    if (m.contains('probeg')) return 1000000;
    if (m.contains('year') || m.contains('manufacture')) return 2030;
    if (m.contains('engine') && m.contains('power')) return 500;
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
      final renderType = _effectiveRenderType(f);
      switch (renderType) {
        case _RenderType.multiPicker:
          final type = f.type.toLowerCase();
          if (type == 'multiselect') {
            final v = _data.dynamicFields[f.name];
            if (v is List && v.isNotEmpty) {
              dynamicMap[f.name] = v.join(',');
            }
          } else {
            final v = _data.dynamicFields[f.name];
            if (v is String && v.isNotEmpty) dynamicMap[f.name] = v;
          }
          break;
        case _RenderType.dropdown:
          final v = _data.dynamicFields[f.name];
          if (v is String && v.isNotEmpty) dynamicMap[f.name] = v;
          break;
        case _RenderType.range:
          final r = _rangeValues[f.name];
          final minVal = _rangeMin[f.name] ?? 0;
          final maxVal = _rangeMax[f.name] ?? 0;
          if (r != null) {
            if (r.start > minVal) {
              dynamicMap['${f.name}_min'] = r.start.toInt();
            }
            if (r.end < maxVal) {
              dynamicMap['${f.name}_max'] = r.end.toInt();
            }
          }
          break;
        case _RenderType.toggle:
          if (_data.dynamicFields[f.name] == true) {
            dynamicMap[f.name] = true;
          }
          break;
        case _RenderType.textInput:
          final v = _textControllers[f.name]?.text.trim() ?? '';
          if (v.isNotEmpty) dynamicMap[f.name] = v;
          break;
      }
    }
    final selectedPathIds = _activeCategoryPathIds;
    final basePathIds = _normalizedCategoryPathIds(widget.baseCategoryPathIds);
    final persistedPathIds = selectedPathIds.isNotEmpty &&
            !_sameCategoryPath(selectedPathIds, basePathIds)
        ? selectedPathIds
        : const <int>[];
    return ProductFilterData(
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxPriceSlider ? _priceRange.end : null,
      hasDiscount: _data.hasDiscount,
      hasServices: _data.hasServices,
      onlyTop: _data.onlyTop,
      selectedCategoryIndex: _data.selectedCategoryIndex,
      selectedConditionIndex: _data.selectedConditionIndex,
      selectedSellerTypeIndex: _data.selectedSellerTypeIndex,
      selectedColorIndex: _data.selectedColorIndex,
      selectedSizeIndex: _data.selectedSizeIndex,
      categoryPathIds: persistedPathIds,
      vehiclePrimaryCategoryId: _isVehicleListing && persistedPathIds.isNotEmpty
          ? persistedPathIds.first
          : null,
      vehicleMarkId: _data.vehicleMarkId,
      vehicleMark: _data.vehicleMark,
      vehicleModelId: _data.vehicleModelId,
      vehicleModel: _data.vehicleModel,
      vehicleConfigurationId: _data.vehicleConfigurationId,
      vehicleConfiguration: _data.vehicleConfiguration,
      dynamicFields: dynamicMap,
    );
  }

  void _apply() =>
      Navigator.of(context).pop(ProductFilterSheetResult(filter: _snapshot()));

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final border = context.borderColor;
    final card = context.surfaceContainer;

    final layout = FilterSheetLayout.of(context);
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: layout.sheetInitialSize,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            SizedBox(height: layout.handlePadding),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: layout.handlePadding),
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Filtrlar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _reset,
                    child: Text(
                      'Tozalash',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: layout.headerBottom),
            Divider(color: border, height: 1),
            // ── Body ──
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: layout.listTop),
                  // ── Map ──
                  _FilterMapPreviewCard(
                    height: layout.mapHeight,
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
                  SizedBox(height: layout.sectionGap),
                  // ── Summa ──
                  _buildSectionLabel('Summa', textSecondary, layout),
                  SizedBox(height: layout.labelGap),
                  _buildPriceInputs(border, textPrimary, layout),
                  SizedBox(height: layout.sliderGap),
                  _buildPriceSlider(border, layout),
                  SizedBox(height: layout.sectionGap),
                  ..._buildCategorySections(
                    border: border,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    layout: layout,
                  ),
                  if (_isVehicleListing)
                    ..._buildVehicleStaticSections(
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      layout: layout,
                    ),
                  // ── Dynamic fields ──
                  if (_dynamicFieldsLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: layout.sectionGap + 4,
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_dynamicFieldsError != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: layout.sectionGap,
                      ),
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
                      layout: layout,
                    ),
                  // ── Chegirma & TOP ──
                  Divider(color: border, height: 1),
                  _ToggleRow(
                    title: 'Chegirmalar va aksiyalar',
                    value: _data.hasDiscount,
                    textColor: textPrimary,
                    verticalPadding: layout.togglePadding,
                    fontSize: layout.inputFontSize,
                    onChanged: (v) => setState(() => _data.hasDiscount = v),
                  ),
                  Divider(color: border, height: 1),
                  _ToggleRow(
                    title: 'Faqat TOP',
                    value: _data.onlyTop,
                    textColor: textPrimary,
                    verticalPadding: layout.togglePadding,
                    fontSize: layout.inputFontSize,
                    onChanged: (v) => setState(() => _data.onlyTop = v),
                  ),
                  SizedBox(height: layout.sectionEnd),
                ],
              ),
            ),
            // ── Apply Button ──
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                12 + MediaQuery.of(context).viewPadding.bottom,
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
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: layout.applyButtonPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Qo'llash",
                    style: TextStyle(
                      fontSize: layout.inputFontSize + 1,
                      fontWeight: FontWeight.w700,
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

  List<Widget> _buildCategorySections({
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    final widgets = <Widget>[
      _buildSectionLabel('Kategoriya', textSecondary, layout),
      SizedBox(height: layout.labelGap),
    ];

    if (_categoriesLoading) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: layout.labelGap + 4),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
      widgets.add(SizedBox(height: layout.sectionGap));
      return widgets;
    }

    widgets.add(
      _buildCategoryDropdown(
        items: _categories,
        selected: _selectedRootCategory,
        hint: 'Kategoriyani tanlang',
        border: border,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        layout: layout,
        onSelected: (item) => _onCategorySelected(0, item),
      ),
    );

    for (var level = 0; level < _categoryPath.length; level++) {
      final parent = _categoryPath[level];
      final isLoadingChildren = _loadingParentIds.contains(parent.id);
      final children = _childrenByParent[parent.id];
      if (!isLoadingChildren && children != null && children.isEmpty) {
        continue;
      }
      final childLevel = level + 1;
      final selectedChild = childLevel < _categoryPath.length
          ? _categoryPath[childLevel]
          : null;
      widgets.add(SizedBox(height: layout.sectionGap));
      widgets.add(
        _buildSectionLabel(
          childLevel == 1 ? 'Subkategoriya' : 'Bo\'lim',
          textSecondary,
          layout,
        ),
      );
      widgets.add(SizedBox(height: layout.labelGap));
      if (isLoadingChildren && children == null) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: layout.labelGap + 4),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          _buildCategoryDropdown(
            items: children ?? const <SubcategoryItem>[],
            selected: selectedChild,
            hint: childLevel == 1
                ? 'Subkategoriyani tanlang'
                : 'Bo\'limni tanlang',
            border: border,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            layout: layout,
            onSelected: (item) => _onCategorySelected(childLevel, item),
          ),
        );
      }
    }

    widgets.add(SizedBox(height: layout.sectionGap));
    return widgets;
  }

  List<Widget> _buildVehicleStaticSections({
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    return [
      _buildVehicleLookupField(
        label: 'Marka',
        hint: _selectedRootCategory == null
            ? 'Avval kategoriyani tanlang'
            : 'Markani tanlang',
        value: _data.vehicleMark,
        border: border,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        layout: layout,
        enabled: _selectedRootCategory != null,
        onTap: () {
          final rootCategoryId = _selectedRootCategory?.id;
          if (rootCategoryId == null) return;
          _showCarPagedSelectSheet(
            title: 'Marka',
            selectedId: _data.vehicleMarkId,
            loadPage: (page, search) => _fetchCarPagedList(
              path: ApiUrls.carBrand,
              page: page,
              search: search,
              extraQuery: {'category': rootCategoryId},
            ),
            onSelected: (id, name) {
              setState(() {
                if (_data.vehicleMarkId != id) {
                  _data.vehicleModelId = null;
                  _data.vehicleModel = null;
                  _data.vehicleConfigurationId = null;
                  _data.vehicleConfiguration = null;
                }
                _data.vehicleMarkId = id;
                _data.vehicleMark = name;
              });
            },
          );
        },
        onClear: _data.vehicleMarkId != null
            ? () {
                setState(() {
                  _resetVehicleStaticSelection();
                });
              }
            : null,
      ),
      SizedBox(height: layout.sectionGap),
      _buildVehicleLookupField(
        label: 'Model',
        hint: _data.vehicleMarkId == null
            ? 'Avval markani tanlang'
            : 'Modelni tanlang',
        value: _data.vehicleModel,
        border: border,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        layout: layout,
        enabled: _data.vehicleMarkId != null,
        onTap: () {
          if (_data.vehicleMarkId == null) return;
          _showCarPagedSelectSheet(
            title: 'Model',
            selectedId: _data.vehicleModelId,
            loadPage: (page, search) => _fetchCarPagedList(
              path: ApiUrls.carBrandModel,
              page: page,
              search: search,
              extraQuery: {'brand': _data.vehicleMarkId},
            ),
            onSelected: (id, name) {
              setState(() {
                if (_data.vehicleModelId != id) {
                  _data.vehicleConfigurationId = null;
                  _data.vehicleConfiguration = null;
                }
                _data.vehicleModelId = id;
                _data.vehicleModel = name;
              });
            },
          );
        },
        onClear: _data.vehicleModelId != null
            ? () {
                setState(() {
                  _data.vehicleModelId = null;
                  _data.vehicleModel = null;
                  _data.vehicleConfigurationId = null;
                  _data.vehicleConfiguration = null;
                });
              }
            : null,
      ),
      SizedBox(height: layout.sectionGap),
      _buildVehicleLookupField(
        label: 'Komplektatsiya',
        hint: _data.vehicleModelId == null
            ? 'Avval modelni tanlang'
            : 'Komplektatsiyani tanlang',
        value: _data.vehicleConfiguration,
        border: border,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        layout: layout,
        enabled: _data.vehicleModelId != null,
        onTap: () {
          if (_data.vehicleMarkId == null || _data.vehicleModelId == null) {
            return;
          }
          _showCarPagedSelectSheet(
            title: 'Komplektatsiya',
            selectedId: _data.vehicleConfigurationId,
            loadPage: (page, search) => _fetchCarPagedList(
              path: ApiUrls.carVehicleTrim,
              page: page,
              search: search,
              extraQuery: {
                'brand': _data.vehicleMarkId,
                'model': _data.vehicleModelId,
              },
            ),
            onSelected: (id, name) {
              setState(() {
                _data.vehicleConfigurationId = id;
                _data.vehicleConfiguration = name;
              });
            },
          );
        },
        onClear: _data.vehicleConfigurationId != null
            ? () {
                setState(() {
                  _data.vehicleConfigurationId = null;
                  _data.vehicleConfiguration = null;
                });
              }
            : null,
      ),
      SizedBox(height: layout.sectionGap),
    ];
  }

  // ── Kategoriya dropdown ──
  Widget _buildCategoryDropdown({
    required List<SubcategoryItem> items,
    required SubcategoryItem? selected,
    required String hint,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
    required ValueChanged<SubcategoryItem> onSelected,
  }) {
    return GestureDetector(
      onTap: () => _showCategoryPickerSheet(
        items: items,
        selected: selected,
        onSelected: onSelected,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: layout.inputHPadding,
          vertical: layout.inputPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(layout.fieldRadius),
          border: Border.all(
            color: selected != null ? primaryColor : border,
          ),
        ),
        child: Row(
          children: [
            if (selected?.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  selected!.image!,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                selected?.name ?? hint,
                style: TextStyle(
                  color: selected != null
                      ? textPrimary
                      : textPrimary.withValues(alpha: 0.4),
                  fontSize: layout.inputFontSize,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPickerSheet({
    required List<SubcategoryItem> items,
    required SubcategoryItem? selected,
    required ValueChanged<SubcategoryItem> onSelected,
  }) {
    final showSearch = _shouldShowSheetSearch(items.length);
    var query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final layout = FilterSheetLayout.of(ctx);
        final bg = Theme.of(ctx).scaffoldBackgroundColor;
        final border = ctx.borderColor;
        final textPrimary = ctx.textPrimary;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filteredItems = _filterSheetItems(
              items,
              query,
              (item) => item.name,
            );
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              builder: (_, scrollCtrl) => Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: layout.pickerSheetHandle),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: layout.pickerSheetHandle),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kategoriya',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: layout.labelGap),
                    Divider(color: border, height: 1),
                    if (showSearch) ...[
                      SizedBox(height: layout.labelGap),
                      _buildSheetSearchField(
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: ctx.textSecondary,
                        layout: layout,
                      ),
                    ],
                    Expanded(
                      child: filteredItems.isEmpty
                          ? _buildSheetEmptyState(
                              textSecondary: ctx.textSecondary,
                              layout: layout,
                            )
                          : ListView.separated(
                              controller: scrollCtrl,
                              itemCount: filteredItems.length,
                              padding: EdgeInsets.zero,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: border),
                              itemBuilder: (_, i) {
                                final item = filteredItems[i];
                                final isSel = selected?.id == item.id;
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 0,
                                  ),
                                  leading: item.image != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Image.network(
                                            item.image!,
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const SizedBox(
                                              width: 28,
                                              height: 28,
                                            ),
                                          ),
                                        )
                                      : null,
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: isSel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  trailing: isSel
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: primaryColor,
                                          size: 18,
                                        )
                                      : null,
                                  onTap: () {
                                    onSelected(item);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVehicleLookupField({
    required String label,
    required String hint,
    required String? value,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
    required bool enabled,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final hasValue = value != null && value.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label, textSecondary, layout),
        SizedBox(height: layout.labelGap),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: layout.inputHPadding,
              vertical: layout.inputPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(layout.fieldRadius),
              border: Border.all(
                color: hasValue ? primaryColor : border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasValue
                          ? textPrimary
                          : textPrimary.withValues(alpha: 0.4),
                      fontSize: layout.inputFontSize,
                    ),
                  ),
                ),
                if (hasValue && onClear != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      color: textSecondary,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<_CarPagedResult> _fetchCarPagedList({
    required String path,
    required int page,
    required String search,
    Map<String, dynamic> extraQuery = const {},
  }) async {
    try {
      final dio = getIt<DioClient>().dio;
      final query = <String, dynamic>{
        'page': page,
        'page_size': 20,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      };
      extraQuery.forEach((key, value) {
        if (value != null) {
          query[key] = value;
        }
      });
      final response = await dio.get(path, queryParameters: query);
      final body = response.data;
      if (body is! Map) {
        return const _CarPagedResult(items: [], hasNext: false);
      }
      final data = body['data'];
      if (data is! Map) {
        return const _CarPagedResult(items: [], hasNext: false);
      }
      final results = data['results'];
      final items = <_CarLookupItem>[];
      if (results is List) {
        for (final raw in results) {
          if (raw is! Map) continue;
          final id = raw['id'];
          final name = raw['name']?.toString();
          if (id is int && name != null && name.isNotEmpty) {
            items.add(_CarLookupItem(id: id, name: name));
          }
        }
      }
      final links = data['links'];
      final hasNext = links is Map && links['next'] != null;
      return _CarPagedResult(items: items, hasNext: hasNext);
    } catch (_) {
      return const _CarPagedResult(items: [], hasNext: false);
    }
  }

  void _showCarPagedSelectSheet({
    required String title,
    required int? selectedId,
    required Future<_CarPagedResult> Function(int page, String search) loadPage,
    required void Function(int id, String name) onSelected,
  }) {
    final pageContext = context;
    showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.of(sheetContext).size.height;
        final viewInsets = MediaQuery.of(sheetContext).viewInsets.bottom;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: viewInsets),
          child: SizedBox(
            height: screenHeight * 0.85,
            child: _CarPagedSelectSheetBody(
              title: title,
              selectedId: selectedId,
              loadPage: loadPage,
              onSelected: (id, name) {
                Navigator.pop(sheetContext);
                onSelected(id, name);
              },
              textColor: pageContext.textPrimary,
              textSecondary: pageContext.textSecondary,
              borderColor: pageContext.borderColor,
              primaryColor: primaryColor,
              surfaceColor: sheetContext.cardSurface,
            ),
          ),
        );
      },
    );
  }

  // ── Price ──
  Widget _buildPriceInputs(
    Color border,
    Color textPrimary,
    FilterSheetLayout layout,
  ) {
    return Row(
      children: [
        Expanded(
          child: _RangeInputField(
            controller: _minCtrl,
            hint: '0',
            borderColor: border,
            textColor: textPrimary,
            layout: layout,
            maxValue: _maxPriceSlider.toInt(),
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
        SizedBox(width: layout.fieldRowGap),
        Expanded(
          child: _RangeInputField(
            controller: _maxCtrl,
            hint: '1 000 000 000',
            borderColor: border,
            textColor: textPrimary,
            layout: layout,
            maxValue: _maxPriceSlider.toInt(),
            suffix: '₸',
            onChanged: (v) {
              if (_updatingPriceFromSlider) return;
              final parsed = _parseDigitsOnly(v);
              final val = (parsed ?? _maxPriceSlider.toInt())
                  .toDouble()
                  .clamp(_priceRange.start, _maxPriceSlider)
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

  Widget _buildPriceSlider(Color border, FilterSheetLayout layout) {
    return SizedBox(
      height: layout.sliderHeight,
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: primaryColor,
          inactiveTrackColor: border,
          thumbColor: primaryColor,
          overlayColor: primaryColor.withValues(alpha: 0.12),
          overlayShape: SliderComponentShape.noOverlay,
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: RangeSlider(
          values: _priceRange,
          min: 0,
          max: _maxPriceSlider,
          onChanged: (v) {
            _updatingPriceFromSlider = true;
            setState(() {
              _priceRange = v;
              _minCtrl.text = v.start > 0 ? _formatSumInt(v.start.toInt()) : '';
              _maxCtrl.text = v.end < _maxPriceSlider
                  ? _formatSumInt(v.end.toInt())
                  : '';
            });
            _updatingPriceFromSlider = false;
          },
        ),
      ),
    );
  }

  // ── Dynamic fields ──
  List<Widget> _buildDynamicSections({
    required Color border,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    final widgets = <Widget>[];
    final visible = _dynamicFields.where(_isVisible).toList();
    for (final f in visible) {
      widgets.add(
        _buildField(
          f,
          border: border,
          card: card,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          layout: layout,
        ),
      );
    }
    return widgets;
  }

  Widget _buildField(
    CategoryFieldEntity field, {
    required Color border,
    required Color card,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    final renderType = _effectiveRenderType(field);
    switch (renderType) {
      case _RenderType.range:
        return _buildRangeSection(
          field,
          border: border,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          layout: layout,
        );
      case _RenderType.multiPicker:
        return _buildMultiPickerSection(
          field,
          border: border,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          layout: layout,
        );
      case _RenderType.dropdown:
        return _buildDropdownSection(
          field,
          border: border,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          layout: layout,
        );
      case _RenderType.toggle:
        return Column(
          children: [
            _ToggleRow(
              title: _capitalize(field.label),
              value: _data.dynamicFields[field.name] == true,
              textColor: textPrimary,
              verticalPadding: layout.togglePadding,
              fontSize: layout.inputFontSize,
              onChanged: (v) => setState(() => _setDynamicField(field.name, v)),
            ),
            Divider(color: border, height: 1),
          ],
        );
      case _RenderType.textInput:
        return _buildTextSection(
          field,
          border: border,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          layout: layout,
        );
    }
  }

  // ── Range section ──
  Widget _buildRangeSection(
    CategoryFieldEntity field, {
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    _ensureRangeState(field);
    final minVal = _rangeMin[field.name]!;
    final maxVal = _rangeMax[field.name]!;
    final values = _rangeValues[field.name]!;
    final minCtrl = _rangeMinCtrl[field.name]!;
    final maxCtrl = _rangeMaxCtrl[field.name]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(_capitalize(field.label), textSecondary, layout),
        SizedBox(height: layout.labelGap),
        Row(
          children: [
            Expanded(
              child: _RangeInputField(
                controller: minCtrl,
                hint: 'dan',
                borderColor: border,
                textColor: textPrimary,
                layout: layout,
                maxValue: maxVal.toInt(),
                onChanged: (v) {
                  if (_updatingFromSlider) return;
                  final parsed = _parseDigitsOnly(v) ?? minVal.toInt();
                  final val = parsed
                      .toDouble()
                      .clamp(minVal, values.end)
                      .toDouble();
                  setState(() {
                    _rangeValues[field.name] = RangeValues(val, values.end);
                  });
                },
              ),
            ),
            SizedBox(width: layout.fieldRowGap),
            Expanded(
              child: _RangeInputField(
                controller: maxCtrl,
                hint: 'gacha',
                borderColor: border,
                textColor: textPrimary,
                layout: layout,
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
        SizedBox(height: layout.sliderGap),
        SizedBox(
          height: layout.sliderHeight,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: primaryColor,
              inactiveTrackColor: border,
              thumbColor: primaryColor,
              overlayColor: primaryColor.withValues(alpha: 0.12),
              overlayShape: SliderComponentShape.noOverlay,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: RangeSlider(
              values: values,
              min: minVal,
              max: maxVal,
              onChanged: (v) {
                _updatingFromSlider = true;
                setState(() {
                  _rangeValues[field.name] = v;
                  minCtrl.text = v.start > minVal
                      ? _formatSumInt(v.start.toInt())
                      : '';
                  maxCtrl.text = v.end < maxVal
                      ? _formatSumInt(v.end.toInt())
                      : '';
                });
                _updatingFromSlider = false;
              },
            ),
          ),
        ),
        SizedBox(height: layout.sectionGap),
      ],
    );
  }

  // ── Multiselect — dropdown + ro'yxat ──
  Widget _buildMultiPickerSection(
    CategoryFieldEntity field, {
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    final raw = _data.dynamicFields[field.name];
    final selected = <String>{};
    if (raw is List) {
      for (final v in raw) {
        selected.add(v.toString());
      }
    }
    final labels = field.options
        .where((o) => selected.contains(o.value))
        .map((o) => o.label)
        .toList();
    final display = labels.isEmpty
        ? _capitalize(field.label)
        : labels.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(_capitalize(field.label), textSecondary, layout),
        SizedBox(height: layout.labelGap),
        GestureDetector(
          onTap: () => _showMultiSelectSheet(field),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: layout.inputHPadding,
              vertical: layout.inputPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(layout.fieldRadius),
              border: Border.all(
                color: labels.isNotEmpty ? primaryColor : border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: labels.isNotEmpty
                          ? textPrimary
                          : textPrimary.withValues(alpha: 0.4),
                      fontSize: layout.inputFontSize,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: layout.sectionGap),
      ],
    );
  }

  Set<String> _selectedValuesForField(CategoryFieldEntity field) {
    final raw = _data.dynamicFields[field.name];
    final selected = <String>{};
    if (raw is List) {
      for (final v in raw) {
        selected.add(v.toString());
      }
    }
    return selected;
  }

  void _showMultiSelectSheet(CategoryFieldEntity field) {
    final showSearch = _shouldShowSheetSearch(field.options.length);
    var query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final layout = FilterSheetLayout.of(ctx);
        final bg = Theme.of(ctx).scaffoldBackgroundColor;
        final border = ctx.borderColor;
        final textPrimary = ctx.textPrimary;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final selected = _selectedValuesForField(field);
            final filteredOptions = _filterSheetItems(
              field.options,
              query,
              (item) => item.label,
            );
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              builder: (_, scrollCtrl) => Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: layout.pickerSheetHandle),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: layout.pickerSheetHandle),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _capitalize(field.label),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          if (selected.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() => _removeDynamicField(field.name));
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                'Tozalash',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: layout.labelGap),
                    Divider(color: border, height: 1),
                    if (showSearch) ...[
                      SizedBox(height: layout.labelGap),
                      _buildSheetSearchField(
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: ctx.textSecondary,
                        layout: layout,
                      ),
                    ],
                    Expanded(
                      child: filteredOptions.isEmpty
                          ? _buildSheetEmptyState(
                              textSecondary: ctx.textSecondary,
                              layout: layout,
                            )
                          : ListView.separated(
                              controller: scrollCtrl,
                              itemCount: filteredOptions.length,
                              padding: EdgeInsets.zero,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: border),
                              itemBuilder: (_, i) {
                                final opt = filteredOptions[i];
                                final isSel = selected.contains(opt.value);
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 0,
                                  ),
                                  title: Text(
                                    opt.label,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: isSel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  trailing: isSel
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: primaryColor,
                                          size: 18,
                                        )
                                      : null,
                                  onTap: () {
                                    final next = _selectedValuesForField(field);
                                    if (isSel) {
                                      next.remove(opt.value);
                                    } else {
                                      next.add(opt.value);
                                    }
                                    setState(() {
                                      if (next.isEmpty) {
                                        _removeDynamicField(field.name);
                                      } else {
                                        _setDynamicField(
                                          field.name,
                                          next.toList(),
                                        );
                                      }
                                    });
                                    setSheetState(() {});
                                  },
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        12 + MediaQuery.of(ctx).viewPadding.bottom,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: layout.applyButtonPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Qo'llash",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Dropdown section (select with many options) ──
  Widget _buildDropdownSection(
    CategoryFieldEntity field, {
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    final selected = _data.dynamicFields[field.name]?.toString();
    final hasColor = field.options.any((o) => o.hexColor != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(_capitalize(field.label), textSecondary, layout),
        SizedBox(height: layout.labelGap),
        GestureDetector(
          onTap: () => _showDropdownSheet(field, hasColor: hasColor),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: layout.inputHPadding,
              vertical: layout.inputPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(layout.fieldRadius),
              border: Border.all(
                color: selected != null ? primaryColor : border,
              ),
            ),
            child: Row(
              children: [
                if (selected != null && hasColor) ...[
                  _buildColorCircle(
                    field.options.firstWhere(
                      (o) => o.value == selected,
                      orElse: () => field.options.first,
                    ),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selected != null
                        ? field.options
                              .firstWhere(
                                (o) => o.value == selected,
                                orElse: () => CategoryFieldOptionEntity(
                                  label: selected,
                                  value: '',
                                ),
                              )
                              .label
                        : _capitalize(field.label),
                    style: TextStyle(
                      color: selected != null
                          ? textPrimary
                          : textPrimary.withValues(alpha: 0.4),
                      fontSize: layout.inputFontSize,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: layout.sectionGap),
      ],
    );
  }

  void _showDropdownSheet(CategoryFieldEntity field, {bool hasColor = false}) {
    final selected = _data.dynamicFields[field.name]?.toString();
    final showSearch = _shouldShowSheetSearch(field.options.length);
    var query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final layout = FilterSheetLayout.of(ctx);
        final bg = Theme.of(ctx).scaffoldBackgroundColor;
        final border = ctx.borderColor;
        final textPrimary = ctx.textPrimary;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filteredOptions = _filterSheetItems(
              field.options,
              query,
              (item) => item.label,
            );
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              builder: (_, scrollCtrl) => Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: layout.pickerSheetHandle),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: layout.pickerSheetHandle),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _capitalize(field.label),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          if (selected != null)
                            GestureDetector(
                              onTap: () {
                                setState(() => _removeDynamicField(field.name));
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                'Tozalash',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: layout.labelGap),
                    Divider(color: border, height: 1),
                    if (showSearch) ...[
                      SizedBox(height: layout.labelGap),
                      _buildSheetSearchField(
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: ctx.textSecondary,
                        layout: layout,
                      ),
                    ],
                    Expanded(
                      child: filteredOptions.isEmpty
                          ? _buildSheetEmptyState(
                              textSecondary: ctx.textSecondary,
                              layout: layout,
                            )
                          : ListView.separated(
                              controller: scrollCtrl,
                              itemCount: filteredOptions.length,
                              padding: EdgeInsets.zero,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: border),
                              itemBuilder: (_, i) {
                                final opt = filteredOptions[i];
                                final isSel = selected == opt.value;
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 0,
                                  ),
                                  leading: hasColor
                                      ? _buildColorCircle(opt, size: 22)
                                      : null,
                                  title: Text(
                                    opt.label,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: isSel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  trailing: isSel
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: primaryColor,
                                          size: 18,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(
                                      () => _setDynamicField(
                                        field.name,
                                        opt.value,
                                      ),
                                    );
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildColorCircle(CategoryFieldOptionEntity opt, {double size = 20}) {
    final color = _hexToColor(opt.hexColor);
    if (color == null) return SizedBox(width: size, height: size);
    final r = (color.r * 255.0).round();
    final g = (color.g * 255.0).round();
    final b = (color.b * 255.0).round();
    final isWhite = (r > 240 && g > 240 && b > 240);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: isWhite
            ? Border.all(color: const Color(0xFFDCDDDE), width: 1)
            : null,
      ),
    );
  }

  // ── Text input section ──
  Widget _buildTextSection(
    CategoryFieldEntity field, {
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    _ensureTextController(field);
    final c = _textControllers[field.name]!;
    final isNumber = field.type.toLowerCase() == 'number';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(_capitalize(field.label), textSecondary, layout),
        SizedBox(height: layout.labelGap),
        TextField(
          controller: c,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            color: textPrimary,
            fontSize: layout.inputFontSize,
            height: 1.2,
          ),
          decoration: InputDecoration(
            hintText: field.placeholder?.isNotEmpty == true
                ? field.placeholder
                : _capitalize(field.label),
            hintStyle: TextStyle(color: textPrimary.withValues(alpha: 0.4)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: layout.inputHPadding,
              vertical: layout.inputPadding,
            ),
            isDense: true,
            isCollapsed: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(layout.fieldRadius),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(layout.fieldRadius),
              borderSide: BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(height: layout.sectionGap),
      ],
    );
  }

  // ── Helpers ──
  Widget _buildSectionLabel(
    String title,
    Color textSecondary,
    FilterSheetLayout layout,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: layout.labelFontSize,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }

  bool _shouldShowSheetSearch(int itemCount) {
    return itemCount > _sheetSearchThreshold;
  }

  List<T> _filterSheetItems<T>(
    List<T> items,
    String query,
    String Function(T item) labelBuilder,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return items;
    return items.where((item) {
      return labelBuilder(item).toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Widget _buildSheetSearchField({
    required ValueChanged<String> onChanged,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    return _SheetSearchField(
      onChanged: onChanged,
      border: border,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      layout: layout,
    );
  }

  Widget _buildSheetEmptyState({
    required Color textSecondary,
    required FilterSheetLayout layout,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: layout.sectionGap * 6,
        ),
        child: Text(
          'Hech narsa topilmadi',
          style: TextStyle(
            color: textSecondary,
            fontSize: layout.inputFontSize,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
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

enum _RenderType { range, dropdown, multiPicker, toggle, textInput }

// ─── Small Helpers ────────────────────────────────────────────────────────────

class _SheetSearchField extends StatefulWidget {
  const _SheetSearchField({
    required this.onChanged,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.layout,
  });

  final ValueChanged<String> onChanged;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final FilterSheetLayout layout;

  @override
  State<_SheetSearchField> createState() => _SheetSearchFieldState();
}

class _SheetSearchFieldState extends State<_SheetSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.layout.fieldRadius);
    final hasValue = _controller.text.trim().isNotEmpty;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: widget.textPrimary,
          fontSize: widget.layout.inputFontSize,
        ),
        decoration: InputDecoration(
          hintText: 'Qidirish',
          hintStyle: TextStyle(
            color: widget.textPrimary.withValues(alpha: 0.4),
            fontSize: widget.layout.inputFontSize,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: widget.textSecondary,
            size: 20,
          ),
          suffixIcon: hasValue
              ? IconButton(
                  onPressed: _clear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: widget.textSecondary,
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: widget.border.withValues(alpha: 0.08),
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.layout.inputHPadding,
            vertical: widget.layout.inputPadding,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: widget.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _CarLookupItem {
  const _CarLookupItem({required this.id, required this.name});
  final int id;
  final String name;
}

class _CarPagedResult {
  const _CarPagedResult({required this.items, required this.hasNext});
  final List<_CarLookupItem> items;
  final bool hasNext;
}

class _CarPagedSelectSheetBody extends StatefulWidget {
  const _CarPagedSelectSheetBody({
    required this.title,
    required this.selectedId,
    required this.loadPage,
    required this.onSelected,
    required this.textColor,
    required this.textSecondary,
    required this.borderColor,
    required this.primaryColor,
    required this.surfaceColor,
  });

  final String title;
  final int? selectedId;
  final Future<_CarPagedResult> Function(int page, String search) loadPage;
  final void Function(int id, String name) onSelected;
  final Color textColor;
  final Color textSecondary;
  final Color borderColor;
  final Color primaryColor;
  final Color surfaceColor;

  @override
  State<_CarPagedSelectSheetBody> createState() =>
      _CarPagedSelectSheetBodyState();
}

class _CarPagedSelectSheetBodyState extends State<_CarPagedSelectSheetBody> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_CarLookupItem> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasNext = true;
  String _search = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _items.clear();
      _page = 1;
      _hasNext = true;
    });
    final res = await widget.loadPage(1, _search);
    if (!mounted) return;
    setState(() {
      _items.addAll(res.items);
      _hasNext = res.hasNext;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasNext) return;
    setState(() {
      _loadingMore = true;
    });
    final nextPage = _page + 1;
    final res = await widget.loadPage(nextPage, _search);
    if (!mounted) return;
    setState(() {
      _items.addAll(res.items);
      _hasNext = res.hasNext;
      _page = nextPage;
      _loadingMore = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final nextSearch = value.trim();
      if (nextSearch == _search) return;
      _search = nextSearch;
      _loadFirst();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(fontSize: 14, color: widget.textColor),
                decoration: InputDecoration(
                  hintText: 'Qidirish',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: widget.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: widget.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: context.surfaceContainer,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : _items.isEmpty
                ? Center(
                    child: Text(
                      'Topilmadi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.zero,
                    itemCount: _items.length + (_loadingMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: widget.borderColor),
                    itemBuilder: (_, index) {
                      if (index >= _items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final item = _items[index];
                      final isSelected = widget.selectedId == item.id;
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? widget.primaryColor
                                : widget.textColor,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: widget.primaryColor,
                                size: 18,
                              )
                            : null,
                        onTap: () => widget.onSelected(item.id, item.name),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
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
    this.verticalPadding = 2,
    this.fontSize = 14,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;
  final double verticalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

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

class _RangeInputField extends StatelessWidget {
  const _RangeInputField({
    required this.controller,
    required this.hint,
    required this.borderColor,
    required this.textColor,
    required this.onChanged,
    required this.maxValue,
    required this.layout,
    this.suffix,
  });
  final TextEditingController controller;
  final String hint;
  final Color borderColor;
  final Color textColor;
  final ValueChanged<String> onChanged;
  final int maxValue;
  final FilterSheetLayout layout;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(layout.fieldRadius);
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_SumThousandsFormatter(maxValue: maxValue)],
      onChanged: onChanged,
      style: TextStyle(
        color: textColor,
        fontSize: layout.inputFontSize,
        height: 1.2,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: textColor.withValues(alpha: 0.4),
          fontSize: layout.inputFontSize,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: textColor.withValues(alpha: 0.5),
          fontSize: layout.inputFontSize - 1,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: layout.inputHPadding,
          vertical: layout.inputPadding,
        ),
        isDense: true,
        isCollapsed: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}

class _FilterMapPreviewCard extends StatefulWidget {
  const _FilterMapPreviewCard({
    required this.height,
    required this.textPrimary,
    required this.onShowOnMap,
  });
  final double height;
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
      height: widget.height,
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
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: widget.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Xaritada ko'rsatish",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.textPrimary,
                          ),
                        ),
                      ],
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
