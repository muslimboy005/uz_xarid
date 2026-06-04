import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/cubit/app_mode_cubit.dart';
import 'package:uzxarid/core/localization/locale_cubit.dart';
import 'package:uzxarid/core/theme/theme_cubit.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  static const List<Locale> _supportedLocales = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
    Locale('kaa'),
    Locale('tg'),
    Locale('kk'),
  ];

  final Map<Permission, PermissionStatus> _permissionStatuses = {
    Permission.notification: PermissionStatus.denied,
    Permission.camera: PermissionStatus.denied,
    Permission.photos: PermissionStatus.denied,
    Permission.locationWhenInUse: PermissionStatus.denied,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notification = await Permission.notification.status;
    final camera = await Permission.camera.status;
    final photos = await Permission.photos.status;
    final location = await Permission.locationWhenInUse.status;

    if (mounted) {
      setState(() {
        _permissionStatuses[Permission.notification] = notification;
        _permissionStatuses[Permission.camera] = camera;
        _permissionStatuses[Permission.photos] = photos;
        _permissionStatuses[Permission.locationWhenInUse] = location;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = _settingsScale(context);

    return UzXaridScaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.black50,
      body: SingleChildScrollView(
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
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
                            padding: const EdgeInsets.all(9),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 15,
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
                          fontSize: 18 * s,
                          fontWeight: 700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.black500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                          const SizedBox(height: 5),
                          ..._supportedLocales.map((locale) {
                            final currentLocale = context
                                .watch<LocaleCubit>()
                                .state;
                            final isSelected =
                                currentLocale.languageCode ==
                                locale.languageCode;
                            return _LanguageTile(
                              locale: locale,
                              isSelected: isSelected,
                              isDark: isDark,
                              primaryColor: primaryColor,
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
                const SizedBox(height: 10),
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
                          const SizedBox(height: 5),
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
                                      primaryColor: primaryColor,
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
                                      primaryColor: primaryColor,
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
                const SizedBox(height: 10),
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
                            title: l10n.permissionsTitle,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 5),
                          _PermissionTile(
                            icon: Icons.notifications_none,
                            title: l10n.permissionNotification,
                            status:
                                _permissionStatuses[Permission.notification]!,
                            isDark: isDark,
                          ),
                          _PermissionTile(
                            icon: Icons.camera_alt_outlined,
                            title: l10n.permissionCamera,
                            status: _permissionStatuses[Permission.camera]!,
                            isDark: isDark,
                          ),
                          _PermissionTile(
                            icon: Icons.photo_library_outlined,
                            title: l10n.permissionGallery,
                            status: _permissionStatuses[Permission.photos]!,
                            isDark: isDark,
                          ),
                          _PermissionTile(
                            icon: Icons.location_on_outlined,
                            title: l10n.permissionLocation,
                            status:
                                _permissionStatuses[Permission
                                    .locationWhenInUse]!,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pastdagi suzuvchi bottom-nav ortida kontent qolib ketmasligi uchun.
                SizedBox(height: 110 + MediaQuery.paddingOf(context).bottom),
              ],
            ),
      ),
    );
  }
}

/// Ekran kengligiga qarab o'lchamlarni moslashtiruvchi koeffitsiyent (responsiv).
double _settingsScale(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return (w / 390).clamp(0.85, 1.12);
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: AppText(
          text: title,
          fontSize: 12.5 * _settingsScale(context),
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
    required this.primaryColor,
    required this.onTap,
  });

  final Locale locale;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  static String _languageName(String code) {
    switch (code) {
      case 'uz':
        return 'Oʻzbekcha';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'kaa':
        return 'Qaraqalpaqsha';
      case 'tg':
        return 'Тоҷикӣ';
      case 'kk':
        return 'Қазақша';
      default:
        return code.toUpperCase();
    }
  }

  /// Tilning ona tilidagi (yoki mintaqaviy) izohi — ikkilamchi matn.
  static String _languageSubtitle(String code) {
    switch (code) {
      case 'uz':
        return 'Uzbek';
      case 'ru':
        return 'Russian';
      case 'en':
        return 'English';
      case 'kaa':
        return 'Karakalpak';
      case 'tg':
        return 'Tajik';
      case 'kk':
        return 'Kazakh';
      default:
        return code.toUpperCase();
    }
  }

  static String _flagAsset(String code) {
    switch (code) {
      case 'uz':
        return AppAssets.flagUz;
      case 'ru':
        return AppAssets.flagRu;
      case 'en':
        return AppAssets.flagEn;
      case 'kaa':
        return AppAssets.flagKaa;
      case 'tg':
        return AppAssets.flagTg;
      case 'kk':
        return AppAssets.flagKk;
      default:
        return AppAssets.flagUz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _settingsScale(context);
    final flagSize = 30.0 * s;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: EdgeInsets.symmetric(vertical: 2 * s),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: isDark ? 0.18 : 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.45)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * s, horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: flagSize,
                  height: flagSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.12)
                          : AppColors.black500.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SvgPicture.asset(
                    _flagAsset(locale.languageCode),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: _languageName(locale.languageCode),
                        fontSize: 14 * s,
                        fontWeight: isSelected ? 700 : 500,
                        color: isSelected
                            ? primaryColor
                            : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.black500),
                      ),
                      SizedBox(height: 1 * s),
                      AppText(
                        text: _languageSubtitle(locale.languageCode),
                        fontSize: 11 * s,
                        fontWeight: 400,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: isSelected ? 1 : 0,
                  child: Icon(
                    Icons.check_circle,
                    size: 20 * s,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
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
    required this.primaryColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = _settingsScale(context);
    return Material(
      color: isSelected
          ? (primaryColor.withValues(alpha: 0.15))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11 * s, horizontal: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 23 * s,
                color: isSelected
                    ? primaryColor
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
              SizedBox(height: 6 * s),
              AppText(
                text: label,
                fontSize: 13 * s,
                fontWeight: isSelected ? 700 : 500,
                color: isDark
                    ? (isSelected ? primaryColor : AppColors.darkTextPrimary)
                    : (isSelected ? primaryColor : AppColors.black500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.status,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final PermissionStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = _settingsScale(context);
    final bool isGranted = status.isGranted || status.isLimited;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openAppSettings(),
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9 * s, horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                size: 21 * s,
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: title,
                      fontSize: 14 * s,
                      fontWeight: 500,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.black500,
                    ),
                    SizedBox(height: 2 * s),
                    AppText(
                      text: isGranted ? l10n.permissionGranted : l10n.permissionDenied,
                      fontSize: 11 * s,
                      fontWeight: 400,
                      color: isGranted
                          ? AppColors.green
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                size: 18 * s,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
