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
import 'package:uz_xarid/core/widgets/w_text_form.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});

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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'Qayerga yetkazamiz?',
                      fontSize: 24,
                      fontWeight: 700,
                      color: AppColors.black500,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: 'Xaritadan manzilni kiriting',
                      fontSize: 14,
                      fontWeight: 400,
                      color: AppColors.black300,
                    ),
                    const SizedBox(height: 24),
                    ContainerW(
                      color: AppColors.white,
                      radius: 12,
                      border: Border.all(color: AppColors.black100),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ContainerW(
                              color: AppColors.primary,
                              radius: 20, // Circular looking
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: 'Parkent kochasi 4/2',
                                    fontSize: 16,
                                    fontWeight: 600,
                                    color: AppColors.black500,
                                  ),
                                  const SizedBox(height: 4),
                                  AppText(
                                    text: 'Toshkent',
                                    fontSize: 14,
                                    fontWeight: 400,
                                    color: AppColors.black300,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.black500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.paddingLarge),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      WTextField(
                        title: 'Город',
                        hintText: 'Введите город',
                        fillColor: AppColors.black50,
                        borderNoFocusColor: AppColors.black100,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: WTextField(
                              title: 'Улица',
                              hintText: 'Введите улицу',
                              fillColor: AppColors.black50,
                              borderNoFocusColor: AppColors.black100,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: WTextField(
                              title: 'Дом / Квартира',
                              hintText: 'Дом / Квартира',
                              fillColor: AppColors.black50,
                              borderNoFocusColor: AppColors.black100,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      WTextField(
                        title: 'Ориентир',
                        hintText: 'Укажите ближайший ориентир',
                        fillColor: AppColors.black50,
                        borderNoFocusColor: AppColors.black100,
                      ),
                      const SizedBox(height: 48),
                      ContainerW(
                        onTap: () => context.pop(),
                        color: AppColors.primary,
                        radius: 12,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: AppText(
                              text: 'Сохранить',
                              fontSize: 16,
                              fontWeight: 600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}