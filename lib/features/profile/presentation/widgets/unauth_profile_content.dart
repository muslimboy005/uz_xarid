import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';

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
        AppText(
          text: 'Что даёт авторизация?',

          fontWeight: 700,
          fontSize: 16,
          color: AppColors.black500,
        ),
        const SizedBox(height: 20),
        const _BenefitRow(
          icon: AppAssets.work,
          text: 'Возможность предлагать свои услуги',
        ),
        const SizedBox(height: 12),
        const _BenefitRow(
          icon: AppAssets.call,
          text: 'Пользоваться услугами других пользователей',
        ),
        const SizedBox(height: 12),
        const _BenefitRow(
          icon: AppAssets.fire,
          text: 'Эксклюзивные предложения именно для вас',
        ),
        const SizedBox(height: 12),
        const _BenefitRow(
          icon: AppAssets.chat,
          text: 'Размещение объявлений и избранное',
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        const Divider(color: AppColors.black100),
        const SizedBox(height: AppDimens.paddingLarge),
        ContainerW(
          width: double.infinity,
          onTap: () => _showPhoneBottomSheet(context),
          color: AppColors.blue500,
          radius: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: AppText(
                text: 'Войти или создать профиль',
                fontSize: 12,
                fontWeight: 500,
                color: AppColors.white,
              ),
            ),
          ),
        ),

        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.primary,
        //       foregroundColor: Colors.white,
        //       padding: const EdgeInsets.symmetric(
        //         vertical: AppDimens.paddingMedium,
        //       ),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //     onPressed: () => _showPhoneBottomSheet(context),
        //     child: const Text('Войти или создать профиль'),
        //   ),
        // ),
        const SizedBox(height: AppDimens.paddingLarge),
        AppText(
          text:
              'Покупайте, продавайте и пользуйтесь услугами!\nРазмещайте объявления, находите нужное и добавляйте в избранное',
          fontSize: 12,
          fontWeight: 400,
          color: AppColors.black300,
          maxLines: 3,
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
          } else {}
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

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppImage(
            path: icon,
            color: AppColors.primary,
            size: 30,
            fit: BoxFit.none,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(
            text: text,
            fontSize: 12,
            fontWeight: 500,
            color: AppColors.black400,
          ),
        ),
      ],
    );
  }
}
