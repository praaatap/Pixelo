import 'package:flutter/material.dart';

class PinchToZoomImage extends StatefulWidget {
  final Widget child;

  const PinchToZoomImage({super.key, required this.child});

  @override
  State<PinchToZoomImage> createState() => _PinchToZoomImageState();
}

class _PinchToZoomImageState extends State<PinchToZoomImage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();

  late final AnimationController _animationController;

  OverlayEntry? _overlayEntry;

  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;
  Animation<double>? _opacityAnimation;

  Rect _childRect = Rect.zero;
  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  double _scale = 1;
  double _overlayOpacity = 0;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 220),
          )
          ..addListener(_handleAnimationTick)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _removeOverlay();
              if (mounted) {
                setState(() {
                  _scale = 1;
                  _offset = Offset.zero;
                  _overlayOpacity = 0;
                  _isZooming = false;
                });
              }
            }
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _handleAnimationTick() {
    if (_scaleAnimation != null) {
      _scale = _scaleAnimation!.value;
    }
    if (_offsetAnimation != null) {
      _offset = _offsetAnimation!.value;
    }
    if (_opacityAnimation != null) {
      _overlayOpacity = _opacityAnimation!.value;
    }
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    if (_overlayEntry != null || _childKey.currentContext == null) {
      return;
    }

    final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
    final origin = renderBox.localToGlobal(Offset.zero);
    _childRect = origin & renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: Material(
            color: Colors.black.withValues(alpha: _overlayOpacity),
            child: Stack(
              children: [
                Positioned.fromRect(
                  rect: _childRect,
                  child: Transform.translate(
                    offset: _offset,
                    child: Transform.scale(
                      scale: _scale,
                      alignment: Alignment.center,
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _updateOverlay(ScaleUpdateDetails details) {
    if (!_isZooming) {
      return;
    }

    _scale = details.scale.clamp(1.0, 4.0);
    _offset = _startOffset + (details.focalPoint - _startFocalPoint);
    _overlayOpacity = (((_scale - 1) * 0.45) + (_offset.distance / 1400)).clamp(
      0.0,
      0.65,
    );
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _animateBack() {
    _scaleAnimation = Tween<double>(begin: _scale, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _offsetAnimation = Tween<Offset>(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _opacityAnimation = Tween<double>(begin: _overlayOpacity, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) {
        if (details.pointerCount < 2) {
          return;
        }

        _animationController.stop();
        _startOffset = _offset;
        _startFocalPoint = details.focalPoint;
        _isZooming = true;
        _showOverlay();
        setState(() {});
      },
      onScaleUpdate: (details) {
        _updateOverlay(details);
      },
      onScaleEnd: (_) {
        if (_overlayEntry != null) {
          _animateBack();
        }
      },
      child: Opacity(
        opacity: _isZooming ? 0 : 1,
        child: KeyedSubtree(key: _childKey, child: widget.child),
      ),
    );
  }
}
