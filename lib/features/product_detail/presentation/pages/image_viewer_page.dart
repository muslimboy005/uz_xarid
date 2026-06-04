import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uzxarid/core/utils/image_parser.dart';

/// To'liq ekranli rasm ko'ruvchi (Telegram uslubida):
/// - ikkita barmoq bilan pinch-zoom (va double-tap zoom),
/// - zoom qilingach bitta barmoq bilan rasmni surib (pan) ko'rish,
/// - zoom qilinmaganda tepadan pastga swipe qilib chiqish (back).
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

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _resetController;
  late int _currentIndex;

  /// Vertikal dismiss drag'ining joriy siljishi (px).
  double _dragOffsetY = 0;

  /// True bo'lsa, foydalanuvchi rasmni zoom qilgan — vertikal dismiss o'chadi,
  /// shunda bitta barmoq bilan pan (surish) InteractiveViewer'ga o'tadi.
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails _) {
    _resetController.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    setState(() => _dragOffsetY += d.delta.dy);
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    // Tepadan pastga (yoki yetarlicha) tortilsa — back.
    if (_dragOffsetY.abs() > 120 || velocity.abs() > 700) {
      Navigator.of(context).pop();
    } else {
      _springBack();
    }
  }

  /// Yetarlicha tortilmaganda rasmni joyiga qaytarish.
  void _springBack() {
    final start = _dragOffsetY;
    final anim = _resetController.drive(
      Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeOut)),
    );
    void listener() => setState(() => _dragOffsetY = start * anim.value);
    _resetController.addListener(listener);
    _resetController.forward(from: 0).whenComplete(() {
      _resetController.removeListener(listener);
      setState(() => _dragOffsetY = 0);
    });
  }

  void _setZoomed(bool zoomed) {
    if (_isZoomed != zoomed) setState(() => _isZoomed = zoomed);
  }

  @override
  Widget build(BuildContext context) {
    final dragProgress = (_dragOffsetY.abs() / 400).clamp(0.0, 1.0);
    final bgOpacity = 1.0 - dragProgress; // pastga tortilsa fon ochiladi
    final contentScale = 1.0 - dragProgress * 0.12; // Telegram'dagidek biroz kichrayadi
    final chromeOpacity = (1.0 - dragProgress).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: bgOpacity),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              // Zoom qilinganda vertikal drag recognizer'i butunlay o'chadi
              // (null) — shunda bitta barmoq bilan pan InteractiveViewer'ga o'tadi.
              onVerticalDragStart: _isZoomed ? null : _onVerticalDragStart,
              onVerticalDragUpdate: _isZoomed ? null : _onVerticalDragUpdate,
              onVerticalDragEnd: _isZoomed ? null : _onVerticalDragEnd,
              child: Transform.translate(
                offset: Offset(0, _dragOffsetY),
                child: Transform.scale(
                  scale: contentScale,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: _isZoomed
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    itemCount: widget.images.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (_, i) => _ZoomableImage(
                      url: widget.images[i],
                      onZoomChanged: _setZoomed,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tepa panel: orqaga tugmasi + sanagich. Drag paytida sekin yo'qoladi.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: chromeOpacity < 0.1,
              child: Opacity(
                opacity: chromeOpacity,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Text(
                            '${_currentIndex + 1} / ${widget.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _zoomAnim;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_zoomAnim != null) _controller.value = _zoomAnim!.value;
      });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransform);
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onTransform() {
    widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.05);
  }

  void _animateTo(Matrix4 target) {
    _zoomAnim = Matrix4Tween(begin: _controller.value, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0);
  }

  /// Double-tap: bosilgan nuqtaga qarab zoom, yoki qaytadan 1.0 ga qaytarish.
  void _handleDoubleTap() {
    if (_controller.value.getMaxScaleOnAxis() > 1.05) {
      _animateTo(Matrix4.identity());
      return;
    }
    final pos = _doubleTapDetails?.localPosition;
    if (pos == null) return;
    const targetScale = 2.5;
    final zoomed = Matrix4.identity()
      ..translateByDouble(
          -pos.dx * (targetScale - 1), -pos.dy * (targetScale - 1), 0, 1)
      ..scaleByDouble(targetScale, targetScale, 1, 1);
    _animateTo(zoomed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _handleDoubleTap,
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
