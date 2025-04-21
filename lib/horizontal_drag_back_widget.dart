import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_drag_back_widget/constant.dart';
import 'package:horizontal_drag_back_widget/custom_drag_gesture_recognizer.dart';
import 'package:horizontal_drag_back_widget/horizontal_drag_back_parent_widget.dart';

///
///@auther Gever
///created at 2024/9/26/09:35

class HorizontalDragBackWidget extends StatefulWidget {
  const HorizontalDragBackWidget({
    this.child,
    this.onWidgetOut,
    this.canPop = true,
    this.responseDepth = const [],
    this.hasScrollChild = false,
    this.noBackAnimation = false,
    super.key,
  });

  final Widget? child;

  ///是否支持右滑返回，实体/虚拟按键返回
  final bool canPop;

  ///响应哪个子滚动组件
  final List<int> responseDepth;
  final bool hasScrollChild;

  /// 自定义返回响应
  final Function()? onWidgetOut;

  /// 只响应事件，不执行动画
  final bool noBackAnimation;

  @override
  State<HorizontalDragBackWidget> createState() =>
      _HorizontalDragBackWidgetState();
}

class _HorizontalDragBackWidgetState extends State<HorizontalDragBackWidget>
    with TickerProviderStateMixin {
  ///手指按下的x位置
  double startX = -1, endX = -1;

  ///移动的距离
  double offsetX = 0;

  /// 布局宽度
  double width = 0;
  late AnimationController animationController;
  late Tween<double> tween;

  /// 回收动画的最小时长
  int minMilliseconds = 100;

  /// 回收动画的最大时长
  int maxMilliseconds = 200;
  late Animation<double> animation;
  late Duration duration;

  bool isReset = false;

  bool isOnLeftSide = false;

  bool isOut = false;

  // 开始滚动时是否在边界
  bool startScrollFlag = false;

  /// 页面退出中
  bool popping = false;

  /// Get.back()/Navigator.pop() 标记
  bool systemPopping = false;

  /// 进入动画
  late AnimationController enterAnimationController;
  late Animation<double> enterAnimation;

  @override
  void initState() {
    super.initState();
    enterAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: Constant.transitionDuration));
    Future.delayed(Duration.zero, () {
      // print('horizontalDragBack----delayed---offsetX: $offsetX');
      enterAnimation = TweenSequence([
        // TweenSequenceItem(
        //     tween: Tween(begin: width, end: width / 2), weight: 0.2),
        TweenSequenceItem(tween: Tween(begin: width, end: 0.0), weight: 1),
      ]).animate(enterAnimationController)
        ..addListener(() {
          print('horizontalDragBack----11111---offsetX: $offsetX');
          offsetX = enterAnimation.value;
          setState(() {});
          pageAnimation(value: enterAnimation.value);
        });
      enterAnimationController.forward();
    });

    duration = Duration(milliseconds: maxMilliseconds);
    tween = Tween(begin: 0, end: 1);
    animationController = AnimationController(vsync: this)
      ..addListener(() {
        if (mounted && !isReset) {
          offsetX = animation.value;
          if (!widget.noBackAnimation && !systemPopping) {
            setState(() {});
            // print('horizontalDragBack----33333---offsetX: $offsetX');
            pageAnimation();
          }
        }
        if (animationController.status == AnimationStatus.completed) {
          if (offsetX >= width && !isOut) {
            if (widget.onWidgetOut != null) {
              widget.onWidgetOut!.call();
            } else {
              isOut = true;
              Navigator.of(context).pop();
            }
            if (widget.noBackAnimation) {
              offsetX = 0;
            }
          }
        }
      });
    animation = tween.animate(animationController);
  }

  bool hasHorizontalScroll(BuildContext context) {
    final scrollable = Scrollable.of(context);
    return scrollable.axisDirection == AxisDirection.right ||
        scrollable.axisDirection == AxisDirection.left;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    // print('widget.noBackAnimation----------:${widget.noBackAnimation}');
    onHorizontalDragStart(DragStartDetails detail) {
      if (!isOnLeftSide) {
        return;
      }
      // print('onHorizontalDragStart: ${detail.localPosition}');
      offsetX = 0;
      startX = endX = detail.localPosition.dx;
    }

    onHorizontalDragEnd(DragEndDetails detail) {
      if (!isOnLeftSide) {
        return;
      }
      if (animationController.isAnimating || isOut) {
        return;
      }
      // print('onHorizontalDragEnd: ${detail.localPosition}');
      print('onHorizontalDragEnd: ${detail.velocity}');
      endX = detail.localPosition.dx;
      _recycleAnimation(velocity: detail.velocity.pixelsPerSecond.dx);
    }

    onHorizontalDragCancel() {
      if (!isOnLeftSide) {
        return;
      }
      if (animationController.isAnimating || isOut) {
        return;
      }
      // print('onHorizontalDragCancel: ');
      _recycleAnimation();
    }

    onHorizontalDragDown(DragDownDetails detail) {
      if (!isOnLeftSide) {
        return;
      }
      // print('onHorizontalDragDown: ${detail.localPosition}');
      offsetX = 0;
      startX = endX = detail.localPosition.dx;
    }

    onHorizontalDragUpdate(DragUpdateDetails detail) {
      // print('onHorizontalDragUpdate: ${detail.localPosition}');
      if (!isOnLeftSide) {
        return;
      }
      if (animationController.isAnimating || isOut) {
        return;
      }
      // print('onHorizontalDragUpdate-offsetX:$offsetX');
      // print('detail.delta.dy:${detail.delta}');
      if (detail.delta.dy.abs() > detail.delta.dx.abs()) {
        return;
      }
      if (startX <= 0) {
        offsetX = 0;
        startX = detail.localPosition.dx;
      }
      endX = detail.localPosition.dx;
      // offsetX = detail.localPosition.dx - startX;
      offsetX += detail.delta.dx;
      if (offsetX < 0) {
        offsetX = 0;
      }
      if (!widget.noBackAnimation) {
        setState(() {});
        // print('horizontalDragBack----44444---offsetX: $offsetX');
        pageAnimation();
      }
    }

    Widget content(BuildContext context) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          /// 查看滚动容器的depth
          // print('notification:${notification.runtimeType}'
          //     ',pixels:${notification.metrics.pixels}'
          //     ',minScrollExtent:${notification.metrics.minScrollExtent}'
          //     ',axisDirection:${notification.metrics.axisDirection}'
          //     ',depth:${notification.depth}');
          if (notification is OverscrollNotification) {
            // print('notification.metrics.pixels:${notification.metrics.pixels}');
            if (notification.metrics.pixels <=
                    notification.metrics.minScrollExtent &&
                !isOnLeftSide &&
                notification.metrics.axisDirection == AxisDirection.right &&
                startScrollFlag &&
                checkDepth(notification)) {
              //到达左边界
              isOnLeftSide = true;
            }
          }
          if (notification is ScrollUpdateNotification &&
              !isOnLeftSide &&
              startScrollFlag) {
            // print(
            //     'notification.metrics.pixels:${notification.metrics.pixels}');
            if (notification.metrics.pixels <=
                    notification.metrics.minScrollExtent &&
                !isOnLeftSide &&
                notification.metrics.axisDirection == AxisDirection.right &&
                checkDepth(notification)) {
              //到达左边界
              isOnLeftSide = true;
            }
          }
          if (notification is ScrollStartNotification) {
            isOnLeftSide = false;
            //在边界
            if (notification.metrics.pixels <=
                    notification.metrics.minScrollExtent &&
                checkDepth(notification)) {
              startScrollFlag = true;
            }
          }
          if (notification is ScrollEndNotification) {
            startScrollFlag = false;
          }
          // true 阻止向上冒泡 ,false 继续向上冒泡
          return true;
        },
        child: RawGestureDetector(
          gestures: {
            CustomDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                CustomDragGestureRecognizer>(
              () => CustomDragGestureRecognizer(),
              (DragGestureRecognizer detector) {
                detector
                  ..onDown = onHorizontalDragDown
                  ..onStart = onHorizontalDragStart
                  ..onUpdate = onHorizontalDragUpdate
                  ..onEnd = onHorizontalDragEnd
                  ..onCancel = onHorizontalDragCancel;
              },
            )
          },
          child: Stack(
            children: [
              Container(
                color: Color.lerp(Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(.0), offsetX / width),
              ),
              Transform.translate(
                  offset: Offset((widget.noBackAnimation ? 0 : offsetX), 0),
                  child: widget.child),
            ],
          ),
        ),
      );
    }

    Widget ges(BuildContext context) {
      return GestureDetector(
          onHorizontalDragDown: (detail) {
            // print('onHorizontalDragDown');
            //处理没有滚动子组件的情况
            if (!isOnLeftSide) {
              isOnLeftSide = true;
            }
          },
          onHorizontalDragStart: (detail) {
            // print('onHorizontalDragStart');
            //处理没有滚动子组件的情况
            if (!isOnLeftSide) {
              isOnLeftSide = true;
            }
          },
          child: content(context));
    }

    return PopScope(
      // canPop: widget.canPop,
      canPop: false,
      onPopInvokedWithResult: (pop, _) {
        print('onPopInvokedWithResult:$pop,$popping');
        if(!pop && !popping){
          onTapBackKey();
        }
        // if (pop) {
        //   if (!popping) {
        //     /// Get.back()/Navigator.pop()进这里
        //     systemPopping = true;
        //     pageAnimation(value: -1);
        //   }
        // }
      },
      child: HorizontalDragBackState(
        onTapBackKey: onTapBackKey,
        child: Builder(builder: (context) {
          if (!widget.hasScrollChild) {
            return ges(context);
          }
          return content(context);
        }),
      ),
    );
  }

  void onTapBackKey() {
    tween.begin = 0.0;
    tween.end = width;
    animationController.duration = Duration(milliseconds: maxMilliseconds);
    animationController.forward(from: 0);
    popping = true;
  }

  void pageAnimation({num? value}) {
    HorizontalDragBackController().notify(value ?? offsetX);
  }

  bool checkDepth(ScrollNotification notification) =>
      widget.responseDepth.contains(notification.depth) ||
      widget.responseDepth.isEmpty;

  ///松手执行回收动画
  void _recycleAnimation({double velocity = 0}) {
    if (endX == startX) {
      return;
    }
    double beforeResetOffsetX = offsetX;
    animationController.reset();
    isReset = true;
    if ((beforeResetOffsetX > 0 && velocity > 700) ||
        (beforeResetOffsetX > 50 && velocity > 500) ||
        (beforeResetOffsetX > width / 5 && velocity >= 250) ||
        beforeResetOffsetX > width * 2 / 5 && velocity >= 0) {
      /// 最后距离大于宽度的 1/5 且停止接触屏幕时移动的速度大于 250 则进入退出动画
      /// 最后距离大于宽度的 2/5 进入退出动画
      tween.begin = beforeResetOffsetX;
      tween.end = width;
      animationController.duration = Duration(
          milliseconds: velocity > 1000 ? minMilliseconds : maxMilliseconds);
      if (!widget.noBackAnimation) {
        popping = true;
      }
    } else {
      tween.begin = beforeResetOffsetX;
      tween.end = 0.0;
      animationController.duration = Duration(
          milliseconds:
              velocity.abs() > 1000 ? minMilliseconds : maxMilliseconds);
    }
    animationController.forward();
    isReset = false;
  }

  @override
  void dispose() {
    animationController.dispose();
    enterAnimationController.dispose();
    super.dispose();
  }
}

class HorizontalDragBackState extends InheritedWidget {
  final Function? _onTapBackKey;

  const HorizontalDragBackState(
      {super.key, Function? onTapBackKey, required super.child})
      : _onTapBackKey = onTapBackKey;

  @override
  bool updateShouldNotify(covariant HorizontalDragBackState oldWidget) {
    return oldWidget._onTapBackKey != _onTapBackKey;
  }

  static HorizontalDragBackState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HorizontalDragBackState>();
  }

  pop() {
    _onTapBackKey?.call();
  }
}
