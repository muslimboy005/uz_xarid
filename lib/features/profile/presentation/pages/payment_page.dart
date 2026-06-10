import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/profile/data/model/plan_history_model.dart';
import 'package:uzxarid/features/profile/data/model/plan_model.dart';
import 'package:uzxarid/features/profile/presentation/bloc/payment/payment_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/payment/payment_event.dart';
import 'package:uzxarid/features/profile/presentation/bloc/payment/payment_state.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

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
      child: UzXaridScaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.black50,
        body: BlocConsumer<PaymentBloc, PaymentState>(
              listenWhen: (prev, curr) =>
                  prev.orderStatus != curr.orderStatus,
              listener: (context, state) async {
                if (state.orderStatus == PlanOrderStatus.success &&
                    state.paymentLink != null &&
                    state.paymentLink!.isNotEmpty) {
                  final link = state.paymentLink!;
                  context.read<PaymentBloc>().add(
                    const ClearPaymentLinkEvent(),
                  );
                  final uri = Uri.tryParse(link);
                  if (uri == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Noto‘g‘ri to‘lov havolasi')),
                      );
                    }
                    return;
                  }
                  final opened = await launchUrl(
                    uri,
                    mode: LaunchMode.inAppWebView,
                  );
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('To‘lov sahifasini ochib bo‘lmadi'),
                      ),
                    );
                  }
                } else if (state.orderStatus == PlanOrderStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.orderErrorMessage ??
                            l10n.dataLoadError,
                      ),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  context.read<PaymentBloc>().add(
                    const ClearPaymentLinkEvent(),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == PaymentStatus.loading &&
                    state.plans == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == PaymentStatus.failure &&
                    state.plans == null) {
                  return Center(
                    child: AppText(
                      text: state.errorMessage ?? l10n.dataLoadError,
                    ),
                  );
                }

                final plans = state.plans?.data.results ?? [];
                final history = state.history?.data.results ?? [];

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(
                          left: AppDimens.paddingMedium,
                          right: AppDimens.paddingMedium,
                          top: AppDimens.paddingMedium,
                          bottom:
                              AppDimens.bottomNavClearance +
                              MediaQuery.of(context).padding.bottom,
                        ),
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
                          const SizedBox(height: 16),
                          ...plans.asMap().entries.map((entry) {
                            final index = entry.key;
                            final plan = entry.value;
                            final isOrdering =
                                state.orderStatus == PlanOrderStatus.loading &&
                                state.orderingPlanId == plan.id;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == plans.length - 1 ? 0 : 12,
                              ),
                              child: _buildTariffCard(
                                primaryColor: primaryColor,
                                context: context,
                                plan: plan,
                                isLoading: isOrdering,
                                onSelect: plan.isPurchased
                                    ? null
                                    : () => _onSelectPlan(context, plan.id),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          ContainerW(
                            color: cardColor,
                            radius: 12,
                            border: Border.all(color: borderColor),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        text: l10n.paymentHistoryTitle,
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
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: AppText(
                                              text:
                                                  'jami ${state.history?.data.totalItems ?? history.length} ta',
                                              fontSize: 13,
                                              fontWeight: 500,
                                              color: context.textSecondary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (history.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: AppText(
                                          text: 'Tarix mavjud emas',
                                          fontSize: 16,
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    )
                                  else
                                    _buildHistoryList(context, history),
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
    );
  }

  void _onSelectPlan(BuildContext context, int planId) {
    context.read<PaymentBloc>().add(
      CreatePlanOrderEvent(userPlanId: planId, paymentMethod: 'rahmat'),
    );
  }

  Widget _buildTariffCard({
    required BuildContext context,
    required Color primaryColor,
    required PlanModel plan,
    bool isLoading = false,
    VoidCallback? onSelect,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final palette = _paletteFor(context, plan);
    final hasDiscount = plan.hasDiscount;

    // Bepul (0 so'm) reja foydalanuvchining joriy/aktiv rejasi hisoblanadi —
    // shu sababli uning tugmasi bosilmaydi.
    final isFree =
        plan.type == 'free' || (double.tryParse(plan.finalPrice) ?? 0) == 0;
    final isCurrent = plan.isPurchased || isFree;
    final buttonDisabled = isCurrent || isLoading;

    return ContainerW(
      color: palette.cardBg,
      radius: 16,
      border: Border.all(color: palette.border),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sarlavha + chegirma belgisi
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    text: plan.name,
                    fontSize: 16,
                    fontWeight: 600,
                    color: palette.titleColor,
                    maxLines: 2,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: palette.discountBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      text: '-${plan.discountValue.toStringAsFixed(0)}%',
                      fontSize: 13,
                      fontWeight: 700,
                      color: palette.discountText,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // Chegirma bo'lsa - eski narx (chizilgan)
            if (hasDiscount)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: AppText(
                  text: "${formatPrice(plan.price)} so'm",
                  fontSize: 14,
                  fontWeight: 500,
                  color: palette.struckColor,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: palette.struckColor,
                ),
              ),
            // Yakuniy narx
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: AppText(
                    text: formatPrice(plan.finalPrice),
                    fontSize: 30,
                    fontWeight: 700,
                    color: palette.priceColor,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: AppText(
                    text: "so'm, Oylik",
                    fontSize: 13,
                    fontWeight: 400,
                    color: palette.subtitleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AppText(
              text: "(${_formatMoneyKeepDecimals(plan.currencyPrice)} so'm)",
              fontSize: 13,
              fontWeight: 400,
              color: palette.subtitleColor,
            ),
            const SizedBox(height: 12),
            ContainerW(
              onTap: buttonDisabled ? null : onSelect,
              color: isCurrent ? palette.buttonDisabledBg : palette.buttonBg,
              radius: 10,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.buttonText,
                          ),
                        )
                      : AppText(
                          text: plan.isPurchased
                              ? l10n.paymentCurrentPlan
                              : l10n.paymentSelectPlan,
                          fontSize: 14,
                          fontWeight: 600,
                          color: isCurrent
                              ? palette.buttonDisabledText
                              : palette.buttonText,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: palette.dividerColor, thickness: 1, height: 1),
            const SizedBox(height: 12),
            ...plan.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature.isIncluded
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: feature.isIncluded
                          ? palette.includedIcon
                          : palette.excludedIcon,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText(
                        text: feature.name,
                        fontSize: 14,
                        fontWeight: 500,
                        color: palette.featureColor,
                        maxLines: 3,
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

  /// Reja turiga (`free` / `standard` / `premium`) qarab rang palitrasi.
  /// Web dizayndagi ranglarga moslangan: bepul — och binafsha, biznes — to'q
  /// ko'k, premium — krem/sariq.
  _PlanPalette _paletteFor(BuildContext context, PlanModel plan) {
    final isDark = context.isDark;

    switch (plan.type) {
      case 'standard':
        const navy = Color(0xFF0F1B3D);
        return _PlanPalette(
          cardBg: navy,
          border: navy,
          titleColor: AppColors.white,
          priceColor: AppColors.white,
          subtitleColor: const Color(0xFF9AA6C4),
          struckColor: const Color(0xFF8693B4),
          dividerColor: AppColors.white.withOpacity(0.12),
          includedIcon: const Color(0xFF4D8BFF),
          excludedIcon: AppColors.red,
          featureColor: const Color(0xFFE8ECF6),
          discountBg: AppColors.red,
          discountText: AppColors.white,
          buttonBg: AppColors.primary,
          buttonText: AppColors.white,
          buttonDisabledBg: AppColors.primary.withOpacity(0.30),
          buttonDisabledText: AppColors.white.withOpacity(0.6),
        );
      case 'premium':
        const amber = Color(0xFFE0A22B);
        final cardBg = isDark ? context.cardSurface : const Color(0xFFFFF8E6);
        return _PlanPalette(
          cardBg: cardBg,
          border: isDark ? context.borderColor : const Color(0xFFF0E2BB),
          titleColor: context.textSecondary,
          priceColor: context.textPrimary,
          subtitleColor: context.textSecondary,
          struckColor: context.textSecondary,
          dividerColor: isDark
              ? context.borderColor
              : const Color(0xFFEFE3C2),
          includedIcon: amber,
          excludedIcon: AppColors.red,
          featureColor: isDark
              ? context.textPrimary
              : const Color(0xFF6E6B61),
          discountBg: amber,
          discountText: AppColors.white,
          buttonBg: AppColors.primary,
          buttonText: AppColors.white,
          buttonDisabledBg: AppColors.primary.withOpacity(0.30),
          buttonDisabledText: AppColors.white.withOpacity(0.7),
        );
      case 'free':
      default:
        final cardBg = isDark ? context.cardSurface : const Color(0xFFF1F4FF);
        return _PlanPalette(
          cardBg: cardBg,
          border: isDark ? context.borderColor : const Color(0xFFE1E8FF),
          titleColor: context.textSecondary,
          priceColor: context.textPrimary,
          subtitleColor: context.textSecondary,
          struckColor: context.textSecondary,
          dividerColor: isDark
              ? context.borderColor
              : const Color(0xFFDDE4FA),
          includedIcon: AppColors.primary,
          excludedIcon: AppColors.red,
          featureColor: isDark
              ? context.textPrimary
              : const Color(0xFF59637A),
          discountBg: AppColors.red,
          discountText: AppColors.white,
          buttonBg: AppColors.primary,
          buttonText: AppColors.white,
          buttonDisabledBg: isDark
              ? AppColors.primary.withOpacity(0.20)
              : const Color(0xFFCFE0FF),
          buttonDisabledText: isDark
              ? AppColors.white.withOpacity(0.6)
              : const Color(0xFF7CA3EC),
        );
    }
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<PlanHistoryItemModel> history,
  ) {
    return Column(
      children: history.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == history.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: _buildHistoryCard(context, item),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PlanHistoryItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    final status = _statusStyle(item.paymentStatus);
    final date = _formatDate(item.createdAt);

    return ContainerW(
      color: context.surfaceContainer,
      radius: 12,
      border: Border.all(color: context.borderColor),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: '#${item.id}',
                  fontSize: 15,
                  fontWeight: 700,
                  color: context.textPrimary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AppText(
                        text: status.label,
                        fontSize: 12,
                        fontWeight: 600,
                        color: status.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHistoryRow(
              context,
              l10n.paymentTariff,
              item.planName.isEmpty ? '-' : item.planName,
            ),
            const SizedBox(height: 8),
            _buildHistoryRow(
              context,
              'Summa',
              "${formatPrice(item.amount)} so'm",
              valueBold: true,
            ),
            if (date != null) ...[
              const SizedBox(height: 8),
              _buildHistoryRow(context, 'Sana', date),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(
    BuildContext context,
    String label,
    String value, {
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: AppText(
            text: label,
            fontSize: 13,
            fontWeight: 400,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            text: value,
            fontSize: 13,
            fontWeight: valueBold ? 700 : 500,
            color: context.textPrimary,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  /// Sana ISO formatdan `dd.MM.yyyy` ko'rinishiga o'tkaziladi.
  String? _formatDate(String? iso) {
    if (iso == null || iso.length < 10) return null;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return null;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  /// To'lov holatiga mos rang va matn.
  _StatusStyle _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'completed':
        return _StatusStyle(
          color: AppColors.green,
          background: AppColors.green.withOpacity(0.12),
          label: "to'landi",
        );
      case 'failed':
      case 'cancelled':
      case 'canceled':
      case 'error':
        return _StatusStyle(
          color: AppColors.red,
          background: AppColors.red.withOpacity(0.12),
          label: 'bekor qilindi',
        );
      case 'pending':
      default:
        return _StatusStyle(
          color: AppColors.textYellow500,
          background: AppColors.textYellow500.withOpacity(0.14),
          label: 'kutilmoqda',
        );
    }
  }

  /// Narxni 2 xonali kasr bilan formatlash (masalan, 206 000.00).
  String _formatMoneyKeepDecimals(String? value) {
    if (value == null || value.isEmpty) return '0.00';
    final cleaned = value.trim();
    final dotIndex = cleaned.indexOf('.');
    final intPart = dotIndex == -1 ? cleaned : cleaned.substring(0, dotIndex);
    var fracPart = dotIndex == -1 ? '' : cleaned.substring(dotIndex + 1);
    fracPart = fracPart.padRight(2, '0');
    if (fracPart.length > 2) fracPart = fracPart.substring(0, 2);

    final buf = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      buf.write(intPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) buf.write(' ');
    }
    final formattedInt = buf.toString().split('').reversed.join();
    return '$formattedInt.$fracPart';
  }
}

/// To'lov holati uchun vizual uslub.
class _StatusStyle {
  final Color color;
  final Color background;
  final String label;

  const _StatusStyle({
    required this.color,
    required this.background,
    required this.label,
  });
}

/// Tarif kartasi uchun reja turiga bog'liq rang palitrasi.
class _PlanPalette {
  final Color cardBg;
  final Color border;
  final Color titleColor;
  final Color priceColor;
  final Color subtitleColor;
  final Color struckColor;
  final Color dividerColor;
  final Color includedIcon;
  final Color excludedIcon;
  final Color featureColor;
  final Color discountBg;
  final Color discountText;
  final Color buttonBg;
  final Color buttonText;
  final Color buttonDisabledBg;
  final Color buttonDisabledText;

  const _PlanPalette({
    required this.cardBg,
    required this.border,
    required this.titleColor,
    required this.priceColor,
    required this.subtitleColor,
    required this.struckColor,
    required this.dividerColor,
    required this.includedIcon,
    required this.excludedIcon,
    required this.featureColor,
    required this.discountBg,
    required this.discountText,
    required this.buttonBg,
    required this.buttonText,
    required this.buttonDisabledBg,
    required this.buttonDisabledText,
  });
}
