import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final borderColor = context.borderColor;
    final surfaceContainer = context.surfaceContainer;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.primary,
      body: Container(
        color: bodyBg,
        child: SafeArea(
          child: Column(
            children: [
              ProfileBreadcrumb(
                labels: [l10n.navHome, l10n.profileTitle, l10n.paymentTitle],
                onTaps: [
                  () => context.go('/home'),
                  () => context.go('/profile'),
                  null,
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  children: [
                    Row(
                      children: [
                        ContainerW(
                          onTap: () => context.pop(),
                          radius: 10,
                          color: cardColor,
                          border: Border.all(color: borderColor),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: AppImage(
                              path: AppAssets.backDropleft,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        AppText(
                          text: 'Оплата и тарифы',
                          fontSize: 20,
                          fontWeight: 700,
                          color: textColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ContainerW(
                      color: cardColor,
                      radius: 12,
                      border: Border.all(color: borderColor),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTariffCard(
                              context: context,
                              title: 'Базовый аккаунт',
                              price: '0.00',
                              unit: "so'm, Oylik",
                              isCurrentPlan: true,
                              features: [
                                _FeatureItem(
                                  'Размещение до 5 объявлений',
                                  true,
                                ),
                                _FeatureItem('Просмотр статистики', true),
                                _FeatureItem(
                                  'Добавление ссылок на соцсети',
                                  true,
                                ),
                                _FeatureItem('Базовая поддержка', true),
                                _FeatureItem('Без автопродления', false),
                                _FeatureItem(
                                  'Без рекламы и продвижения',
                                  false,
                                ),
                                _FeatureItem('Без приоритета в поиске', false),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTariffCard(
                              context: context,
                              title: 'Бизнес-аккаунт',
                              price: '300 000',
                              unit: "so'm, Oylik",
                              isCurrentPlan:
                                  true, // As per second card in design
                              features: [
                                _FeatureItem('Всё из базового плана', true),
                                _FeatureItem(
                                  'Без ограничений по объявлениям',
                                  true,
                                ),
                                _FeatureItem('Автопродление объявлений', true),
                                _FeatureItem('Реклама и продвижение', true),
                                _FeatureItem(
                                  'Приоритетное размещение в поиске',
                                  true,
                                ),
                                _FeatureItem('Поддержка 24/7', true),
                                _FeatureItem('Персональный менеджер', true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    ContainerW(
                      color: cardColor,
                      radius: 12,
                      border: Border.all(color: borderColor),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: 'История',
                                  fontSize: 20,
                                  fontWeight: 700,
                                  color: textColor,
                                ),
                                ContainerW(
                                  color: surfaceContainer,
                                  radius: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.insert_drive_file,
                                          color: context.textSecondary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        AppText(
                                          text: 'Export file',
                                          fontSize: 14,
                                          fontWeight: 500,
                                          color: textColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildHistoryTable(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTariffCard({
    required BuildContext context,
    required String title,
    required String price,
    required String unit,
    required bool isCurrentPlan,
    required List<_FeatureItem> features,
  }) {
    return ContainerW(
      color: context.cardSurface,
      radius: 16,
      border: Border.all(color: context.borderColor),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontSize: 16,
              fontWeight: 600,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  text: price,
                  fontSize: 32,
                  fontWeight: 700,
                  color: context.textPrimary,
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppText(
                    text: unit,
                    fontSize: 14,
                    fontWeight: 400,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: context.borderColor, thickness: 1),
            const SizedBox(height: 16),
            ContainerW(
              color: isCurrentPlan
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
              radius: 8,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: AppText(
                    text: isCurrentPlan ? 'Текущий план' : 'Выбрать план',
                    fontSize: 14,
                    fontWeight: 600,
                    color: isCurrentPlan ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      feature.isIncluded
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: feature.isIncluded
                          ? AppColors.primary
                          : AppColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        text: feature.title,
                        fontSize: 14,
                        fontWeight: 500,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context) {
    final invoices = [
      'Invoice 200112',
      'Invoice 200113',
      'Invoice 200111',
      'Invoice 200110',
      'Invoice 200110',
      'Invoice 200110',
    ];

    return ContainerW(
      color: context.cardSurface,
      radius: 12,
      border: Border.all(color: context.borderColor),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppText(
                    text: 'Счёт',
                    fontSize: 12,
                    fontWeight: 500,
                    color: context.textPrimary,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppText(
                    text: 'Тариф',
                    fontSize: 12,
                    fontWeight: 500,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...invoices.asMap().entries.map((entry) {
            final isLast = entry.key == invoices.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              color: context.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              text: entry.value,
                              fontSize: 14,
                              fontWeight: 500,
                              color: context.textPrimary,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: AppText(
                          text: 'Бизнес-аккаунт',
                          fontSize: 14,
                          fontWeight: 500,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(color: context.borderColor, thickness: 1, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final bool isIncluded;

  _FeatureItem(this.title, this.isIncluded);
}