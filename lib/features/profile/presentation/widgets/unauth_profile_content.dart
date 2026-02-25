import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/constants/app_dimens.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uz_xarid/features/profile/presentation/bloc/profile_bloc.dart';

import 'bottom_sheets/name_bottom_sheet.dart';
import 'bottom_sheets/otp_bottom_sheet.dart';
import 'bottom_sheets/phone_bottom_sheet.dart';

class UnauthProfileContent extends StatelessWidget {
  const UnauthProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;
    final dividerColor = context.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: l10n.profileAuthBenefitsTitle,
          fontWeight: 700,
          fontSize: 16,
          color: textColor,
        ),
        const SizedBox(height: 20),
        _BenefitRow(
          icon: AppAssets.work,
          text: l10n.profileBenefitOfferServices,
        ),
        const SizedBox(height: 12),
        _BenefitRow(
          icon: AppAssets.call,
          text: l10n.profileBenefitUseServices,
        ),
        const SizedBox(height: 12),
        _BenefitRow(
          icon: AppAssets.fire,
          text: l10n.profileBenefitExclusive,
        ),
        const SizedBox(height: 12),
        _BenefitRow(
          icon: AppAssets.chat,
          text: l10n.profileBenefitAdsFavorites,
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        Divider(color: dividerColor),
        const SizedBox(height: AppDimens.paddingLarge),
        ContainerW(
          width: double.infinity,
          onTap: () => _showPhoneBottomSheet(context),
          color: AppColors.primary,
          radius: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: AppText(
                text: l10n.profileAuthCta,
                fontSize: 12,
                fontWeight: 500,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingLarge),
        AppText(
          text: l10n.profileAuthDescription,
          fontSize: 12,
          fontWeight: 400,
          color: textSecondary,
          maxLines: 3,
        ),
        const SizedBox(height: AppDimens.paddingMedium),
        GestureDetector(
          onTap: () => context.push('/profile/settings'),
          child: AppText(
            text: l10n.profileMenuSettings,
            fontSize: 14,
            fontWeight: 600,
            color: AppColors.primary,
          ),
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
      onOtpSuccess: () {
        if (context.mounted) {
          context.read<ProfileBloc>().add(const ProfileLoadEvent());
        }
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
    final iconBg = context.isDark
        ? AppColors.primary.withValues(alpha: 0.25)
        : AppColors.blue50;
    final textColor = context.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: iconBg,
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
            color: textColor,
          ),
        ),
      ],
    );
  }
}
