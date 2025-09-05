import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../widgets/ui_components.dart';

/// 错误类型枚举
enum ErrorType {
  network,      // 网络错误
  auth,         // 认证错误
  validation,   // 验证错误
  server,       // 服务器错误
  unknown,      // 未知错误
}

/// 应用错误模型
class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final int? code;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.code,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 从异常创建错误
  factory AppError.fromException(Exception exception) {
    if (exception.toString().contains('SocketException')) {
      return AppError(
        type: ErrorType.network,
        message: '网络连接失败，请检查网络设置',
        details: exception.toString(),
      );
    } else if (exception.toString().contains('TimeoutException')) {
      return AppError(
        type: ErrorType.network,
        message: '请求超时，请稍后重试',
        details: exception.toString(),
      );
    } else if (exception.toString().contains('FormatException')) {
      return AppError(
        type: ErrorType.server,
        message: '数据格式错误',
        details: exception.toString(),
      );
    }
    
    return AppError(
      type: ErrorType.unknown,
      message: '发生未知错误，请稍后重试',
      details: exception.toString(),
    );
  }

  /// 从HTTP状态码创建错误
  factory AppError.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return AppError(
          type: ErrorType.validation,
          message: message ?? '请求参数错误',
          code: statusCode,
        );
      case 401:
        return AppError(
          type: ErrorType.auth,
          message: message ?? '身份验证失败，请重新登录',
          code: statusCode,
        );
      case 403:
        return AppError(
          type: ErrorType.auth,
          message: message ?? '权限不足，无法访问',
          code: statusCode,
        );
      case 404:
        return AppError(
          type: ErrorType.server,
          message: message ?? '请求的资源不存在',
          code: statusCode,
        );
      case 500:
        return AppError(
          type: ErrorType.server,
          message: message ?? '服务器内部错误',
          code: statusCode,
        );
      case 502:
      case 503:
      case 504:
        return AppError(
          type: ErrorType.server,
          message: message ?? '服务器暂时不可用，请稍后重试',
          code: statusCode,
        );
      default:
        return AppError(
          type: ErrorType.server,
          message: message ?? '服务器错误（$statusCode）',
          code: statusCode,
        );
    }
  }

  /// 获取用户友好的错误消息
  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return '网络连接异常，请检查网络后重试';
      case ErrorType.auth:
        return '登录状态已过期，请重新登录';
      case ErrorType.validation:
        return '输入信息有误，请检查后重试';
      case ErrorType.server:
        return '服务暂时不可用，请稍后重试';
      case ErrorType.unknown:
        return '操作失败，请稍后重试';
    }
  }

  /// 获取错误图标
  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  /// 获取错误颜色
  Color get color {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.auth:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }
}

/// 错误处理服务
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  // 当前错误状态
  late final Signal<AppError?> _currentError;
  Signal<AppError?> get currentError => _currentError;

  // 错误历史记录
  final List<AppError> _errorHistory = [];
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  // 全局上下文（用于显示错误提示）
  BuildContext? _globalContext;

  /// 初始化错误服务
  void init([BuildContext? context]) {
    _currentError = signal<AppError?>(null);
    _globalContext = context;
  }

  /// 设置全局上下文
  void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  /// 处理错误
  void handleError(dynamic error, {bool showSnackBar = true, bool logError = true}) {
    AppError appError;
    
    if (error is AppError) {
      appError = error;
    } else if (error is Exception) {
      appError = AppError.fromException(error);
    } else {
      appError = AppError(
        type: ErrorType.unknown,
        message: error.toString(),
      );
    }

    // 更新当前错误状态
    _currentError.value = appError;
    
    // 添加到历史记录
    _errorHistory.add(appError);
    
    // 限制历史记录数量
    if (_errorHistory.length > 50) {
      _errorHistory.removeAt(0);
    }

    // 记录错误日志
    if (logError) {
      _logError(appError);
    }

    // 显示用户提示
    if (showSnackBar && _globalContext != null) {
      _showErrorSnackBar(appError);
    }
  }

  /// 处理网络错误
  void handleNetworkError(dynamic error, {bool showSnackBar = true}) {
    final appError = AppError(
      type: ErrorType.network,
      message: '网络请求失败',
      details: error.toString(),
    );
    handleError(appError, showSnackBar: showSnackBar);
  }

  /// 处理认证错误
  void handleAuthError(String message, {bool showSnackBar = true}) {
    final appError = AppError(
      type: ErrorType.auth,
      message: message,
    );
    handleError(appError, showSnackBar: showSnackBar);
  }

  /// 处理验证错误
  void handleValidationError(String message, {bool showSnackBar = true}) {
    final appError = AppError(
      type: ErrorType.validation,
      message: message,
    );
    handleError(appError, showSnackBar: showSnackBar);
  }

  /// 清除当前错误
  void clearCurrentError() {
    _currentError.value = null;
  }

  /// 清除错误历史
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// 显示错误对话框
  void showErrorDialog(AppError error, {VoidCallback? onRetry}) {
    if (_globalContext == null) return;

    showDialog(
      context: _globalContext!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(error.icon, color: error.color),
            const SizedBox(width: 8),
            const Text('错误提示'),
          ],
        ),
        content: Text(error.userFriendlyMessage),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('重试'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误SnackBar
  void _showErrorSnackBar(AppError error) {
    if (_globalContext == null) return;

    AppSnackBar.showError(
      _globalContext!,
      error.userFriendlyMessage,
    );
  }

  /// 记录错误日志
  void _logError(AppError error) {
    debugPrint('=== 错误日志 ===');
    debugPrint('时间: ${error.timestamp}');
    debugPrint('类型: ${error.type}');
    debugPrint('消息: ${error.message}');
    if (error.code != null) {
      debugPrint('代码: ${error.code}');
    }
    if (error.details != null) {
      debugPrint('详情: ${error.details}');
    }
    debugPrint('===============');
  }

  /// 获取错误统计信息
  Map<ErrorType, int> getErrorStatistics() {
    final stats = <ErrorType, int>{};
    for (final error in _errorHistory) {
      stats[error.type] = (stats[error.type] ?? 0) + 1;
    }
    return stats;
  }

  /// 检查是否有特定类型的错误
  bool hasErrorType(ErrorType type) {
    return _errorHistory.any((error) => error.type == type);
  }

  /// 获取最近的错误
  AppError? getLatestError() {
    return _errorHistory.isNotEmpty ? _errorHistory.last : null;
  }

  /// 获取特定类型的最近错误
  AppError? getLatestErrorOfType(ErrorType type) {
    for (int i = _errorHistory.length - 1; i >= 0; i--) {
      if (_errorHistory[i].type == type) {
        return _errorHistory[i];
      }
    }
    return null;
  }
}

/// 错误处理扩展
extension ErrorHandlingExtension on BuildContext {
  /// 处理错误
  void handleError(dynamic error, {bool showSnackBar = true}) {
    ErrorService().setGlobalContext(this);
    ErrorService().handleError(error, showSnackBar: showSnackBar);
  }

  /// 显示错误对话框
  void showErrorDialog(AppError error, {VoidCallback? onRetry}) {
    ErrorService().setGlobalContext(this);
    ErrorService().showErrorDialog(error, onRetry: onRetry);
  }
}