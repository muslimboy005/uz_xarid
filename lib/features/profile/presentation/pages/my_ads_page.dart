import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/utils/image_parser.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/features/profile/data/models/my_listing_item_dto.dart';
import 'package:uzxarid/features/profile/presentation/bloc/my_ads/my_ads_bloc.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

/// status key -> label getter (l10n -> text)
List<(String, String Function(AppLocalizations l))> _statusTabLabels() => [
  ('active', (l) => l.myAdsStatusActive),
  ('pending', (l) => l.myAdsStatusPending),
  ('unpaid', (l) => l.myAdsStatusUnpaid),
  ('inactive', (l) => l.myAdsStatusInactive),
  ('rejected', (l) => l.myAdsStatusRejected),
];

class MyAdsPage extends StatelessWidget {
  const MyAdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final borderColor = context.borderColor;

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
        title: AppText(
          text: l10n.myAdsTitle,
          fontSize: 18,
          fontWeight: 700,
          color: Colors.white,
        ),
        backgroundColor: primaryColor,
        elevation: 0,

        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.only(right: 16),
        //       child: TextButton.icon(
        //         onPressed: () => context.push('/add-listing'),
        //         icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        //         label: AppText(
        //           text: 'Qo\'shish',
        //           fontSize: 14,
        //           fontWeight: 600,
        //           color: Colors.white,
        //         ),
        //         style: TextButton.styleFrom(
        //           backgroundColor: AppColors.primary,
        //           foregroundColor: Colors.white,
        //         ),
        //       ),
        //     ),
        //   ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLimitCard(
              context,
              l10n,
              primaryColor,
              cardColor,
              textColor,
              textSecondary,
              borderColor,
            ),
            _buildTabs(
              context,
              l10n,
              primaryColor,
              cardColor,
              textColor,
              borderColor,
            ),
            Expanded(
              child: BlocBuilder<MyAdsBloc, MyAdsState>(
                builder: (context, state) {
                  if (state.loading && state.list.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null && state.list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    );
                  }
                  if (state.list.isEmpty) {
                    return _buildEmptyState(
                      l10n,
                      primaryColor,
                      textColor,
                      textSecondary,
                    );
                  }
                  return _buildGrid(
                    context,
                    state,
                    l10n,
                    primaryColor,
                    cardColor,
                    textColor,
                    textSecondary,
                    borderColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-listing'),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildLimitCard(
    BuildContext context,
    AppLocalizations l10n,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    const limit = 4;
    const used = 1; // TODO: API dan kelganda almashtirish
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: l10n.myAdsLimitTitle,
            fontSize: 16,
            fontWeight: 600,
            color: textColor,
          ),
          const SizedBox(height: 4),
          AppText(
            text: l10n.myAdsLimitUpTo(limit),
            fontSize: 13,
            fontWeight: 400,
            color: textSecondary,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.push('/profile/payment'),
            icon: Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: primaryColor,
            ),
            label: AppText(
              text: l10n.myAdsIncreaseLimit,
              fontSize: 14,
              fontWeight: 500,
              color: primaryColor,
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(limit, (i) {
              final filled = i < used;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < limit - 1 ? 6 : 0),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled
                        ? primaryColor
                        : borderColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(
    BuildContext context,
    AppLocalizations l10n,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final tabs = _statusTabLabels();
    return BlocBuilder<MyAdsBloc, MyAdsState>(
      buildWhen: (prev, cur) => prev.status != cur.status,
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final tab = tabs[i];
              final statusKey = tab.$1;
              final label = tab.$2(l10n);
              final selected = state.status == statusKey;
              return GestureDetector(
                onTap: () {
                  context.read<MyAdsBloc>().add(MyAdsLoadRequested(statusKey));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? primaryColor : cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? primaryColor : borderColor,
                    ),
                  ),
                  child: Center(
                    child: AppText(
                      text: label,
                      fontSize: 13,
                      fontWeight: selected ? 600 : 500,
                      color: selected ? Colors.white : textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    Color primaryColor,
    Color textColor,
    Color textSecondary,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 80,
              color: primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            AppText(
              text: l10n.myAdsEmptyTitle,
              fontSize: 18,
              fontWeight: 700,
              color: textColor,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              text: l10n.myAdsEmptySubtitle,
              fontSize: 14,
              fontWeight: 400,
              color: textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    MyAdsState state,
    AppLocalizations l10n,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    final list = state.list;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.48,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        final isDeleting = state.deletingSlug == item.slug;
        return _MyAdCard(
          item: item,
          l10n: l10n,
          primaryColor: primaryColor,
          cardColor: cardColor,
          textColor: textColor,
          textSecondary: textSecondary,
          borderColor: borderColor,
          isDeleting: isDeleting,
          onTap: () => context.push('/ad/${item.slug}', extra: item),
          onEdit: () => context.push('/add-listing/${item.slug}', extra: item),
          onDelete: () => _showDeleteConfirmDialog(context, l10n, item.slug),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
    String slug,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.myAdsDeleteDialogTitle),
        content: Text(l10n.myAdsDeleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(l10n.myAdsDelete),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<MyAdsBloc>().add(MyAdsDeleteRequested(slug));
      }
    });
  }
}

String _formatAdType(AppLocalizations l10n, String? adType) {
  if (adType == null) return '—';
  return adType == 'Sell' ? l10n.adTypeSell : l10n.adTypeBuy;
}

String _formatListingType(AppLocalizations l10n, String? type) {
  if (type == null) return '—';
  return switch (type) {
    'Product' => l10n.listingTypeProduct,
    'Service' => l10n.listingTypeService,
    'Auto' => l10n.listingTypeAuto,
    'Home' => l10n.listingTypeHome,
    _ => type,
  };
}

String _formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';
  } catch (_) {
    return iso;
  }
}

String _monthName(int m) {
  const names = [
    '',
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'Iyun',
    'Iyul',
    'Avg',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];
  return m >= 1 && m <= 12 ? names[m] : '$m';
}

class _MyAdCard extends StatelessWidget {
  const _MyAdCard({
    required this.item,
    required this.l10n,
    required this.primaryColor,
    required this.cardColor,
    required this.textColor,
    required this.textSecondary,
    required this.borderColor,
    required this.isDeleting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final MyListingItemDto item;
  final AppLocalizations l10n;
  final Color primaryColor;
  final Color cardColor;
  final Color textColor;
  final Color textSecondary;
  final Color borderColor;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: onTap,
              child: AspectRatio(
                aspectRatio: 1.35,
                child: item.mainImage != null && item.mainImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.mainImage!.cdnUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: borderColor.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: textSecondary,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: AppText(
                                  text: _formatDate(item.createdAt),
                                  fontSize: 11,
                                  fontWeight: 400,
                                  color: textSecondary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: textSecondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  text: _formatAdType(l10n, item.adType),
                                  fontSize: 10,
                                  fontWeight: 500,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFB85C2A,
                                  ).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AppText(
                                  text: _formatListingType(
                                    l10n,
                                    item.listingType,
                                  ),
                                  fontSize: 10,
                                  fontWeight: 500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AppText(
                            text: item.title,
                            fontSize: 13,
                            fontWeight: 700,
                            color: textColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.categoryName != null &&
                              item.categoryName!.isNotEmpty)
                            AppText(
                              text: item.categoryName!,
                              fontSize: 12,
                              fontWeight: 400,
                              color: textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 2),
                              AppText(
                                text: '${item.viewsCount}',
                                fontSize: 11,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 14,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 2),
                              AppText(
                                text: '${item.likesCount}',
                                fontSize: 11,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 2),
                              AppText(
                                text: '${item.callCount}',
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CardButton(
                      label: l10n.myAdsPromoFrom,
                      color: textSecondary.withValues(alpha: 0.2),
                      textColor: textColor,
                      onTap: () {},
                    ),
                    const SizedBox(height: 6),
                    _CardButton(
                      label: l10n.myAdsDelete,
                      color: AppColors.red,
                      textColor: Colors.white,
                      icon: Icons.delete_outline_rounded,
                      isLoading: isDeleting,
                      onTap: onDelete,
                    ),
                    const SizedBox(height: 6),
                    _CardButton(
                      label: l10n.myAdsEdit,
                      color: primaryColor,
                      textColor: Colors.white,
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
    this.isLoading = false,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 20,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 16, color: textColor),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: AppText(
                            text: label,
                            fontSize: 11,
                            fontWeight: 600,
                            color: textColor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
