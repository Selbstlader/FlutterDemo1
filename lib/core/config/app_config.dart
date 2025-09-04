import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 手动模式设置 - 修改此常量来切换应用模式
/// 设置为 null 时使用自动检测模式
/// 设置为 AppMode.demo 强制使用演示模式
/// 设置为 AppMode.development 强制使用开发模式
///
/// 测试手动切换：将下面的值改为 AppMode.demo 或 AppMode.development
const AppMode? MANUAL_MODE = AppMode.demo;

/// 应用模式枚举
enum AppMode {
  demo, // 演示模式 - 使用 /lib/pages/demo/ 目录下的页面
  development, // 开发模式 - 使用 /lib/pages/ 根目录下的页面
}

/// 应用配置管理类
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._internal();

  AppConfig._internal();

  // 应用模式管理
  static AppMode _currentMode = _detectAppMode();
  static final ValueNotifier<AppMode> _modeNotifier =
      ValueNotifier(_currentMode);

  // 热重载检测定时器
  Timer? _hotReloadTimer;

  /// 获取当前应用模式
  static AppMode get currentMode => _currentMode;

  /// 模式变化通知器
  static ValueNotifier<AppMode> get modeNotifier => _modeNotifier;

  /// 检测应用模式
  /// 优先级：手动模式 > 环境变量 > 调试模式检测
  static AppMode _detectAppMode() {
    // 1. 最高优先级：检查手动模式设置
    if (MANUAL_MODE != null) {
      return MANUAL_MODE!;
    }

    // 2. 次优先级：检查环境变量
    const String? envMode = String.fromEnvironment('APP_MODE');
    if (envMode != null) {
      switch (envMode.toLowerCase()) {
        case 'demo':
          return AppMode.demo;
        case 'development':
        case 'dev':
          return AppMode.development;
      }
    }

    // 3. 默认：在调试模式下使用开发模式，发布模式下使用演示模式
    return kDebugMode ? AppMode.development : AppMode.demo;
  }

  /// 切换应用模式
  static void switchMode(AppMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      _modeNotifier.value = mode;
      _modeNotifier.notifyListeners();
    }
  }

  /// 初始化配置
  void init() {
    _setupHotReloadDetection();
  }

  /// 热重载检测和自动切换
  void _setupHotReloadDetection() {
    if (kDebugMode) {
      // 在调试模式下监听环境变量变化
      _hotReloadTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final newMode = _detectAppMode();
        if (newMode != _currentMode) {
          switchMode(newMode);
        }
      });
    }
  }

  /// 停止热重载检测
  void dispose() {
    _hotReloadTimer?.cancel();
    _hotReloadTimer = null;
  }

  /// 获取模式配置信息
  static Map<String, dynamic> getModeConfig() {
    return {
      'currentMode': _currentMode.name,
      'manualMode': MANUAL_MODE?.name ?? 'auto',
      'isDebugMode': kDebugMode,
      'envMode': const String.fromEnvironment('APP_MODE', defaultValue: 'auto'),
      'hotReloadEnabled': kDebugMode,
    };
  }
}
