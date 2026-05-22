import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/price_formatter.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/currency/domain/currency.dart';
import 'package:uzxarid/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:uzxarid/features/profile/data/model/viewed_ads_response_model.dart';
import 'package:uzxarid/features/profile/presentation/bloc/view_history/view_history_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/view_history/view_history_event.dart';
import 'package:uzxarid/features/profile/presentation/bloc/view_history/view_history_state.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class ViewHistoryPage extends StatelessWidget {
  const ViewHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;

    return BlocProvider(
      create: (context) =>
          GetIt.I<ViewHistoryBloc>()..add(const GetViewHistoryEvent()),
      child: UzXaridScaffold(
        backgroundColor: bodyBg,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: ContainerW(
                      color: cardColor,
                      radius: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppImage(
                          path: AppAssets.backDropleft,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText(
                      text: l10n.viewHistoryTitle,
                      fontSize: 20,
                      fontWeight: 700,
                      color: textColor,
                    ),
                  ),
                  BlocBuilder<ViewHistoryBloc, ViewHistoryState>(
                    buildWhen: (p, c) => p.history != c.history,
                    builder: (context, state) {
                      final count = state.history?.data.totalItems ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          text: '$count',
                          fontSize: 13,
                          fontWeight: 700,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ViewHistoryBloc, ViewHistoryState>(
                builder: (context, state) {
                  if (state.status == ViewHistoryStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ViewHistoryStatus.failure) {
                    return Center(
                      child: AppText(text: state.errorMessage ?? 'Error'),
                    );
                  }

                  final history = state.history?.data.results ?? [];

                  if (history.isEmpty) {
                    return _EmptyState(l10n: l10n);
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: _ClearHistoryButton(l10n: l10n),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = history[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryItemCard(item: item, l10n: l10n),
                            );
                          }, childCount: history.length),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearHistoryButton extends StatelessWidget {
  final AppLocalizations l10n;

  const _ClearHistoryButton({required this.l10n});

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: AppText(
          text: l10n.clearHistory,
          fontSize: 18,
          fontWeight: 700,
        ),
        content: AppText(
          text: l10n.viewHistoryEmptyDesc,
          fontSize: 14,
          color: ctx.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: AppText(
              text: 'Bekor qilish',
              color: ctx.textSecondary,
              fontWeight: 600,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: AppText(
              text: l10n.clearHistory,
              color: AppColors.red,
              fontWeight: 700,
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ViewHistoryBloc>().add(const ClearHistoryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _confirm(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_sweep_rounded,
              size: 20,
              color: AppColors.red,
            ),
            const SizedBox(width: 10),
            AppText(
              text: l10n.clearHistory,
              fontSize: 15,
              fontWeight: 700,
              color: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final ViewedAdItem item;
  final AppLocalizations l10n;

  const _HistoryItemCard({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final ad = item.ad;
    final primary = context.watch<AppModeCubit>().state.primaryColor;
    final selectedCcy = context.watch<CurrencyCubit>().state.selectedCcy;
    final currency = currencyDisplayLabel(selectedCcy);
    final currentPrice = formatPrice(ad.finalPrice ?? ad.price);
    final formattedOld = formatPrice(ad.price);
    final oldPrice = (ad.finalPrice != null && formattedOld != currentPrice)
        ? formattedOld
        : '';

    return InkWell(
      onTap: () => context.pushNamed(
        'product-detail',
        pathParameters: {'slug': ad.slug},
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 92,
                height: 92,
                child: AppImage(
                  path: ad.mainImage ?? '',
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: context.surfaceContainer,
                    child: Icon(
                      Icons.image_outlined,
                      color: context.textSecondary.withOpacity(0.5),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: ad.title,
                    fontSize: 15,
                    fontWeight: 700,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    height: 1.25,
                    color: context.textPrimary,
                  ),
                  const SizedBox(height: 6),
                  if (oldPrice.isNotEmpty)
                    AppText(
                      text: '$oldPrice $currency',
                      fontSize: 12,
                      color: context.textSecondary,
                      decoration: TextDecoration.lineThrough,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (currentPrice.isNotEmpty)
                    AppText(
                      text: '$currentPrice $currency',
                      fontSize: 16,
                      fontWeight: 800,
                      color: primary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AppText(
                          text: _formatRelativeTime(item.viewedAt, l10n),
                          fontSize: 12,
                          color: context.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (ad.categoryName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: context.textSecondary.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: AppText(
                            text: ad.categoryName!,
                            fontSize: 12,
                            color: context.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRelativeTime(DateTime? when, AppLocalizations l10n) {
  if (when == null) return '';
  final diff = DateTime.now().difference(when);
  if (diff.inSeconds < 60) return 'hozir';
  if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
  if (diff.inHours < 24) return '${diff.inHours} soat oldin';
  if (diff.inDays < 7) return '${diff.inDays} kun oldin';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} hafta oldin';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} oy oldin';
  return '${(diff.inDays / 365).floor()} yil oldin';
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          AppText(
            text: l10n.noViewHistory,
            fontSize: 20,
            fontWeight: 700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AppText(
              text: l10n.viewHistoryEmptyDesc,
              fontSize: 14,
              color: context.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
