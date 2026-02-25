import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class MyAddressesPage extends StatelessWidget {
  const MyAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.primary,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              ProfileBreadcrumb(
                labels: [
                  l10n.navHome,
                  l10n.profileTitle,
                  l10n.profileMenuMyAds,
                ],
                onTaps: [
                  () => context.go('/home'),
                  () => context.go('/profile'),
                  null,
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                child: Row(
                  children: [
                    ContainerW(
                      onTap: () => context.pop(),
                      radius: 10,
                      color: AppColors.white,
                      border: Border.all(color: AppColors.black100),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AppImage(path: AppAssets.backDropleft),
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppText(
                      text: 'Мои адреса',
                      fontSize: 20,
                      fontWeight: 700,
                      color: AppColors.black500,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingMedium,
                  ),
                  child: ContainerW(
                    width: double.infinity,
                    radius: 12,
                    color: AppColors.white,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ContainerW(
                          color: AppColors.primary,
                          radius: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
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
                          fontSize: 18,
                          fontWeight: 700,
                          color: AppColors.black500,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          text:
                              'Сохраняйте адреса для быстрого\nоформления заказов.',
                          fontSize: 14,
                          fontWeight: 400,
                          color: AppColors.black300,
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
                                AppImage(
                                  path: AppAssets.plus,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
