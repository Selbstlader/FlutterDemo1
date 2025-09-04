import 'package:flutter/material.dart';

/// 用户模型
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (avatar != null) 'avatar': avatar,
      if (preferences != null) 'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 应用配置模型
class AppConfig {
  final String key;
  final dynamic value;
  final String type;
  final String? description;
  final DateTime updatedAt;

  const AppConfig({
    required this.key,
    required this.value,
    required this.type,
    this.description,
    required this.updatedAt,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      key: json['key'] as String,
      value: json['value'],
      type: json['type'] as String,
      description: json['description'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'type': type,
      if (description != null) 'description': description,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  T getValue<T>() {
    return value as T;
  }

  AppConfig copyWith({
    String? key,
    dynamic value,
    String? type,
    String? description,
    DateTime? updatedAt,
  }) {
    return AppConfig(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 动画配置模型
class AnimationConfig {
  final String id;
  final String name;
  final Duration duration;
  final Curve curve;
  final AnimationType type;
  final Map<String, dynamic> properties;

  const AnimationConfig({
    required this.id,
    required this.name,
    required this.duration,
    required this.curve,
    required this.type,
    required this.properties,
  });

  factory AnimationConfig.fromJson(Map<String, dynamic> json) {
    return AnimationConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      curve: _parseCurve(json['curve'] as String),
      type: AnimationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AnimationType.fade,
      ),
      properties: json['properties'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration.inMilliseconds,
      'curve': curve.toString(),
      'type': type.name,
      'properties': properties,
    };
  }

  static Curve _parseCurve(String curveString) {
    switch (curveString) {
      case 'linear':
        return Curves.linear;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      default:
        return Curves.easeInOut;
    }
  }
}

/// 动画类型枚举
enum AnimationType {
  fade('淡入淡出'),
  slide('滑动'),
  scale('缩放'),
  rotation('旋转'),
  custom('自定义');

  const AnimationType(this.label);
  final String label;
}

/// 图标信息模型
class IconInfo {
  final String id;
  final String name;
  final IconType type;
  final String path;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  const IconInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
    required this.metadata,
    this.tags = const [],
  });

  factory IconInfo.fromJson(Map<String, dynamic> json) {
    return IconInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      type: IconType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => IconType.material,
      ),
      path: json['path'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'path': path,
      'metadata': metadata,
      'tags': tags,
    };
  }

  IconInfo copyWith({
    String? id,
    String? name,
    IconType? type,
    String? path,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) {
    return IconInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      path: path ?? this.path,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }
}

/// 图标类型枚举
enum IconType {
  material('Material Icons'),
  svg('SVG Icons'),
  font('Font Icons'),
  custom('Custom Icons');

  const IconType(this.label);
  final String label;
}

/// 日志条目模型
class LogEntry {
  final String id;
  final LogLevel level;
  final String message;
  final String tag;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    required this.tag,
    required this.timestamp,
    this.extra,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      level: LogLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      tag: json['tag'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.name,
      'message': message,
      'tag': tag,
      'timestamp': timestamp.toIso8601String(),
      if (extra != null) 'extra': extra,
    };
  }

  @override
  String toString() {
    return '${timestamp.toIso8601String()} [${level.name.toUpperCase()}] $tag: $message';
  }
}

/// 日志级别枚举
enum LogLevel {
  trace('TRACE', 0),
  debug('DEBUG', 1),
  info('INFO', 2),
  warning('WARNING', 3),
  error('ERROR', 4),
  fatal('FATAL', 5);

  const LogLevel(this.label, this.priority);
  final String label;
  final int priority;
}

/// 网络状态枚举
enum NetworkStatus {
  connected('已连接'),
  disconnected('已断开'),
  connecting('连接中'),
  error('连接错误');

  const NetworkStatus(this.label);
  final String label;
}

/// API响应模型
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? code;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
    this.meta,
  });

  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? meta}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      meta: meta,
    );
  }

  factory ApiResponse.error(String message, {int? code, Map<String, dynamic>? meta}) {
    return ApiResponse(
      success: false,
      message: message,
      code: code,
      meta: meta,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      code: json['code'] as int?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      if (data != null) 'data': toJsonT(data as T),
      if (message != null) 'message': message,
      if (code != null) 'code': code,
      if (meta != null) 'meta': meta,
    };
  }
}