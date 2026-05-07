import 'package:flutter/material.dart';
import 'package:uz_xarid/core/theme/theme_colors.dart';
import 'package:uz_xarid/core/widgets/shimmer_box.dart';

/// Banner uchun shimmer (balandlik bilan).
class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key, this.height = 240, this.borderRadius = 20});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Kichik kategoriya karti (gorizontal qatorda, masalan 150x180).
class ShimmerCategoryCard extends StatelessWidget {
  const ShimmerCategoryCard({
    super.key,
    this.width = 150,
    this.height = 180,
    this.borderRadius = 16,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: context.borderColor),
        ),
      ),
    );
  }
}

/// Mahsulot / tavsiya karti (gorizontal ListView da, masalan 230 kenglik).
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({
    super.key,
    this.width = 230,
    this.height = 320,
    this.borderRadius = 16,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: context.borderColor),
        ),
      ),
    );
  }
}

/// Kichik mahsulot karti (masalan gifts qatorida 240).
class ShimmerProductCardSmall extends StatelessWidget {
  const ShimmerProductCardSmall({
    super.key,
    this.width = 240,
    this.height = 320,
    this.borderRadius = 16,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: context.borderColor),
        ),
      ),
    );
  }
}

/// Griddagi mahsulot karti (2 ustun layout).
class ShimmerGridProductCard extends StatelessWidget {
  const ShimmerGridProductCard({super.key, this.borderRadius = 16});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: context.borderColor),
        ),
      ),
    );
  }
}

/// Services / grid 2 ustun uchun bitta cell.
class ShimmerServiceCard extends StatelessWidget {
  const ShimmerServiceCard({super.key, this.borderRadius = 16});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: context.borderColor),
        ),
      ),
    );
  }
}

/// Catalog list tile (bir qator).
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key, this.height = 56, this.borderRadius = 12});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Product detail: rasim bloki.
class ShimmerDetailImage extends StatelessWidget {
  const ShimmerDetailImage({super.key, this.height = 300});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(height: height, color: context.cardSurface),
    );
  }
}

/// Product detail: sarlavha / matn bloki.
class ShimmerDetailBlock extends StatelessWidget {
  const ShimmerDetailBlock({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.cardSurface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
