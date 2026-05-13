import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:uzxarid/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_state.dart';

import 'package:uzxarid/app/router/app_router.dart';
import 'package:uzxarid/core/app_config.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/localization/locale_cubit.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class UzXaridAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UzXaridAppBar({
    super.key,
    this.leading,
    this.onSearchChanged,
    this.onSearchTap,
    this.onMenuTap,
    this.isMenuOpen = false,
    this.actions,
    this.searchHint,
    this.onClose,
    this.showLanguageSelector = false,
  });

  /// Chap tomonda ko'rsatiladigan widget (masalan, orqaga tugmasi).
  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;

  /// Qidirish maydonini bosganda ochiladigan sahifa (masalan, to'liq qidirish ekrani).
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final bool isMenuOpen;
  final List<Widget>? actions;

  /// Search input hint (berilmasa l10n.searchHint ishlatiladi).
  final String? searchHint;

  /// Modal/menu rejimi: berilsa, apps/cart/menu o'rniga X close ko'rsatiladi va
  /// til selektor avtomatik yoqiladi.
  final VoidCallback? onClose;

  /// Header da til selektorni ko'rsatish (default: yashirin).
  final bool showLanguageSelector;

  static const double _height = 112;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: _height,
      flexibleSpace: _UzXaridAppBarContent(
        locale: locale,
        hintText: searchHint ?? l10n.searchHint,
        leading: leading,
        onSearchChanged: onSearchChanged,
        onSearchTap: onSearchTap,
        onMenuTap: () => context.push('/support-menu'),
        isMenuOpen: isMenuOpen,
        actions: actions,
        onClose: onClose,
        showLanguageSelector: showLanguageSelector || onClose != null,
      ),
    );
  }
}

/// Sliver variant, ishlatmoqchi bo‘lsangiz:
/// CustomScrollView(
///   slivers: [
///     UzXaridSliverAppBar(...),
///     ...
///   ],
/// )
class UzXaridSliverAppBar extends StatelessWidget {
  const UzXaridSliverAppBar({
    super.key,
    this.leading,
    this.onSearchChanged,
    this.onSearchTap,
    this.onMenuTap,
    this.isMenuOpen = false,
    this.actions,
  });

  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final bool isMenuOpen;
  final List<Widget>? actions;

  static const double _height = 112;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      expandedHeight: _height,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: _UzXaridAppBarContent(
        locale: locale,
        hintText: l10n.searchHint,
        leading: leading,
        onSearchChanged: onSearchChanged,
        onSearchTap: onSearchTap,
        onMenuTap: onMenuTap,
        isMenuOpen: isMenuOpen,
        actions: actions,
      ),
    );
  }
}

class _UzXaridAppBarContent extends StatelessWidget {
  const _UzXaridAppBarContent({
    required this.locale,
    required this.hintText,
    this.leading,
    this.onSearchChanged,
    this.onSearchTap,
    this.onMenuTap,
    this.isMenuOpen = false,
    this.actions,
    this.onClose,
    this.showLanguageSelector = false,
  });

  final Locale locale;
  final String hintText;
  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final bool isMenuOpen;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final bool showLanguageSelector;

  static const double _height = 112;

  @override
  Widget build(BuildContext context) {
    void onAppsIconTapped() {
      showDialog(
        context: context,
        builder: (dialogContext) {
          final l10n = AppLocalizations.of(dialogContext)!;
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          final currentMode = dialogContext.watch<AppModeCubit>().state;
          final textColor = isDark
              ? AppColors.darkTextPrimary
              : AppColors.textPrimary;

          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.appsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            contentPadding: const EdgeInsets.only(top: 16, bottom: 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentMode.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: currentMode.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Tez Elt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    l10n.tezEltSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    AppRouter.openApp1(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyBg = isDark ? AppColors.darkBackground : AppColors.background;
    final appMode = context.watch<AppModeCubit>().state;
    final headerColor = appMode.appBarColor;
    final onHeader = appMode.onAppBarColor;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: bodyBg,
      child: Stack(
        children: [
          // Ko'k/sariq header qismi – pastki burchaklari yumaloq, status barni ham qoplaydi
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 112 + topPadding,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          // Content (status bardan pastdan boshlanadi)
          Positioned.fill(
            top: topPadding,
            child: SizedBox(
              height: _height,
              child: Stack(
                children: [
                  // Leading (back) + logo + language + menu row (ko'k fonda)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 12,
                    child: Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(width: 8),
                        ],
                        Image.asset(
                          appMode == AppMode.buying
                              ? AppAssets.logoAppBarBuying
                              : AppAssets.logoAppBar,
                          package: AppConfig.packageName,
                          height: 42,
                        ),
                        const Spacer(),
                        if (showLanguageSelector) ...[
                          _LanguageSelector(
                            currentLocale: locale,
                            iconColor: onHeader,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onClose != null)
                          _AppBarButton(
                            onTap: onClose,
                            icon: Icon(
                              Icons.close,
                              color: onHeader,
                              size: 22,
                            ),
                            color: onHeader,
                            alpha: 0.18,
                          )
                        else ...[
                          _AppBarButton(
                            onTap: onAppsIconTapped,
                            icon: Icon(
                              Icons.apps_outlined,
                              color: onHeader,
                              size: 22,
                            ),
                            color: onHeader,
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, state) {
                              final count = state.totalItems;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _AppBarButton(
                                    onTap: () => context.push('/cart'),
                                    icon: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: onHeader,
                                      size: 22,
                                    ),
                                    color: onHeader,
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          if (actions != null) ...actions!,
                          if (actions != null) const SizedBox(width: 8),
                          _MenuButton(
                            onTap: onMenuTap,
                            isOpen: isMenuOpen,
                            iconColor: onHeader,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Search field floating so that half is on blue, half on white
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 0,
                    child: _SearchField(
                      hintText: hintText,
                      onChanged: onSearchChanged,
                      onTap: onSearchTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.currentLocale,
    this.iconColor = Colors.white,
  });

  final Locale currentLocale;
  final Color iconColor;

  String _flagAssetFor(String code) {
    switch (code) {
      case 'ru':
        return 'assets/svg/flag_ru.svg';
      case 'uz':
        return 'assets/svg/flag_uz.svg';
      case 'en':
      default:
        return 'assets/svg/flag_en.svg';
    }
  }

  String _shortLabel(String code) {
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
    final languageCode = currentLocale.languageCode;

    return PopupMenuButton<Locale>(
      elevation: 4,
      offset: const Offset(0, 44),
      onSelected: (locale) {
        context.read<LocaleCubit>().change(locale);
      },
      itemBuilder: (context) => [
        _buildItem(context, const Locale('uz'), 'Uz', 'assets/svg/flag_uz.svg'),
        _buildItem(context, const Locale('ru'), 'Ру', 'assets/svg/flag_ru.svg'),
        _buildItem(context, const Locale('en'), 'En', 'assets/svg/flag_en.svg'),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SvgPicture.asset(
                _flagAssetFor(languageCode),
                package: AppConfig.packageName,
                width: 22,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _shortLabel(languageCode),
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              color: iconColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<Locale> _buildItem(
    BuildContext context,
    Locale locale,
    String label,
    String asset,
  ) {
    return PopupMenuItem<Locale>(
      value: locale,
      child: Row(
        children: [
          SvgPicture.asset(
            asset,
            width: 20,
            height: 20,
            package: AppConfig.packageName,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  const _AppBarButton({
    required this.icon,
    this.onTap,
    this.color = AppColors.white,
    this.alpha = 0.12,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    this.onTap,
    this.isOpen = false,
    this.iconColor = AppColors.white,
  });

  final VoidCallback? onTap;
  final bool isOpen;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return _AppBarButton(
      onTap: onTap,
      alpha: isOpen ? 0.25 : 0.12,
      color: iconColor,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: isOpen
            ? Icon(
                Icons.close,
                color: iconColor,
                size: 22,
                key: const ValueKey('close'),
              )
            : Icon(
                Icons.menu,
                color: iconColor,
                size: 25,
                key: const ValueKey('menu'),
              ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText, this.onChanged, this.onTap});

  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkCard : Colors.white;
    final iconColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final child = Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        readOnly: onTap != null,
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : null),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : null,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              'assets/svg/search.svg',
              package: AppConfig.packageName,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              'assets/svg/access_time_filled.svg',
              package: AppConfig.packageName,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
    return child;
  }
}
