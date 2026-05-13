import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/features/currency/presentation/widgets/currency_selector.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class SupportMenuPage extends StatelessWidget {
  const SupportMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final isBuying = mode == AppMode.buying;
    final bg = context.bodyBackground;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final border = context.borderColor;
    final card = context.surfaceContainer;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: mode.appBarColor,
      appBar: UzXaridAppBar(
        onClose: () => context.pop(),
        onSearchTap: () => context.push('/search'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - 112,
        color: bg,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CurrencySelectorSection(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _Tab(
                        label: l10n.supportMenuSotaman,
                        selected: !isBuying,
                        onTap: () => context.read<AppModeCubit>().setSelling(),
                      ),
                      _Tab(
                        label: l10n.supportMenuSotibOlaman,
                        selected: isBuying,
                        onTap: () => context.read<AppModeCubit>().setBuying(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _MenuItem(
                icon: Icons.move_to_inbox_outlined,
                iconColor: textPrimary,
                iconBg: textSecondary.withValues(alpha: 0.12),
                title: 'Ariza va taklif',
                textColor: textPrimary,
                border: border,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.local_offer_outlined,
                iconColor: AppColors.red,
                iconBg: AppColors.red.withValues(alpha: 0.12),
                title: l10n.supportMenuChegirmalar,
                textColor: textPrimary,
                border: border,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.card_giftcard_outlined,
                iconColor: const Color(0xFFFF8C00),
                iconBg: const Color(0xFFFF8C00).withValues(alpha: 0.12),
                title: l10n.supportMenuAksiyalar,
                textColor: textPrimary,
                border: border,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline,
                iconColor: mode.primaryColor,
                iconBg: mode.primaryColor.withValues(alpha: 0.12),
                title: l10n.supportMenuQollabQuvvatlash,
                textColor: textPrimary,
                border: border,
                onTap: () => context.push('/profile/support'),
              ),
              _MenuItem(
                icon: null,
                iconColor: Colors.transparent,
                iconBg: Colors.transparent,
                title: l10n.supportMenuHowToOrder,
                textColor: textPrimary,
                border: border,
                onTap: () {},
              ),
              _MenuItem(
                icon: null,
                iconColor: Colors.transparent,
                iconBg: Colors.transparent,
                title: l10n.supportMenuDeliveryAndPayment,
                textColor: textPrimary,
                border: border,
                onTap: () {},
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final card = context.surfaceContainer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                ] else
                  const SizedBox(width: 4),
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
      ),
    );
  }
}
