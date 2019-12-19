/**
 *
 * Eddie, enguagns2@gmail.com
 *
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// It's child widget should have a fixed width and height
class DroppableWidget extends StatefulWidget {
  final List<Widget> children;

  const DroppableWidget({Key key, this.children}) : super(key: key);

  @override
  _DroppableWidgetState createState() => _DroppableWidgetState();
}

class _DroppableWidgetState extends State<DroppableWidget>
    with TickerProviderStateMixin {
  /// Offset
  double _offsetDx;
  double _offsetDy;

  /// Mark if dragging
  bool _isDragging;

  /// Animation Controller
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Init
    _offsetDx = _offsetDy = 0;
    _isDragging = false;
  }

  bool get _isAnimating => _animationController?.isAnimating ?? false;

  /// Update offset value
  _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    if (!_isDragging) {
      _isDragging = true;
      return;
    }
    _offsetDx += details.delta.dx;
    _offsetDy += details.delta.dy;
    setState(() {});
  }

  /// Start animation when PanEnd
  _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    _isDragging = false;
    bool change = _offsetDx.abs() >= context.size.width * 0.1 ||
        _offsetDy.abs() >= context.size.height * 0.1;
    if (change) {
      double endX, endY;
      if (_offsetDx.abs() > _offsetDy.abs()) {
        endX = context.size.width * _offsetDx.sign;
        endY = _offsetDy.sign *
            context.size.width *
            _offsetDy.abs() /
            _offsetDx.abs();
      } else {
        endY = context.size.height * _offsetDy.sign;
        endX = _offsetDx.sign *
            context.size.height *
            _offsetDx.abs() /
            _offsetDy.abs();
      }
      _startAnimation(Offset(_offsetDx, _offsetDy), Offset(endX, endY), true);
    } else {
      _startAnimation(Offset(_offsetDx, _offsetDy), Offset.zero, false);
    }
  }

  /// Start animation
  /// [change] if change child, when animation complete
  _startAnimation(Offset begin, Offset end, bool change) {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    var _animation = Tween(begin: begin, end: end).animate(
      _animationController,
    );
    _animationController.addListener(() {
      setState(() {
        _offsetDx = _animation.value.dx;
        _offsetDy = _animation.value.dy;
      });
    });
    _animationController.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _offsetDx = 0;
      _offsetDy = 0;
      if (change) {
        widget.children.insert(
          widget.children.length - 1,
          widget.children.removeAt(0),
        );
      }
      setState(() {});
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int length = widget.children?.length ?? 0;
    double offset = 8.0;
    for (int i = 0; i < length; i++) {
      double dx = i == 0 ? _offsetDx : 0.0;
      double dy = i == 0 ? _offsetDy : 0.0;
      Widget child = Transform.translate(
        child: widget.children[i],
        offset: Offset(dx + (offset * i), dy + (offset * i)),
      );
      if (i == 0) {
        child = GestureDetector(
          child: child,
          onPanEnd: _onPanEnd,
          onPanUpdate: _onPanUpdate,
        );
      }
      children.add(child);
    }
    return Stack(
      children: children.reversed.toList(),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
