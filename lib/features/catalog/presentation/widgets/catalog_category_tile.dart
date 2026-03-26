import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';

class CatalogCategoryTile extends StatelessWidget {
  const CatalogCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.isExpanded = false,
    this.indentLevel = 0,
  });

  final CategoryEntity category;
  final VoidCallback onTap;

  /// When true, shows chevron down (expanded); otherwise chevron right (collapsed).
  final bool isExpanded;

  /// Indent level for nested subcategories (e.g. 1 = one level in).
  final int indentLevel;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppDimens.paddingMedium + (indentLevel * 16.0);
    final textColor = context.textPrimary;
    return Material(
      color: context.cardSurface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingSmall2,
            bottom: AppDimens.paddingSmall2,
          ),
          child: Row(
            children: [
              if (category.image != null && category.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  child: AppImage(
                    path: category.image!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              if (category.image != null && category.image!.isNotEmpty)
                const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpanded ? AppColors.primary : textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (category.hasChildren)
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  color: isExpanded ? AppColors.primary : textColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
