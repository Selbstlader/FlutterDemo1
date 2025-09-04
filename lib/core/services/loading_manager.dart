import 'package:flutter/material.dart';
import '../widgets/loading_overlay.dart';

/// 全屏 Loading 管理器
class LoadingManager {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;
  static int _loadingCount = 0;

  /// 显示全屏 loading
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) {
      _loadingCount++;
      return;
    }

    _loadingCount = 1;
    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingOverlay(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 隐藏全屏 loading
  static void hide() {
    if (!_isShowing) return;

    _loadingCount--;
    if (_loadingCount > 0) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
    _loadingCount = 0;
  }

  /// 强制隐藏所有 loading
  static void forceHide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isShowing = false;
    _loadingCount = 0;
  }

  /// 检查是否正在显示 loading
  static bool get isShowing => _isShowing;

  /// 获取当前 loading 计数
  static int get loadingCount => _loadingCount;
}