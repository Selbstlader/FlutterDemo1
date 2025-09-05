import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

/// 加载状态类型
enum LoadingType {
  global,     // 全局加载（覆盖整个屏幕）
  local,      // 局部加载（在特定组件内）
  button,     // 按钮加载（按钮内显示加载状态）
  overlay,    // 覆盖层加载（半透明遮罩）
}

/// 加载状态模型
class LoadingState {
  final String id;
  final LoadingType type;
  final String? message;
  final bool isLoading;
  final DateTime startTime;
  final Duration? timeout;

  LoadingState({
    required this.id,
    required this.type,
    this.message,
    required this.isLoading,
    DateTime? startTime,
    this.timeout,
  }) : startTime = startTime ?? DateTime.now();

  LoadingState copyWith({
    String? id,
    LoadingType? type,
    String? message,
    bool? isLoading,
    DateTime? startTime,
    Duration? timeout,
  }) {
    return LoadingState(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      startTime: startTime ?? this.startTime,
      timeout: timeout ?? this.timeout,
    );
  }

  /// 检查是否超时
  bool get isTimeout {
    if (timeout == null) return false;
    return DateTime.now().difference(startTime) > timeout!;
  }

  /// 获取加载持续时间
  Duration get duration => DateTime.now().difference(startTime);
}

/// 加载管理服务
class LoadingService {
  static final LoadingService _instance = LoadingService._internal();
  factory LoadingService() => _instance;
  LoadingService._internal();

  // 全局加载状态
  late final Signal<bool> _globalLoading;
  Signal<bool> get globalLoading => _globalLoading;

  // 全局加载消息
  late final Signal<String?> _globalMessage;
  Signal<String?> get globalMessage => _globalMessage;

  // 所有加载状态
  late final Signal<Map<String, LoadingState>> _loadingStates;
  Signal<Map<String, LoadingState>> get loadingStates => _loadingStates;

  // 防重复提交的操作记录
  final Set<String> _pendingOperations = {};

  // 全局上下文
  BuildContext? _globalContext;

  /// 初始化加载服务
  void init([BuildContext? context]) {
    _globalLoading = signal(false);
    _globalMessage = signal<String?>(null);
    _loadingStates = signal<Map<String, LoadingState>>({});
    _globalContext = context;
  }

  /// 设置全局上下文
  void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  /// 开始全局加载
  void startGlobalLoading([String? message]) {
    _globalLoading.value = true;
    _globalMessage.value = message;
    
    final loadingState = LoadingState(
      id: 'global',
      type: LoadingType.global,
      message: message,
      isLoading: true,
    );
    
    final currentStates = Map<String, LoadingState>.from(_loadingStates.value);
    currentStates['global'] = loadingState;
    _loadingStates.value = currentStates;
  }

  /// 停止全局加载
  void stopGlobalLoading() {
    _globalLoading.value = false;
    _globalMessage.value = null;
    
    final currentStates = Map<String, LoadingState>.from(_loadingStates.value);
    currentStates.remove('global');
    _loadingStates.value = currentStates;
  }

  /// 开始局部加载
  String startLocalLoading({
    String? id,
    LoadingType type = LoadingType.local,
    String? message,
    Duration? timeout,
  }) {
    final loadingId = id ?? 'loading_${DateTime.now().millisecondsSinceEpoch}';
    
    final loadingState = LoadingState(
      id: loadingId,
      type: type,
      message: message,
      isLoading: true,
      timeout: timeout,
    );
    
    final currentStates = Map<String, LoadingState>.from(_loadingStates.value);
    currentStates[loadingId] = loadingState;
    _loadingStates.value = currentStates;
    
    // 如果设置了超时，自动停止加载
    if (timeout != null) {
      Future.delayed(timeout, () {
        stopLocalLoading(loadingId);
      });
    }
    
    return loadingId;
  }

  /// 停止局部加载
  void stopLocalLoading(String id) {
    final currentStates = Map<String, LoadingState>.from(_loadingStates.value);
    currentStates.remove(id);
    _loadingStates.value = currentStates;
  }

  /// 更新加载消息
  void updateLoadingMessage(String id, String message) {
    final currentStates = Map<String, LoadingState>.from(_loadingStates.value);
    final loadingState = currentStates[id];
    if (loadingState != null) {
      currentStates[id] = loadingState.copyWith(message: message);
      _loadingStates.value = currentStates;
      
      // 如果是全局加载，同时更新全局消息
      if (id == 'global') {
        _globalMessage.value = message;
      }
    }
  }

  /// 检查是否正在加载
  bool isLoading([String? id]) {
    if (id == null) {
      return _globalLoading.value || _loadingStates.value.isNotEmpty;
    }
    return _loadingStates.value.containsKey(id);
  }

  /// 获取加载状态
  LoadingState? getLoadingState(String id) {
    return _loadingStates.value[id];
  }

  /// 获取所有加载状态
  List<LoadingState> getAllLoadingStates() {
    return _loadingStates.value.values.toList();
  }

  /// 清除所有加载状态
  void clearAllLoading() {
    _globalLoading.value = false;
    _globalMessage.value = null;
    _loadingStates.value = {};
    _pendingOperations.clear();
  }

  /// 防重复提交：检查操作是否正在进行
  bool isOperationPending(String operationId) {
    return _pendingOperations.contains(operationId);
  }

  /// 防重复提交：开始操作
  bool startOperation(String operationId) {
    if (_pendingOperations.contains(operationId)) {
      return false; // 操作已在进行中
    }
    _pendingOperations.add(operationId);
    return true;
  }

  /// 防重复提交：完成操作
  void completeOperation(String operationId) {
    _pendingOperations.remove(operationId);
  }

  /// 执行带加载状态的异步操作
  Future<T> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? loadingId,
    String? message,
    LoadingType type = LoadingType.global,
    Duration? timeout,
    bool preventDuplicate = false,
    String? operationId,
  }) async {
    // 防重复提交检查
    if (preventDuplicate) {
      final opId = operationId ?? operation.toString();
      if (!startOperation(opId)) {
        throw Exception('操作正在进行中，请勿重复提交');
      }
      
      try {
        return await _executeWithLoadingInternal(
          operation,
          loadingId: loadingId,
          message: message,
          type: type,
          timeout: timeout,
        );
      } finally {
        completeOperation(opId);
      }
    } else {
      return await _executeWithLoadingInternal(
        operation,
        loadingId: loadingId,
        message: message,
        type: type,
        timeout: timeout,
      );
    }
  }

  /// 内部执行带加载状态的异步操作
  Future<T> _executeWithLoadingInternal<T>(
    Future<T> Function() operation, {
    String? loadingId,
    String? message,
    LoadingType type = LoadingType.global,
    Duration? timeout,
  }) async {
    String? activeLoadingId;
    
    try {
      // 开始加载
      if (type == LoadingType.global) {
        startGlobalLoading(message);
      } else {
        activeLoadingId = startLocalLoading(
          id: loadingId,
          type: type,
          message: message,
          timeout: timeout,
        );
      }
      
      // 执行操作
      final result = await operation();
      return result;
    } finally {
      // 停止加载
      if (type == LoadingType.global) {
        stopGlobalLoading();
      } else if (activeLoadingId != null) {
        stopLocalLoading(activeLoadingId);
      }
    }
  }

  /// 显示加载对话框
  void showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
  }) {
    if (_globalContext == null) return;
    
    showDialog(
      context: _globalContext!,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: barrierDismissible,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (_globalContext != null) {
      Navigator.of(_globalContext!).pop();
    }
  }

  /// 获取加载统计信息
  Map<String, dynamic> getLoadingStatistics() {
    final states = _loadingStates.value;
    final typeCount = <LoadingType, int>{};
    Duration totalDuration = Duration.zero;
    
    for (final state in states.values) {
      typeCount[state.type] = (typeCount[state.type] ?? 0) + 1;
      totalDuration += state.duration;
    }
    
    return {
      'activeCount': states.length,
      'typeCount': typeCount,
      'totalDuration': totalDuration,
      'pendingOperations': _pendingOperations.length,
    };
  }
}

/// 加载状态扩展
extension LoadingExtension on BuildContext {
  /// 执行带加载状态的异步操作
  Future<T> executeWithLoading<T>(
    Future<T> Function() operation, {
    String? message,
    LoadingType type = LoadingType.global,
    bool preventDuplicate = false,
    String? operationId,
  }) {
    LoadingService().setGlobalContext(this);
    return LoadingService().executeWithLoading(
      operation,
      message: message,
      type: type,
      preventDuplicate: preventDuplicate,
      operationId: operationId,
    );
  }

  /// 显示加载对话框
  void showLoadingDialog({String? message}) {
    LoadingService().setGlobalContext(this);
    LoadingService().showLoadingDialog(message: message);
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    LoadingService().hideLoadingDialog();
  }
}