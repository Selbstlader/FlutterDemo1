import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 本地存储服务
class StorageService {
  static late SharedPreferences _prefs;

  /// 初始化存储服务
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // 基础存储方法

  /// 存储字符串
  static Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      return result;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 获取字符串
  static String? getString(String key, [String? defaultValue]) {
    try {
      return _prefs.getString(key) ?? defaultValue;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// 存储整数
  static Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      return result;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 获取整数
  static int? getInt(String key, [int? defaultValue]) {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// 存储布尔值
  static Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      return result;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 获取布尔值
  static bool? getBool(String key, [bool? defaultValue]) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e, stackTrace) {
      return defaultValue;
    }
  }

  /// 存储JSON对象
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await _prefs.setString(key, jsonString);
      return result;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 获取JSON对象
  static Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// 删除键值
  static Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      return result;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 清空所有数据
  static Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      return result;
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// 检查键是否存在
  static bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e, stackTrace) {
      return false;
    }
  }

  // 应用特定的存储方法

  /// 设置主题模式
  static Future<bool> setThemeMode(ThemeMode mode) {
    return setString(AppConstants.themeKey, mode.name);
  }

  /// 获取主题模式
  static ThemeMode getThemeMode() {
    final mode = getString(AppConstants.themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ThemeMode.system,
    );
  }

  /// 设置语言代码
  static Future<bool> setLanguageCode(String languageCode) {
    return setString(AppConstants.languageKey, languageCode);
  }

  /// 获取语言代码
  static String getLanguageCode() {
    return getString(AppConstants.languageKey, 'zh') ?? 'zh';
  }

  /// 设置首次启动标记
  static Future<bool> setFirstLaunch(bool isFirstLaunch) {
    return setBool(AppConstants.firstLaunchKey, isFirstLaunch);
  }

  /// 是否首次启动
  static bool isFirstLaunch() {
    return getBool(AppConstants.firstLaunchKey, true) ?? true;
  }

  /// 保存图表配置
  static Future<bool> saveChartConfig(
      String chartId, Map<String, dynamic> config) {
    return setJson('chart_$chartId', config);
  }

  /// 获取图表配置
  static Map<String, dynamic>? getChartConfig(String chartId) {
    return getJson('chart_$chartId');
  }

  /// 释放存储服务
  static void dispose() {}
}
