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

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: context.bodyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontSize: 16,
              fontWeight: 600,
              color: AppColors.black400,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  text: price,
                  fontSize: 32,
                  fontWeight: 700,
                  color: AppColors.black500,
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppText(
                    text: unit,
                    fontSize: 14,
                    fontWeight: 400,
                    color: AppColors.black300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.black100, thickness: 1),
            const SizedBox(height: 16),
            ContainerW(
              color: isCurrentPlan
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary,
              radius: 8,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: AppText(
                    text: isCurrentPlan ? 'Текущий план' : 'Выбрать план',
                    fontSize: 14,
                    fontWeight: 600,
                    color: AppColors.white,
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
                        color: AppColors.black500,
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

  Widget _buildHistoryTable() {
    final invoices = [
      'Invoice 200112',
      'Invoice 200113',
      'Invoice 200111',
      'Invoice 200110',
      'Invoice 200110',
      'Invoice 200110',
    ];

    return ContainerW(
      color: AppColors.white,
      radius: 12,
      border: Border.all(color: AppColors.black100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.black50,
              borderRadius: BorderRadius.only(
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
                    color: AppColors.black500,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppText(
                    text: 'Тариф',
                    fontSize: 12,
                    fontWeight: 500,
                    color: AppColors.black500,
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
                            const Icon(
                              Icons.insert_drive_file_outlined,
                              color: AppColors.black400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              text: entry.value,
                              fontSize: 14,
                              fontWeight: 500,
                              color: AppColors.black500,
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
                          color: AppColors.black500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    color: AppColors.black100,
                    thickness: 1,
                    height: 1,
                  ),
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
