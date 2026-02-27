import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/localization/locale_cubit.dart';
import 'package:uz_xarid/core/theme/theme_cubit.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/profile_breadcrumb.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<Locale> _supportedLocales = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: UzXaridAppBar(onSearchChanged: (_) {}, onMenuTap: () {}),
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.black50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBreadcrumb(
              labels: [l10n.navHome, l10n.profileTitle, l10n.settingsTitle],
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
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      radius: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.black500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText(
                      text: l10n.settingsTitle,
                      fontSize: 20,
                      fontWeight: 700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.black500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingLarge),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: ContainerW(
                color: isDark ? AppColors.darkCard : AppColors.white,
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _SettingsSectionTitle(
                        title: l10n.settingsLanguage,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      ..._supportedLocales.map((locale) {
                        final currentLocale = context
                            .watch<LocaleCubit>()
                            .state;
                        final isSelected =
                            currentLocale.languageCode == locale.languageCode;
                        return _LanguageTile(
                          locale: locale,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () {
                            context.read<LocaleCubit>().change(locale);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingMedium,
              ),
              child: ContainerW(
                color: isDark ? AppColors.darkCard : AppColors.white,
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _SettingsSectionTitle(
                        title: l10n.settingsTheme,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, themeMode) {
                          final isDarkMode = themeMode == ThemeMode.dark;
                          return Row(
                            children: [
                              Expanded(
                                child: _ThemeOptionTile(
                                  label: l10n.settingsThemeLight,
                                  icon: Icons.light_mode_outlined,
                                  isSelected: !isDarkMode,
                                  isDark: isDark,
                                  onTap: () {
                                    context.read<ThemeCubit>().setThemeMode(
                                      ThemeMode.light,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ThemeOptionTile(
                                  label: l10n.settingsThemeDark,
                                  icon: Icons.dark_mode_outlined,
                                  isSelected: isDarkMode,
                                  isDark: isDark,
                                  onTap: () {
                                    context.read<ThemeCubit>().setThemeMode(
                                      ThemeMode.dark,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: AppText(
          text: title,
          fontSize: 14,
          fontWeight: 600,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final Locale locale;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  static String _languageName(String code) {
    switch (code) {
      case 'uz':
        return 'Oʻzbekcha';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              AppText(
                text: _languageName(locale.languageCode),
                fontSize: 16,
                fontWeight: isSelected ? 700 : 500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.black500,
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, size: 22, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? (AppColors.primary.withValues(alpha: 0.15))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              AppText(
                text: label,
                fontSize: 14,
                fontWeight: isSelected ? 700 : 500,
                color: isDark
                    ? (isSelected
                          ? AppColors.primary
                          : AppColors.darkTextPrimary)
                    : (isSelected ? AppColors.primary : AppColors.black500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
