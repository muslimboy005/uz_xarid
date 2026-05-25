import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
import 'package:uzxarid/core/utils/responsive.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/cart_counter.dart';
import 'package:uzxarid/features/currency/domain/currency.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

/// Rasmdagi mahsulot kartasi: rasm, yulduz/sharh, sarlavha, narxlar, "Ko'rish".
/// Home (RecommendationCard) va ProductList sahifasida ishlatiladi.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.slug,
    required this.title,
    this.color,
    this.description,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency = 'uzs',
    this.rating = 0,
    this.reviewCount = 0,
    this.width,
    this.height,
    this.isLiked = false,
    this.onLikeTap,
    this.showCartButton = true,
  });

  final String slug;
  final String title;
  final Color? color;
  final String? description;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final double? width;
  final double? height;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final bool showCartButton;

  void _openDetail(BuildContext context) {
    if (slug.isNotEmpty) context.push('/ad/$slug');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final l10n = AppLocalizations.of(context)!;
    final currentPrice = formatPrice(finalPrice ?? price);
    final formattedOld = formatPrice(price);
    final oldPrice = (finalPrice != null && formattedOld != currentPrice)
        ? formattedOld
        : '';
    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final displayCurrency = currencyDisplayLabel(selectedCcy);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? context.bodyBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = width ??
              (constraints.maxWidth.isFinite ? constraints.maxWidth : 170.0);
          final cardHeight = height ??
              (constraints.maxHeight.isFinite ? constraints.maxHeight : null);

          final layout = AppResponsive.productCardLayout(
            context,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            showCartButton: showCartButton,
          );

          final oldPriceLineHeight = layout.oldPriceFontSize * 1.2;
          final metaSpacing = layout.isCompact ? 8.0 : 14.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => _openDetail(context),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    SizedBox(
                      height: layout.imageHeight,
                      width: double.infinity,
                      child: AppImage(
                        path: mainImage ?? '',
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.black50,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: context.textSecondary,
                              size: layout.isCompact ? 32 : 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: layout.heartInset,
                      top: layout.heartInset,
                      child: onLikeTap != null
                          ? GestureDetector(
                              onTap: onLikeTap,
                              child: AppImage(
                                path: AppAssets.heartOutline,
                                color: isLiked
                                    ? AppColors.red
                                    : AppColors.black200,
                                size: layout.heartSize,
                              ),
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: layout.heartSize,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openDetail(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      layout.hPad,
                      layout.isCompact ? 4 : 6,
                      layout.hPad,
                      2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppImage(path: AppAssets.star, size: layout.iconSize),
                            const SizedBox(width: 4),
                            AppText(
                              text: rating.toStringAsFixed(1),
                              color: context.textPrimary,
                              fontSize: layout.metaFontSize,
                              fontWeight: 500,
                            ),
                            SizedBox(width: metaSpacing),
                            AppImage(path: AppAssets.chat, size: layout.iconSize),
                            const SizedBox(width: 4),
                            Flexible(
                              child: AppText(
                                text: '$reviewCount ${l10n.reviewsLabel}',
                                color: context.textPrimary,
                                fontSize: layout.metaFontSize,
                                fontWeight: 500,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: AppText(
                            text: title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: 600,
                            height: 1.2,
                            fontSize: layout.titleFontSize,
                            color: context.textPrimary,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: oldPriceLineHeight,
                              child: oldPrice.isNotEmpty
                                  ? AppText(
                                      text: '$oldPrice $displayCurrency',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: layout.oldPriceFontSize,
                                      color: context.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : null,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currentPrice.isNotEmpty
                                    ? '$currentPrice $displayCurrency'
                                    : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: layout.priceFontSize,
                                  fontWeight: FontWeight.w800,
                                  color: context
                                      .watch<AppModeCubit>()
                                      .state
                                      .primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showCartButton)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    layout.hPad,
                    0,
                    layout.hPad,
                    layout.isCompact ? 6 : 8,
                  ),
                  child: CartCounter(adSlug: slug, height: layout.cartHeight),
                )
              else
                SizedBox(height: layout.isCompact ? 6 : 8),
            ],
          );
        },
      ),
    );
  }
}
