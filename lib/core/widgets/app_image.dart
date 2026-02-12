  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum ImageType { svg, png, jpg, jpeg, gif, webp, network }

class GlobalImageWidget extends StatelessWidget {
  const GlobalImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.callback,
    this.color,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.imageType,
  });

  final String imagePath;
  final double? width, height;
  final VoidCallback? callback;
  final Color? color;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageType? imageType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: width?.w,
        height: height?.h,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Agar imagePath bo'sh bo'lsa, errorWidget chiqaramiz
    if (imagePath.trim().isEmpty) {
      return errorWidget ?? _defaultErrorWidget();
    }

    final ImageType type = imageType ?? _getImageType(imagePath);

    switch (type) {
      case ImageType.svg:
        return SvgPicture.asset(
          imagePath,
          width: width?.w,
          height: height?.h,
          fit: fit,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          placeholderBuilder: (context) => placeholder ?? _defaultPlaceholder(),
        );

      case ImageType.network:
        return CachedNetworkImage(
          imageUrl: imagePath,
          width: width?.w,
          height: height?.h,
          fit: fit,
          // color: color,
          placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
          errorWidget: (context, url, error) =>
          errorWidget ?? _defaultErrorWidget(),
        );

      default:
        return Image.asset(
          imagePath,
          width: width?.w,
          height: height?.h,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(),
        );
    }
  }

  ImageType _getImageType(String path) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.startsWith('http://') || lowerPath.startsWith('https://')) {
      return ImageType.network;
    }

    if (!path.contains('.')) return ImageType.png;

    final extension = path.split('.').last;
    switch (extension) {
      case 'svg':
        return ImageType.svg;
      case 'png':
        return ImageType.png;
      case 'jpg':
        return ImageType.jpg;
      case 'jpeg':
        return ImageType.jpeg;
      case 'gif':
        return ImageType.gif;
      case 'webp':
        return ImageType.webp;
      default:
        return ImageType.png;
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width?.w,
      height: height?.h,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width?.w,
      height: height?.h,
      color: Colors.grey[300],
      child: const Icon(
        Icons.error,
        color: Colors.red,
      ),
    );
  }
}

  class AppImage extends StatelessWidget {
    const AppImage({
      super.key,
      required this.path,
      this.size,
      this.width,
      this.height,
      this.color, // Agar berilmasa, tema ikonka rangini oladi
      this.onTap,
      this.fit = BoxFit.cover,
      this.borderRadius,
    });

    final String path;
    final double? size;
    final double? width, height;
    final Color? color;
    final VoidCallback? onTap;
    final BoxFit fit;
    final BorderRadius? borderRadius;

    @override
    Widget build(BuildContext context) {
      // Agar color berilmasa, tema ikonka rangini olish
      // final imageColor = color ?? Theme.of(context).iconTheme.color;

      return GlobalImageWidget(
        imagePath: path,
        width: width ?? size,
        height: height ?? size,
        color: color, // //Tema ikonka rangi
        callback: onTap,
        fit: fit,
        borderRadius: borderRadius,
      );
    }
  }
