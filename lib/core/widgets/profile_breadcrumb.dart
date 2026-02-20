import 'package:flutter/material.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';
import 'package:uz_xarid/core/widgets/app_text.dart';

/// A reusable breadcrumb row for profile section pages.
/// Usage: ProfileBreadcrumb(labels: [...], onTaps: [...])
class ProfileBreadcrumb extends StatelessWidget {
  final List<String> labels;
  final List<VoidCallback?>? onTaps;

  const ProfileBreadcrumb({super.key, required this.labels, this.onTaps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 4),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.black300,
                ),
              ),
            GestureDetector(
              onTap: onTaps != null && i < onTaps!.length ? onTaps![i] : null,
              child: AppText(
                text: labels[i],
                fontSize: 13,
                fontWeight: i == labels.length - 1 ? 600 : 400,
                color: i == labels.length - 1
                    ? AppColors.blue500
                    : AppColors.black300,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
