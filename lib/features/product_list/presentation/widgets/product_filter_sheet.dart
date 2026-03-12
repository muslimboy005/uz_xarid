import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';

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
    );
  }
}

// Sentinel: returned by _reset() to signal "clear all filters"
final _kClearedFilter = ProductFilterData();

/// Shows the filter sheet. Returns:
/// - non-null ProductFilterData when user pressed Qo'llash with selections
/// - null when user dismissed without changes OR pressed Tozalash (clear all)
/// Caller should set _activeFilter = null when result is null (clear badge).
Future<ProductFilterData?> showProductFilterSheet(
  BuildContext context, {
  ProductFilterData? initial,
}) async {
  final result = await showModalBottomSheet<ProductFilterData>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _ProductFilterSheet(initial: initial ?? ProductFilterData()),
  );
  // Sentinel (empty filter from Tozalash) → return special sentinel
  // so parent can distinguish "cleared" from "dismissed without change"
  return result;
}

// ─── Sheet Widget ─────────────────────────────────────────────────────────────

class _ProductFilterSheet extends StatefulWidget {
  const _ProductFilterSheet({required this.initial});
  final ProductFilterData initial;

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  late ProductFilterData _data;

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

    if (min > 0) _minCtrl.text = min.toInt().toString();
    // Only populate maxCtrl if user explicitly set a max (not the full max)
    if (_data.maxPrice != null && max < _maxSlider) {
      _maxCtrl.text = max.toInt().toString();
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    // Pop with a special sentinel empty filter — parent will detect allCleared = true
    // and set _activeFilter = null (removes red dot badge)
    Navigator.of(context).pop(_kClearedFilter);
  }

  void _apply() => Navigator.of(context).pop(
    ProductFilterData(
      // Prices: use null when slider is at its default edge (no filter)
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxSlider ? _priceRange.end : null,
      // All other fields come from current _data state
      hasDiscount: _data.hasDiscount,
      hasServices: _data.hasServices,
      selectedCategoryIndex: _data.selectedCategoryIndex,
      selectedConditionIndex: _data.selectedConditionIndex,
      selectedSellerTypeIndex: _data.selectedSellerTypeIndex,
      selectedColorIndex: _data.selectedColorIndex,
      selectedSizeIndex: _data.selectedSizeIndex,
    ),
  );

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
                        child: _PriceField(
                          controller: _minCtrl,
                          hint: 'Dan',
                          borderColor: border,
                          textColor: textPrimary,
                          onChanged: (v) {
                            if (_updatingFromSlider) return;
                            final val = double.tryParse(v) ?? 0;
                            setState(() {
                              _priceRange = RangeValues(
                                val.clamp(0, _priceRange.end),
                                _priceRange.end,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PriceField(
                          controller: _maxCtrl,
                          hint: 'Gacha',
                          borderColor: border,
                          textColor: textPrimary,
                          onChanged: (v) {
                            if (_updatingFromSlider) return;
                            final val = double.tryParse(v) ?? _maxSlider;
                            setState(() {
                              _priceRange = RangeValues(
                                _priceRange.start,
                                val.clamp(_priceRange.start, _maxSlider),
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
                          if (v.start > 0) {
                            _minCtrl.text = v.start.toInt().toString();
                          } else {
                            _minCtrl.clear();
                          }
                          if (v.end < _maxSlider) {
                            _maxCtrl.text = v.end.toInt().toString();
                          } else {
                            _maxCtrl.clear();
                          }
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
                    onToggle: () =>
                        setState(() => _categoryExpanded = !_categoryExpanded),
                  ),
                  if (_categoryExpanded) ...[
                    const SizedBox(height: 8),
                    ..._categories.asMap().entries.map((e) {
                      final selected = _data.selectedCategoryIndex == e.key;
                      return InkWell(
                        onTap: () =>
                            setState(() => _data.selectedCategoryIndex = e.key),
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
                  // ── Color ────────────────────────────────────────────────
                  _SectionHeader(
                    title: 'Rang',
                    expanded: _colorExpanded,
                    trailing: _data.selectedColorIndex != null
                        ? _ColorLabel(
                            color: _colors[_data.selectedColorIndex!],
                            textColor: textSecondary,
                          )
                        : null,
                    onToggle: () =>
                        setState(() => _colorExpanded = !_colorExpanded),
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
                          onTap: () => setState(
                            () => _data.selectedColorIndex = sel ? null : e.key,
                          ),
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
                                    color: isWhite
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                            () => _data.selectedSizeIndex = sel ? null : e.key,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
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
