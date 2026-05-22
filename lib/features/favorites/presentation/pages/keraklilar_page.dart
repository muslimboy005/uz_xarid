import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class _MoreItem {
  const _MoreItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class KeraklilarPage extends StatelessWidget {
  const KeraklilarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final mode = context.watch<AppModeCubit>().state;
    final primary = mode.primaryColor;

    final items = <_MoreItem>[
      _MoreItem(
        icon: Icons.shopping_bag_rounded,
        iconColor: AppColors.orange,
        title: l10n.myOrdersTitle,
        subtitle: l10n.myOrdersEmptySubtitle,
        onTap: () => context.push('/profile/my-orders'),
      ),
      _MoreItem(
        icon: Icons.shopping_cart_rounded,
        iconColor: AppColors.green,
        title: 'Mening savatim',
        subtitle: 'Savatdagi mahsulotlarni ko\'rish va boshqarish',
        onTap: () => context.push('/cart'),
      ),
      _MoreItem(
        icon: Icons.chat_bubble_rounded,
        iconColor: primary,
        title: l10n.chatTitle,
        subtitle: l10n.chatDescription,
        onTap: () => context.push('/keraklilar/chats'),
      ),
      _MoreItem(
        icon: Icons.history_rounded,
        iconColor: AppColors.blue500,
        title: 'Ko\'rilgan tarix',
        subtitle: 'Yaqinda ko\'rilgan e\'lonlar',
        onTap: () => context.push('/profile/view-history'),
      ),
      _MoreItem(
        icon: Icons.notifications_rounded,
        iconColor: AppColors.red,
        title: 'Bildirishnomalar',
        subtitle: 'Yangiliklar va xabarlar',
        onTap: () => context.push('/profile/notifications'),
      ),
      _MoreItem(
        icon: Icons.support_agent_rounded,
        iconColor: AppColors.blue500,
        title: l10n.supportMenuQollabQuvvatlash,
        subtitle: 'Yordam va qo\'llab-quvvatlash',
        onTap: () => context.push('/profile/support'),
      ),
      _MoreItem(
        icon: Icons.local_offer_rounded,
        iconColor: AppColors.red,
        title: l10n.supportMenuChegirmalar,
        subtitle: 'Aksiyalar va chegirmalar',
        onTap: () => context.push('/support-menu'),
      ),
      _MoreItem(
        icon: Icons.settings_rounded,
        iconColor: AppColors.black300,
        title: 'Sozlamalar',
        subtitle: 'Ilova sozlamalari',
        onTap: () => context.push('/profile/settings'),
      ),
    ];

    return UzXaridScaffold.slivers(
      backgroundColor: bodyBg,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
