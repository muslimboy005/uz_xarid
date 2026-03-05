import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

/// Rasmdagi mahsulot kartasi: rasm, yulduz/sharh, sarlavha, narxlar, "Ko'rish".
/// Home (RecommendationCard) va ProductList sahifasida ishlatiladi.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.slug,
    required this.title,
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

  static String _formatPrice(String? value) {
    if (value == null || value.isEmpty) return '';
    final intPart = value.split('.').first;
    final buf = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      buf.write(intPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) buf.write(' ');
    }
    return buf.toString().split('').reversed.join();
  }

  void _openDetail(BuildContext context) {
    if (slug.isNotEmpty) context.push('/ad/$slug');
  }

  String get _displayCurrency => currency == 'uzs' ? 'so\'m' : currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPrice = _formatPrice(finalPrice ?? price);
    final oldPrice = finalPrice != null ? _formatPrice(price) : '';

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
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
            Stack(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: AppImage(
                    path: mainImage ?? '',
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: context.surfaceContainer,
                      child: Center(
                        child: Icon(Icons.image, color: context.textSecondary),
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
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppColors.red : Colors.white,
                        size: 22,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                          ),
                        ],
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.textPrimary,
                                fontSize: 11,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 12,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$reviewCount ${l10n.reviewsLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.22,
                        fontSize: 13,
                        color: context.textPrimary,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 4),
                    if (oldPrice.isNotEmpty)
                      Text(
                        '$oldPrice $_displayCurrency',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      currentPrice.isNotEmpty
                          ? '$currentPrice $_displayCurrency'
                          : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue600,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _openDetail(context),
                  child: Text(
                    l10n.view,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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
