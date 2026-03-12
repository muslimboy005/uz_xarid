import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uz_xarid/core/constants/app_assets.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';
import 'package:uz_xarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uz_xarid/core/widgets/w__container.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final borderColor = context.borderColor;

    return Scaffold(
      appBar: UzXaridAppBar(
        onSearchChanged: (query) {},
        onMenuTap: () {},
      ),
      backgroundColor: bodyBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: ContainerW(
                      color: cardColor,
                      radius: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          AppAssets.backDropleft,
                          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    text: l10n.supportTitle,
                    fontSize: 20,
                    fontWeight: 700,
                    color: textColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ContainerW(
                color: cardColor,
                radius: 16,
                border: Border.all(color: borderColor),
                child: Column(
                  children: [
                    _SupportItem(
                      iconPath: AppAssets.chat,
                      title: l10n.supportChat,
                      onTap: () {
                        // Plan: Implement chat or redirect to Telegram
                      },
                    ),
                    Divider(height: 1, color: borderColor, indent: 48),
                    _SupportItem(
                      iconPath: AppAssets.call,
                      title: l10n.supportPhone,
                      trailingText: '1888',
                      onTap: () => _makePhoneCall('1888'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SupportItem({
    required this.iconPath,
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    final isDark = context.isDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              height: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                text: title,
                fontSize: 16,
                fontWeight: 600,
                color: textColor,
              ),
            ),
            if (trailingText != null) ...[
              AppText(
                text: trailingText!,
                fontSize: 16,
                fontWeight: 700,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
            ],
            SvgPicture.asset(
              AppAssets.backDropright,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white54 : Colors.black26, 
                BlendMode.srcIn,
              ),
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}
