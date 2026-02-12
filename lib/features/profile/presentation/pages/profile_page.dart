import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => ProfileBloc()..add(const ProfileStarted()),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: UzXaridAppBar(
          onSearchChanged: (query) {
            // TODO: implement profile search if needed
          },
          onMenuTap: () {
            // TODO: open profile menu
          },
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: AppColors.background,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!state.isAuthorized) {
                    return _UnauthProfileContent(l10n: l10n);
                  }

                  return _AuthorizedProfileContent(
                    fullName: state.fullName ?? '',
                    phoneNumber: state.phoneNumber ?? '',
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnauthProfileContent extends StatelessWidget {
  const _UnauthProfileContent({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Что даёт авторизация?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        _BenefitRow(
          icon: Icons.work_outline,
          text: 'Возможность предлагать свои услуги',
        ),
        const SizedBox(height: 16),
        _BenefitRow(
          icon: Icons.phone_in_talk_outlined,
          text: 'Пользоваться услугами других пользователей',
        ),
        const SizedBox(height: 16),
        _BenefitRow(
          icon: Icons.local_fire_department_outlined,
          text: 'Эксклюзивные предложения именно для вас',
        ),
        const SizedBox(height: 16),
        _BenefitRow(
          icon: Icons.shopping_bag_outlined,
          text: 'Возможность предлагать свои услуги',
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        const Divider(),
        const SizedBox(height: AppDimens.paddingLarge),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<ProfileBloc>().add(const ProfileAuthFlowStarted());
              _showPhoneBottomSheet(context);
            },
            child: const Text('Войти или создать профиль'),
          ),
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        Text(
          'Покупайте, продавайте и пользуйтесь услугами!\n'
          'Размещайте объявления, находите нужное и добавляйте в избранное',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  void _showPhoneBottomSheet(BuildContext context) {
    final phoneController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.paddingMedium,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingMedium,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                AppDimens.paddingMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Вход в аккаунт',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Мы отправим проверочный код на введённый номер по SMS.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Телефон',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Введите номер',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<ProfileBloc>()
                        .add(ProfilePhoneSubmitted(phoneController.text));
                    Navigator.of(context).pop();
                    _showOtpBottomSheet(
                      context,
                      phoneController.text,
                    );
                  },
                  child: const Text('Получить код'),
                ),
              ),
              const SizedBox(height: AppDimens.paddingMedium),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodySmall,
                child: const Text(
                  'Автоитзациядан o‘tish орқали сиз шахсий маълумотларни '
                  'қайта ишлаш сиёсатга розилик биладирасиз',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOtpBottomSheet(BuildContext context, String phone) {
    final otpController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.paddingMedium,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingMedium,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                AppDimens.paddingMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Введите код',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Код был отправлен на ваш номер телефона ($phone).\n'
                'Пожалуйста, проверьте SMS.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '———',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<ProfileBloc>()
                        .add(ProfileOtpSubmitted(otpController.text));
                    Navigator.of(context).pop();
                    _showNameBottomSheet(context);
                  },
                  child: const Text('Продолжить'),
                ),
              ),
              const SizedBox(height: AppDimens.paddingMedium),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodySmall,
                child: const Text(
                  'Отправить код повторно (через 28 секунд)',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNameBottomSheet(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.paddingMedium,
            right: AppDimens.paddingMedium,
            top: AppDimens.paddingMedium,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                AppDimens.paddingMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Почти готово',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ваш профиль почти готов, представьтесь',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Имя',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  hintText: 'Ваше имя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              Text(
                'Фамилия',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  hintText: 'Ваша фамилия',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                          ProfileNameSubmitted(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Продолжить'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _AuthorizedProfileContent extends StatelessWidget {
  const _AuthorizedProfileContent({
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
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {},
              child: const Text('Подтвердите аккаунт'),
            ),
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          Card(
            child: Column(
              children: const [
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
          Card(
            child: Column(
              children: const [
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
            onPressed: () {},
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            label: const Text(
              'Выйти',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
  });

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

