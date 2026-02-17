import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';

import 'bottom_sheets/name_bottom_sheet.dart';
import 'bottom_sheets/otp_bottom_sheet.dart';
import 'bottom_sheets/phone_bottom_sheet.dart';

class UnauthProfileContent extends StatelessWidget {
  const UnauthProfileContent({super.key});

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
        const _BenefitRow(
          icon: Icons.work_outline,
          text: 'Возможность предлагать свои услуги',
        ),
        const SizedBox(height: 16),
        const _BenefitRow(
          icon: Icons.phone_in_talk_outlined,
          text: 'Пользоваться услугами других пользователей',
        ),
        const SizedBox(height: 16),
        const _BenefitRow(
          icon: Icons.local_fire_department_outlined,
          text: 'Эксклюзивные предложения именно для вас',
        ),
        const SizedBox(height: 16),
        const _BenefitRow(
          icon: Icons.shopping_bag_outlined,
          text: 'Размещение объявлений и избранное',
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
            onPressed: () => _showPhoneBottomSheet(context),
            child: const Text('Войти или создать профиль'),
          ),
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        Text(
          'Покупайте, продавайте и пользуйтесь услугами!\n'
          'Размещайте объявления, находите нужное и добавляйте в избранное',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showPhoneBottomSheet(BuildContext context) {
    PhoneBottomSheet.show(
      context,
      onCodeSent: (phone) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            _showOtpBottomSheet(context, phone);
          } else {
          }
        });
      },
    );
  }

  void _showOtpBottomSheet(BuildContext context, String phone) {
    OtpBottomSheet.show(
      context,
      phone,
      onAskName: () {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            _showNameBottomSheet(context);
          }
        });
      },
    );
  }

  void _showNameBottomSheet(BuildContext context) {
    NameBottomSheet.show(context);
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

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
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
