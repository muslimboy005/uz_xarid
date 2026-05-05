import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/order/presentation/bloc/my_orders/my_orders_bloc.dart';
import 'package:uz_xarid/features/order/presentation/bloc/my_orders/my_orders_event.dart';
import 'package:uz_xarid/features/order/presentation/bloc/my_orders/my_orders_state.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // final isDark = context.isDark;
    // final bodyBg = context.bodyBackground;
    // final cardColor = context.cardSurface;
    // final textColor = context.textPrimary;
    // final textSecondary = context.textSecondary;
    // final borderColor = context.borderColor;
    // final surfaceContainer = context.surfaceContainer;
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),

      body: Container(
        color: bodyBg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: ContainerW(
                        color: context.cardSurface,
                        radius: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppText(
                      text: l10n.myOrdersTitle,
                      fontSize: 22,
                      fontWeight: 700,
                      color: context.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ContainerW(
                    color: context.cardSurface,
                    radius: 16,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: _TabBar(
                            tabs: [l10n.myOrdersTab, l10n.myRequestsTab],
                            selectedIndex: _selectedTab,
                            onTap: (i) => setState(() => _selectedTab = i),
                          ),
                        ),
                        Expanded(
                          child: _selectedTab == 0
                              ? BlocProvider(
                                  create: (context) => getIt<MyOrdersBloc>()
                                    ..add(
                                      const LoadMyOrdersEvent(refresh: true),
                                    ),
                                  child: const _OrdersListView(),
                                )
                              : _EmptyState(
                                  icon: Icons.list_alt_rounded,
                                  title: 'Hali so‘rovlar yo‘q',
                                  subtitle:
                                      'Siz hali hech qanday so‘rov qoldirmadingiz.',
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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
    // final isDark = context.isDark;
    // final surfaceContainer = context.surfaceContainer;
    final cardColor = context.cardSurface;
    final tabUnselected = context.tabUnselected;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final bodyBg = context.bodyBackground;
    return Container(
      decoration: BoxDecoration(
        color: bodyBg,
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

class _OrdersListView extends StatelessWidget {
  const _OrdersListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MyOrdersBloc, MyOrdersState>(
      builder: (context, state) {
        if (state.status == MyOrdersStatus.loading && state.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == MyOrdersStatus.failure &&
            state.orders.isEmpty) {
          return Center(child: Text(state.errorMessage ?? 'Error'));
        } else if (state.status == MyOrdersStatus.success &&
            state.orders.isEmpty) {
          return _EmptyState(
            icon: Icons.shopping_cart_rounded,
            title: l10n.myOrdersEmptyTitle,
            subtitle: l10n.myOrdersEmptySubtitle,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.orders.length + (state.hasReachedMax ? 0 : 1),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= state.orders.length) {
              context.read<MyOrdersBloc>().add(const LoadMyOrdersEvent());
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final order = state.orders[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.bodyBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buyurtma #${order.id}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context
                              .watch<AppModeCubit>()
                              .state
                              .primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.status ?? 'pending',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context
                                    .watch<AppModeCubit>()
                                    .state
                                    .primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Miqdor: ${order.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Izoh: ${order.notes}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    (order.createdAt ?? '').split('T').first,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
