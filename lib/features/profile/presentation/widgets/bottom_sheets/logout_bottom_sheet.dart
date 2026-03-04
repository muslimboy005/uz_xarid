import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.black400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Icon(
                    Icons.close,
                    color: context.textPrimary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              ContainerW(
                color: AppColors.orange,
                radius: 12,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AppImage(
                    path: AppAssets.logout,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              AppText(
                text: 'Вы уверены, что\nхотите выйти?',
                fontSize: 22,
                fontWeight: 700,
                color: context.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              AppText(
                text:
                    'Вы всегда сможете войти обратно,\nкогда это будет удобно',
                fontSize: 14,
                fontWeight: 400,
                color: context.textSecondary,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ContainerW(
                      onTap: () => Navigator.pop(context, false),
                      color: isDark ? AppColors.black500 : AppColors.white,
                      radius: 12,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: AppText(
                            text: 'Отменить',
                            fontSize: 16,
                            fontWeight: 500,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      child: ContainerW(
                        onTap: () => Navigator.pop(context, true),
                        color: AppColors.red,
                        radius: 12,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: AppText(
                              text: 'Выйти',
                              fontSize: 16,
                              fontWeight: 500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
