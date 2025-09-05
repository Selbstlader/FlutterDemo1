import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals.dart';

/// 键盘管理服务
/// 负责处理键盘显示/隐藏、界面适配等功能
class KeyboardService {
  static final KeyboardService _instance = KeyboardService._internal();
  factory KeyboardService() => _instance;
  KeyboardService._internal() {
    _isKeyboardVisible = signal(false);
    _keyboardHeight = signal(0.0);
    _safeAreaPadding = signal(EdgeInsets.zero);
  }

  /// 键盘是否显示
  late final Signal<bool> _isKeyboardVisible;
  Signal<bool> get isKeyboardVisible => _isKeyboardVisible;

  /// 键盘高度
  late final Signal<double> _keyboardHeight;
  Signal<double> get keyboardHeight => _keyboardHeight;

  /// 安全区域内边距
  late final Signal<EdgeInsets> _safeAreaPadding;
  Signal<EdgeInsets> get safeAreaPadding => _safeAreaPadding;

  /// 当前焦点节点
  FocusNode? _currentFocusNode;
  FocusNode? get currentFocusNode => _currentFocusNode;

  /// 滚动控制器映射
  final Map<String, ScrollController> _scrollControllers = {};

  /// 更新键盘状态
  void updateKeyboardState(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final padding = mediaQuery.padding;
    
    final keyboardHeight = viewInsets.bottom;
    final isVisible = keyboardHeight > 0;
    
    _keyboardHeight.value = keyboardHeight;
    _isKeyboardVisible.value = isVisible;
    _safeAreaPadding.value = padding;
  }

  /// 隐藏键盘
  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// 显示键盘
  void showKeyboard(FocusNode focusNode) {
    _currentFocusNode = focusNode;
    focusNode.requestFocus();
  }

  /// 注册滚动控制器
  void registerScrollController(String key, ScrollController controller) {
    _scrollControllers[key] = controller;
  }

  /// 注销滚动控制器
  void unregisterScrollController(String key) {
    _scrollControllers.remove(key);
  }

  /// 滚动到指定位置以确保输入框可见
  Future<void> ensureVisible({
    required BuildContext context,
    required GlobalKey widgetKey,
    String? scrollControllerKey,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double extraOffset = 20.0,
  }) async {
    if (!_isKeyboardVisible.value) return;

    final renderObject = widgetKey.currentContext?.findRenderObject();
    if (renderObject == null) return;

    final renderBox = renderObject as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardTop = screenHeight - _keyboardHeight.value;
    final widgetBottom = position.dy + size.height;
    
    // 检查输入框是否被键盘遮挡
    if (widgetBottom > keyboardTop - extraOffset) {
      final scrollController = scrollControllerKey != null 
          ? _scrollControllers[scrollControllerKey]
          : null;
      
      if (scrollController != null && scrollController.hasClients) {
        final scrollOffset = widgetBottom - keyboardTop + extraOffset;
        final targetOffset = scrollController.offset + scrollOffset;
        
        await scrollController.animateTo(
          targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: duration,
          curve: curve,
        );
      }
    }
  }

  /// 自动调整滚动位置
  Future<void> autoAdjustScroll({
    required BuildContext context,
    required FocusNode focusNode,
    String? scrollControllerKey,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    // 等待键盘动画完成
    await Future.delayed(delay);
    
    if (!focusNode.hasFocus) return;
    
    final scrollController = scrollControllerKey != null 
        ? _scrollControllers[scrollControllerKey]
        : null;
    
    if (scrollController != null && scrollController.hasClients) {
      final screenHeight = MediaQuery.of(context).size.height;
      final keyboardHeight = _keyboardHeight.value;
      final availableHeight = screenHeight - keyboardHeight;
      
      // 计算需要滚动的距离
      final currentOffset = scrollController.offset;
      final maxScrollExtent = scrollController.position.maxScrollExtent;
      
      if (maxScrollExtent > availableHeight) {
        final targetOffset = (maxScrollExtent * 0.3).clamp(0.0, maxScrollExtent);
        
        await scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// 处理键盘弹出时的界面调整
  void handleKeyboardShow(BuildContext context, FocusNode focusNode) {
    _currentFocusNode = focusNode;
    
    // 延迟执行，等待键盘动画
    Future.delayed(const Duration(milliseconds: 300), () {
      if (focusNode.hasFocus) {
        autoAdjustScroll(
          context: context,
          focusNode: focusNode,
          scrollControllerKey: 'main',
        );
      }
    });
  }

  /// 处理键盘隐藏时的界面调整
  void handleKeyboardHide() {
    _currentFocusNode = null;
  }

  /// 获取键盘安全区域
  EdgeInsets getKeyboardSafeArea() {
    return EdgeInsets.only(bottom: _keyboardHeight.value);
  }

  /// 获取适配后的内边距
  EdgeInsets getAdaptivePadding({
    EdgeInsets base = const EdgeInsets.all(16.0),
    bool avoidKeyboard = true,
  }) {
    if (!avoidKeyboard || !_isKeyboardVisible.value) {
      return base;
    }
    
    return base.copyWith(
      bottom: base.bottom + _keyboardHeight.value,
    );
  }

  /// 清理资源
  void dispose() {
    _scrollControllers.clear();
    _currentFocusNode = null;
  }
}

/// 键盘监听器Widget
class KeyboardMonitor extends StatefulWidget {
  final Widget child;
  final VoidCallback? onKeyboardShow;
  final VoidCallback? onKeyboardHide;
  
  const KeyboardMonitor({
    super.key,
    required this.child,
    this.onKeyboardShow,
    this.onKeyboardHide,
  });
  
  @override
  State<KeyboardMonitor> createState() => _KeyboardMonitorState();
}

class _KeyboardMonitorState extends State<KeyboardMonitor> {
  final _keyboardService = KeyboardService();
  bool _wasKeyboardVisible = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 更新键盘状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _keyboardService.updateKeyboardState(context);
          
          // 检查键盘状态变化
          final isKeyboardVisible = _keyboardService.isKeyboardVisible.value;
          if (isKeyboardVisible != _wasKeyboardVisible) {
            _wasKeyboardVisible = isKeyboardVisible;
            
            if (isKeyboardVisible) {
              widget.onKeyboardShow?.call();
            } else {
              widget.onKeyboardHide?.call();
              _keyboardService.handleKeyboardHide();
            }
          }
        });
        
        return widget.child;
      },
    );
  }
}

/// 键盘适配扩展
extension KeyboardExtension on BuildContext {
  /// 隐藏键盘
  void hideKeyboard() {
    KeyboardService().hideKeyboard();
  }
  
  /// 获取键盘高度
  double get keyboardHeight {
    return KeyboardService().keyboardHeight.value;
  }
  
  /// 键盘是否显示
  bool get isKeyboardVisible {
    return KeyboardService().isKeyboardVisible.value;
  }
  
  /// 获取键盘安全区域
  EdgeInsets get keyboardSafeArea {
    return KeyboardService().getKeyboardSafeArea();
  }
}