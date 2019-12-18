## 效果图

![](https://user-gold-cdn.xitu.io/2019/12/18/16f182dd37573bde?w=272&h=480&f=gif&s=2942308)

## 第一步：通过Stack实现层叠卡片
通过Stack实现层叠效果，它的子Widget的部署实现方式还是比较多的，比如使用**Container**，计算每个卡片的margin. 使用**Positioned**，计算left，top，right，bottom. 使用**Transform**，计算Offset. 

~~~
@override
Widget build(BuildContext context) {
  List<Widget> children = [];
  double offset = 8.0;
  for (int i = 0; i < 3; i++) {
    Widget child = Transform.translate(
      child: children[i],
      offset: Offset(offset * i, offset * i),
    );
    children.add(child);
  }
  return Stack(children: children.reversed.toList());
}
~~~
## 第二步：通过GestureDetector实现拖拽效果
第一层的卡片，需要识别用户的拖拽手势。并根据拖拽的距离更新第一层卡片的Offset.

关于手势识别，可以查看 [[译] 深入 Flutter 之手势](https://juejin.im/post/5b70eee8e51d456682516d36)。

~~~
_onPanUpdate(DragUpdateDetails details) {
  if (!_isDragging) {
    _isDragging = true;
    return;
  }
  _offsetDx += details.delta.dx;
  _offsetDy += details.delta.dy;
  setState(() {});
}
~~~

## 第三步：实现移除动画
当用户抬起手势的时候，启动移除的动画，也可以把第一层卡片移到最后一层。

切换List的两个元素：可以使用
~~~
list.insert(a, list.removeAt(b));
~~~

移除动画的时候，需要计算移除的终止点Offset，比如用户偏左上角拖拽，就从左上角移除。如果用户拖拽的距离较时，可以选择恢复原始位置，及Offset.zero。

启动动画，其实就是利用Tween，在规定时间内，由一个Offset到另一个Offset，并给Animation添加value监听，刷新UI. 添加status监听，动画完成时，移除卡片或切换卡片。

关于动画的了解可以参考 [Flutter 动画及示例](https://juejin.im/post/5dda35ce5188257350242d74)

## DroppableWidget代码

~~~
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Its child widget should have a fixed width and height
class DroppableWidget extends StatefulWidget {
  /// Children cards
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
      double dx = i == 0 ? _offsetDx : offset;
      double dy = i == 0 ? _offsetDy : offset;
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
    return Stack(children: children.reversed.toList());
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

~~~
## 项目地址
[https://github.com/smiling1990/FlutterCards](https://github.com/smiling1990/FlutterCards)