import 'package:flutter/material.dart';

/// Mahsulot kartasi ichidagi moslashuvchan o'lchamlar.
class ProductCardLayout {
  const ProductCardLayout({
    required this.isCompact,
    required this.isNarrow,
    required this.cartHeight,
    required this.hPad,
    required this.imageHeight,
    required this.iconSize,
    required this.metaFontSize,
    required this.titleFontSize,
    required this.oldPriceFontSize,
    required this.priceFontSize,
    required this.heartSize,
    required this.heartInset,
  });

  final bool isCompact;
  final bool isNarrow;
  final double cartHeight;
  final double hPad;
  final double imageHeight;
  final double iconSize;
  final double metaFontSize;
  final double titleFontSize;
  final double oldPriceFontSize;
  final double priceFontSize;
  final double heartSize;
  final double heartInset;
}

/// Telefon va planshet ekranlari uchun moslashuvchan o'lchamlar.
class AppResponsive {
  AppResponsive._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0);

  static double horizontalPadding(BuildContext context) {
    final w = screenWidth(context);
    if (w < 360) return 12;
    return 16;
  }

  static double homeFloatingHeaderHeight(BuildContext context) {
    const toggle = 44.0;
    const gap = 8.0;
    const search = 40.0;
    const padding = 6.0;
    final scale = textScale(context).clamp(1.0, 1.35);
    return padding + toggle + gap + search * scale + 4;
  }

  static int productGridCrossAxisCount(BuildContext context) {
    final w = screenWidth(context);
    if (w >= 720) return 4;
    if (w >= 600) return 3;
    if (w < 340) return 1;
    return 2;
  }

  static double productGridSpacing(BuildContext context) {
    return screenWidth(context) < 360 ? 8 : 12;
  }

  static double productGridCellWidth(
    BuildContext context, {
    double? padding,
    double? spacing,
  }) {
    final cross = productGridCrossAxisCount(context);
    final pad = padding ?? horizontalPadding(context);
    final gap = spacing ?? productGridSpacing(context);
    final w = screenWidth(context);
    return (w - pad * 2 - gap * (cross - 1)) / cross;
  }

  static double estimatedProductCardHeight(
    BuildContext context, {
    required double cellWidth,
    bool showCartButton = true,
    double extraContentHeight = 0,
  }) {
    final scale = textScale(context).clamp(1.0, 1.35);
    final compact = cellWidth < 165;
    // Rasm balandligi kenglikdan ozgina baland (~1.1)
    final imageH = cellWidth * 1.1;
    final metaH = (compact ? 14.0 : 16.0) * scale;
    final titleH = 30.0 * scale;
    final priceH = 30.0 * scale;
    final cartH = showCartButton ? (compact ? 40.0 : 42.0) : 8.0;
    final padding = compact ? 8.0 : 10.0;
    return imageH + metaH + titleH + priceH + cartH + padding + extraContentHeight;
  }

  static double productGridAspectRatio(
    BuildContext context, {
    bool showCartButton = true,
    double extraContentHeight = 0,
    double? padding,
  }) {
    final cellW = productGridCellWidth(context, padding: padding);
    final cellH = estimatedProductCardHeight(
      context,
      cellWidth: cellW,
      showCartButton: showCartButton,
      extraContentHeight: extraContentHeight,
    );
    return cellW / cellH;
  }

  static SliverGridDelegate productGridDelegate(
    BuildContext context, {
    bool showCartButton = true,
    double extraContentHeight = 0,
    double? padding,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: productGridCrossAxisCount(context),
      crossAxisSpacing: productGridSpacing(context),
      mainAxisSpacing: productGridSpacing(context),
      childAspectRatio: productGridAspectRatio(
        context,
        showCartButton: showCartButton,
        extraContentHeight: extraContentHeight,
        padding: padding,
      ),
    );
  }

  /// Berilgan ustunlar soni bilan moslashuvchan grid (masalan: bir qatorda 3 ta
  /// karta). Katak kengligi ekran kengligidan hisoblanadi — to'liq responsiv.
  static SliverGridDelegate productGridDelegateFixedCount(
    BuildContext context,
    int crossAxisCount, {
    bool showCartButton = true,
    double extraContentHeight = 0,
    double? padding,
  }) {
    final cross = crossAxisCount < 1 ? 1 : crossAxisCount;
    final spacing = productGridSpacing(context);
    final pad = padding ?? horizontalPadding(context);
    final w = screenWidth(context);
    final cellW = (w - pad * 2 - spacing * (cross - 1)) / cross;
    final cellH = estimatedProductCardHeight(
      context,
      cellWidth: cellW,
      showCartButton: showCartButton,
      extraContentHeight: extraContentHeight,
    );
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cross,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: cellW / cellH,
    );
  }

  /// Mening e'lonlarim — qo'shimcha tugmalar qatori uchun balandroq katak.
  static SliverGridDelegate myAdsGridDelegate(BuildContext context) {
    return productGridDelegate(
      context,
      showCartButton: false,
      extraContentHeight: 72,
      padding: 12,
    );
  }

  static double horizontalProductCardWidth(BuildContext context) {
    final w = screenWidth(context);
    if (w < 360) return w * 0.46;
    return (w * 0.42).clamp(148.0, 176.0);
  }

  static double horizontalProductCardHeight(
    BuildContext context, {
    bool showCartButton = false,
  }) {
    final width = horizontalProductCardWidth(context);
    return estimatedProductCardHeight(
      context,
      cellWidth: width,
      showCartButton: showCartButton,
    );
  }

  static ProductCardLayout productCardLayout(
    BuildContext context, {
    required double cardWidth,
    double? cardHeight,
    bool showCartButton = true,
  }) {
    final scale = textScale(context).clamp(1.0, 1.35);
    final compact = cardWidth < 165;
    final narrow = cardWidth < 140;

    final cartHeight = (compact ? 30.0 : 34.0) * (scale > 1.15 ? 1.05 : 1.0);
    final hPad = compact ? 8.0 : 10.0;
    final iconSize = compact ? 12.0 : 14.0;
    // Barcha matnlar 11 (productcard)
    final metaFontSize = 11.0 * scale.clamp(1.0, 1.2);
    final titleFontSize = 11.0 * scale.clamp(1.0, 1.2);
    final oldPriceFontSize = 11.0 * scale.clamp(1.0, 1.15);
    final priceFontSize = 11.0 * scale.clamp(1.0, 1.15);
    final heartSize = compact ? 20.0 : 22.0;
    final heartInset = compact ? 8.0 : 12.0;

    final textBlock = 70.0 * scale.clamp(1.0, 1.25);
    final cartBlock = showCartButton ? cartHeight + 8 : 6;
    final verticalPad = hPad + 6;

    double imageHeight;
    if (cardHeight != null && cardHeight.isFinite && cardHeight > 0) {
      imageHeight = (cardHeight - textBlock - cartBlock - verticalPad).clamp(
        narrow ? 56.0 : 64.0,
        cardHeight * 0.85,
      );
    } else {
      imageHeight = cardWidth * 1.1;
    }

    return ProductCardLayout(
      isCompact: compact,
      isNarrow: narrow,
      cartHeight: cartHeight,
      hPad: hPad,
      imageHeight: imageHeight,
      iconSize: iconSize,
      metaFontSize: metaFontSize,
      titleFontSize: titleFontSize,
      oldPriceFontSize: oldPriceFontSize,
      priceFontSize: priceFontSize,
      heartSize: heartSize,
      heartInset: heartInset,
    );
  }

  static double homeCategoryListHeight(BuildContext context) {
    final tile = homeCategoryTileSize(context);
    final scale = textScale(context).clamp(1.0, 1.25);
    return tile + 8 + 22 * scale + 4;
  }

  static double homeCategoryTileSize(BuildContext context) {
    final w = screenWidth(context);
    if (w < 360) return 64;
    if (w < 400) return 66;
    return 70;
  }
}

/// Filtr pastki paneli uchun ixcham moslashuvchan o'lchamlar.
class FilterSheetLayout {
  FilterSheetLayout._({
    required this.handlePadding,
    required this.headerBottom,
    required this.listTop,
    required this.sectionGap,
    required this.labelGap,
    required this.sliderGap,
    required this.chipsGap,
    required this.sectionEnd,
    required this.mapHeight,
    required this.inputPadding,
    required this.chipPadding,
    required this.applyButtonPadding,
    required this.sheetInitialSize,
    required this.togglePadding,
    required this.sliderHeight,
    required this.listItemPadding,
    required this.pickerSheetHandle,
    required this.labelFontSize,
    required this.inputFontSize,
    required this.fieldRadius,
    required this.inputHPadding,
    required this.fieldRowGap,
  });

  final double handlePadding;
  final double headerBottom;
  final double listTop;
  final double sectionGap;
  final double labelGap;
  final double sliderGap;
  final double chipsGap;
  final double sectionEnd;
  final double mapHeight;
  final double inputPadding;
  final double chipPadding;
  final double applyButtonPadding;
  final double sheetInitialSize;
  final double togglePadding;
  final double sliderHeight;
  final double listItemPadding;
  final double pickerSheetHandle;
  final double labelFontSize;
  final double inputFontSize;
  final double fieldRadius;
  final double inputHPadding;
  final double fieldRowGap;

  factory FilterSheetLayout.of(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final compact = h < 700;
    final tight = h < 640;

    return FilterSheetLayout._(
      handlePadding: tight ? 4 : 6,
      headerBottom: tight ? 4 : 6,
      listTop: tight ? 4 : 6,
      sectionGap: tight ? 5 : (compact ? 6 : 7),
      labelGap: tight ? 3 : 4,
      sliderGap: 0,
      chipsGap: tight ? 3 : 4,
      sectionEnd: tight ? 4 : 6,
      mapHeight: tight ? 76 : (compact ? 84 : 92),
      inputPadding: tight ? 4 : 5,
      chipPadding: tight ? 4 : 5,
      applyButtonPadding: tight ? 10 : 12,
      sheetInitialSize: tight ? 0.86 : (compact ? 0.88 : 0.9),
      togglePadding: 2,
      sliderHeight: tight ? 22 : 24,
      listItemPadding: tight ? 4 : 5,
      pickerSheetHandle: tight ? 4 : 6,
      labelFontSize: tight ? 11 : 11.5,
      inputFontSize: tight ? 12.5 : 13.5,
      fieldRadius: 10,
      inputHPadding: 12,
      fieldRowGap: 8,
    );
  }
}
