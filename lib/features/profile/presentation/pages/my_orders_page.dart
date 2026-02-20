import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      backgroundColor: AppColors.black50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBreadcrumb(
              labels: [l10n.navHome, l10n.profileTitle, l10n.myOrdersTitle],
              onTaps: [
                () => context.go('/home'),
                () => context.go('/profile'),
                null,
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: ContainerW(
                      color: AppColors.white,
                      radius: 8,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    text: l10n.myOrdersTitle,
                    fontSize: 22,
                    fontWeight: 700,
                    color: AppColors.black500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ContainerW(
                  color: AppColors.white,
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
                        child: _EmptyState(
                          icon: Icons.shopping_cart_rounded,
                          title: l10n.myOrdersEmptyTitle,
                          subtitle: l10n.myOrdersEmptySubtitle,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black50,
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
                  color: selected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                    fontWeight: selected ? 600 : 400,
                    color: selected ? AppColors.black500 : AppColors.black300,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.blue500,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.white, size: 34),
          ),
          const SizedBox(height: 20),
          AppText(
            text: title,
            fontSize: 16,
            fontWeight: 700,
            color: AppColors.black500,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            AppText(
              text: subtitle!,
              fontSize: 13,
              fontWeight: 400,
              color: AppColors.black300,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
