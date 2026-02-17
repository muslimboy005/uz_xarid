import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/dp/infection.dart';
import 'package:uz_xarid/core/service/local_service.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

class AuthorizedProfileContent extends StatelessWidget {
  const AuthorizedProfileContent({
    super.key,
    required this.fullName,
    required this.phoneNumber,
  });

  final String fullName;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Главная > Профиль',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          Row(
            children: [
              Text(
                'Профиль',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Базовый аккаунт',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingLarge),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          const Card(
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Личные данные',
                ),
                _ProfileMenuItem(
                  icon: Icons.campaign_outlined,
                  title: 'Мои объявления',
                ),
                _ProfileMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Мои заказы',
                ),
                _ProfileMenuItem(
                  icon: Icons.favorite_border,
                  title: 'Избранное',
                ),
                _ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Push-уведомления',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          Card(
            color: AppColors.primary.withOpacity(0.06),
            child: ListTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('Станьте бизнес пользователем'),
              subtitle: const Text('Перейти'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          const Card(
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Мои адреса',
                ),
                _ProfileMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Оплата и тарифы',
                ),
                _ProfileMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Поддержка',
                ),
                _ProfileMenuItem(
                  icon: Icons.history,
                  title: 'История просмотров',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          TextButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Выйти из аккаунта?'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
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
                  context.read<ProfileBloc>().add(const ProfileLogoutEvent());
                }
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
