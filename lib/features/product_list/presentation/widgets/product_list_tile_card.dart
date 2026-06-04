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

/// Mahsulotning gorizontal (list tile) ko'rinishi: rasm chapda, ma'lumotlar
/// o'ngda. ProductList sahifasidagi "list" ko'rinish rejimi uchun ishlatiladi.
class ProductListTileCard extends StatelessWidget {
  const ProductListTileCard({
    super.key,
    required this.slug,
    required this.title,
    this.color,
    this.mainImage,
    this.price,
    this.finalPrice,
    this.currency = 'uzs',
    this.rating = 0,
    this.reviewCount = 0,
    this.isLiked = false,
    this.onLikeTap,
    this.showCartButton = true,
  });

  final String slug;
  final String title;
  final Color? color;
  final String? mainImage;
  final String? price;
  final String? finalPrice;
  final String currency;
  final double rating;
  final int reviewCount;
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
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: color ?? context.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.cardBorderColor.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openDetail(context),
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: AppImage(
                        path: mainImage ?? '',
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color:
                              isDark ? AppColors.darkSurface : AppColors.black50,
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: context.textSecondary,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (onLikeTap != null)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: GestureDetector(
                          onTap: onLikeTap,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: AppImage(
                              path: AppAssets.heartOutline,
                              color: isLiked ? AppColors.red : AppColors.black200,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _openDetail(context),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 108,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppImage(path: AppAssets.star, size: 14),
                          const SizedBox(width: 4),
                          AppText(
                            text: rating.toStringAsFixed(1),
                            color: context.textPrimary,
                            fontSize: 12,
                            fontWeight: 500,
                          ),
                          const SizedBox(width: 14),
                          AppImage(path: AppAssets.chat, size: 14),
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
                      AppText(
                        text: title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: 600,
                        height: 1.2,
                        fontSize: 15,
                        color: context.textPrimary,
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (oldPrice.isNotEmpty)
                                  AppText(
                                    text: '$oldPrice $displayCurrency',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 11.5,
                                    color: context.textSecondary,
                                    decoration: TextDecoration.lineThrough,
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
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showCartButton) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 112,
                              child: CartCounter(adSlug: slug, height: 38),
                            ),
                          ],
                        ],
                      ),
                    ],
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
