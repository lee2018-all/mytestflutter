import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DraggableFloatingView extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Offset? initialPosition;
  final double size;
  final bool snapToEdge;
  final double edgeMargin;

  const DraggableFloatingView({
    Key? key,
    required this.child,
    this.onTap,
    this.initialPosition,
    this.size = 60,
    this.snapToEdge = true,
    this.edgeMargin = 0,
  }) : super(key: key);

  @override
  State<DraggableFloatingView> createState() => _DraggableFloatingViewState();
}

class _DraggableFloatingViewState extends State<DraggableFloatingView> {
  late Offset _position;
  Offset _dragStartPosition = Offset.zero;
  Offset _dragStartGlobalPosition = Offset.zero;
  bool _isDragging = false;
  double _screenWidth = 0;
  double _screenHeight = 0;
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition ?? const Offset(0, 180);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScreenSize();
  }

  void _updateScreenSize() {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _clampPosition();
  }

  void _clampPosition() {
    final childSize = widget.size;
    final minX = 0.0;
    final maxX = _screenWidth - childSize;
    final minY = 0.0;
    final maxY = _screenHeight - childSize;

    _position = Offset(
      _position.dx.clamp(minX, maxX),
      _position.dy.clamp(minY, maxY),
    );
  }

  void _snapToEdge() {
    final childSize = widget.size;
    final leftEdge = widget.edgeMargin;
    final rightEdge = _screenWidth - childSize - widget.edgeMargin;

    if (_position.dx < _screenWidth / 2) {
      _position = Offset(leftEdge, _position.dy);
    } else {
      _position = Offset(rightEdge, _position.dy);
    }
    _clampPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Listener(
        onPointerMove: (event) {
          if (!_isDragging) {
            setState(() {
              _isDragging = true;
              _dragStartGlobalPosition = event.position;
              _dragStartPosition = _position;
            });
          } else {
            final delta = event.position - _dragStartGlobalPosition;
            setState(() {
              _position = _dragStartPosition + delta;
              _clampPosition();
            });
          }
        },
        onPointerUp: (event) {
          if (_isDragging) {
            setState(() {
              _isDragging = false;
              if (widget.snapToEdge) {
                _snapToEdge();
              }
            });
          }
        },
        child: GestureDetector(
          onTap: () {
            if (!_isDragging && widget.onTap != null) {
              widget.onTap!();
            }
          },
          child: AnimatedContainer(
            duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}