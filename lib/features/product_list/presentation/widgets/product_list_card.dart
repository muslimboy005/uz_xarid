import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';

class ProductListCard extends StatelessWidget {
  const ProductListCard({super.key, required this.item});

  final ProductListItemEntity item;

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

  @override
  Widget build(BuildContext context) {
    final currency = item.currency == 'uzs' ? 'so\'m' : item.currency;
    return GestureDetector(
      onTap: () => context.push('/ad/${item.slug}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (item.finalPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatPrice(item.finalPrice)} $currency',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final hasImage =
        item.mainImage != null && item.mainImage!.isNotEmpty;
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: item.mainImage!,
              fit: BoxFit.cover,
              errorWidget: (BuildContext context, String url, Object? error) =>
                  _placeholderImage(),
            )
          : _placeholderImage(),
    );
  }

  Widget _placeholderImage() => Container(
        color: AppColors.black100,
        child: const Center(child: Icon(Icons.image)),
      );
}
