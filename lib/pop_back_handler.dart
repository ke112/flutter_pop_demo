import 'dart:io';

import 'package:flutter/material.dart';

/// 统一的返回事件处理器
/// 集成 PopScope + iOS 侧滑检测，对外只暴露一个回调
class PopBackHandler extends StatefulWidget {
  const PopBackHandler({
    super.key,
    required this.child,
    required this.onPopRequested,
    this.enableInterceptBack = true,
    this.edgeWidth = 20.0,
    this.swipeThreshold = 100.0,
  });

  final Widget child;

  /// 统一的返回事件回调
  /// 当用户尝试返回时触发（Android 返回键、iOS 侧滑）
  final VoidCallback onPopRequested;

  /// 是否开启拦截返回功能
  /// true: 拦截返回事件，通过 onPopRequested 回调处理
  /// false: 不拦截，允许系统默认返回行为
  final bool enableInterceptBack;

  /// iOS 边缘触发区域宽度
  final double edgeWidth;

  /// iOS 触发返回的滑动距离阈值
  final double swipeThreshold;

  @override
  State<PopBackHandler> createState() => _PopBackHandlerState();
}

class _PopBackHandlerState extends State<PopBackHandler> {
  double _startX = 0;
  bool _isEdgeSwipe = false;

  bool _isIOS = false;

  @override
  void initState() {
    super.initState();
    _isIOS = Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.enableInterceptBack,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          widget.onPopRequested();
        }
      },
      child: _buildIOSSwipeDetector(context),
    );
  }

  Widget _buildIOSSwipeDetector(BuildContext context) {
    // 非 iOS 平台或未开启拦截功能时，直接返回子组件
    // 未开启拦截时，iOS 系统自带的侧滑返回手势会正常工作
    if (!_isIOS || !widget.enableInterceptBack) {
      return widget.child;
    }

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final startPosition = details.globalPosition.dx;

        // 根据布局方向判断边缘位置
        // LTR: 从左边缘开始滑动
        // RTL: 从右边缘开始滑动
        if (isRTL) {
          _isEdgeSwipe = startPosition > screenWidth - widget.edgeWidth;
        } else {
          _isEdgeSwipe = startPosition < widget.edgeWidth;
        }
        _startX = startPosition;
      },
      onHorizontalDragUpdate: (details) {
        // 可以在这里添加滑动过程中的视觉反馈
      },
      onHorizontalDragEnd: (details) {
        if (!_isEdgeSwipe) return;

        final currentX = details.localPosition.dx;
        final deltaX = isRTL ? (_startX - currentX) : (currentX - _startX);

        // 滑动距离超过阈值，触发返回
        if (deltaX > widget.swipeThreshold) {
          widget.onPopRequested();
        }

        _isEdgeSwipe = false;
        _startX = 0;
      },
      onHorizontalDragCancel: () {
        _isEdgeSwipe = false;
        _startX = 0;
      },
      child: widget.child,
    );
  }
}
