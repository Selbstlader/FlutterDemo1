import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'loading_manager.dart';

/// 网络请求服务
class NetworkService {
  static late Dio _dio;
  static BuildContext? _context;
  static bool _globalLoadingEnabled = true;

  /// 初始化网络服务
  static void init({
    String? baseUrl,
    BuildContext? context,
    bool globalLoadingEnabled = true,
  }) {
    _context = context;
    _globalLoadingEnabled = globalLoadingEnabled;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: AppConstants.networkTimeout,
        receiveTimeout: AppConstants.networkTimeout,
        sendTimeout: AppConstants.networkTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  /// 设置全局 BuildContext
  static void setContext(BuildContext context) {
    _context = context;
  }

  /// 设置全局 loading 开关
  static void setGlobalLoadingEnabled(bool enabled) {
    _globalLoadingEnabled = enabled;
  }

  /// 显示 loading
  static void _showLoading({String? message, bool? showLoading}) {
    if (_context != null && 
        (showLoading ?? _globalLoadingEnabled)) {
      LoadingManager.show(_context!, message: message);
    }
  }

  /// 隐藏 loading
  static void _hideLoading({bool? showLoading}) {
    if (showLoading ?? _globalLoadingEnabled) {
      LoadingManager.hide();
    }
  }

  /// 释放网络服务
  static void dispose() {
    LoadingManager.forceHide();
    _dio.close();
  }

  /// GET请求
  static Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage, showLoading: showLoading);
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// POST请求
  static Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage, showLoading: showLoading);
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// PUT请求
  static Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage, showLoading: showLoading);
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// DELETE请求
  static Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage, showLoading: showLoading);
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// PATCH请求
  static Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage, showLoading: showLoading);
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// 下载文件
  static Future<void> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage ?? '正在下载...', showLoading: showLoading);
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// 上传文件
  static Future<T> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    bool? showLoading,
    String? loadingMessage,
  }) async {
    _showLoading(message: loadingMessage ?? '正在上传...', showLoading: showLoading);
    try {
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      _hideLoading(showLoading: showLoading);
    }
  }

  /// 处理网络错误
  static NetworkException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: '网络连接超时，请检查网络设置',
          type: NetworkExceptionType.timeout,
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return NetworkException(
          message: _getErrorMessage(error.response?.statusCode),
          type: NetworkExceptionType.badResponse,
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: '请求已取消',
          type: NetworkExceptionType.cancel,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          message: '网络连接失败，请检查网络设置',
          type: NetworkExceptionType.connectionError,
        );
      default:
        return NetworkException(
          message: '网络请求失败：${error.message}',
          type: NetworkExceptionType.unknown,
        );
    }
  }

  /// 根据状态码获取错误信息
  static String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '禁止访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      default:
        return '网络请求失败（$statusCode）';
    }
  }
}

/// 网络异常类型
enum NetworkExceptionType {
  timeout,
  badResponse,
  cancel,
  connectionError,
  unknown,
}

/// 网络异常
class NetworkException implements Exception {
  final String message;
  final NetworkExceptionType type;
  final int? statusCode;

  const NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  @override
  String toString() {
    return 'NetworkException: $message (type: $type, statusCode: $statusCode)';
  }
}
