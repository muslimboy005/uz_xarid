import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    // final bodyBg = context.bodyBackground;
    // final borderColor = context.borderColor;
    // final surfaceContainer = context.surfaceContainer;
    final l10n = AppLocalizations.of(context)!;

    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (query) {}, onMenuTap: () {}),
      
      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.black50,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
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
                      onTap: () {},
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
                            onTap: (i) => setState(() => _selectedTab = i),
                          ),
                        ),
                        Expanded(
                          child: _EmptyState(
                            icon: Icons.notifications_rounded,
                            title: l10n.notificationsEmptyTitle,
                            subtitle: l10n.notificationsEmptySubtitle,
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
    final cardSurface = context.cardSurface;
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
                  color: selected ? AppColors.black500 : cardSurface,
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
              color: AppColors.primary,
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
