import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/cubit/app_mode_cubit.dart';
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
    if (!context.mounted) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = context.watch<AppModeCubit>().state.primaryColor;
    final textColor = context.textPrimary;
    final textSecondary = context.textSecondary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          AppText(
            text: l10n.profileAuthBenefitsTitle,
            fontWeight: 700,
            fontSize: 16,
            color: textColor,
          ),
          const SizedBox(height: 20),

          // Benefits Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _BenefitCard(
                icon: AppAssets.work,
                text: l10n.profileBenefitOfferServices,
                color: Colors.blue,
              ),
              _BenefitCard(
                icon: AppAssets.call,
                text: l10n.profileBenefitUseServices,
                color: Colors.green,
              ),
              _BenefitCard(
                icon: AppAssets.fire,
                text: l10n.profileBenefitExclusive,
                color: Colors.orange,
              ),
              _BenefitCard(
                icon: AppAssets.heartOutline,
                text: l10n.profileBenefitAdsFavorites,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 20),

          InkWell(
            onTap: () => context.push('/profile/settings'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    text: l10n.profileMenuSettings,
                    fontSize: 15,
                    fontWeight: 600,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // CTA Section
          ContainerW(
            width: double.infinity,
            onTap: () => _showPhoneBottomSheet(context),
            color: primaryColor,
            radius: 16,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: AppText(
                  text: l10n.profileAuthCta,
                  fontSize: 16,
                  fontWeight: 700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.text,
    required this.color,
  });

  final String icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.surfaceContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppImage(path: icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          AppText(
            text: text,
            fontSize: 11,
            fontWeight: 600,
            maxLines: 3,
            color: context.textPrimary,
          ),
        ],
      ),
    );
  }
}
