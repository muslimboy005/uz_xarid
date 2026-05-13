import 'package:flutter/material.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_image.dart';

/// Pinned navigation bar for catalog: path bo‘laklari har biri bosiladigan.
class CatalogNavBar extends StatelessWidget {
  const CatalogNavBar({
    super.key,
    required this.pathParts,
    this.onSegmentTap,
    this.onBack,
    this.showBack = false,
    this.trailingImagePath,
  });

  final List<String> pathParts;
  final void Function(int index)? onSegmentTap;
  final VoidCallback? onBack;
  final bool showBack;

  /// Category (yoki tur) rasmi – bo‘lsa, yuk mashina ikonkasi o‘rnida ko‘rsatiladi.
  final String? trailingImagePath;

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: textColor,
    );
    return Container(
      height: height,
      color: context.cardSurface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBack,
                color: textColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < pathParts.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '>',
                          style: textStyle?.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: onSegmentTap != null
                          ? () => onSegmentTap!(i)
                          : null,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Text(
                          pathParts[i],
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: textSecondary, size: 20),
          const SizedBox(width: 8),
          if (trailingImagePath != null && trailingImagePath!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AppImage(
                path: trailingImagePath!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(Icons.local_shipping_outlined, color: textSecondary, size: 32),
        ],
      ),
    );
  }
}

/// [SliverPersistentHeaderDelegate] for [CatalogNavBar] so it stays pinned.
class CatalogNavBarDelegate extends SliverPersistentHeaderDelegate {
  CatalogNavBarDelegate({
    required this.pathParts,
    this.onSegmentTap,
    this.onBack,
    this.showBack = false,
    this.trailingImagePath,
  });

  final List<String> pathParts;
  final void Function(int index)? onSegmentTap;
  final VoidCallback? onBack;
  final bool showBack;
  final String? trailingImagePath;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return CatalogNavBar(
      pathParts: pathParts,
      onSegmentTap: onSegmentTap,
      onBack: onBack,
      showBack: showBack,
      trailingImagePath: trailingImagePath,
    );
  }

  @override
  double get maxExtent => CatalogNavBar.height;

  @override
  double get minExtent => CatalogNavBar.height;

  @override
  bool shouldRebuild(covariant CatalogNavBarDelegate oldDelegate) {
    return oldDelegate.pathParts != pathParts ||
        oldDelegate.showBack != showBack ||
        oldDelegate.trailingImagePath != trailingImagePath;
  }
}
