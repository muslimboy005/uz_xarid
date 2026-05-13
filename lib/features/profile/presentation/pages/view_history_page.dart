import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_image.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/profile/presentation/bloc/view_history/view_history_bloc.dart';
import 'package:uzxarid/features/profile/presentation/bloc/view_history/view_history_event.dart';
import 'package:uzxarid/features/profile/presentation/bloc/view_history/view_history_state.dart';
import 'package:uzxarid/l10n/app_localizations.dart';
import 'package:uzxarid/features/product_list/data/models/product_list_item_dto.dart';

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
      child: Scaffold(
        appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
        backgroundColor: bodyBg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                    AppText(
                      text: l10n.viewHistoryTitle,
                      fontSize: 20,
                      fontWeight: 700,
                      color: textColor,
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
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            child: InkWell(
                              onTap: () => context.read<ViewHistoryBloc>().add(
                                const ClearHistoryEvent(),
                              ),
                              child: ContainerW(
                                color: context.surfaceContainer.withOpacity(
                                  0.5,
                                ),
                                radius: 12,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cleaning_services_sharp,
                                        size: 20,
                                        color: context.textPrimary,
                                      ),
                                      const SizedBox(width: 12),
                                      AppText(
                                        text: l10n.clearHistory,
                                        fontSize: 16,
                                        fontWeight: 600,
                                        color: context.textPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = history[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _HistoryItemCard(item: item),
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
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final ProductListItemDto item;

  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(
        'product-detail',
        pathParameters: {'slug': item.slug},
      ),
      borderRadius: BorderRadius.circular(16),
      child: ContainerW(
        color: context.cardSurface,
        radius: 16,
        border: Border.all(color: context.borderColor.withOpacity(0.5)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        AppText(
                          text:
                              "1 min ago", // API dan kelgan bo'lsa o'zgartiriladi
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: item.title,
                      fontSize: 17,
                      fontWeight: 800,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text:
                          "Bosh sahifa › Kategoriyalar › ${item.categoryName ?? 'Boshqa'}",
                      fontSize: 14,
                      color: context.textSecondary.withOpacity(0.7),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 22,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.access_time_filled,
              size: 40,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          AppText(
            text: l10n.noViewHistory,
            fontSize: 22,
            fontWeight: 700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AppText(
              text: l10n.viewHistoryEmptyDesc,
              fontSize: 16,
              color: context.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
