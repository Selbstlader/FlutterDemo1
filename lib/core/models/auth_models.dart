import 'package:supabase_flutter/supabase_flutter.dart';

/// 认证结果枚举
enum AuthResultType {
  success,
  failure,
  userNotFound,
  invalidCredentials,
  userAlreadyExists,
  weakPassword,
  networkError,
  unknown,
}

/// 认证结果模型
class AuthResult {
  final AuthResultType type;
  final String? message;
  final User? user;
  final Session? session;

  const AuthResult({
    required this.type,
    this.message,
    this.user,
    this.session,
  });

  /// 创建成功结果
  factory AuthResult.success({
    User? user,
    Session? session,
    String? message,
  }) {
    return AuthResult(
      type: AuthResultType.success,
      user: user,
      session: session,
      message: message ?? '操作成功',
    );
  }

  /// 创建失败结果
  factory AuthResult.failure({
    required AuthResultType type,
    String? message,
  }) {
    return AuthResult(
      type: type,
      message: message ?? '操作失败',
    );
  }

  /// 是否成功
  bool get isSuccess => type == AuthResultType.success;

  /// 是否失败
  bool get isFailure => !isSuccess;
}

/// 用户注册请求模型
class RegisterRequest {
  final String username;
  final String password;
  final String? displayName;
  final Map<String, dynamic>? metadata;

  const RegisterRequest({
    required this.username,
    required this.password,
    this.displayName,
    this.metadata,
  });

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      if (displayName != null) 'display_name': displayName,
      if (metadata != null) ...metadata!,
    };
  }

  /// 验证请求数据
  String? validate() {
    if (username.isEmpty) {
      return '用户名不能为空';
    }
    if (password.isEmpty) {
      return '密码不能为空';
    }
    return null;
  }
}

/// 用户登录请求模型
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  /// 验证请求数据
  String? validate() {
    if (username.isEmpty) {
      return '用户名不能为空';
    }
    if (password.isEmpty) {
      return '密码不能为空';
    }
    return null;
  }
}

/// 用户资料模型 - 基于Supabase auth.users表
class UserProfile {
  final String id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? phone;
  final bool phoneVerified;
  final bool emailVerified;
  final Map<String, dynamic>? userMetadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.phone,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.userMetadata,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从Supabase User对象创建
  factory UserProfile.fromSupabaseUser(User user) {
    return UserProfile(
      id: user.id,
      email: user.email,
      username: user.email, // 使用email作为username
      displayName: user.userMetadata?['display_name'] as String? ?? user.email,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      phone: user.phone,
      phoneVerified: user.phoneConfirmedAt != null,
      emailVerified: user.emailConfirmedAt != null,
      userMetadata: user.userMetadata,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt:
          user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
    );
  }

  /// 从Map创建（保持向后兼容）
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      username: map['username'] as String? ?? map['email'] as String?,
      displayName: map['display_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      phoneVerified: map['phone_verified'] as bool? ?? false,
      emailVerified: map['email_verified'] as bool? ?? false,
      userMetadata: map['user_metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'phone_verified': phoneVerified,
      'email_verified': emailVerified,
      'user_metadata': userMetadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 复制并更新
  UserProfile copyWith({
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? phone,
    bool? phoneVerified,
    bool? emailVerified,
    Map<String, dynamic>? userMetadata,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      userMetadata: userMetadata ?? this.userMetadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 认证状态枚举
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// 认证状态模型
class AuthState {
  final AuthStatus status;
  final User? user;
  final UserProfile? profile;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.profile,
    this.errorMessage,
  });

  /// 初始状态
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// 加载状态
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// 已认证状态
  factory AuthState.authenticated({
    required User user,
    UserProfile? profile,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      profile: profile,
    );
  }

  /// 未认证状态
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// 错误状态
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// 是否已认证
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// 是否加载中
  bool get isLoading => status == AuthStatus.loading;

  /// 是否有错误
  bool get hasError => status == AuthStatus.error;

  /// 复制并更新
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserProfile? profile,
    String? errorMessage,
    bool clearProfile = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: clearProfile ? null : (profile ?? this.profile),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
