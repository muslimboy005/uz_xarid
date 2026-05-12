import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/app_config.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/localization/locale_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/features/currency/presentation/widgets/currency_selector.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class SupportMenuPage extends StatelessWidget {
  const SupportMenuPage({super.key});

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: appBarColor,
      body: Column(
        children: [
          _Header(
            appBarColor: appBarColor,
            onBar: onBar,
            isBuying: isBuying,
            hintText: l10n.searchHint,
          ),
          Expanded(
            child: Container(
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
                              onTap: () =>
                                  context.read<AppModeCubit>().setSelling(),
                            ),
                            _Tab(
                              label: l10n.supportMenuSotibOlaman,
                              selected: isBuying,
                              onTap: () =>
                                  context.read<AppModeCubit>().setBuying(),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header (logo + lang + close + search) ───────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.appBarColor,
    required this.onBar,
    required this.isBuying,
    required this.hintText,
  });

  final Color appBarColor;
  final Color onBar;
  final bool isBuying;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final locale = Localizations.localeOf(context);
    return Container(
      decoration: BoxDecoration(
        color: appBarColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(14),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 16,
        right: 16,
        bottom: 28,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Image.asset(
                  isBuying ? AppAssets.logoAppBarBuying : AppAssets.logoAppBar,
                  package: AppConfig.packageName,
                  height: 42,
                ),
                const Spacer(),
                _LanguageSelector(currentLocale: locale, color: onBar),
                const SizedBox(width: 8),
                _CloseButton(onBar: onBar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SearchBar(hintText: hintText),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onBar});
  final Color onBar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onBar.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.close, color: onBar, size: 22),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.currentLocale, required this.color});

  final Locale currentLocale;
  final Color color;

  String _flagAssetFor(String code) {
    switch (code) {
      case 'ru':
        return 'assets/svg/flag_ru.svg';
      case 'en':
        return 'assets/svg/flag_en.svg';
      case 'uz':
      default:
        return 'assets/svg/flag_uz.svg';
    }
  }

  String _label(String code) {
    switch (code) {
      case 'ru':
        return 'Ру';
      case 'en':
        return 'En';
      case 'uz':
      default:
        return 'Uz';
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = currentLocale.languageCode;
    return PopupMenuButton<Locale>(
      elevation: 4,
      offset: const Offset(0, 44),
      onSelected: (locale) => context.read<LocaleCubit>().change(locale),
      itemBuilder: (context) => const [
        PopupMenuItem(value: Locale('uz'), child: Text('Uz')),
        PopupMenuItem(value: Locale('ru'), child: Text('Ру')),
        PopupMenuItem(value: Locale('en'), child: Text('En')),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SvgPicture.asset(
                _flagAssetFor(code),
                package: AppConfig.packageName,
                width: 22,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _label(code),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final hintColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final divider = isDark
        ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
        : const Color(0xFFE5E7EB);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/search'),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search, color: hintColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(color: hintColor, fontSize: 15),
              ),
            ),
            Container(width: 1, height: 28, color: divider),
            SizedBox(
              width: 50,
              height: double.infinity,
              child: Icon(Icons.history, color: hintColor, size: 22),
            ),
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
