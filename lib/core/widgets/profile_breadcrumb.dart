import 'package:flutter/material.dart';
import 'package:uzxarid/core/theme/theme_colors.dart';
import 'package:uzxarid/core/widgets/app_text.dart';

/// A reusable breadcrumb row for profile section pages.
/// Usage: ProfileBreadcrumb(labels: [...], onTaps: [...])
class ProfileBreadcrumb extends StatelessWidget {
  final List<String> labels;
  final List<VoidCallback?>? onTaps;

  const ProfileBreadcrumb({super.key, required this.labels, this.onTaps});

  @override
  Widget build(BuildContext context) {
    final textSecondary = context.textSecondary;
    final activeColor = context.primaryColor;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: textSecondary,
                ),
              ),
            GestureDetector(
              onTap: onTaps != null && i < onTaps!.length ? onTaps![i] : null,
              child: AppText(
                text: labels[i],
                fontSize: 13,
                fontWeight: i == labels.length - 1 ? 600 : 400,
                color: i == labels.length - 1 ? activeColor : textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
