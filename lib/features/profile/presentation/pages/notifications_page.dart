import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/features/notification/domain/entities/notification_entity.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_event.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_state.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();

  NotificationKind get _currentKind =>
      _selectedTab == 0 ? NotificationKind.order : NotificationKind.system;

  @override
  void initState() {
    super.initState();
    // Open with the Order tab loaded; System loads lazily on tab switch.
    context.read<NotificationBloc>().add(
          const NotificationTabLoadRequested(
            kind: NotificationKind.order,
            refresh: true,
          ),
        );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset < 200) {
      context.read<NotificationBloc>().add(
            NotificationTabLoadMoreRequested(kind: _currentKind),
          );
    }
  }

  void _onTabTap(int index) {
    setState(() => _selectedTab = index);
    final kind = _currentKind;
    final tab = context.read<NotificationBloc>().state.tabFor(kind);
    if (tab.status == NotificationStatus.initial) {
      context.read<NotificationBloc>().add(
            NotificationTabLoadRequested(kind: kind),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final l10n = AppLocalizations.of(context)!;

    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return UzXaridScaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.black50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: ContainerW(
                    color: cardColor,
                    radius: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    text: l10n.notificationsTitle,
                    fontSize: 20,
                    fontWeight: 700,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context
                      .read<NotificationBloc>()
                      .add(const NotificationMarkAllReadRequested()),
                  child: ContainerW(
                    color: cardColor,
                    radius: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.done_all_rounded,
                        size: 20,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ContainerW(
                color: cardColor,
                radius: 16,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _TabBar(
                        tabs: [
                          l10n.notificationsContractsTab,
                          l10n.notificationsSystemTab,
                        ],
                        selectedIndex: _selectedTab,
                        onTap: _onTabTap,
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          final kind = _currentKind;
                          final tab = state.tabFor(kind);

                          if (tab.status == NotificationStatus.loading &&
                              tab.items.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final filtered = tab.items;

                          if (filtered.isEmpty) {
                            return _EmptyState(
                              icon: Icons.notifications_rounded,
                              title: l10n.notificationsEmptyTitle,
                              subtitle: l10n.notificationsEmptySubtitle,
                            );
                          }

                          final bottomInset =
                              MediaQuery.of(context).padding.bottom;
                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<NotificationBloc>().add(
                                    NotificationTabLoadRequested(
                                      kind: kind,
                                      refresh: true,
                                    ),
                                  );
                            },
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: EdgeInsets.fromLTRB(
                                12,
                                4,
                                12,
                                bottomInset + 110,
                              ),
                              itemCount: filtered.length +
                                  (tab.isLoadingMore ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (index >= filtered.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final item = filtered[index];
                                return _NotificationTile(
                                  item: item,
                                  onTap: () {
                                    context
                                        .read<NotificationBloc>()
                                        .add(NotificationOpened(item.id));
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int selectedIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final surfaceContainer = context.surfaceContainer;
    final cardColor = context.cardSurface;
    final tabUnselected = context.tabUnselected;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? cardColor : tabUnselected,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AppText(
                    text: tabs[i],
                    fontSize: 13,
                    fontWeight: selected ? 700 : 500,
                    color: selected ? textColor : textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationEntity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final surface = context.surfaceContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.kind == NotificationKind.order
                    ? Icons.shopping_bag_outlined
                    : Icons.notifications_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: item.title,
                          fontSize: 14,
                          fontWeight: item.isRead ? 500 : 700,
                          color: textColor,
                          maxLines: 2,
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: item.description,
                    fontSize: 12,
                    fontWeight: 400,
                    color: textSecondary,
                    maxLines: 3,
                  ),
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 6),
                    AppText(
                      text: _formatDate(item.createdAt!),
                      fontSize: 11,
                      fontWeight: 400,
                      color: textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.white, size: 34),
          ),
          const SizedBox(height: 20),
          AppText(text: title, fontSize: 16, fontWeight: 700, color: textColor),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            AppText(
              text: subtitle!,
              fontSize: 13,
              fontWeight: 400,
              color: textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
