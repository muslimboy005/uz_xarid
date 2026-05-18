import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
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

  void _openDetail(BuildContext context) {
    if (slug.isNotEmpty) context.push('/ad/$slug');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final l10n = AppLocalizations.of(context)!;
    final currentPrice = formatPrice(finalPrice ?? price);
    final formattedOld = formatPrice(price);
    // Eski narx faqat haqiqiy chegirma bo'lganda ko'rsatiladi (joriy narxdan farqli).
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 220.0;

          // Responsive o'lchamlar: kart kengligi/balandligiga qarab moslashadi.
          final isCompact = cardWidth < 170 || cardHeight < 240;
          final cartHeight = isCompact ? 34.0 : 40.0;
          final hPad = isCompact ? 8.0 : 10.0;
          // Matn bloki uchun zarur joy: rating + title (2 satr) + price block + paddings.
          final textBlockHeight = isCompact ? 95.0 : 108.0;
          final reservedForContent = textBlockHeight + cartHeight + 10;
          final imageHeight = (cardHeight - reservedForContent)
              .clamp(70.0, cardHeight * 0.55);
          final iconSize = isCompact ? 12.0 : 14.0;
          final metaFontSize = isCompact ? 11.0 : 12.0;
          final titleFontSize = isCompact ? 13.0 : 14.0;
          final oldPriceFontSize = isCompact ? 10.5 : 11.5;
          final priceFontSize = isCompact ? 16.0 : 18.0;
          // Eski narx qatori uchun balandlik (chegirma yo'q bo'lsa ham joy saqlanadi).
          final oldPriceLineHeight = oldPriceFontSize * 1.2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _openDetail(context),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: AppImage(
                        path: mainImage ?? '',
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: isDark ? AppColors.darkSurface : AppColors.black50,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: context.textSecondary,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (onLikeTap != null)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () {
                            onLikeTap!();
                          },
                          child: AppImage(
                            path: AppAssets.heartOutline,
                            color: isLiked ? AppColors.red : AppColors.black200,
                            size: 22,
                          ),
                        ),
                      )
                    else
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 22,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
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
                    padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppImage(path: AppAssets.star, size: iconSize),
                            const SizedBox(width: 4),
                            AppText(
                              text: rating.toStringAsFixed(1),
                              color: context.textPrimary,
                              fontSize: metaFontSize,
                              fontWeight: 500,
                            ),
                            SizedBox(width: isCompact ? 10 : 14),
                            AppImage(path: AppAssets.chat, size: iconSize),
                            const SizedBox(width: 4),
                            Flexible(
                              child: AppText(
                                text: '$reviewCount ${l10n.reviewsLabel}',
                                color: context.textPrimary,
                                fontSize: metaFontSize,
                                fontWeight: 500,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: AppText(
                            text: title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: 600,
                            height: 1.2,
                            fontSize: titleFontSize,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                                      fontSize: oldPriceFontSize,
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
                                  fontSize: priceFontSize,
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
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                child: CartCounter(adSlug: slug, height: cartHeight),
              ),
            ],
          );
        },
      ),
    );
  }
}
