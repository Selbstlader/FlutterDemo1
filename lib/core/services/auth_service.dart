import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:signals/signals.dart';
import '../models/auth_models.dart' as auth_models;
import 'supabase_service.dart';
import 'storage_service.dart';
import '../router/app_router.dart';

/// 认证服务
/// 负责处理用户认证相关的业务逻辑
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initializeAuthState();
  }

  /// 刷新认证状态
  Future<void> refreshAuthState() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      final userProfile = auth_models.UserProfile.fromSupabaseUser(user);
      _authState.value = auth_models.AuthState.authenticated(
        user: user,
        profile: userProfile,
      );
    } else {
      _authState.value = auth_models.AuthState.unauthenticated();
    }
  }

  /// 初始化认证服务
  Future<void> initialize() async {
    try {
      // 刷新当前认证状态
      await refreshAuthState();
    } catch (e) {
      if (kDebugMode) {
        print('AuthService初始化失败: $e');
      }
    }
  }

  final SupabaseService _supabaseService = SupabaseService();

  /// 认证状态Signal
  late final Signal<auth_models.AuthState> _authState;

  /// 获取认证状态
  Signal<auth_models.AuthState> get authState => _authState;

  /// 获取当前认证状态值
  auth_models.AuthState get currentAuthState => _authState.value;

  /// 获取当前用户
  supabase.User? get currentUser => _supabaseService.currentUser;

  /// 检查是否已登录
  bool get isLoggedIn => _supabaseService.isLoggedIn;

  /// 自动登录启用状态
  late final Signal<bool> _autoLoginEnabled;
  Signal<bool> get autoLoginEnabled => _autoLoginEnabled;

  /// 记住的用户名
  late final Signal<String?> _rememberedUsername;
  Signal<String?> get rememberedUsername => _rememberedUsername;

  // 存储键常量
  static const String _autoLoginKey = 'auto_login_enabled';
  static const String _rememberedUsernameKey = 'remembered_username';
  static const String _rememberedPasswordKey = 'remembered_password';
  static const String _lastLoginTimeKey = 'last_login_time';

  /// 初始化认证状态
  void _initializeAuthState() {
    // 初始化自动登录相关状态
    _autoLoginEnabled = signal(StorageService.getBool(_autoLoginKey, false) ?? false);
    _rememberedUsername = signal(StorageService.getString(_rememberedUsernameKey));

    // 初始化认证状态
    final user = _supabaseService.currentUser;
    if (user != null) {
      final userProfile = auth_models.UserProfile.fromSupabaseUser(user);
      _authState = signal(auth_models.AuthState.authenticated(
        user: user,
        profile: userProfile,
      ));
    } else {
      _authState = signal(auth_models.AuthState.unauthenticated());
    }

    // 监听认证状态变化
    _supabaseService.authStateChanges.listen((authState) {
      _handleAuthStateChange(authState);
    });
  }

  /// 处理认证状态变化
  void _handleAuthStateChange(supabase.AuthState supabaseAuthState) {
    final user = supabaseAuthState.session?.user;
    final previousState = _authState.value;

    if (user != null) {
      final userProfile = auth_models.UserProfile.fromSupabaseUser(user);
      _authState.value = auth_models.AuthState.authenticated(
        user: user,
        profile: userProfile,
      );
    } else {
      _authState.value = auth_models.AuthState.unauthenticated();

      // 如果之前是已认证状态，现在变为未认证，说明是登出操作
      // 确保跳转到认证页面（但避免在手动登出时重复跳转）
      if (previousState.isAuthenticated &&
          supabaseAuthState.event == supabase.AuthChangeEvent.signedOut) {
        Future.microtask(() {
          if (AppRouter.currentLocation != AppRoutes.auth) {
            AppRouter.go(AppRoutes.auth);
          }
        });
      }
    }
  }

  /// 用户名注册
  ///
  /// [request] 注册请求数据
  /// 返回 [AuthResult] 注册结果
  Future<auth_models.AuthResult> registerWithUsername(
      auth_models.RegisterRequest request) async {
    try {
      // 验证请求数据
      final validationError = request.validate();
      if (validationError != null) {
        return auth_models.AuthResult.failure(
          type: auth_models.AuthResultType.invalidCredentials,
          message: validationError,
        );
      }

      _authState.value = auth_models.AuthState.loading();

      // Supabase会自动处理邮箱重复的情况，这里不需要预先检查

      // 使用用户名作为邮箱进行注册（Supabase要求邮箱格式）
      final email = request.username;

      final response = await _supabaseService.auth.signUp(
        email: email,
        password: request.password,
        data: {
          'username': request.username,
          'display_name': request.displayName ?? request.username,
          ...?request.metadata,
        },
      );

      if (response.user != null) {
        // 更新认证状态，直接使用Supabase用户数据创建UserProfile
        final userProfile =
            auth_models.UserProfile.fromSupabaseUser(response.user!);
        _authState.value = auth_models.AuthState.authenticated(
          user: response.user!,
          profile: userProfile,
        );

        return auth_models.AuthResult.success(
          user: response.user,
          session: response.session,
          message: response.session != null ? '注册成功' : '用户已存在，已为您登录',
        );
      } else {
        _authState.value = auth_models.AuthState.unauthenticated();
        return auth_models.AuthResult.failure(
          type: auth_models.AuthResultType.failure,
          message: '注册失败，请重试',
        );
      }
    } on supabase.AuthException catch (e) {
      _authState.value = auth_models.AuthState.error(e.message);
      return _handleAuthException(e);
    } catch (e) {
      _authState.value = auth_models.AuthState.error('注册失败：$e');
      return auth_models.AuthResult.failure(
        type: auth_models.AuthResultType.networkError,
        message: '网络错误，请检查网络连接',
      );
    }
  }

  /// 用户名登录
  ///
  /// [request] 登录请求数据
  /// 返回 [AuthResult] 登录结果
  Future<auth_models.AuthResult> loginWithUsername(
      auth_models.LoginRequest request) async {
    try {
      // 验证请求数据
      final validationError = request.validate();
      if (validationError != null) {
        return auth_models.AuthResult.failure(
          type: auth_models.AuthResultType.invalidCredentials,
          message: validationError,
        );
      }

      _authState.value = auth_models.AuthState.loading();

      // 使用用户名作为邮箱进行登录
      final response = await _supabaseService.auth.signInWithPassword(
        email: request.username,
        password: request.password,
      );

      if (response.user != null) {
        // 更新认证状态，直接使用Supabase用户数据创建UserProfile
        final userProfile =
            auth_models.UserProfile.fromSupabaseUser(response.user!);
        _authState.value = auth_models.AuthState.authenticated(
          user: response.user!,
          profile: userProfile,
        );

        // 如果启用了自动登录，保存凭据
        if (_autoLoginEnabled.value) {
          await _saveLoginCredentials(request.username, request.password);
        }

        return auth_models.AuthResult.success(
          user: response.user,
          session: response.session,
          message: '登录成功',
        );
      } else {
        _authState.value = auth_models.AuthState.unauthenticated();
        return auth_models.AuthResult.failure(
          type: auth_models.AuthResultType.invalidCredentials,
          message: '用户名或密码错误',
        );
      }
    } on supabase.AuthException catch (e) {
      _authState.value = auth_models.AuthState.error(e.message);
      return _handleAuthException(e);
    } catch (e) {
      _authState.value = auth_models.AuthState.error('登录失败：$e');
      return auth_models.AuthResult.failure(
        type: auth_models.AuthResultType.networkError,
        message: '网络错误，请检查网络连接',
      );
    }
  }

  /// 登出
  /// [clearCredentials] 是否清除保存的登录凭据
  Future<auth_models.AuthResult> signOut({bool clearCredentials = false}) async {
    try {
      _authState.value = auth_models.AuthState.loading();

      // 如果需要清除凭据
      if (clearCredentials) {
        await _clearLoginCredentials();
      }

      // 执行Supabase登出，这会触发认证状态变化事件
      // _handleAuthStateChange会自动处理路由跳转
      await _supabaseService.auth.signOut();

      return auth_models.AuthResult.success(message: '登出成功');
    } catch (e) {
      _authState.value = auth_models.AuthState.error('登出失败：$e');
      return auth_models.AuthResult.failure(
        type: auth_models.AuthResultType.failure,
        message: '登出失败，请重试',
      );
    }
  }

  /// 处理认证异常
  auth_models.AuthResult _handleAuthException(
      supabase.AuthException exception) {
    // 检查错误消息中是否包含用户已存在的信息
    if (exception.message.contains('User already registered') ||
        exception.message.contains('user_already_exists')) {
      return auth_models.AuthResult.failure(
        type: auth_models.AuthResultType.userAlreadyExists,
        message: '用户已存在，请直接登录',
      );
    }

    switch (exception.statusCode) {
      case '400':
        if (exception.message.contains('Invalid login credentials')) {
          return auth_models.AuthResult.failure(
            type: auth_models.AuthResultType.invalidCredentials,
            message: '用户名或密码错误',
          );
        }
        break;
      case '422':
        if (exception.message.contains('Password should be at least')) {
          return auth_models.AuthResult.failure(
            type: auth_models.AuthResultType.weakPassword,
            message: '密码强度不够，至少需要6个字符',
          );
        }
        break;
      case '429':
        return auth_models.AuthResult.failure(
          type: auth_models.AuthResultType.failure,
          message: '请求过于频繁，请稍后重试',
        );
    }

    return auth_models.AuthResult.failure(
      type: auth_models.AuthResultType.failure,
      message: exception.message,
    );
  }

  /// 获取用户资料
  Future<auth_models.UserProfile?> getUserProfile([String? userId]) async {
    try {
      final targetUserId = userId ?? currentUser?.id;
      if (targetUserId == null) return null;

      final response = await _supabaseService.client
          .from('user_profiles')
          .select()
          .eq('user_id', targetUserId)
          .single();

      return auth_models.UserProfile.fromMap(response);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user profile: $e');
      }
      return null;
    }
  }

  /// 更新用户资料
  Future<bool> updateUserProfile(auth_models.UserProfile profile) async {
    try {
      // 创建更新数据，排除id、created_at等不应更新的字段
      final updateData = {
        'username': profile.username,
        'display_name': profile.displayName,
        'avatar_url': profile.avatarUrl,
        'phone': profile.phone,
        'phone_verified': profile.phoneVerified,
        'email_verified': profile.emailVerified,
        'user_metadata': profile.userMetadata,
        // updated_at会由数据库触发器自动更新
      };

      await _supabaseService.client
          .from('user_profiles')
          .update(updateData)
          .eq('id', profile.id);

      // 更新本地状态
      final currentState = _authState.value;
      if (currentState.isAuthenticated) {
        _authState.value = currentState.copyWith(profile: profile);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile: $e');
      }
      return false;
    }
  }

  /// 尝试自动登录
  Future<auth_models.AuthResult?> tryAutoLogin() async {
    try {
      // 检查是否启用自动登录
      if (!_autoLoginEnabled.value) {
        return null;
      }

      // 检查是否有保存的凭据
      final username = StorageService.getString(_rememberedUsernameKey);
      final password = StorageService.getString(_rememberedPasswordKey);
      final lastLoginTime = StorageService.getInt(_lastLoginTimeKey);

      if (username == null || password == null) {
        return null;
      }

      // 检查凭据是否过期（30天）
      if (lastLoginTime != null) {
        final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
        final now = DateTime.now();
        final daysSinceLastLogin = now.difference(lastLogin).inDays;
        
        if (daysSinceLastLogin > 30) {
          // 凭据过期，清除保存的信息
          await _clearLoginCredentials();
          return null;
        }
      }

      // 尝试自动登录
      final loginRequest = auth_models.LoginRequest(
        username: username,
        password: password,
      );

      final result = await loginWithUsername(loginRequest);
      
      // 如果自动登录失败，清除保存的凭据
      if (!result.isSuccess) {
        await _clearLoginCredentials();
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('自动登录失败: $e');
      }
      // 自动登录失败时清除凭据
      await _clearLoginCredentials();
      return null;
    }
  }

  /// 设置自动登录
  Future<void> setAutoLoginEnabled(bool enabled) async {
    _autoLoginEnabled.value = enabled;
    await StorageService.setBool(_autoLoginKey, enabled);
    
    // 如果禁用自动登录，清除保存的凭据
    if (!enabled) {
      await _clearLoginCredentials();
    }
  }

  /// 保存登录凭据
  Future<void> _saveLoginCredentials(String username, String password) async {
    await Future.wait([
      StorageService.setString(_rememberedUsernameKey, username),
      StorageService.setString(_rememberedPasswordKey, password),
      StorageService.setInt(_lastLoginTimeKey, DateTime.now().millisecondsSinceEpoch),
    ]);
    
    _rememberedUsername.value = username;
  }

  /// 清除登录凭据
  Future<void> _clearLoginCredentials() async {
    await Future.wait([
      StorageService.remove(_rememberedUsernameKey),
      StorageService.remove(_rememberedPasswordKey),
      StorageService.remove(_lastLoginTimeKey),
    ]);
    
    _rememberedUsername.value = null;
  }

  /// 检查是否有保存的登录凭据
  bool get hasRememberedCredentials {
    final username = StorageService.getString(_rememberedUsernameKey);
    final password = StorageService.getString(_rememberedPasswordKey);
    return username != null && password != null;
  }

  /// 清理资源
  void dispose() {
    // 清理Signal资源
    // Signals会自动处理清理，这里预留接口
  }
}
