import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/localization/locale_cubit.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class UzXaridAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UzXaridAppBar({
    super.key,
    this.leading,
    this.onSearchChanged,
    this.onSearchTap,
    this.onMenuTap,
  });

  /// Chap tomonda ko'rsatiladigan widget (masalan, orqaga tugmasi).
  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;

  /// Qidirish maydonini bosganda ochiladigan sahifa (masalan, to'liq qidirish ekrani).
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;

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
        hintText: l10n.searchHint,
        leading: leading,
        onSearchChanged: onSearchChanged,
        onSearchTap: onSearchTap,
        onMenuTap: onMenuTap,
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
  });

  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;

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
  });

  final Locale locale;
  final String hintText;
  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;

  static const double _height = 112;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyBg = isDark ? AppColors.darkBackground : AppColors.background;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            // Asosiy fon (dark/light rejimga mos)
            Positioned.fill(top: 0, child: ColoredBox(color: bodyBg)),
            // Ko'k header qismi – pastki burchaklari yumaloq
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 85,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
            ),
            // Leading (back) + logo + language + menu row (ko'k fonda)
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Image.asset('assets/images/uzxarid.png', height: 42),

                  const Spacer(),
                  // _LanguageSelector(currentLocale: locale),
                  // const SizedBox(width: 12),
                  _MenuButton(onTap: onMenuTap),
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
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.currentLocale});

  final Locale currentLocale;

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

  @override
  Widget build(BuildContext context) {
    final languageCode = currentLocale.languageCode;
    final displayCode = languageCode.toUpperCase();

    return PopupMenuButton<Locale>(
      elevation: 4,
      offset: const Offset(0, 32),
      onSelected: (locale) {
        context.read<LocaleCubit>().change(locale);
      },
      itemBuilder: (context) => [
        _buildItem(context, const Locale('ru'), 'RU', 'assets/svg/flag_ru.svg'),
        _buildItem(context, const Locale('uz'), 'UZ', 'assets/svg/flag_uz.svg'),
        _buildItem(context, const Locale('en'), 'EN', 'assets/svg/flag_en.svg'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
        child: Row(
          children: [
            SvgPicture.asset(
              _flagAssetFor(languageCode),
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 6),
            Text(
              displayCode,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 24,
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
          SvgPicture.asset(asset, width: 20, height: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.menu, color: AppColors.white, size: 25),
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
              width: 20,
              height: 20,
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
              width: 20,
              height: 20,
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
