import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizontal_drag_back_widget/constant.dart';
import 'package:horizontal_drag_back_widget/horizontal_route_observer.dart';

/// 要放在HorizontalDragBackWidget上层
///@auther Gever
///created at 2025/1/22/17:00

class HorizontalDragBackParentWidget extends StatefulWidget {
  const HorizontalDragBackParentWidget({super.key, required this.child});

  final Widget child;

  @override
  State<HorizontalDragBackParentWidget> createState() =>
      _HorizontalDragBackParentWidgetState();
}

class _HorizontalDragBackParentWidgetState
    extends State<HorizontalDragBackParentWidget>
    with SingleTickerProviderStateMixin {
  late StreamController<num> controller = StreamController();
  num? offsetX;
  AnimationController? animationController;

  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    // print(
    //     'HorizontalDragBackParentWidget initState:${HorizontalRouteObserver.getInstance().length}');
    HorizontalDragBackController().addController(
        HorizontalRouteObserver.getInstance().length, controller);
    controller.stream.listen((num value) {
      print('horizontalDragBack----2222---offsetX: $value');
      if (animationController?.isAnimating ?? false) {
        return;
      }
      if (value == -1) {
        backAnimation();
      } else {
        offsetX = value;
        setState(() {});
      }
    });
  }

  backAnimation() {
    animationController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: Constant.transitionDuration));
    var begin = MediaQuery.of(context).size.width;
    animation = Tween(begin: 0.0, end: begin).animate(animationController!)
      ..addListener(() {
        // print('begin222: ${animation!.value}');
        offsetX = animation!.value;
        if (offsetX == 0) {
          offsetX = null;
        }
        setState(() {});
      });
    animationController?.forward(from: 0);
  }

  @override
  void dispose() {
    // print(
        // 'HorizontalDragBackParentWidget dispose:${HorizontalRouteObserver.getInstance().length}');
    HorizontalDragBackController().removeController(controller);
    controller.close();
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return HorizontalDragBackParentState(
      controller: controller,
      child: Transform.translate(
        offset: Offset(
            offsetX == null ? 0 : min(0, (-width + (offsetX ?? 0)) / 10 * 3),
            0),
        child: widget.child,
      ),
    );
  }
}

class HorizontalDragBackParentState extends InheritedWidget {
  final StreamController<num> controller;

  const HorizontalDragBackParentState(
      {super.key, required this.controller, required super.child});

  @override
  bool updateShouldNotify(covariant HorizontalDragBackParentState oldWidget) {
    return oldWidget.controller != controller;
  }

  static HorizontalDragBackParentState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HorizontalDragBackParentState>();
  }
}

class HorizontalDragBackController {
  final Map<int, StreamController> _controllers = {};

  static final HorizontalDragBackController _instance =
      HorizontalDragBackController._();

  factory HorizontalDragBackController() => _instance;

  void addController(int page, StreamController controller) {
    _controllers[page] = controller;
    // print('HorizontalDragBackController addController:${_controllers.length}');
  }

  void removeController(StreamController controller) {
    _controllers.removeWhere((_, value) => value == controller);
    // print('HorizontalDragBackController removeController:${_controllers.length}');
  }

  void notify(num value) {
    if (_controllers.isEmpty) {
      return;
    }
    var index = HorizontalRouteObserver.getInstance().length - 1;
    _controllers[index]?.add(value);
  }

  HorizontalDragBackController._();
}
