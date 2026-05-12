import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/utils/price_formatter.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/cart_counter.dart';
import 'package:uz_xarid/features/currency/domain/currency.dart';
import 'package:uz_xarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

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
    final oldPrice = finalPrice != null ? formatPrice(price) : '';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openDetail(context),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 118,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          AppImage(path: AppAssets.star),
                          const SizedBox(width: 4),
                          AppText(
                            text: rating.toStringAsFixed(1),
                            color: context.textPrimary,
                            fontSize: 12,
                            fontWeight: 500,
                          ),
                          const SizedBox(width: 17),
                          AppImage(path: AppAssets.chat),
                          const SizedBox(width: 4),
                          Flexible(
                            child: AppText(
                              text: '$reviewCount ${l10n.reviewsLabel}',
                              color: context.textPrimary,
                              fontSize: 12,
                              fontWeight: 500,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 36,
                        child: AppText(
                          text: title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: 600,
                          height: 1.22,
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                      ),
                      if (oldPrice.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: AppText(
                                text: '$oldPrice $displayCurrency',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: context.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      if (oldPrice.isNotEmpty) const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentPrice.isNotEmpty ? '$currentPrice $displayCurrency' : '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: context.watch<AppModeCubit>().state.primaryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: CartCounter(adSlug: slug, height: 40),
          ),
        ],
      ),
    );
  }
}
