import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';

class SupportMenuPage extends StatelessWidget {
  const SupportMenuPage({super.key});

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:+998995501-48');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final isBuying = mode == AppMode.buying;
    final appBarColor = mode.appBarColor;
    final onBar = mode.onAppBarColor;
    final bg = context.bodyBackground;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final border = context.borderColor;
    final card = context.surfaceContainer;

    return Scaffold(
      backgroundColor: appBarColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 60,
            color: appBarColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Logo
                Image.asset(
                  isBuying ? AppAssets.logoAppBarBuying : AppAssets.logoAppBar,
                  height: 36,
                ),
                const Spacer(),
                // X close button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: onBar.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.close, color: onBar, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: bg,
        child: Column(
          children: [
            // Tabs row — stays fixed at top
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _Tab(
                      label: 'Sotaman',
                      selected: !isBuying,
                      onTap: () => context.read<AppModeCubit>().setSelling(),
                    ),
                    _Tab(
                      label: 'Sotib olaman',
                      selected: isBuying,
                      onTap: () => context.read<AppModeCubit>().setBuying(),
                    ),
                  ],
                ),
              ),
            ),
            // Menu items
            Divider(height: 1, color: border),
            _MenuItem(
              icon: Icons.local_offer_outlined,
              iconColor: AppColors.red,
              iconBg: AppColors.red.withValues(alpha: 0.12),
              title: 'Chegirmalar',
              textColor: textPrimary,
              border: border,
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.campaign_outlined,
              iconColor: const Color(0xFFFF8C00),
              iconBg: const Color(0xFFFF8C00).withValues(alpha: 0.12),
              title: 'Aksiyalar',
              textColor: textPrimary,
              border: border,
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.chat_bubble_outline,
              iconColor: mode.primaryColor,
              iconBg: mode.primaryColor.withValues(alpha: 0.12),
              title: 'Qo\'llab-quvvatlash',
              textColor: textPrimary,
              border: border,
              onTap: () => context.push('/profile/support'),
            ),
            _MenuItem(
              icon: null,
              iconColor: Colors.transparent,
              iconBg: Colors.transparent,
              title: 'Buyurtma qanday beriladi?',
              textColor: textPrimary,
              border: border,
              onTap: () {},
            ),
            _MenuItem(
              icon: null,
              iconColor: Colors.transparent,
              iconBg: Colors.transparent,
              title: 'Yetkazib berish va to\'lov',
              textColor: textPrimary,
              border: border,
              onTap: () {},
            ),
            // Phone row
            InkWell(
              onTap: _callPhone,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '+998 99 55-01-48 \u2013 Doimiy',
                        style: TextStyle(fontSize: 15, color: textPrimary),
                      ),
                    ),
                    Icon(Icons.phone_outlined, color: textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: border),
          ],
        ),
      ),
    );
  }
}

// ─── Tab chip ────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final selectedBg = mode.primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Menu item ───────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.textColor,
    required this.border,
    required this.onTap,
  });

  final IconData? icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color textColor;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textColor.withValues(alpha: 0.45),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: border, indent: 16, endIndent: 16),
      ],
    );
  }
}
