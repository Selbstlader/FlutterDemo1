import 'package:signals/signals.dart';
import 'package:flutter/material.dart';

/// 状态管理服务 - 基于Signals的响应式状态管理
class StateService {
  static final StateService _instance = StateService._internal();
  factory StateService() => _instance;
  StateService._internal();

  /// 全局状态存储
  final Map<String, Signal> _globalSignals = {};
  final Map<String, Computed> _globalComputed = {};
  final Map<String, Effect> _globalEffects = {};

  /// 创建或获取全局Signal
  Signal<T> signal<T>(String key, T initialValue) {
    if (_globalSignals.containsKey(key)) {
      return _globalSignals[key] as Signal<T>;
    }
    final signal = Signal<T>(initialValue);
    _globalSignals[key] = signal;
    return signal;
  }

  /// 创建或获取全局Computed
  Computed<T> computed<T>(String key, T Function() computation) {
    if (_globalComputed.containsKey(key)) {
      return _globalComputed[key] as Computed<T>;
    }
    final computed = Computed<T>(computation);
    _globalComputed[key] = computed;
    return computed;
  }

  /// 创建全局Effect
  Effect effect(String key, void Function() callback) {
    if (_globalEffects.containsKey(key)) {
      _globalEffects[key]!.dispose();
    }
    final effect = Effect(callback);
    _globalEffects[key] = effect;
    return effect;
  }

  /// 获取Signal值
  T? getSignalValue<T>(String key) {
    final signal = _globalSignals[key];
    return signal?.value as T?;
  }

  /// 设置Signal值
  void setSignalValue<T>(String key, T value) {
    final signal = _globalSignals[key] as Signal<T>?;
    if (signal != null) {
      signal.value = value;
    }
  }

  /// 批量更新Signal
  void batch(void Function() updates) {
    batch(updates);
  }

  /// 清理指定的状态
  void dispose(String key) {
    _globalSignals.remove(key);
    _globalComputed.remove(key);
    final effect = _globalEffects.remove(key);
    effect?.dispose();
  }

  /// 清理所有状态
  void disposeAll() {
    for (final effect in _globalEffects.values) {
      effect.dispose();
    }
    _globalSignals.clear();
    _globalComputed.clear();
    _globalEffects.clear();
  }

  /// 获取所有Signal的键
  List<String> get signalKeys => _globalSignals.keys.toList();

  /// 获取状态统计信息
  Map<String, int> get stateStats => {
    'signals': _globalSignals.length,
    'computed': _globalComputed.length,
    'effects': _globalEffects.length,
  };
}

/// 状态管理扩展方法
extension StateExtension on BuildContext {
  /// 快速访问StateService
  StateService get state => StateService();

  /// 创建局部Signal
  Signal<T> useSignal<T>(T initialValue) {
    return Signal<T>(initialValue);
  }

  /// 创建局部Computed
  Computed<T> useComputed<T>(T Function() computation) {
    return Computed<T>(computation);
  }

  /// 创建局部Effect
  Effect useEffect(void Function() callback) {
    return Effect(callback);
  }
}

/// 响应式Widget基类
abstract class ReactiveWidget extends StatefulWidget {
  const ReactiveWidget({super.key});

  @override
  State<ReactiveWidget> createState() => _ReactiveWidgetState();

  /// 构建响应式UI
  Widget buildReactive(BuildContext context);

  /// 初始化状态
  void initState() {}

  /// 清理状态
  void dispose() {}
}

class _ReactiveWidgetState extends State<ReactiveWidget> {
  final List<Effect> _effects = [];

  @override
  void initState() {
    super.initState();
    widget.initState();
  }

  @override
  void dispose() {
    for (final effect in _effects) {
      effect.dispose();
    }
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.buildReactive(context);
  }

  /// 添加Effect到生命周期管理
  void addEffect(Effect effect) {
    _effects.add(effect);
  }
}

/// 常用的全局状态键
class GlobalStateKeys {
  static const String theme = 'global_theme';
  static const String locale = 'global_locale';
  static const String user = 'global_user';
  static const String loading = 'global_loading';
  static const String error = 'global_error';
  static const String networkStatus = 'global_network_status';
}

/// 主题状态管理
class ThemeStateManager {
  static final StateService _state = StateService();

  /// 主题模式Signal
  static Signal<ThemeMode> get themeMode => 
      _state.signal(GlobalStateKeys.theme, ThemeMode.system);

  /// 是否为暗色主题
  static Computed<bool> get isDarkMode => 
      _state.computed('is_dark_mode', () => themeMode.value == ThemeMode.dark);

  /// 切换主题
  static void toggleTheme() {
    final current = themeMode.value;
    themeMode.value = current == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
  }

  /// 设置主题模式
  static void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }
}

/// 加载状态管理
class LoadingStateManager {
  static final StateService _state = StateService();

  /// 全局加载状态
  static Signal<bool> get isLoading => 
      _state.signal(GlobalStateKeys.loading, false);

  /// 显示加载
  static void showLoading() {
    isLoading.value = true;
  }

  /// 隐藏加载
  static void hideLoading() {
    isLoading.value = false;
  }

  /// 异步操作包装
  static Future<T> withLoading<T>(Future<T> Function() operation) async {
    showLoading();
    try {
      return await operation();
    } finally {
      hideLoading();
    }
  }
}

/// 错误状态管理
class ErrorStateManager {
  static final StateService _state = StateService();

  /// 全局错误状态
  static Signal<String?> get error => 
      _state.signal(GlobalStateKeys.error, null);

  /// 设置错误
  static void setError(String message) {
    error.value = message;
  }

  /// 清除错误
  static void clearError() {
    error.value = null;
  }

  /// 是否有错误
  static Computed<bool> get hasError => 
      _state.computed('has_error', () => error.value != null);
}