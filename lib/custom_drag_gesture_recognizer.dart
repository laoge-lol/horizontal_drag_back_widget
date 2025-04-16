import 'dart:ui';

import 'package:flutter/gestures.dart';

///
///@auther Gever
///created at 2024/11/6/14:28

class CustomDragGestureRecognizer extends PanGestureRecognizer {
  bool _isTracking = false;

  @override
  void addPointer(PointerDownEvent event) {
    // 如果已经有一个触控点，则忽略新的触控点
    if (_isTracking) {
      return;
    }
    _isTracking = true; // 标记正在追踪触控点
    super.addPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _isTracking = false; // 重置追踪状态
    }
    super.handleEvent(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _isTracking = false; // 停止追踪时重置状态
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void rejectGesture(int pointer) {
    //不，我不要失败，我要成功
    //super.rejectGesture(pointer);
    //宣布成功
    super.acceptGesture(pointer);
  }

  @override
  bool isFlingGesture(VelocityEstimate estimate, PointerDeviceKind kind) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance =
        minFlingDistance ?? computeHitSlop(kind, gestureSettings);
    return estimate.pixelsPerSecond.dx.abs() > minVelocity &&
        estimate.offset.dx.abs() > minDistance;
  }
}
