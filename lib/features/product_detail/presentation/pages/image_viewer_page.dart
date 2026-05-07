import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uz_xarid/core/utils/image_parser.dart';

/// To'liq ekranli rasm ko'ruvchi: zoom + gorizontal swipe + pastga sirpaltirib chiqish.
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;
  double _dragOffsetY = 0;
  double _bgOpacity = 1.0;

  /// True bo'lsa, foydalanuvchi rasmni zoom qilgan — vertikal drag dismiss ishlamasin.
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (_isZoomed) return;
    setState(() {
      _dragOffsetY += d.delta.dy;
      final progress = (_dragOffsetY.abs() / 300).clamp(0.0, 1.0);
      _bgOpacity = 1.0 - progress * 0.7;
    });
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    if (_isZoomed) return;
    final velocity = d.primaryVelocity ?? 0;
    if (_dragOffsetY.abs() > 140 || velocity.abs() > 800) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffsetY = 0;
        _bgOpacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _bgOpacity),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Transform.translate(
          offset: Offset(0, _dragOffsetY),
          child: PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _ZoomableImage(
              url: widget.images[i],
              onZoomChanged: (zoomed) {
                if (_isZoomed != zoomed) {
                  setState(() => _isZoomed = zoomed);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({required this.url, required this.onZoomChanged});

  final String url;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _controller = TransformationController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransform);
    _controller.dispose();
    super.dispose();
  }

  void _onTransform() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.05);
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        final scale = _controller.value.getMaxScaleOnAxis();
        if (scale > 1.05) {
          _resetZoom();
        } else {
          _controller.value = Matrix4.identity()..scaleByDouble(2.5, 2.5, 1, 1);
        }
      },
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1.0,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.url.cdnUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            errorWidget: (_, _, _) => const Center(
              child: Icon(
                Icons.broken_image_rounded,
                size: 64,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
