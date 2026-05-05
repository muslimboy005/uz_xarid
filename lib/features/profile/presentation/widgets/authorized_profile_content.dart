import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/widgets/bottom_sheets/logout_bottom_sheet.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class AuthorizedProfileContent extends StatelessWidget {
  const AuthorizedProfileContent({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final cardColor = context.cardSurface;

    Future<void> logout() async {
      await getIt<SecureStorageService>().clearAll();
      if (context.mounted) {
        context.read<ProfileBloc>().add(const ProfileLogoutEvent());
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: AppDimens.paddingMedium),
          Row(
            children: [
              AppText(
                text: l10n.profileTitle,
                fontSize: 24,
                fontWeight: 700,
                color: textColor,
              ),
              const SizedBox(width: 12),
              ContainerW(
                color: AppColors.blue500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      AppImage(path: AppAssets.labelImportant),
                      const SizedBox(width: 8),
                      AppText(
                        text: l10n.profileBasicAccount,
                        fontSize: 12,
                        fontWeight: 500,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingLarge),
          ContainerW(
            color: cardColor,
            radius: 16,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.isDark
                        ? primaryColor.withValues(alpha: 0.25)
                        : AppColors.blue50,
                    backgroundImage: user.avatar.isNotEmpty
                        ? NetworkImage(() {
                            String url = user.avatar.replaceFirst(
                              'file://',
                              '',
                            );
                            if (url.startsWith('/')) {
                              return 'https://api.uzxarid.uz$url';
                            }
                            return url;
                          }())
                        : null,
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: user.avatar.isEmpty
                        ? Icon(Icons.person, color: AppColors.blue500, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "${user.firstName} ${user.lastName}",
                        fontSize: 16,
                        fontWeight: 600,
                        color: textColor,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        text: user.phone,
                        fontSize: 12,
                        fontWeight: 400,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 22),
          ContainerW(
            color: cardColor,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: AppAssets.accountCircle,
                    title: l10n.profileMenuPersonalData,
                    onTap: () async {
                      await context.push('/profile/personal-data');
                      if (context.mounted) {
                        context.read<ProfileBloc>().add(
                          const ProfileLoadEvent(),
                        );
                      }
                    },
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.feed,
                    title: l10n.profileMenuMyAds,
                    onTap: () => context.push('/profile/my-ads'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.shoppingCart,
                    title: l10n.profileMenuMyOrders,
                    onTap: () => context.push('/profile/my-orders'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.eventNote,
                    title: 'Shartnomalar',
                    onTap: () => context.push('/profile/contracts'),
                  ),
                  // _ProfileMenuItem(
                  //   icon: AppAssets.favorite1,
                  //   title: l10n.profileMenuFavorites,
                  //   onTap: () => context.push('/profile/favorites'),
                  // ),
                  _ProfileMenuItem(
                    icon: AppAssets.notifications,
                    title: l10n.profileMenuNotifications,
                    onTap: () => context.push('/profile/notifications'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          ContainerW(
            radius: 16,
            gradient: LinearGradient(
              colors: [Color(0xFF171D23), Color(0xFF0A4F99)],
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 0,
                bottom: 0,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: l10n.profileBecomeBusinessTitle,
                        fontSize: 16,
                        fontWeight: 700,
                        color: AppColors.white,
                        maxLines: 2,
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => context.push('/profile/my-business'),
                        child: Row(
                          children: [
                            AppText(
                              text: l10n.actionGo,
                              fontSize: 12,
                              fontWeight: 500,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 4),
                            AppImage(
                              path: AppAssets.backDropright,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  AppImage(path: AppAssets.businessImage, size: 120),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          ContainerW(
            color: cardColor,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: AppAssets.mapLocation,
                    title: l10n.profileMenuMyAddresses,
                    onTap: () => context.push('/profile/my-addresses'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.creditScore,
                    title: l10n.profileMenuPayment,
                    onTap: () => context.push('/profile/payment'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.chat,
                    title: 'Taklif va shikoyatlar',
                    onTap: () => context.push('/profile/feedback'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.accessTimeFilled,
                    title: l10n.profileMenuViewHistory,
                    onTap: () => context.push('/profile/view-history'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.settings,
                    title: l10n.profileMenuSettings,
                    onTap: () => context.push('/profile/settings'),
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final confirmed = await showModalBottomSheet<bool>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (dialogContext) => const LogoutBottomSheet(),
                        );

                        if (confirmed == true && context.mounted) {
                          await logout();
                        }
                      },
                      child: Row(
                        children: [
                          AppImage(path: AppAssets.logout),
                          SizedBox(width: 8),
                          AppText(
                            text: l10n.actionLogout,
                            fontSize: 16,
                            fontWeight: 600,
                            color: AppColors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    child: GestureDetector(
                      onTap: () async => logout(),
                      child: Row(
                        children: [
                          AppImage(
                            path: AppAssets.delete,
                            color: AppColors.red,
                          ),
                          SizedBox(width: 8),
                          AppText(
                            text: l10n.profileDeleteAccount,
                            fontSize: 16,
                            fontWeight: 600,
                            color: AppColors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            AppImage(path: icon, size: 24, color: textColor),
            const SizedBox(width: 8),
            AppText(
              text: title,
              fontSize: 14,
              fontWeight: 700,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
