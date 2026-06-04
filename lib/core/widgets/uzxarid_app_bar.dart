import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:uzxarid/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:uzxarid/features/cart/presentation/bloc/cart_state.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:uzxarid/features/notification/presentation/bloc/notification_state.dart';

import 'package:uzxarid/core/app_config.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/localization/locale_cubit.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

const double _kPinnedRowHeight = 56;
const double _kHorizontalPadding = 16;

/// Sahifalar uchun yagona wrapper:
/// - Pinned `_UzXaridTopAppBar` (faqat top row: logo + cart + bell yoki close)
/// - Ixtiyoriy `floatingHeader` (search/toggle) — `SliverAppBar(floating, snap)`
///   sifatida, pastga scrollda yo‘qoladi, yuqoriga scrollda darhol qaytadi.
/// - Body — body widget yoki sliverlar.
class UzXaridScaffold extends StatelessWidget {
  const UzXaridScaffold({
    super.key,
    required this.body,
    this.onClose,
    this.leading,
    this.actions,
    this.trailing,
    this.showLanguageSelector = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.scrollController,
    this.floatingHeader,
    this.floatingHeaderHeight = 74,
  }) : slivers = null;

  const UzXaridScaffold.slivers({
    super.key,
    required List<Widget> this.slivers,
    this.onClose,
    this.leading,
    this.actions,
    this.trailing,
    this.showLanguageSelector = false,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.scrollController,
    this.floatingHeader,
    this.floatingHeaderHeight = 74,
  }) : body = const SizedBox.shrink();

  final Widget body;
  final List<Widget>? slivers;
  final VoidCallback? onClose;
  final Widget? leading;
  final List<Widget>? actions;
  /// Notifikatsiya tugmasidan keyin (eng chetga) qo‘yiladigan widget.
  final Widget? trailing;
  final bool showLanguageSelector;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final ScrollController? scrollController;

  /// Search field yoki Sotaman/Sotib olaman toggle kabi widgetlar.
  /// Berilganda body color ustida `SliverAppBar(floating: true, snap: true)`
  /// sifatida ko‘rinadi: pastga scrollda yo‘qoladi, yuqoriga scrollda darhol
  /// qaytib chiqadi.
  final Widget? floatingHeader;

  /// `floatingHeader` ning balandligi (pikselda). Default: 74 (faqat search).
  /// Home uchun ~134 (toggle + search).
  final double floatingHeaderHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkBackground : AppColors.background);

    final appBar = _UzXaridTopAppBar(
      leading: leading,
      actions: actions,
      trailing: trailing,
      onClose: onClose,
      showLanguageSelector: showLanguageSelector || onClose != null,
    );

    // Floating header bor — CustomScrollView ichida birinchi sliver sifatida
    // SliverAppBar(floating, snap) yaratamiz.
    if (floatingHeader != null) {
      final bodySlivers = slivers ?? [SliverToBoxAdapter(child: body)];
      return Scaffold(
        backgroundColor: bg,
        appBar: appBar,
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: floatingHeaderHeight,
              flexibleSpace: SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  color: bg,
                  alignment: Alignment.topCenter,
                  child: floatingHeader,
                ),
              ),
            ),
            ...bodySlivers,
          ],
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    if (slivers != null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: appBar,
        body: CustomScrollView(
          controller: scrollController,
          slivers: slivers!,
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Search yoki mode selector bolmagan sahifalar uchun oddiy AppBar.
class _UzXaridTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _UzXaridTopAppBar({
    this.leading,
    this.actions,
    this.trailing,
    this.onClose,
    this.showLanguageSelector = false,
  });

  final Widget? leading;
  final List<Widget>? actions;
  final Widget? trailing;
  final VoidCallback? onClose;
  final bool showLanguageSelector;

  @override
  Size get preferredSize => const Size.fromHeight(_kPinnedRowHeight);

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppModeCubit>().state;
    final headerColor = mode.appBarColor;
    final onHeader = mode.onAppBarColor;
    final topPadding = MediaQuery.of(context).padding.top;
    final locale = Localizations.localeOf(context);

    return PreferredSize(
      preferredSize: Size.fromHeight(_kPinnedRowHeight + topPadding),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        child: Container(
          color: headerColor,
          padding: EdgeInsets.only(
            top: topPadding,
            left: _kHorizontalPadding,
            right: _kHorizontalPadding,
          ),
          child: SizedBox(
            height: _kPinnedRowHeight,
            child: _TopRow(
              appMode: mode,
              onHeader: onHeader,
              locale: locale,
              leading: leading,
              actions: actions,
              trailing: trailing,
              onClose: onClose,
              showLanguageSelector: showLanguageSelector,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.appMode,
    required this.onHeader,
    required this.locale,
    required this.leading,
    required this.actions,
    required this.trailing,
    required this.onClose,
    required this.showLanguageSelector,
  });

  final AppMode appMode;
  final Color onHeader;
  final Locale locale;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? trailing;
  final VoidCallback? onClose;
  final bool showLanguageSelector;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            icon: Icon(Icons.close, color: onHeader, size: 22),
            color: onHeader,
            alpha: 0.18,
          )
        else ...[
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
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notifState) {
              final unread = notifState.unreadBadgeCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _AppBarButton(
                    onTap: () => context.push('/profile/notifications'),
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: onHeader,
                      size: 22,
                    ),
                    color: onHeader,
                  ),
                  if (unread > 0)
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
                          unread > 99 ? '99+' : '$unread',
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
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ],
    );
  }
}

/// Home dagi Sotaman / Sotib olaman segmented toggle. Boshqa joylarda ham
/// foydalanish uchun ochiq.
class HomeModeSegmented extends StatelessWidget {
  const HomeModeSegmented({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = context.watch<AppModeCubit>().state;
    final bgColor = isDark ? AppColors.darkCard : AppColors.white;
    final unselectedText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _HomeModeSegment(
              label: l10n.supportMenuSotaman,
              isSelected: mode == AppMode.selling,
              selectedColor: AppMode.selling.primaryColor,
              unselectedTextColor: unselectedText,
              onTap: () => context.read<AppModeCubit>().setSelling(),
            ),
          ),
          Expanded(
            child: _HomeModeSegment(
              label: l10n.supportMenuSotibOlaman,
              isSelected: mode == AppMode.buying,
              selectedColor: AppMode.buying.primaryColor,
              unselectedTextColor: unselectedText,
              onTap: () => context.read<AppModeCubit>().setBuying(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeModeSegment extends StatelessWidget {
  const _HomeModeSegment({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedTextColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? AppColors.white : unselectedTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
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

class UzXaridSearchField extends StatelessWidget {
  const UzXaridSearchField({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onTap,
    this.height = 40,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _SearchField(
      hintText: hintText,
      onChanged: onChanged,
      onTap: onTap,
      height: height,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hintText,
    this.onChanged,
    this.onTap,
    this.height = 40,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkCard : Colors.white;
    final iconColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        readOnly: onTap != null,
        onChanged: onChanged,
        onTap: onTap,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : null,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : null,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            minHeight: height,
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
          suffixIconConstraints: BoxConstraints(
            minWidth: 40,
            minHeight: height,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DEPRECATED: UzXaridAppBar / UzXaridSliverAppBar
// Yangi sahifalar UzXaridScaffold ishlatsin.
// ============================================================================

@Deprecated('UzXaridScaffold ishlating')
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
    this.showSearch = true,
    this.showModeSelector = true,
  });

  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;
  final bool isMenuOpen;
  final List<Widget>? actions;
  final String? searchHint;
  final VoidCallback? onClose;
  final bool showLanguageSelector;
  final bool showSearch;
  final bool showModeSelector;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    // Deprecation davrida toza top row qaytaramiz.
    final locale = Localizations.localeOf(context);
    final mode = context.watch<AppModeCubit>().state;
    final headerColor = mode.appBarColor;
    final onHeader = mode.onAppBarColor;
    final topPadding = MediaQuery.of(context).padding.top;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 64,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        child: Container(
          color: headerColor,
          padding: EdgeInsets.only(
            top: topPadding,
            left: _kHorizontalPadding,
            right: _kHorizontalPadding,
          ),
          child: SizedBox(
            height: _kPinnedRowHeight,
            child: _TopRow(
              appMode: mode,
              onHeader: onHeader,
              locale: locale,
              leading: leading,
              actions: actions,
              trailing: null,
              onClose: onClose,
              showLanguageSelector: showLanguageSelector || onClose != null,
            ),
          ),
        ),
      ),
    );
  }
}
