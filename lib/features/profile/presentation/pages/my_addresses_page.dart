import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class MyAddressesPage extends StatelessWidget {
  const MyAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.primary,
      body: Container(
        color: bodyBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileBreadcrumb(
                labels: [
                  l10n.navHome,
                  l10n.profileTitle,
                  l10n.myAddressesTitle,
                ],
                onTaps: [
                  () => context.go('/home'),
                  () => context.go('/profile'),
                  null,
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: ContainerW(
                    width: double.infinity,
                    color: cardColor,
                    radius: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ContainerW(
                          color: AppColors.primary,
                          radius: 12,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: AppImage(
                              path: AppAssets.locationOn,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppText(
                          text: 'Добавить свой адрес',
                          fontSize: 20,
                          fontWeight: 700,
                          color: textColor,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          text:
                              'Сохраняйте адреса для быстрого\nоформления заказов.',
                          fontSize: 14,
                          fontWeight: 400,
                          color: textSecondary,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        ContainerW(
                          onTap: () => context.push('/profile/add-address'),
                          color: AppColors.primary,
                          radius: 8,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  text: 'Добавить',
                                  fontSize: 16,
                                  fontWeight: 500,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
