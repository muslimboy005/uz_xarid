import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_image.dart';
import 'package:uz_xarid/features/home/domain/entities/home_entity.dart';
import 'package:uz_xarid/l10n/app_localizations.dart';

class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({super.key, required this.banner});

  final HomeBanner banner;

  Color _parseColor(String? value, {Color fallback = AppColors.green}) {
    if (value == null || value.isEmpty) return fallback;
    var hex = value.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(
      banner.backgroundColor,
      fallback: AppColors.green,
    );
    final titleColor = _parseColor(banner.textColor, fallback: AppColors.white);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 240,
        color: bgColor,
        child: Stack(
          children: [
            // Title visible on top
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Text(
                banner.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.2,
                ),
              ),
            ),

            // Image anchored to bottom, clipped slightly
            Positioned.fill(
              bottom: -45,
              left: -70,
              right: -50,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: const Offset(0, 14), // push down so bottom trims
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child:
                        (banner.mobileImage != null &&
                            banner.mobileImage!.isNotEmpty)
                        ? AppImage(path: banner.mobileImage!, fit: BoxFit.fill)
                        : Container(color: titleColor.withOpacity(0.08)),
                  ),
                ),
              ),
            ),

            // CTA stacked over image near bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue600,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // TODO: handle deep link navigation when routing is ready.
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.allProducts,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
