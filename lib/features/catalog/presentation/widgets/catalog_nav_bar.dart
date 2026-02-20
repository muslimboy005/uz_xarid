import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';

/// Pinned navigation bar for catalog: "Barcha turkumlar > [truck icon]".
/// Used below AppBar, inside body as a sliver.
class CatalogNavBar extends StatelessWidget {
  const CatalogNavBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = false,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBack,
                color: AppColors.textPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.local_shipping_outlined,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

/// [SliverPersistentHeaderDelegate] for [CatalogNavBar] so it stays pinned.
class CatalogNavBarDelegate extends SliverPersistentHeaderDelegate {
  CatalogNavBarDelegate({
    required this.title,
    this.onBack,
    this.showBack = false,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return CatalogNavBar(
      title: title,
      onBack: onBack,
      showBack: showBack,
    );
  }

  @override
  double get maxExtent => CatalogNavBar.height;

  @override
  double get minExtent => CatalogNavBar.height;

  @override
  bool shouldRebuild(covariant CatalogNavBarDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.showBack != showBack;
  }
}
