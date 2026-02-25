import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uz_xarid/core/constants/app_colors.dart';

/// Umumiy shimmer wrapper: [child] ga shimmer effektini qo‘llaydi.
/// [child] odatda oq/och rangdagi Container yoki boshqa shape bo‘ladi.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.child,
    this.baseColor = AppColors.black100,
    this.highlightColor = AppColors.black50,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
