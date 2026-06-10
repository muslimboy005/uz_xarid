import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uzxarid/core/app_config.dart';
import 'package:uzxarid/core/constants/app_assets.dart';
import 'package:uzxarid/core/constants/app_colors.dart';
import 'package:uzxarid/core/constants/app_dimens.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';
import 'package:uzxarid/core/widgets/uzxarid_app_bar.dart';
import 'package:uzxarid/core/widgets/w__container.dart';
import 'package:uzxarid/l10n/app_localizations.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bodyBg = context.bodyBackground;
    final cardColor = context.cardSurface;
    final textColor = context.textPrimary;
    final borderColor = context.borderColor;

    return UzXaridScaffold(
      backgroundColor: bodyBg,
      body: Column(
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
                          package: AppConfig.packageName,
                          colorFilter: ColorFilter.mode(
                            textColor,
                            BlendMode.srcIn,
                          ),
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
                        context.pushNamed(
                          'support-chat',
                          extra: {
                            'chatRoomId': 0,
                          }, // Remove hardcoded 10, use 0 as placeholder
                        );
                      },
                    ),
                    Divider(height: 1, color: borderColor, indent: 48),
                    _SupportItem(
                      icon: Icons.auto_awesome,
                      title: l10n.aiAssistantTitle,
                      onTap: () => context.pushNamed('ai-assistant'),
                    ),
                  ],
                ),
              ),
            ),
            // Pastdagi suzuvchi bottom-nav ortida kontent qolib ketmasligi uchun.
            SizedBox(
              height:
                  AppDimens.bottomNavClearance +
                  MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final String title;
  final VoidCallback onTap;

  const _SupportItem({
    this.iconPath,
    this.icon,
    required this.title,
    required this.onTap,
  }) : assert(iconPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final textColor = context.textPrimary;
    final isDark = context.isDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                package: AppConfig.packageName,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
                height: 24,
              )
            else
              Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                text: title,
                fontSize: 16,
                fontWeight: 600,
                color: textColor,
              ),
            ),
            SvgPicture.asset(
              AppAssets.backDropright,
              package: AppConfig.packageName,
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
