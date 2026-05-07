import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';

/// Umumiy shimmer wrapper: [child] ga shimmer effektini qo‘llaydi.
/// Ranglarni avtomatik tema (dark/light) bo'yicha tanlaydi —
/// chaqiruvchi qiymat bersa shu ustun bo'ladi.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? context.shimmerBase,
      highlightColor: highlightColor ?? context.shimmerHighlight,
      child: child,
    );
  }
}
