import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/utils/image_parser.dart';
import 'package:uz_xarid/core/utils/price_formatter.dart';
import 'package:uz_xarid/core/widgets/cart_counter.dart';
import 'package:uz_xarid/features/currency/domain/currency.dart';
import 'package:uz_xarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uz_xarid/features/product_list/domain/entities/product_list_item_entity.dart';

class ProductListCard extends StatelessWidget {
  const ProductListCard({super.key, required this.item});

  final ProductListItemEntity item;

  @override
  Widget build(BuildContext context) {
    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final currency = currencyDisplayLabel(selectedCcy);
    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/ad/${item.slug}'),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                                height: 1.2,
                              ),
                        ),
                      ),
                      if (item.finalPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${formatPrice(item.finalPrice)} $currency',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: context.watch<AppModeCubit>().state.primaryColor,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: CartCounter(adSlug: item.slug, height: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final hasImage = item.mainImage != null && item.mainImage!.isNotEmpty;
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: item.mainImage!.cdnUrl,
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
