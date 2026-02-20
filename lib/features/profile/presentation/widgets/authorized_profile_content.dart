import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/features/profile/data/model/profile_model.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

class AuthorizedProfileContent extends StatelessWidget {
  const AuthorizedProfileContent({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/home'),
                child: AppText(
                  text: 'Главная',
                  fontSize: 12,
                  fontWeight: 400,
                  color: AppColors.black300,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: AppColors.black300,
                ),
              ),
              AppText(
                text: 'Профиль',
                fontSize: 12,
                fontWeight: 600,
                color: AppColors.blue500,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          Row(
            children: [
              AppText(
                text: 'Профиль',
                fontSize: 24,
                fontWeight: 700,
                color: AppColors.black500,
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
                        text: 'Базовый аккаунт',
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
            color: AppColors.white,
            radius: 16,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.blue50,
                    backgroundImage: user.avatar.isNotEmpty
                        ? NetworkImage(user.avatar)
                        : null,
                    child: user.avatar.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: AppColors.blue500,
                            size: 24,
                          )
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
                        color: AppColors.black500,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        text: user.phone,
                        fontSize: 12,
                        fontWeight: 400,
                        color: AppColors.black300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 22),
          ContainerW(
            color: AppColors.red,
            radius: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  AppImage(path: AppAssets.information),
                  SizedBox(width: 6),
                  AppText(
                    text: 'Подтвердите аккаунт',
                    fontSize: 12,
                    fontWeight: 500,
                    color: AppColors.white,
                  ),
                  Spacer(),
                  AppImage(
                    path: AppAssets.backDropright,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 22),
          ContainerW(
            color: AppColors.white,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: AppAssets.accountCircle,
                    title: 'Личные данные',
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
                    title: 'Мои объявления',
                    onTap: () => context.push('/profile/my-ads'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.shoppingCart,
                    title: 'Мои заказы',
                    onTap: () => context.push('/profile/my-orders'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.favorite1,
                    title: 'Избранное',
                    onTap: () => context.push('/profile/favorites'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.notifications,
                    title: 'Push-уведомления',
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
                        text: "Станьте бизнес\nпользователем",
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
                              text: "Перейти",
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
            color: AppColors.white,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: AppAssets.mapLocation,
                    title: 'Мои адреса',
                    onTap: () => context.push('/profile/my-addresses'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.creditScore,
                    title: 'Оплата и тарифы',
                    onTap: () => context.push('/profile/payment'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.chat,
                    title: 'Поддержка',
                    onTap: () => context.push('/profile/support'),
                  ),
                  _ProfileMenuItem(
                    icon: AppAssets.accessTimeFilled,
                    title: 'История просмотров',
                    onTap: () => context.push('/profile/view-history'),
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
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Выйти из аккаунта?'),
                            content: const Text(
                              'Вы уверены, что хотите выйти?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text(
                                  'Выйти',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          await getIt<SecureStorageService>().clearAll();
                          if (context.mounted) {
                            context.read<ProfileBloc>().add(
                              const ProfileLogoutEvent(),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          AppImage(path: AppAssets.logout),
                          SizedBox(width: 8),
                          AppText(
                            text: 'Выйти',
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            AppImage(path: icon, size: 24, color: AppColors.black500),
            const SizedBox(width: 8),

            AppText(
              text: title,
              fontSize: 14,
              fontWeight: 700,
              color: AppColors.black500,
            ),
          ],
        ),
      ),
    );
  }
}
