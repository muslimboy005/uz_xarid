import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/profile/data/model/plan_history_model.dart';
import 'package:uz_xarid/features/profile/data/model/plan_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/payment/payment_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/payment/payment_event.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/payment/payment_state.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final isDark = context.isDark;
    final l10n = AppLocalizations.of(context)!;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final borderColor = context.borderColor;
    final surfaceContainer = context.surfaceContainer;

    return BlocProvider(
      create: (context) => GetIt.I<PaymentBloc>()
        ..add(const GetPaymentPlansEvent())
        ..add(const GetPaymentHistoryEvent()),
      child: Scaffold(
        appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
        body: Container(
          color: isDark ? AppColors.darkBackground : AppColors.black50,
          child: SafeArea(
            child: BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state.status == PaymentStatus.loading && state.plans == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == PaymentStatus.failure && state.plans == null) {
                  return Center(child: AppText(text: state.errorMessage ?? l10n.dataLoadError));
                }

                final plans = state.plans?.data.results ?? [];
                final history = state.history?.data.results ?? [];

                return Column(
                  children: [
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
                                text: l10n.paymentTitle,
                                fontSize: 20,
                                fontWeight: 700,
                                color: textColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (plans.isNotEmpty)
                            ContainerW(
                              color: cardColor,
                              radius: 12,
                              border: Border.all(color: borderColor),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: plans.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final plan = entry.value;
                                    return Column(
                                      children: [
                                        _buildTariffCard(
                                          context: context,
                                          title: plan.name,
                                          price: plan.price,
                                          unit: "so'm, Oylik",
                                          isCurrentPlan: plan.isPurchased,
                                          features: plan.features,
                                          primaryColor: primaryColor,
                                          
                                        ),
                                        if (index != plans.length - 1)
                                          const SizedBox(height: 16),
                                      ],
                                    );
                                  }).toList(),
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
                                      if (history.isNotEmpty)
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
                                  if (history.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                        child: AppText(
                                          text: 'Tarix mavjud emas',
                                          fontSize: 16,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    )
                                  else
                                    _buildHistoryTable(context, history),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTariffCard({
    required BuildContext context,
    required Color primaryColor,
    required String title,
    required String price,
    required String unit,
    required bool isCurrentPlan,
    required List<PlanFeatureModel> features,
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
                  text: double.tryParse(price)?.toStringAsFixed(0) ?? price,
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
                  : AppColors.primary.withOpacity(0.2),
              radius: 8,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: AppText(
                    text: isCurrentPlan ? 'Текущий план' : 'Выбрать план',
                    fontSize: 14,
                    fontWeight: 600,
                    color: isCurrentPlan ? AppColors.white : primaryColor,
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
                      feature.isIncluded ? Icons.check_circle : Icons.cancel_outlined,
                      color: feature.isIncluded ? AppColors.primary : AppColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        text: feature.name,
                        fontSize: 14,
                        fontWeight: 500,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, List<PlanHistoryItemModel> history) {
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
          ...history.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == history.length - 1;
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
                              text: 'Invoice ${item.id}',
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
                          text: item.planName,
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

