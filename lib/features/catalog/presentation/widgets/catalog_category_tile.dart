import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/catalog/domain/entities/category_entity.dart';

class CatalogCategoryTile extends StatelessWidget {
  const CatalogCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  final CategoryEntity category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium,
            vertical: AppDimens.paddingSmall2,
          ),
          child: Row(
            children: [
              if (category.image != null && category.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  child: AppImage(
                    path: category.image!,
                    width: 40,
                    height: 40,
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
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (category.hasChildren)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
